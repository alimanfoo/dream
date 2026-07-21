#!/usr/bin/env bash
#
# Dreamcatcher: dispatch labelled issues to dream sessions.
#
# The issue's label selects the skill: the team label dispatches a /dream:team
# session, the solo label a /dream:solo session, the less label a /dream:less
# session. An issue carrying more than one goes to the heaviest: team over solo
# over less. Everything below the choice of skill is shared.
#
# Each tick is stateless. It reads live truth from git, tmux, and `gh`, then
# dispatches at most one session. Nothing is stored between ticks: the worktrees
# on disk, the tmux sessions, and the issues and pull requests on GitHub are the
# only state. So any trigger works. The default is a background loop. Drive
# `catch.sh --once` from cron for a machine that must survive reboots.
#
# Dispatched sessions run in a detached tmux session, not `claude --bg`. A
# background session dies when the team goes idle between steps. A tmux session
# stays alive and drives the work to completion, the same as a session run by
# hand.
#
# One session develops at a time. The coordinator holds the slot from dispatch
# until the pull request is ready for review, then frees it for the next
# dispatch. Sessions awaiting review pile up alongside the one still
# developing.
#
# Each session is its own process, in its own worktree, on its own branch. Git
# worktrees support concurrent commit and push against one shared object
# store. The one collision on record was agent-identity eviction between two
# in-process `claude --bg` teams, retired when tmux hosting replaced it
# (commit 0e88d7d). So the slot paces dispatch. It does not guard against
# corruption.
#
# Each tick also cleans up finished sessions. It kills and removes a worktree
# whose pull request was merged or closed past a linger period. That keeps tmux
# sessions from piling up until tmux refuses to open more.
#
# Permissions: a dispatched session runs in auto mode. dispatch passes the
# recurring unattended writes (gh pr create, gh issue create, git push, and so
# on) as narrow --allowedTools rules. Auto mode resolves these before its
# classifier runs. The classifier would otherwise stall an unattended session on
# a write it can't attribute to the user. Auto mode handles the rest and notifies
# on anything it blocks.
#
# Layout: the coordinator assumes the standard worktree layout, where each
# dispatched worktree is a sibling of the main checkout under a directory
# dedicated to this repo. It creates them as <container>/GH<n>-<timestamp>-auto.
# The timestamp makes each attempt unique, so a retry never collides with an
# earlier attempt's branch or pull request.

set -uo pipefail

usage() {
  cat <<'EOF'
Dreamcatcher: dispatch labelled issues to dream sessions.

Usage:
  catch.sh [--team-label <label>] [--solo-label <label>] [--less-label <label>]
           [--solo-model <model>] [--solo-effort <effort>]
           [--less-model <model>] [--less-effort <effort>]
           [--assignee <who>] [--interval <seconds>] [--once]

  --team-label  Issue label that dispatches a /dream:team session. Default: dream:team.
  --solo-label  Issue label that dispatches a /dream:solo session. Default: dream:solo.
  --less-label  Issue label that dispatches a /dream:less session. Default: dream:less.
  --solo-model  Model a /dream:solo session runs under. Default: opus[1m].
  --solo-effort Reasoning effort a /dream:solo session runs under. Default: high.
  --less-model  Model a /dream:less session runs under. Default: sonnet.
  --less-effort Reasoning effort a /dream:less session runs under. Default: medium.
  --assignee    Whose issues to pick up. Default: @me.
  --interval    Seconds between ticks in loop mode. Default: 300.
  --linger      Minutes a finished session lingers before it is cleaned up. Default: 30.
  --once        A single tick, then exit, instead of looping.
EOF
}

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# --- configuration ---------------------------------------------------------

team_label="dream:team"
solo_label="dream:solo"
less_label="dream:less"
solo_model="opus[1m]"
solo_effort="high"
less_model="sonnet"
less_effort="medium"
assignee="@me"
interval=300
linger=30
once=0

while [ $# -gt 0 ]; do
  case "$1" in
    --team-label) [ $# -ge 2 ] || die "--team-label requires a value"; team_label=$2; shift 2;;
    --solo-label) [ $# -ge 2 ] || die "--solo-label requires a value"; solo_label=$2; shift 2;;
    --less-label) [ $# -ge 2 ] || die "--less-label requires a value"; less_label=$2; shift 2;;
    --solo-model) [ $# -ge 2 ] || die "--solo-model requires a value"; solo_model=$2; shift 2;;
    --solo-effort) [ $# -ge 2 ] || die "--solo-effort requires a value"; solo_effort=$2; shift 2;;
    --less-model) [ $# -ge 2 ] || die "--less-model requires a value"; less_model=$2; shift 2;;
    --less-effort) [ $# -ge 2 ] || die "--less-effort requires a value"; less_effort=$2; shift 2;;
    --assignee) [ $# -ge 2 ] || die "--assignee requires a value"; assignee=$2; shift 2;;
    --interval) [ $# -ge 2 ] || die "--interval requires a value"; interval=$2; shift 2;;
    --linger)   [ $# -ge 2 ] || die "--linger requires a value"; linger=$2; shift 2;;
    --once)     once=1; shift;;
    -h|--help)  usage; exit 0;;
    *)          die "unknown argument: $1";;
  esac
done

# Reject a non-numeric interval or linger at parse time. Left unchecked, a typo
# like "30m" survives to the arithmetic in clean_up_finished and aborts the whole
# loop under set -u, silently ending the unattended run.
[[ "$interval" =~ ^[1-9][0-9]*$ ]] || die "--interval must be a positive whole number of seconds"
[[ "$linger" =~ ^[1-9][0-9]*$ ]] || die "--linger must be a positive whole number of minutes"

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

# --- one tick --------------------------------------------------------------

# A worktree or branch this coordinator created, named GH<n>-<timestamp>-auto.
# The pattern is anchored to that exact shape, so cleanup never removes a
# worktree a human happens to name with an "auto" token.
is_auto_branch() { [[ "$1" =~ ^GH[0-9]+-[0-9]{8}-[0-9]{6}-auto$ ]]; }

# The path of every worktree of this repo, one per line. sed, not awk, keeps a
# path that contains a space intact.
worktree_paths() { git -C "$main_root" worktree list --porcelain | sed -n 's/^worktree //p'; }

# True when a session still holds the slot: a live "-auto" session for this
# repo whose branch has no pull request that is merged, closed, or ready for
# review. isDraft is the signal every dispatched session type emits at the
# same point, team, solo, and less alike, so this reads uniformly across all
# three. A crashed session's tmux session is gone too, so it never wedges the
# slot. Each branch is unique per attempt, so its pull request state is that
# session's alone, never an earlier attempt's.
session_developing() {
  local wt branch reached_review
  while read -r wt; do
    [ -n "$wt" ] || continue
    branch=$(basename "$wt")
    is_auto_branch "$branch" || continue
    tmux has-session -t "dream-$branch" 2>/dev/null || continue
    reached_review=$(gh pr list --repo "$repo" --head "$branch" --state all --json state,isDraft \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED" or (.state == "OPEN" and .isDraft == false))] | length' \
      2>/dev/null || echo 0)
    if [ "${reached_review:-0}" -eq 0 ]; then
      log "deferring: $branch is still developing"
      return 0
    fi
  done < <(worktree_paths)
  return 1
}

# True when the issue already has an open or merged pull request: a current or
# earlier session still going, or one already merged. The issue's closed state
# can lag in `gh issue list`, so a merged pull request still counts. A
# closed-unmerged pull request does not count, so an old declined attempt never
# locks the issue out. A read failure returns true, so a transient error never
# re-dispatches an issue already under way.
already_handled() {
  local n=$1 count
  count=$(gh pr list --repo "$repo" --state all --limit 500 --json headRefName,state 2>/dev/null \
    | jq -r --arg n "$n" '[.[] | select(.headRefName | test("^GH" + $n + "(-.*)?-auto$")) | select(.state == "OPEN" or .state == "MERGED")] | length' 2>/dev/null)
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

epoch_of() {
  date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null || date -u -d "$1" +%s 2>/dev/null
}

# Mark the worktree as trusted, so the session does not block on the
# workspace-trust prompt. A background session skips that prompt, but an
# interactive tmux session hits it on a fresh directory. The flag lives in
# ~/.claude.json under the worktree's absolute path. The write is atomic.
trust_worktree() {
  local dir=$1 cfg="$HOME/.claude.json" tmp
  [ -f "$cfg" ] || printf '{}\n' >"$cfg"
  tmp=$(mktemp) || return 1
  # shellcheck disable=SC2015  # the fallback is correct cleanup whether jq or mv fails
  jq --arg d "$dir" '.projects[$d].hasTrustDialogAccepted = true' "$cfg" >"$tmp" 2>/dev/null \
    && mv "$tmp" "$cfg" || { rm -f "$tmp"; return 1; }
}

# Undo trust_worktree, so a removed worktree leaves no entry behind in
# ~/.claude.json. The write is atomic.
untrust_worktree() {
  local dir=$1 cfg="$HOME/.claude.json" tmp
  [ -f "$cfg" ] || return 0
  tmp=$(mktemp) || return 1
  # shellcheck disable=SC2015  # the fallback is correct cleanup whether jq or mv fails
  jq --arg d "$dir" 'del(.projects[$d])' "$cfg" >"$tmp" 2>/dev/null \
    && mv "$tmp" "$cfg" || { rm -f "$tmp"; return 1; }
}

# Remove a worktree, its branch, and its trust entry together, so nothing is
# left behind. This backs out a failed dispatch and reclaims a finished session.
discard_worktree() {
  git -C "$main_root" worktree remove --force "$1" 2>/dev/null
  git -C "$main_root" branch -D "$2" 2>/dev/null
  untrust_worktree "$1"
}

# Clean up finished sessions to free tmux's session slots. A worktree whose pull
# request has been merged or closed for at least the linger period is done. Its
# Collect has already run, so kill its tmux session and remove the worktree. This
# automates the cleanup a user would otherwise do by hand. No reliable "team
# idle" signal exists, so the linger period, set above any Collect run, is the
# guard against cleaning up mid-Collect.
clean_up_finished() {
  local cutoff wt branch done_at done_epoch
  cutoff=$(( $(date -u +%s) - linger * 60 ))
  while read -r wt; do
    [ -n "$wt" ] || continue
    branch=$(basename "$wt")
    is_auto_branch "$branch" || continue
    done_at=$(gh pr list --repo "$repo" --head "$branch" --state all --json state,mergedAt,closedAt \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED") | (.mergedAt // .closedAt)] | map(select(.)) | sort | last // empty' \
      2>/dev/null)
    [ -n "$done_at" ] || continue
    done_epoch=$(epoch_of "$done_at")
    [ -n "$done_epoch" ] || continue
    [ "$done_epoch" -le "$cutoff" ] || continue
    log "cleaning up $branch (PR finished $done_at, past ${linger}m linger)"
    tmux kill-session -t "dream-$branch" 2>/dev/null
    discard_worktree "$wt" "$branch"
  done < <(worktree_paths)
}

# Create the worktree and launch a session for it in a detached tmux session.
# The branch name carries the issue number and the auto token. A dispatched
# session reads the issue number at boot to take the issue as its input. A team
# session also reads the auto token to engage autopilot and auto-collect; a solo
# or less session runs autonomously already. The timestamp between them makes the
# name unique per attempt, so a retry never collides with an earlier attempt's
# branch or pull request.
#
# `git worktree add` creates the worktree, not `claude -w`. That lands it at a
# predictable sibling path, with a branch name the cap, cleanup, and dedup checks
# rely on. tmux hosts the session. The launch differs by skill: a team session
# runs under the experimental agent teams feature in teammate tmux mode, a solo
# or less session under neither. A solo or less session also sets its model and
# effort, the --solo-model/--solo-effort or --less-model/--less-effort values,
# because its single agent would otherwise take the launcher's defaults, where
# the team's agents carry their own. All run in auto mode, and the narrow allow
# rules passed at launch handle unattended writes.
dispatch() {
  local n=$1 skill=$2 ts branch wt session err writes run
  ts=$(date -u +%Y%m%d-%H%M%S)
  branch="GH${n}-${ts}-auto"
  wt="$container/${branch}"
  session="dream-${branch}"
  log "dispatching GH${n} ($skill) as $branch"
  err=$(git -C "$main_root" fetch origin main --quiet 2>&1) \
    || { log "fetch failed for GH${n}: $err"; return 1; }
  err=$(git -C "$main_root" worktree add -b "$branch" "$wt" origin/main 2>&1) \
    || { log "could not create worktree $wt for GH${n}: $err"; return 1; }
  trust_worktree "$wt" \
    || { log "could not pre-trust $wt, skipping GH${n}"; discard_worktree "$wt" "$branch"; return 1; }
  # The writes a session makes unattended, as narrow per-command allow rules.
  # Auto mode drops a broad Bash allow, so only narrow rules serve here.
  writes="Bash(gh pr create:*) Bash(gh pr comment:*) Bash(gh pr edit:*) Bash(gh pr ready:*) Bash(gh pr close:*) Bash(gh issue create:*) Bash(gh issue comment:*) Bash(git commit:*) Bash(git push:*)"
  run="claude --permission-mode auto --allowedTools '$writes'"
  case "$skill" in
    team) run="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 exec $run --teammate-mode tmux '/dream:team'";;
    solo) run="exec $run --model '$solo_model' --effort '$solo_effort' '/dream:solo'";;
    less) run="exec $run --model '$less_model' --effort '$less_effort' '/dream:less'";;
    *)    log "unknown skill '$skill' for GH${n}, discarding worktree"; discard_worktree "$wt" "$branch"; return 1;;
  esac
  if ! tmux new-session -d -s "$session" -x 220 -y 50 -c "$wt" "$run"; then
    log "tmux launch failed for GH${n}, discarding worktree"
    discard_worktree "$wt" "$branch"
    return 1
  fi
  log "dispatched GH${n} ($skill) into tmux session $session"
}

# Open issues carrying a label, one per line as createdAt<TAB>number<TAB>skill.
# The skill is the one the label dispatches, so a caller can order across labels
# by the timestamp and still know which skill each issue selected.
list_labelled() {
  local lbl=$1 skill=$2
  gh issue list --repo "$repo" --assignee "$assignee" --label "$lbl" \
    --state open --limit 500 --json number,createdAt \
    --jq ".[] | [.createdAt, (.number | tostring), \"$skill\"] | @tsv" 2>/dev/null
}

tick() {
  clean_up_finished
  if session_developing; then
    return 0
  fi
  local team_list solo_list less_list candidates n skill
  team_list=$(list_labelled "$team_label" team) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  solo_list=$(list_labelled "$solo_label" solo) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  less_list=$(list_labelled "$less_label" less) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  # Oldest eligible issue first across all three labels. A stable sort on the
  # timestamp alone keeps the lists in fed order for an issue that carries more
  # than one label: team first, then solo, then less. Such an issue dispatches to
  # the heaviest of its labels, since that line is fed first. The timestamp has
  # served its purpose once sorted, so drop it and keep the issue number and skill.
  candidates=$(printf '%s\n%s\n%s\n' "$team_list" "$solo_list" "$less_list" | sort -s -t$'\t' -k1,1 | cut -f2-)
  while IFS=$'\t' read -r n skill; do
    [ -n "$n" ] || continue
    already_handled "$n" && continue   # already has an open or merged pull request
    unblocked "$n" || continue     # a blocker is still open
    dispatch "$n" "$skill" && return 0
  done <<<"$candidates"
  log "no eligible issue"
}

# --- run -------------------------------------------------------------------

log "dreamcatcher watching $repo for labels '$team_label' (team), '$solo_label' (solo), and '$less_label' (less), assignee '$assignee'"
if [ "$once" -eq 1 ]; then
  tick
else
  while true; do
    tick || log "tick error; continuing"
    sleep "$interval"
  done
fi
