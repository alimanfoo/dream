#!/usr/bin/env bash
#
# Dreamcatcher: dispatch labelled issues to dream-team sessions, one at a time.
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
# One session at a time. The coordinator holds the slot from dispatch until the
# pull request is merged or closed, so the user's merge paces the next dispatch.
# This is a granularity choice, letting the user size a session by composing
# issues, not a technical limit.
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
Dreamcatcher: dispatch labelled issues to dream-team sessions, one at a time.

Usage:
  catch.sh [--label <label>] [--assignee <who>] [--interval <seconds>] [--once]

  --label     Issue label that marks work for the team. Default: dream:team.
  --assignee  Whose issues to pick up. Default: @me.
  --interval  Seconds between ticks in loop mode. Default: 300.
  --linger    Minutes a finished session lingers before it is cleaned up. Default: 30.
  --once      A single tick, then exit, instead of looping.
EOF
}

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# --- configuration ---------------------------------------------------------

label="dream:team"
assignee="@me"
interval=300
linger=30
once=0

while [ $# -gt 0 ]; do
  case "$1" in
    --label)    [ $# -ge 2 ] || die "--label requires a value"; label=$2; shift 2;;
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

# True when a session holds the one-at-a-time slot: a live "-auto" session for
# this repo whose branch has no merged or closed pull request. A developing
# session and one awaiting review both hold the slot. Two live teams would
# corrupt each other. A session whose pull request is merged or closed has
# finished and frees the slot. A crashed session frees it too, its tmux session
# gone, so it never wedges the slot. Each branch is unique per attempt, so its
# pull request state is that session's alone, never an earlier attempt's.
session_in_flight() {
  local wt branch finished
  while read -r wt; do
    [ -n "$wt" ] || continue
    branch=$(basename "$wt")
    is_auto_branch "$branch" || continue
    tmux has-session -t "dream-$branch" 2>/dev/null || continue
    finished=$(gh pr list --repo "$repo" --head "$branch" --state all --json state \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED")] | length' \
      2>/dev/null || echo 0)
    if [ "${finished:-0}" -eq 0 ]; then
      log "deferring: $branch is still in flight"
      return 0
    fi
  done < <(worktree_paths)
  return 1
}

# True when the issue already has a session in flight or finished. That is an
# open pull request (a current or earlier session still going) or a merged one.
# The issue's closed state can lag in `gh issue list`, so a merged pull request
# still counts. A closed-unmerged pull request does not count, so an old
# declined attempt never locks the issue out. A read failure returns true, so a
# transient error never re-dispatches an issue already under way. A just-merged
# issue is also never picked up twice.
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
# session reads them at boot to take the issue as its input, with autopilot and
# auto-collect engaged. The timestamp between them makes the name unique per
# attempt, so a retry never collides with an earlier attempt's branch or pull
# request.
#
# `git worktree add` creates the worktree, not `claude -w`. That lands it at a
# predictable sibling path, with a branch name the cap, cleanup, and dedup checks
# rely on. tmux hosts the session. The team feature is set per session through
# the experimental env var. Auto mode plus the narrow allow rules passed at
# launch handle unattended writes.
dispatch() {
  local n=$1 ts branch wt session err writes
  ts=$(date -u +%Y%m%d-%H%M%S)
  branch="GH${n}-${ts}-auto"
  wt="$container/${branch}"
  session="dream-${branch}"
  log "dispatching GH${n} as $branch"
  err=$(git -C "$main_root" fetch origin main --quiet 2>&1) \
    || { log "fetch failed for GH${n}: $err"; return 1; }
  err=$(git -C "$main_root" worktree add -b "$branch" "$wt" origin/main 2>&1) \
    || { log "could not create worktree $wt for GH${n}: $err"; return 1; }
  trust_worktree "$wt" \
    || { log "could not pre-trust $wt, skipping GH${n}"; discard_worktree "$wt" "$branch"; return 1; }
  # The writes a session makes unattended, as narrow per-command allow rules.
  # Auto mode drops a broad Bash allow, so only narrow rules serve here.
  writes="Bash(gh pr create:*) Bash(gh pr comment:*) Bash(gh pr edit:*) Bash(gh pr ready:*) Bash(gh pr close:*) Bash(gh issue create:*) Bash(gh issue comment:*) Bash(git commit:*) Bash(git push:*)"
  if ! tmux new-session -d -s "$session" -x 220 -y 50 -c "$wt" \
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 exec claude --permission-mode auto --allowedTools '$writes' --teammate-mode tmux '/dream:team'"; then
    log "tmux launch failed for GH${n}, discarding worktree"
    discard_worktree "$wt" "$branch"
    return 1
  fi
  log "dispatched GH${n} into tmux session $session"
}

tick() {
  clean_up_finished
  if session_in_flight; then
    return 0
  fi
  local candidates n
  candidates=$(gh issue list --repo "$repo" --assignee "$assignee" --label "$label" \
    --state open --limit 500 --json number,createdAt \
    --jq 'sort_by(.createdAt) | .[].number' 2>/dev/null) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  while read -r n; do
    [ -n "$n" ] || continue
    already_handled "$n" && continue   # in flight or already done
    unblocked "$n" || continue     # a blocker is still open
    dispatch "$n" && return 0
  done <<<"$candidates"
  log "no eligible issue"
}

# --- run -------------------------------------------------------------------

log "dreamcatcher watching $repo for label '$label', assignee '$assignee'"
if [ "$once" -eq 1 ]; then
  tick
else
  while true; do
    tick || log "tick error; continuing"
    sleep "$interval"
  done
fi
