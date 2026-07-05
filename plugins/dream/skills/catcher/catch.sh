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
# Each tick also cleans up finished sessions. A worktree whose pull request was
# merged or closed past a linger period is killed and removed. That keeps tmux
# sessions from piling up until tmux refuses to open more.
#
# Permissions: a dispatched session runs in auto mode and reads the user's and
# the host repo's .claude/settings.json, the same as an autopilot session
# launched by hand. Keep the recurring unattended writes (gh pr create, git
# commit, git push, and so on) allowlisted there, in that one home.
# Auto mode handles the rest and notifies on anything it blocks.
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
  --once      Run a single tick and exit, instead of looping.
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

for tool in git gh jq claude tmux; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

# The main checkout, and the directory that holds it and its sibling worktrees.
main_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not in a git repository"
container=$(dirname "$main_root")
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || die "cannot read the GitHub repository"

# --- one tick --------------------------------------------------------------

# True when a session holds the one-at-a-time slot: a live "-auto" session for
# this repo whose branch has no merged or closed pull request. A developing
# session and one awaiting review both hold the slot, because two live teams
# would corrupt each other. A session whose pull request is merged or closed has
# finished and frees the slot. A crashed session frees it too, its tmux session
# gone, so it never wedges the slot. Each branch is unique per attempt, so its
# pull request state is that session's alone, never an earlier attempt's.
session_in_flight() {
  local wt branch finished
  while read -r wt; do
    [ -n "$wt" ] || continue
    branch=$(basename "$wt")
    [[ "$branch" =~ (^|[-_])[Aa][Uu][Tt][Oo]([-_]|$) ]] || continue
    tmux has-session -t "dream-$branch" 2>/dev/null || continue
    finished=$(gh pr list --repo "$repo" --head "$branch" --state all --json state \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED")] | length' \
      2>/dev/null || echo 0)
    if [ "${finished:-0}" -eq 0 ]; then
      log "deferring: $branch is still in flight; only one session runs at a time"
      return 0
    fi
  done < <(git -C "$main_root" worktree list --porcelain | awk '/^worktree /{print $2}')
  return 1
}

# True when the issue already has a session in flight or finished. That is an
# open pull request (a current or earlier session still going) or a merged one.
# The issue's closed state can lag in `gh issue list`, so a merged PR still
# counts. A closed-unmerged PR does not count, so an old declined attempt never
# locks the issue out. A read failure
# returns true, so a transient error never re-dispatches an issue already under
# way, and a just-merged issue is never picked up a second time.
already_handled() {
  local n=$1 count
  count=$(gh pr list --repo "$repo" --state all --json headRefName,state 2>/dev/null \
    | jq -r --arg n "$n" '[.[] | select(.headRefName | test("^GH" + $n + "(-.*)?-auto$")) | select(.state == "OPEN" or .state == "MERGED")] | length' 2>/dev/null)
  [ -n "$count" ] || return 0
  [ "$count" -ne 0 ]
}

# All of an issue's blockers are closed. A read failure treats the issue as
# still blocked and skips it, so a transient API error never mis-dispatches a
# dependent issue ahead of its blocker.
unblocked() {
  local n=$1 open
  open=$(gh api "repos/$repo/issues/$n/dependencies/blocked_by" \
         --jq '[.[] | select(.state == "open")] | length' 2>/dev/null) \
    || { log "cannot check blockers for GH${n}; skipping this tick"; return 1; }
  [ "${open:-0}" -eq 0 ]
}

# Clean up finished sessions to free tmux's session slots. A worktree whose pull
# request has been merged or closed for at least the linger period is done, its
# Collect run. Kill its tmux session and remove the worktree. This is the
# exit-and-kill a user does by hand, automated. No reliable "team idle" signal
# exists, so the linger period, set above any Collect run, is the guard against
# cleaning up mid-Collect.
epoch_of() {
  date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null || date -u -d "$1" +%s 2>/dev/null
}

clean_up_finished() {
  local cutoff wt base branch done_at done_epoch
  cutoff=$(( $(date -u +%s) - linger * 60 ))
  while read -r wt; do
    [ -n "$wt" ] || continue
    base=$(basename "$wt")
    [[ "$base" =~ (^|[-_])[Aa][Uu][Tt][Oo]([-_]|$) ]] || continue
    branch=$base
    done_at=$(gh pr list --repo "$repo" --head "$branch" --state all --json state,mergedAt,closedAt \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED") | (.mergedAt // .closedAt)] | map(select(.)) | sort | last // empty' \
      2>/dev/null)
    [ -n "$done_at" ] || continue
    done_epoch=$(epoch_of "$done_at")
    [ -n "$done_epoch" ] || continue
    [ "$done_epoch" -le "$cutoff" ] || continue
    log "cleaning up $branch (PR finished $done_at, past ${linger}m linger)"
    tmux kill-session -t "dream-$branch" 2>/dev/null
    git -C "$main_root" worktree remove --force "$wt" 2>/dev/null \
      && git -C "$main_root" branch -D "$branch" 2>/dev/null
  done < <(git -C "$main_root" worktree list --porcelain | awk '/^worktree /{print $2}')
}

# Mark the worktree as trusted, so the session does not block on the
# workspace-trust prompt. A background session skips that prompt, but an
# interactive tmux session hits it on a fresh directory. The flag lives in
# ~/.claude.json under the worktree's absolute path. The write is atomic.
trust_worktree() {
  local dir=$1 cfg="$HOME/.claude.json" tmp
  [ -f "$cfg" ] || printf '{}\n' >"$cfg"
  tmp=$(mktemp) || return 1
  jq --arg d "$dir" '.projects[$d].hasTrustDialogAccepted = true' "$cfg" >"$tmp" 2>/dev/null \
    && mv "$tmp" "$cfg" || { rm -f "$tmp"; return 1; }
}

# Create the worktree and launch a session for it in a detached tmux session.
# The branch name carries the issue number and the auto token, which Grace's
# boot reads to take the issue as the session input with autopilot and
# auto-collect engaged. The timestamp between them makes the name unique per
# attempt, so a retry never collides with an earlier attempt's branch or PR.
#
# The worktree is made with `git worktree add`, not `claude -w`, so it lands at a
# predictable sibling path with a branch name the cap and dedup checks rely on.
# tmux hosts the session because a `claude --bg` session dies when the team goes
# idle between steps, while a tmux session stays alive and drives to completion.
# The team feature is set per session through the experimental env var. Auto mode
# and the host repo's settings.json handle unattended writes.
dispatch() {
  local n=$1 ts branch wt session err
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
    || { log "could not pre-trust $wt; skipping GH${n}"; git -C "$main_root" worktree remove --force "$wt" 2>/dev/null; return 1; }
  if ! tmux new-session -d -s "$session" -x 220 -y 50 -c "$wt" \
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 exec claude --permission-mode auto --teammate-mode tmux '/dream:team'"; then
    log "tmux launch failed for GH${n}; removing worktree"
    git -C "$main_root" worktree remove --force "$wt" 2>/dev/null
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
