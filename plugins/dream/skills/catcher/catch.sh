#!/usr/bin/env bash
#
# Dreamcatcher: hand labelled issues to dream-team sessions, one at a time.
#
# Each tick is stateless. It reads live truth from `claude agents` and `gh`,
# then dispatches at most one session. Nothing is stored between ticks: the
# worktrees on disk, the sessions in `claude agents`, and the issues on GitHub
# are the only state. So any trigger works. The default is a background loop.
# For a machine that must survive reboots, drive `catch.sh --once` from cron.
#
# Permissions: a dispatched session runs in auto mode and reads the user's and
# the host repo's .claude/settings.json, the same as an autopilot session
# launched by hand. Keep the recurring unattended writes (gh pr create, gh pr
# comment, git commit, git push, and so on) allowlisted there, in that one home.
# Auto mode handles the rest and notifies on anything it blocks.
#
# Layout: the coordinator assumes the standard worktree layout, where each
# dispatched worktree is a sibling of the main checkout under a directory
# dedicated to this repo. It creates them as <container>/GH<n>-auto.

set -uo pipefail

usage() {
  cat <<'EOF'
Dreamcatcher: hand labelled issues to dream-team sessions, one at a time.

Usage:
  catch.sh --label <label> [--assignee <who>] [--interval <seconds>] [--once]

  --label     Issue label that marks work for the team. Required.
  --assignee  Whose issues to pick up. Default: @me.
  --interval  Seconds between ticks in loop mode. Default: 300.
  --once      Run a single tick and exit, instead of looping.
EOF
}

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# --- configuration ---------------------------------------------------------

label=""
assignee="@me"
interval=300
once=0

while [ $# -gt 0 ]; do
  case "$1" in
    --label)    [ $# -ge 2 ] || die "--label requires a value"; label=$2; shift 2;;
    --assignee) [ $# -ge 2 ] || die "--assignee requires a value"; assignee=$2; shift 2;;
    --interval) [ $# -ge 2 ] || die "--interval requires a value"; interval=$2; shift 2;;
    --once)     once=1; shift;;
    -h|--help)  usage; exit 0;;
    *)          die "unknown argument: $1";;
  esac
done

[ -n "$label" ] || die "--label is required"
for tool in git gh jq claude; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

# The main checkout, and the directory that holds it and its sibling worktrees.
main_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not in a git repository"
container=$(dirname "$main_root")
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || die "cannot read the GitHub repository"

# --- one tick --------------------------------------------------------------

# True when an autonomous session is still developing: a live "-auto" session
# under this repo whose branch has no ready, merged, or closed pull request. A
# session past PR ready (open non-draft), merged, or closed does not count, so
# the next issue can start while earlier PRs wait for the user. A read failure
# defers, which is the safe direction.
dev_session_in_flight() {
  local agents cwd base branch advanced
  agents=$(claude agents --json 2>/dev/null) || { log "cannot read claude agents; deferring"; return 0; }
  while read -r cwd; do
    [ -n "$cwd" ] || continue
    base=$(basename "$cwd")
    [[ "$base" =~ (^|[-_])[Aa][Uu][Tt][Oo]([-_]|$) ]] || continue
    branch=$base
    advanced=$(gh pr list --repo "$repo" --head "$branch" --state all --json state,isDraft \
      --jq '[.[] | select(.state == "MERGED" or .state == "CLOSED" or (.state == "OPEN" and .isDraft == false))] | length' \
      2>/dev/null || echo 0)
    [ "${advanced:-0}" -eq 0 ] && return 0
  done < <(jq -r --arg c "$container/" '.[] | select(.cwd | startswith($c)) | .cwd' <<<"$agents")
  return 1
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

# Create the worktree and launch a background session for it. The branch name
# carries the issue number and the auto token, which Grace's boot reads to take
# the issue as the session input with autopilot and auto-collect engaged.
#
# The worktree is made with `git worktree add`, not `claude -w`, so it lands at
# a predictable sibling path with a clean branch name that the cap check and the
# already-picked-up check both rely on, independent of the CLI's own worktree
# placement.
dispatch() {
  local n=$1
  local branch="GH${n}-auto"
  local wt="$container/GH${n}-auto"
  log "dispatching GH${n}"
  git -C "$main_root" fetch origin main --quiet || { log "fetch failed; skipping GH${n}"; return 1; }
  git -C "$main_root" worktree add -b "$branch" "$wt" origin/main >/dev/null 2>&1 \
    || { log "could not create worktree $wt; skipping GH${n}"; return 1; }
  if ! ( cd "$wt" && CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 \
      claude --bg --permission-mode auto -- "/dream:team" ); then
    log "launch failed for GH${n}; removing worktree"
    git -C "$main_root" worktree remove --force "$wt" 2>/dev/null
    return 1
  fi
  log "dispatched GH${n} into $wt"
}

tick() {
  if dev_session_in_flight; then
    log "a development session is in flight; deferring"
    return 0
  fi
  local candidates n
  candidates=$(gh issue list --repo "$repo" --assignee "$assignee" --label "$label" \
    --state open --limit 500 --json number,createdAt \
    --jq 'sort_by(.createdAt) | .[].number' 2>/dev/null) \
    || { log "cannot list issues; will retry next tick"; return 1; }
  while read -r n; do
    [ -n "$n" ] || continue
    [ -e "$container/GH${n}-auto" ] && continue   # already picked up
    unblocked "$n" || continue                    # a blocker is still open
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
