#!/usr/bin/env bash
#
# Dreamcatcher: dispatch labelled issues to dream sessions.
#
# The issue's label selects the skill: the smith label dispatches dream:smith,
# and the less label dispatches dream:less. An issue carrying both goes to smith.
#
# Each tick reads the current state from git, tmux, `gh`, and the small amount of
# catcher state under $HOME/.dream/catcher. It first looks for existing
# dispatched work to resume. It dispatches a new issue when no existing session
# needs a round. The default is a background loop. Run
# `catch.sh --harness <claude|codex> --once` from the main checkout in cron on a
# machine that must restart the catcher after a reboot.
#
# Agent rounds run headless inside detached tmux sessions. The tmux session shows
# whether the round is running and gives the user a place to attach. When the
# round ends, tmux exits. The session's context stays on disk, so the next round
# resumes it from the worktree.
#
# The number of live agent rounds has a cap. --max-agents bounds how many agent
# processes run at once, so the user can choose how fast to spend tokens. The
# default is one.
#
# Each dispatched issue has its own worktree and branch. A round is its own
# process. Worktrees isolate concurrent rounds. --max-agents paces token use,
# not repository safety.
#
# A merged or closed pull request gets one final round. The final-started marker
# records that the catcher launched the round, so a later tick does not launch it
# again.
# The worktree and branch stay in place for debugging.
#
# Permissions depend on the selected harness. Claude Code runs in auto mode with
# narrow --allowedTools rules for recurring unattended writes. Codex starts with
# --approve-for-me, then resumes in workspace-write with network access and its
# approval reviewer. Either harness can carry the workflow without waiting for a
# person at the terminal.
#
# Layout: the coordinator assumes the standard worktree layout, where each
# dispatched worktree is a sibling of the main checkout under a directory
# dedicated to this repo. It creates them as
# <container>/dream-catcher-GH<n>-<timestamp>. The timestamp makes each attempt
# unique, so a retry never collides with an earlier attempt's branch or pull
# request.

set -uo pipefail

usage() {
  cat <<EOF
Dreamcatcher: dispatch labelled issues to dream sessions.

Usage:
  catch.sh --harness <claude|codex>
           [--smith-label <label>] [--less-label <label>]
           [--smith-model <model>] [--smith-effort <effort>]
           [--less-model <model>] [--less-effort <effort>]
           [--assignee <who>] [--interval <seconds>]
           [--max-agents <n>] [--once]

  --harness      Agent harness to run. Required.
  --smith-label  Issue label that dispatches a dream:smith session. Default: $default_smith_label.
  --less-label   Issue label that dispatches a dream:less session. Default: $default_less_label.
  --smith-model  Model for a dream:smith session. Defaults: Claude Code $default_claude_smith_model; Codex $default_codex_smith_model.
  --smith-effort Reasoning effort for a dream:smith session. Defaults: Claude Code $default_claude_smith_effort; Codex $default_codex_smith_effort.
  --less-model   Model for a dream:less session. Defaults: Claude Code $default_claude_less_model; Codex $default_codex_less_model.
  --less-effort  Reasoning effort for a dream:less session. Defaults: Claude Code $default_claude_less_effort; Codex $default_codex_less_effort.
  --assignee    Whose issues to pick up. Default: $default_assignee.
  --interval    Seconds between ticks in loop mode. Default: $default_interval.
  --max-agents  Maximum agent rounds to run at once. Default: $default_max_agents.
  --once        A single tick, then exit, instead of looping.
EOF
}

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# Die unless the value is a positive whole number. Keep the shared numeric check
# here, so new flags and validation changes need one edit.
require_positive_int() { [[ "$2" =~ ^[1-9][0-9]*$ ]] || die "--$1 must be a positive whole number of $3"; }

# Quote one value for the shell command tmux will run. Values can include spaces
# because a repository path can. Keeping the quote rule in one helper means the
# launch and resume paths do not grow their own variants.
shell_quote() {
  local value=${1//\'/\'\\\'\'}
  printf "'%s'" "$value"
}

# --- configuration ---------------------------------------------------------

# The defaults have their own home, which usage() reads, so --help always shows
# the true defaults whatever the parsing loop sets. Each working variable starts
# with its default, then a flag may override it.
default_smith_label="dream:smith"
default_less_label="dream:less"
default_claude_smith_model="opus[1m]"
default_claude_smith_effort="xhigh"
default_claude_less_model="sonnet"
default_claude_less_effort="high"
default_codex_smith_model="gpt-5.6-sol"
default_codex_smith_effort="xhigh"
default_codex_less_model="gpt-5.6-terra"
default_codex_less_effort="high"
default_assignee="@me"
default_interval=300
default_max_agents=1

smith_label=$default_smith_label
less_label=$default_less_label
smith_model=
smith_effort=
less_model=
less_effort=
assignee=$default_assignee
interval=$default_interval
max_agents=$default_max_agents
harness=
once=0

while [ $# -gt 0 ]; do
  case "$1" in
    --harness) [ $# -ge 2 ] || die "--harness requires a value"; harness=$2; shift 2;;
    --smith-label) [ $# -ge 2 ] || die "--smith-label requires a value"; smith_label=$2; shift 2;;
    --less-label) [ $# -ge 2 ] || die "--less-label requires a value"; less_label=$2; shift 2;;
    --smith-model) [ $# -ge 2 ] || die "--smith-model requires a value"; smith_model=$2; shift 2;;
    --smith-effort) [ $# -ge 2 ] || die "--smith-effort requires a value"; smith_effort=$2; shift 2;;
    --less-model) [ $# -ge 2 ] || die "--less-model requires a value"; less_model=$2; shift 2;;
    --less-effort) [ $# -ge 2 ] || die "--less-effort requires a value"; less_effort=$2; shift 2;;
    --assignee) [ $# -ge 2 ] || die "--assignee requires a value"; assignee=$2; shift 2;;
    --interval) [ $# -ge 2 ] || die "--interval requires a value"; interval=$2; shift 2;;
    --max-agents) [ $# -ge 2 ] || die "--max-agents requires a value"; max_agents=$2; shift 2;;
    --once)     once=1; shift;;
    -h|--help)  usage; exit 0;;
    *)          die "unknown argument: $1";;
  esac
done

# Resolve model and effort defaults after parsing, because the selected harness
# owns them. The common flags remain overrides whichever harness runs.
[ -n "$harness" ] || die "--harness is required"
case "$harness" in
  claude)
    smith_model=${smith_model:-$default_claude_smith_model}
    smith_effort=${smith_effort:-$default_claude_smith_effort}
    less_model=${less_model:-$default_claude_less_model}
    less_effort=${less_effort:-$default_claude_less_effort}
    ;;
  codex)
    smith_model=${smith_model:-$default_codex_smith_model}
    smith_effort=${smith_effort:-$default_codex_smith_effort}
    less_model=${less_model:-$default_codex_less_model}
    less_effort=${less_effort:-$default_codex_less_effort}
    ;;
  *)
    die "--harness must be claude or codex"
    ;;
esac

# Reject a non-numeric interval or max-agents at parse time. Otherwise the code
# fails later with a message that hides the cause. A bad cap also lets dispatch
# run without a limit. Dying here names the flag instead.
require_positive_int interval "$interval" seconds
require_positive_int max-agents "$max_agents" agents

for tool in git gh jq tmux; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done
command -v "$harness" >/dev/null 2>&1 || die "$harness is not on the PATH"

# The main checkout, and the directory that holds it and its sibling worktrees.
# A linked worktree's .git is a file, not a directory, so this also rejects
# running from one, where the sibling worktrees would land in the wrong place.
main_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not in a git repository"
[ -d "$main_root/.git" ] || die "run this from the main checkout, not a linked worktree"
container=$(dirname "$main_root")
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || die "cannot read the GitHub repository"
script_dir=$(CDPATH=; cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) \
  || die "cannot resolve the catcher script directory"
watch_script="$script_dir/../watcher/watch.sh"
[ -f "$watch_script" ] || die "cannot find watch.sh next to the catcher skill"

# --- one tick --------------------------------------------------------------

# A worktree or branch this coordinator created, named
# dream-catcher-GH<n>-<timestamp>. The pattern is anchored to that exact shape,
# so the catcher never treats a human worktree as its own.
is_session_branch() { [[ "$1" =~ ^dream-catcher-GH[0-9]+-[0-9]{8}-[0-9]{6}$ ]]; }

issue_number_of_branch() {
  local branch=$1
  [[ "$branch" =~ ^dream-catcher-GH([0-9]+)-[0-9]{8}-[0-9]{6}$ ]] || return 1
  printf '%s\n' "${BASH_REMATCH[1]}"
}

# The path of every worktree of this repo, one per line. sed, not awk, keeps a
# path that contains a space intact.
worktree_paths() { git -C "$main_root" worktree list --porcelain | sed -n 's/^worktree //p'; }

# Every dispatched worktree of this repo, as path<TAB>branch. The branch name
# pattern is the source of truth for whether the catcher made it.
session_worktrees() {
  local wt branch
  while read -r wt; do
    [ -n "$wt" ] || continue
    branch=$(basename "$wt")
    is_session_branch "$branch" || continue
    printf '%s\t%s\n' "$wt" "$branch"
  done < <(worktree_paths)
}

# The branch of every live agent round, one per line. A finished or crashed round
# drops out here because its tmux session is gone.
live_agents() {
  local wt branch
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    tmux has-session -t "$branch" 2>/dev/null || continue
    printf '%s\n' "$branch"
  done < <(session_worktrees)
}

# True when live agent rounds fill the cap. Deferring once the count reaches
# max-agents makes it a hard ceiling. Dispatching at the cap would push the total
# past it.
at_agent_cap() {
  local live
  live=$(live_agents | wc -l)
  if [ "$live" -ge "$max_agents" ]; then
    log "deferring: $live live agent rounds at the cap of $max_agents"
    return 0
  fi
  return 1
}

# True when an active worktree for this issue already exists. This covers a
# round that started, then died before it opened a pull request. Without this
# guard, the next tick would dispatch the same issue again under a fresh
# timestamp. A worktree whose final round has already started is done, so it no
# longer blocks a later attempt.
dispatched_worktree_exists() {
  local target=$1 wt branch n
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    if [ -f "$(final_marker_file "$branch")" ] \
      && ! tmux has-session -t "$branch" 2>/dev/null; then
      continue
    fi
    n=$(issue_number_of_branch "$branch") || continue
    [ "$n" = "$target" ] && return 0
  done < <(session_worktrees)
  return 1
}

# True when the issue already has an active catcher worktree, or has an open or
# merged pull request from an earlier catcher branch. The issue's closed state
# can lag in `gh issue list`, so a merged pull request still counts. A
# closed-unmerged pull request without an active worktree does not count, so an
# old declined attempt never locks the issue out. A read failure returns true, so
# a transient error never re-dispatches an issue already under way.
already_handled() {
  local n=$1 count
  dispatched_worktree_exists "$n" && return 0
  count=$(gh pr list --repo "$repo" --state all --limit 500 --json headRefName,state 2>/dev/null \
    | jq -r --arg n "$n" '[.[] | select(.headRefName | test("^dream-catcher-GH" + $n + "-[0-9]{8}-[0-9]{6}$")) | select(.state == "OPEN" or .state == "MERGED")] | length' 2>/dev/null)
  [ -n "$count" ] || return 0
  [ "$count" -ne 0 ]
}

# All of an issue's blockers are closed. A read failure treats the issue as
# still blocked and skips it. So a transient API error never mis-dispatches a
# dependent issue ahead of its blocker.
unblocked() {
  local n=$1 open
  open=$(gh api "repos/$repo/issues/$n/dependencies/blocked_by" \
         --jq '[.[] | select(.state == "open")] | length' 2>/dev/null) \
    || { log "cannot check blockers for GH${n}, skipping it this tick"; return 1; }
  [ "${open:-0}" -eq 0 ]
}

# The catcher keeps per-branch diagnostics under $HOME. The repository stays as
# owner/name path segments, matching watch.sh's watermark key, so similarly named
# repositories do not collide.
catcher_state_dir() { printf '%s/.dream/catcher/%s/%s\n' "$HOME" "$repo" "$1"; }
agent_log_file() { printf '%s/agent.log\n' "$(catcher_state_dir "$1")"; }
inbox_file() { printf '%s/inbox.json\n' "$(catcher_state_dir "$1")"; }
final_marker_file() { printf '%s/final-started\n' "$(catcher_state_dir "$1")"; }
session_config_file() { printf '%s/session.json\n' "$(catcher_state_dir "$1")"; }

# Record the harness settings that Codex does not recover on resume. The saved
# values stay stable across loop restarts and --once runs, even if the command's
# defaults later change.
write_session_config() {
  local branch=$1 session_harness=$2 model=$3 effort=$4 state_dir file pending
  state_dir=$(catcher_state_dir "$branch")
  file=$(session_config_file "$branch")
  pending="$file.pending"
  mkdir -p "$state_dir" \
    || { log "cannot create catcher state directory for $branch"; return 1; }
  jq -n --arg harness "$session_harness" --arg model "$model" \
    --arg effort "$effort" \
    '{harness: $harness, model: $model, effort: $effort}' \
    >"$pending" \
    || { log "cannot write session config for $branch"; return 1; }
  mv "$pending" "$file" \
    || { log "cannot publish session config for $branch"; return 1; }
}

# Read and validate a branch's recorded harness settings. Every session has this
# file. Missing or incomplete configuration is invalid state, so the caller
# skips that branch.
read_session_config() {
  local branch=$1 file
  file=$(session_config_file "$branch")
  [ -f "$file" ] || return 1
  jq -ec '
      if (.harness == "claude" or .harness == "codex")
         and (.model | type == "string" and length > 0)
         and (.effort | type == "string" and length > 0) then
        {harness, model, effort}
      else
        error("incomplete session config")
      end
    ' "$file"
}

# Write the filtered PR input for the round the catcher is about to resume.
# watch.sh has already filtered the posts and advanced its watermark. The inbox
# hands the input to the round: the prompt carries only this path, not the user's
# words.
write_inbox() {
  local branch=$1 json=$2 state_dir
  state_dir=$(catcher_state_dir "$branch")
  mkdir -p "$state_dir" \
    || { log "cannot create catcher state directory for $branch"; return 1; }
  printf '%s\n' "$json" >"$(inbox_file "$branch")" \
    || { log "cannot write inbox for $branch"; return 1; }
}

# Remove a worktree and its branch together. This backs out a failed dispatch.
discard_worktree() {
  git -C "$main_root" worktree remove --force "$1" 2>/dev/null
  git -C "$main_root" branch -D "$2" 2>/dev/null
}

# The pull request for a branch, as a single JSON object. A branch is unique per
# attempt, so the newest matching pull request is the session's own.
pr_for_branch() {
  gh pr list --repo "$repo" --head "$1" --state all --json number,state \
    --jq 'sort_by(.number) | last // empty' 2>/dev/null
}

# The fixed prompt for every resumed round. It carries the pull request number
# and inbox path only. Pull request activity stays out of the command line: the
# resumed agent reads the filtered batch from the inbox file.
resume_prompt() {
  local pr=$1 inbox=$2
  cat <<EOF
PR-inbox prompt for pull request #$pr:

  $inbox

Read that JSON file. Read state before anything else. If state is MERGED or
CLOSED, finish per your session's rules. Otherwise act on posts per your
session's rules. End your turn when done.
EOF
}

# Build the part of every Claude Code command that carries its unattended
# permissions and session name.
claude_base_command() {
  local branch=$1 writes
  writes="Bash(gh pr create:*) Bash(gh pr comment:*) Bash(gh pr edit:*) Bash(gh pr ready:*) Bash(gh pr close:*) Bash(gh issue create:*) Bash(gh issue comment:*) Bash(git commit:*) Bash(git push:*)"
  printf 'claude --print --permission-mode auto --allowedTools %s --name %s\n' \
    "$(shell_quote "$writes")" "$(shell_quote "$branch")"
}

claude_first_round_command() {
  local branch=$1 model=$2 effort=$3 prompt=$4 cmd
  cmd=$(claude_base_command "$branch") || return 1
  cmd="$cmd --model $(shell_quote "$model") --effort $(shell_quote "$effort")"
  printf '%s %s\n' "$cmd" "$(shell_quote "$prompt")"
}

claude_resume_command() {
  local branch=$1 prompt=$2 cmd
  cmd=$(claude_base_command "$branch") || return 1
  printf '%s --continue %s\n' "$cmd" "$(shell_quote "$prompt")"
}

# Start Codex with every setting the unattended round needs. Later rounds resume
# the recorded session from its worktree, replay the settings that Codex does not
# retain, and let --last select the right session through Codex's cwd filter.
codex_first_round_command() {
  local wt=$1 model=$2 effort=$3 prompt=$4
  printf 'codex exec -C %s --approve-for-me -c %s --model %s -c %s %s\n' \
    "$(shell_quote "$wt")" \
    "$(shell_quote 'sandbox_workspace_write.network_access=true')" \
    "$(shell_quote "$model")" \
    "$(shell_quote "model_reasoning_effort=\"$effort\"")" \
    "$(shell_quote "$prompt")"
}

codex_resume_command() {
  local model=$1 effort=$2 prompt=$3
  printf 'codex exec resume --last --model %s -c %s -c %s -c %s -c %s -c %s %s\n' \
    "$(shell_quote "$model")" \
    "$(shell_quote "model_reasoning_effort=\"$effort\"")" \
    "$(shell_quote 'sandbox_mode="workspace-write"')" \
    "$(shell_quote 'sandbox_workspace_write.network_access=true')" \
    "$(shell_quote 'approval_policy="on-request"')" \
    "$(shell_quote 'approvals_reviewer="auto_review"')" \
    "$(shell_quote "$prompt")"
}

# Build one headless command for the selected harness. The lifecycle calls only
# this boundary, so a maintainer can add a harness without changing worktree,
# tmux, inbox, or final-round behaviour.
round_command() {
  local wt=$1 branch=$2 session_harness=$3 model=$4 effort=$5 resume=$6 prompt=$7
  case "$session_harness:$resume" in
    claude:0) claude_first_round_command "$branch" "$model" "$effort" "$prompt";;
    claude:1) claude_resume_command "$branch" "$prompt";;
    codex:0)  codex_first_round_command "$wt" "$model" "$effort" "$prompt";;
    codex:1)  codex_resume_command "$model" "$effort" "$prompt";;
    *)        return 1;;
  esac
}

first_round_prompt() {
  local session_harness=$1 skill=$2
  case "$session_harness" in
    claude) printf '/dream:%s\n' "$skill";;
    codex)  printf "\$dream:%s\n" "$skill";;
    *)      return 1;;
  esac
}

# Start one headless agent round in tmux and append its output to agent.log. tmux
# gives the catcher a liveness signal while the process runs. The log survives
# the tmux session ending and stays out of the worktree.
launch_agent_round() {
  local wt=$1 branch=$2 session_harness=$3 skill=$4 model=$5 effort=$6 resume=$7 final=$8 prompt=$9
  local session state_dir log_file agent_cmd run marker round
  session=$branch
  state_dir=$(catcher_state_dir "$branch")
  log_file=$(agent_log_file "$branch")
  round=$skill
  [ "$resume" -eq 1 ] && round=resume
  mkdir -p "$state_dir" \
    || { log "cannot create catcher state directory for $branch"; return 1; }
  agent_cmd=$(round_command "$wt" "$branch" "$session_harness" "$model" "$effort" "$resume" "$prompt") \
    || { log "cannot build agent command for $branch"; return 1; }
  run="{ printf '%s  starting $branch ($round)\n' \"\$(date -u +%FT%TZ)\"; $agent_cmd; agent_status=\$?; printf '%s  exited with status %s\n' \"\$(date -u +%FT%TZ)\" \"\$agent_status\"; exit \"\$agent_status\"; } 2>&1 | tee -a $(shell_quote "$log_file")"
  if ! tmux new-session -d -s "$session" -x 220 -y 50 -c "$wt" "$run"; then
    log "tmux failed to launch the round for $branch"
    return 1
  fi
  if [ "$final" -eq 1 ]; then
    marker=$(final_marker_file "$branch")
    printf '%s\n' "$(date -u +%FT%TZ)" >"$marker" \
      || log "cannot write final marker for $branch"
  fi
  log "started $round round for $branch in tmux session $session"
}

# Create the worktree and launch the first headless round for it. The branch name
# carries the issue number and a timestamp. A dispatched session reads the issue
# number at boot to take the issue as its input. The timestamp makes the name
# unique per attempt, so a retry never collides with an earlier attempt's branch
# or pull request.
#
# `git worktree add` creates the worktree. That lands it at a predictable sibling
# path, with a branch name the cap and duplicate checks match on.
dispatch() {
  local n=$1 skill=$2 ts branch wt err prompt model effort
  ts=$(date -u +%Y%m%d-%H%M%S)
  branch="dream-catcher-GH${n}-${ts}"
  wt="$container/${branch}"
  log "dispatching GH${n} ($skill) as $branch"
  err=$(git -C "$main_root" fetch origin main --quiet 2>&1) \
    || { log "fetch failed for GH${n}: $err"; return 1; }
  err=$(git -C "$main_root" worktree add -b "$branch" "$wt" origin/main 2>&1) \
    || { log "cannot create worktree $wt for GH${n}: $err"; return 1; }
  case "$skill" in
    smith) model=$smith_model; effort=$smith_effort;;
    less)  model=$less_model; effort=$less_effort;;
    *)     log "unknown skill '$skill' for GH${n}"; discard_worktree "$wt" "$branch"; return 1;;
  esac
  write_session_config "$branch" "$harness" "$model" "$effort" \
    || { discard_worktree "$wt" "$branch"; return 1; }
  prompt=$(first_round_prompt "$harness" "$skill") \
    || { log "cannot build first-round prompt for GH${n}"; discard_worktree "$wt" "$branch"; return 1; }
  if ! launch_agent_round "$wt" "$branch" "$harness" "$skill" "$model" "$effort" 0 0 "$prompt"; then
    log "cannot start first round for GH${n}, discarding worktree"
    discard_worktree "$wt" "$branch"
    return 1
  fi
  log "dispatched GH${n} ($skill) as $branch"
}

# Open issues carrying a label, one per line as createdAt<TAB>number<TAB>skill.
# The skill is the one the label dispatches, so a caller can order across labels
# by the timestamp and still know which skill each issue selected.
list_labelled() {
  local lbl=$1 skill=$2 state=${3:-open}
  gh issue list --repo "$repo" --assignee "$assignee" --label "$lbl" \
    --state "$state" --limit 500 --json number,createdAt \
    --jq ".[] | [.createdAt, (.number | tostring), \"$skill\"] | @tsv" 2>/dev/null
}

# Resume the first existing branch that needs a round. Open pull requests resume
# only when watch.sh returns new user posts. Merged or closed pull requests get
# one final round, guarded by final-started.
resume_existing_work() {
  local wt branch config session_harness model effort pr_json pr_number state watch_json posts prompt
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    tmux has-session -t "$branch" 2>/dev/null && continue
    [ -f "$(final_marker_file "$branch")" ] && continue
    config=$(read_session_config "$branch") \
      || { log "cannot read $(session_config_file "$branch"); skipping $branch"; continue; }
    session_harness=$(printf '%s' "$config" | jq -r '.harness')
    model=$(printf '%s' "$config" | jq -r '.model')
    effort=$(printf '%s' "$config" | jq -r '.effort')
    command -v "$session_harness" >/dev/null 2>&1 \
      || { log "skipping $branch: $session_harness is not on the PATH"; continue; }
    pr_json=$(pr_for_branch "$branch") \
      || { log "cannot read pull request for $branch; will retry next tick"; continue; }
    [ -n "$pr_json" ] \
      || { log "skipping $branch: no pull request yet; see $(agent_log_file "$branch")"; continue; }
    pr_number=$(printf '%s' "$pr_json" | jq -r '.number')
    state=$(printf '%s' "$pr_json" | jq -r '.state')
    case "$state" in
      OPEN)
        watch_json=$(bash "$watch_script" "$pr_number" 2>/dev/null) \
          || { log "cannot read pull request #$pr_number activity for $branch"; continue; }
        posts=$(printf '%s' "$watch_json" | jq -r '.posts | length' 2>/dev/null) \
          || { log "cannot parse watch result for pull request #$pr_number"; continue; }
        [ "${posts:-0}" -gt 0 ] || continue
        write_inbox "$branch" "$watch_json" || continue
        prompt=$(resume_prompt "$pr_number" "$(inbox_file "$branch")")
        launch_agent_round "$wt" "$branch" "$session_harness" "" "$model" "$effort" 1 0 "$prompt" && return 0
        ;;
      MERGED|CLOSED)
        [ -f "$(final_marker_file "$branch")" ] && continue
        watch_json=$(bash "$watch_script" "$pr_number" 2>/dev/null) \
          || { log "cannot read pull request #$pr_number activity for $branch"; continue; }
        write_inbox "$branch" "$watch_json" || continue
        prompt=$(resume_prompt "$pr_number" "$(inbox_file "$branch")")
        launch_agent_round "$wt" "$branch" "$session_harness" "" "$model" "$effort" 1 1 "$prompt" && return 0
        ;;
    esac
  done < <(session_worktrees | sort -t$'\t' -k2,2)
  return 1
}

tick() {
  if at_agent_cap; then
    return 0
  fi
  local smith_open less_open candidates n skill
  resume_existing_work && return 0
  smith_open=$(list_labelled "$smith_label" smith open) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  less_open=$(list_labelled "$less_label" less open) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  # Oldest eligible issue first across both labels. A stable sort on the
  # timestamp alone keeps the lists in input order for an issue that carries both
  # labels: smith first, then less. Such an issue dispatches to smith, since that
  # line enters first. Drop the timestamp after sorting, and keep the issue
  # number and skill. The later code no longer needs the timestamp.
  candidates=$(printf '%s\n%s\n' "$smith_open" "$less_open" | sort -s -t$'\t' -k1,1 | cut -f2-)
  while IFS=$'\t' read -r n skill; do
    [ -n "$n" ] || continue
    already_handled "$n" && continue   # already has a worktree or active PR
    unblocked "$n" || continue     # a blocker is still open
    dispatch "$n" "$skill" && return 0
  done <<<"$candidates"
  log "no eligible issue"
}

# --- run -------------------------------------------------------------------

log "dreamcatcher using $harness, watching $repo for labels '$smith_label' (smith) and '$less_label' (less), assignee '$assignee'"
if [ "$once" -eq 1 ]; then
  tick
else
  while true; do
    tick || log "tick error; continuing"
    sleep "$interval"
  done
fi
