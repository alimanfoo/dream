#!/usr/bin/env bash
#
# Dreamcatcher: dispatch labelled issues to dream sessions.
#
# The issue's label selects the skill: the smith label dispatches a /dream:smith
# session, and the less label dispatches a /dream:less session. An issue carrying
# both goes to smith.
#
# Each tick reads live truth from git, tmux, `gh`, and the small amount of
# catcher state under $HOME/.dream/catcher. It first looks for existing
# dispatched work to resume. Only when none needs a round does it dispatch a new
# issue. The default is a background loop. Drive `catch.sh --once` from cron for
# a machine that must survive reboots.
#
# Agent rounds run headless inside detached tmux sessions. The tmux session is a
# liveness probe and a place to attach while the round is running. When the round
# ends, tmux exits. The session's context stays on disk, so the next round resumes
# it from the worktree.
#
# The number of live agent rounds has a cap. --max-agents bounds how many agent
# processes run at once, so the user can choose how fast to spend tokens. The
# default is one.
#
# Each dispatched issue has its own worktree and branch. A round is its own
# process. Concurrent rounds are isolated by worktree; --max-agents paces token
# use, not repository safety.
#
# Each tick also cleans up finished worktrees. A worktree whose pull request was
# merged or closed, whose final round has started, and whose tmux round is no
# longer running is done. Cleanup removes the worktree and branch. It leaves
# $HOME/.dream/catcher state in place for debugging early lifecycle problems.
#
# Permissions: a dispatched session runs in auto mode. dispatch passes the
# recurring unattended writes (gh pr create, gh issue create, git push, and so
# on), plus the resolved watch.sh command for resumed rounds, as narrow
# --allowedTools rules. Auto mode resolves these before its classifier runs. The
# classifier would otherwise stall an unattended session on a command it can't
# attribute to the user. Auto mode handles the rest and notifies on anything it
# blocks.
#
# Layout: the coordinator assumes the standard worktree layout, where each
# dispatched worktree is a sibling of the main checkout under a directory
# dedicated to this repo. It creates them as <container>/GH<n>-<timestamp>. The
# timestamp makes each attempt unique, so a retry never collides with an earlier
# attempt's branch or pull request.

set -uo pipefail

usage() {
  cat <<EOF
Dreamcatcher: dispatch labelled issues to dream sessions.

Usage:
  catch.sh [--smith-label <label>] [--less-label <label>]
           [--smith-model <model>] [--smith-effort <effort>]
           [--less-model <model>] [--less-effort <effort>]
           [--assignee <who>] [--interval <seconds>]
           [--max-agents <n>] [--once]

  --smith-label  Issue label that dispatches a /dream:smith session. Default: $default_smith_label.
  --less-label  Issue label that dispatches a /dream:less session. Default: $default_less_label.
  --smith-model  Model a /dream:smith session runs under. Default: $default_smith_model.
  --smith-effort Reasoning effort a /dream:smith session runs under. Default: $default_smith_effort.
  --less-model  Model a /dream:less session runs under. Default: $default_less_model.
  --less-effort Reasoning effort a /dream:less session runs under. Default: $default_less_effort.
  --assignee    Whose issues to pick up. Default: $default_assignee.
  --interval    Seconds between ticks in loop mode. Default: $default_interval.
  --max-agents  Most concurrent agent rounds to run. Default: $default_max_agents.
  --once        A single tick, then exit, instead of looping.
EOF
}

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# Die unless the value is a positive whole number. One home for the check every
# numeric flag shares, so a new flag or a change to what counts as valid lands
# in one place.
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
# the true defaults whatever the parsing loop sets. Each working variable seeds
# from its default, then a flag may override it.
default_smith_label="dream:smith"
default_less_label="dream:less"
default_smith_model="opus[1m]"
default_smith_effort="xhigh"
default_less_model="sonnet"
default_less_effort="high"
default_assignee="@me"
default_interval=300
default_max_agents=1

smith_label=$default_smith_label
less_label=$default_less_label
smith_model=$default_smith_model
smith_effort=$default_smith_effort
less_model=$default_less_model
less_effort=$default_less_effort
assignee=$default_assignee
interval=$default_interval
max_agents=$default_max_agents
once=0

while [ $# -gt 0 ]; do
  case "$1" in
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

# Reject a non-numeric interval or max-agents at parse time. A bad value would
# otherwise fail only where it is used, with a message that hides the cause. In
# tick's cap comparison it makes the test fail open, so dispatch runs with no
# cap. Dying here names the flag instead.
require_positive_int interval "$interval" seconds
require_positive_int max-agents "$max_agents" agents

for tool in git gh jq claude tmux; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

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

# A worktree or branch this coordinator created, named GH<n>-<timestamp>. The
# pattern is anchored to that exact shape, so cleanup never removes a worktree a
# human named after the same issue.
is_session_branch() { [[ "$1" =~ ^GH[0-9]+-[0-9]{8}-[0-9]{6}$ ]]; }

issue_number_of_branch() {
  local branch=$1
  [[ "$branch" =~ ^GH([0-9]+)-[0-9]{8}-[0-9]{6}$ ]] || return 1
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
    tmux has-session -t "dream-$branch" 2>/dev/null || continue
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

# True when a worktree for this issue already exists. This covers a round that
# started, then died before it opened a pull request. Without this guard, the next
# tick would dispatch the same issue again under a fresh timestamp.
dispatched_worktree_exists() {
  local target=$1 wt branch n
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    n=$(issue_number_of_branch "$branch") || continue
    [ "$n" = "$target" ] && return 0
  done < <(session_worktrees)
  return 1
}

# True when the issue already has a catcher worktree, or has an open or merged
# pull request from an earlier catcher branch. The issue's closed state can lag in
# `gh issue list`, so a merged pull request still counts. A closed-unmerged pull
# request without a worktree does not count, so an old declined attempt never
# locks the issue out. A read failure returns true, so a transient error never
# re-dispatches an issue already under way.
already_handled() {
  local n=$1 count
  dispatched_worktree_exists "$n" && return 0
  count=$(gh pr list --repo "$repo" --state all --limit 500 --json headRefName,state 2>/dev/null \
    | jq -r --arg n "$n" '[.[] | select(.headRefName | test("^GH" + $n + "-[0-9]{8}-[0-9]{6}$")) | select(.state == "OPEN" or .state == "MERGED")] | length' 2>/dev/null)
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
skill_file() { printf '%s/skill\n' "$(catcher_state_dir "$1")"; }
resume_attempt_file() { printf '%s/resume-attempted-newest\n' "$(catcher_state_dir "$1")"; }
final_marker_file() { printf '%s/final-started\n' "$(catcher_state_dir "$1")"; }
watcher_watermark_file() { printf '%s/.dream/watcher/%s/pr%s\n' "$HOME" "$repo" "$1"; }

# The label chooses the skill at dispatch. After that, the session's skill is
# state, not live GitHub metadata: labels can change while the same branch is
# still waiting for review, merge, or close.
record_branch_skill() {
  local branch=$1 skill=$2 state_dir
  case "$skill" in
    smith|less) ;;
    *) log "unknown skill '$skill' for $branch"; return 1;;
  esac
  state_dir=$(catcher_state_dir "$branch")
  mkdir -p "$state_dir" \
    || { log "cannot create catcher state directory for $branch"; return 1; }
  printf '%s\n' "$skill" >"$(skill_file "$branch")" \
    || { log "cannot record skill for $branch"; return 1; }
}

read_branch_skill() {
  local branch=$1 skill
  [ -f "$(skill_file "$branch")" ] || return 1
  IFS= read -r skill <"$(skill_file "$branch")" || return 1
  case "$skill" in
    smith|less) printf '%s\n' "$skill";;
    *) return 1;;
  esac
}

# A resumed round is meant to consume the posts the catcher peeked. If it exits
# before it runs watch.sh, the watermark stays where it was and the same posts
# still appear on the next tick. Record the newest post timestamp at launch, so
# the catcher skips that same failed batch instead of relaunching forever.
record_resume_attempt() {
  local branch=$1 newest=$2
  printf '%s\n' "$newest" >"$(resume_attempt_file "$branch")" \
    || log "could not record resume attempt for $branch"
}

resume_already_attempted() {
  local branch=$1 newest=$2 previous
  [ -f "$(resume_attempt_file "$branch")" ] || return 1
  IFS= read -r previous <"$(resume_attempt_file "$branch")" || return 1
  [ "$previous" = "$newest" ]
}

# Remove a worktree and its branch together. This backs out a failed dispatch and
# reclaims a finished session. Catcher state under $HOME/.dream/catcher stays in
# place for debugging.
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

# Clean up finished sessions. A worktree whose pull request has ended, whose
# final round has started, and whose tmux round is no longer alive is done. The
# final marker records start, not success; a final round that dies partway is not
# retried.
clean_up_finished() {
  local wt branch pr_json pr_number state
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    tmux has-session -t "dream-$branch" 2>/dev/null && continue
    pr_json=$(pr_for_branch "$branch") || continue
    [ -n "$pr_json" ] || continue
    state=$(printf '%s' "$pr_json" | jq -r '.state')
    case "$state" in
      MERGED|CLOSED) ;;
      *) continue;;
    esac
    [ -f "$(final_marker_file "$branch")" ] || continue
    pr_number=$(printf '%s' "$pr_json" | jq -r '.number')
    log "cleaning up $branch (PR #$pr_number is $state and final round has started)"
    rm -f "$(watcher_watermark_file "$pr_number")"
    discard_worktree "$wt" "$branch"
  done < <(session_worktrees)
}

# The fixed prompt for every resumed round. It carries the pull request number
# and watch.sh path only. Pull request activity stays out of the command line:
# the resumed agent runs watch.sh itself, which consumes the posts only after the
# process that acts on them has started.
resume_prompt() {
  local pr=$1 watch_cmd
  watch_cmd="bash $(shell_quote "$watch_script") $pr"
  cat <<EOF
Watch check for pull request #$pr. Run:

  $watch_cmd

Read the whole JSON result. Read state before anything else. If state is MERGED
or CLOSED, finish per your session's rules. Otherwise act on posts per your
session's rules. End your turn when done.
EOF
}

# Build the Claude Code command for one headless agent round. The same command
# shape starts the first round and resumes later ones; resume adds --continue.
claude_round_command() {
  local branch=$1 skill=$2 resume=$3 prompt=$4 writes watch_rule allowed cmd
  writes="Bash(gh pr create:*) Bash(gh pr comment:*) Bash(gh pr edit:*) Bash(gh pr ready:*) Bash(gh pr close:*) Bash(gh issue create:*) Bash(gh issue comment:*) Bash(git commit:*) Bash(git push:*)"
  watch_rule="Bash(bash $(shell_quote "$watch_script"):*)"
  allowed=$writes
  [ "$resume" -eq 1 ] && allowed="$allowed $watch_rule"
  cmd="claude --print --permission-mode auto --allowedTools $(shell_quote "$allowed") --name $(shell_quote "$branch")"
  [ "$resume" -eq 1 ] && cmd="$cmd --continue"
  case "$skill" in
    smith) cmd="$cmd --model $(shell_quote "$smith_model") --effort $(shell_quote "$smith_effort")";;
    less)  cmd="$cmd --model $(shell_quote "$less_model") --effort $(shell_quote "$less_effort")";;
    *)     return 1;;
  esac
  printf '%s %s\n' "$cmd" "$(shell_quote "$prompt")"
}

# Start one headless agent round in tmux and append its output to agent.log. tmux
# gives the catcher a liveness signal while the process runs. The log survives
# the tmux session ending and stays out of the worktree.
launch_agent_round() {
  local wt=$1 branch=$2 skill=$3 resume=$4 final=$5 prompt=$6 session state_dir log_file agent_cmd run marker
  session="dream-$branch"
  state_dir=$(catcher_state_dir "$branch")
  log_file=$(agent_log_file "$branch")
  mkdir -p "$state_dir" \
    || { log "cannot create catcher state directory for $branch"; return 1; }
  agent_cmd=$(claude_round_command "$branch" "$skill" "$resume" "$prompt") \
    || { log "unknown skill '$skill' for $branch"; return 1; }
  run="{ printf '%s  starting $branch ($skill)\n' \"\$(date -u +%FT%TZ)\"; $agent_cmd; status=\$?; printf '%s  exited with status %s\n' \"\$(date -u +%FT%TZ)\" \"\$status\"; exit \"\$status\"; } 2>&1 | tee -a $(shell_quote "$log_file")"
  if ! tmux new-session -d -s "$session" -x 220 -y 50 -c "$wt" "$run"; then
    log "tmux launch failed for $branch"
    return 1
  fi
  if [ "$final" -eq 1 ]; then
    marker=$(final_marker_file "$branch")
    printf '%s\n' "$(date -u +%FT%TZ)" >"$marker" \
      || log "could not write final marker for $branch"
  fi
  log "started $skill round for $branch in tmux session $session"
}

# Create the worktree and launch the first headless round for it. The branch name
# carries the issue number and a timestamp. A dispatched session reads the issue
# number at boot to take the issue as its input. The timestamp makes the name
# unique per attempt, so a retry never collides with an earlier attempt's branch
# or pull request.
#
# `git worktree add` creates the worktree, not `claude -w`. That lands it at a
# predictable sibling path, with a branch name the cap, cleanup, and dedup checks
# match on.
dispatch() {
  local n=$1 skill=$2 ts branch wt err prompt
  ts=$(date -u +%Y%m%d-%H%M%S)
  branch="GH${n}-${ts}"
  wt="$container/${branch}"
  log "dispatching GH${n} ($skill) as $branch"
  err=$(git -C "$main_root" fetch origin main --quiet 2>&1) \
    || { log "fetch failed for GH${n}: $err"; return 1; }
  err=$(git -C "$main_root" worktree add -b "$branch" "$wt" origin/main 2>&1) \
    || { log "could not create worktree $wt for GH${n}: $err"; return 1; }
  if ! record_branch_skill "$branch" "$skill"; then
    log "could not record session state for GH${n}, discarding worktree"
    discard_worktree "$wt" "$branch"
    return 1
  fi
  prompt="/dream:$skill"
  if ! launch_agent_round "$wt" "$branch" "$skill" 0 0 "$prompt"; then
    log "could not start first round for GH${n}, discarding worktree"
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
# only when watch.sh --peek sees user posts. Merged or closed pull requests get
# one final round, guarded by final-started.
resume_existing_work() {
  local wt branch skill pr_json pr_number state watch_json posts newest prompt
  while IFS=$'\t' read -r wt branch; do
    [ -n "$wt" ] || continue
    tmux has-session -t "dream-$branch" 2>/dev/null && continue
    skill=$(read_branch_skill "$branch") \
      || { log "skipping $branch: no recorded skill; see $(agent_log_file "$branch")"; continue; }
    pr_json=$(pr_for_branch "$branch") \
      || { log "cannot read pull request for $branch; will retry next tick"; continue; }
    [ -n "$pr_json" ] \
      || { log "skipping $branch: no pull request yet; see $(agent_log_file "$branch")"; continue; }
    pr_number=$(printf '%s' "$pr_json" | jq -r '.number')
    state=$(printf '%s' "$pr_json" | jq -r '.state')
    case "$state" in
      OPEN)
        watch_json=$(bash "$watch_script" --peek "$pr_number" 2>/dev/null) \
          || { log "cannot peek pull request #$pr_number for $branch"; continue; }
        posts=$(printf '%s' "$watch_json" | jq -r '.posts | length' 2>/dev/null) \
          || { log "cannot parse watch result for pull request #$pr_number"; continue; }
        [ "${posts:-0}" -gt 0 ] || continue
        newest=$(printf '%s' "$watch_json" | jq -r '(.posts | map(.createdAt) | max) // empty' 2>/dev/null) \
          || { log "cannot parse newest post for pull request #$pr_number"; continue; }
        [ -n "$newest" ] \
          || { log "cannot find newest post for pull request #$pr_number"; continue; }
        if resume_already_attempted "$branch" "$newest"; then
          log "skipping $branch: pull request #$pr_number still has posts already attempted at $newest; see $(agent_log_file "$branch") or remove $(resume_attempt_file "$branch") to retry"
          continue
        fi
        prompt=$(resume_prompt "$pr_number")
        if launch_agent_round "$wt" "$branch" "$skill" 1 0 "$prompt"; then
          record_resume_attempt "$branch" "$newest"
          return 0
        fi
        ;;
      MERGED|CLOSED)
        [ -f "$(final_marker_file "$branch")" ] && continue
        prompt=$(resume_prompt "$pr_number")
        launch_agent_round "$wt" "$branch" "$skill" 1 1 "$prompt" && return 0
        ;;
    esac
  done < <(session_worktrees | sort -t$'\t' -k2,2)
  return 1
}

tick() {
  clean_up_finished
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
  # timestamp alone keeps the lists in fed order for an issue that carries both
  # labels: smith first, then less. Such an issue dispatches to smith, since that
  # line is fed first. The timestamp has served its purpose once sorted, so drop
  # it and keep the issue number and skill.
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

log "dreamcatcher watching $repo for labels '$smith_label' (smith) and '$less_label' (less), assignee '$assignee'"
if [ "$once" -eq 1 ]; then
  tick
else
  while true; do
    tick || log "tick error; continuing"
    sleep "$interval"
  done
fi
