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
# Usage:
#   catch.sh --label <label> [--assignee <who>] [--interval <seconds>] [--once]
#
# --label     Issue label that marks work for the team. Required.
# --assignee  Whose issues to pick up. Default: @me.
# --interval  Seconds between ticks in loop mode. Default: 300.
# --once      Run a single tick and exit, instead of looping.

set -uo pipefail
shopt -s nocasematch

# The recurring writes a session makes unattended. Scoped to command prefixes,
# so the dangerous tail (force-push, merge, reset) still routes through auto
# mode, which notifies on a block. The host repo's .claude/settings.json can
# add its own commands, such as a test or lint runner.
ALLOWLIST=(
  "Bash(gh pr create:*)"
  "Bash(gh pr comment:*)"
  "Bash(gh pr edit:*)"
  "Bash(gh pr ready:*)"
  "Bash(gh issue create:*)"
  "Bash(gh issue comment:*)"
  "Bash(git push:*)"
  "Bash(git commit:*)"
)

log() { printf '%s  %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { printf 'dreamcatcher: %s\n' "$*" >&2; exit 2; }

# --- configuration ---------------------------------------------------------

label=""
assignee="@me"
interval=300
once=0

while [ $# -gt 0 ]; do
  case "$1" in
    --label)    label=${2:-}; shift 2;;
    --assignee) assignee=${2:-}; shift 2;;
    --interval) interval=${2:-}; shift 2;;
    --once)     once=1; shift;;
    -h|--help)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *)          die "unknown argument: $1";;
  esac
done

[ -n "$label" ] || die "--label is required"
for tool in git gh jq claude; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

# The main checkout, and the directory that holds it and its sibling worktrees.
# A dispatched worktree is created here as <container>/GH<n>-auto.
main_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not in a git repository"
container=$(dirname "$main_root")
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || die "cannot read the GitHub repository"

# --- one tick --------------------------------------------------------------

# True when an autonomous session is still developing: a live "-auto" session
# under this repo whose branch has no ready (open, non-draft) pull request. A
# session parked on a ready PR waiting for review does not count, so the next
# issue can start while earlier PRs wait for the user.
dev_session_in_flight() {
  local agents cwd base branch ready
  agents=$(claude agents --json 2>/dev/null) || { log "cannot read claude agents; deferring"; return 0; }
  while read -r cwd; do
    [ -n "$cwd" ] || continue
    base=$(basename "$cwd")
    [[ "$base" =~ (^|[-_])auto([-_]|$) ]] || continue
    branch=$base
    ready=$(gh pr list --repo "$repo" --head "$branch" --state open --json isDraft \
            --jq '[.[] | select(.isDraft == false)] | length' 2>/dev/null || echo 0)
    [ "${ready:-0}" -eq 0 ] && return 0
  done < <(jq -r --arg c "$container/" '.[] | select(.cwd | startswith($c)) | .cwd' <<<"$agents")
  return 1
}

# All of an issue's blockers are closed.
unblocked() {
  local n=$1 open
  open=$(gh api "repos/$repo/issues/$n/dependencies/blocked_by" \
         --jq '[.[] | select(.state == "open")] | length' 2>/dev/null || echo 0)
  [ "${open:-0}" -eq 0 ]
}

# Create the worktree and launch a background session for it. The branch name
# carries the issue number and the auto token, which Grace's boot reads to take
# the issue as the session input with autopilot and auto-collect engaged.
dispatch() {
  local n=$1 branch="GH${n}-auto" wt="$container/GH${n}-auto"
  log "dispatching GH${n}"
  git -C "$main_root" fetch origin main --quiet || { log "fetch failed; skipping GH${n}"; return 1; }
  git -C "$main_root" worktree add -b "$branch" "$wt" origin/main >/dev/null 2>&1 \
    || { log "could not create worktree $wt; skipping GH${n}"; return 1; }
  ( cd "$wt" && CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 \
      claude --bg --permission-mode auto --allowedTools "${ALLOWLIST[@]}" -- "/dream:team" ) \
    || { log "dispatch failed for GH${n}"; return 1; }
  log "dispatched GH${n} into $wt"
}

tick() {
  if dev_session_in_flight; then
    log "a development session is in flight; deferring"
    return 0
  fi
  local n
  while read -r n; do
    [ -n "$n" ] || continue
    [ -e "$container/GH${n}-auto" ] && continue   # already picked up
    unblocked "$n" || continue                    # a blocker is still open
    dispatch "$n" && return 0
  done < <(gh issue list --repo "$repo" --assignee "$assignee" --label "$label" \
           --state open --json number,createdAt --jq 'sort_by(.createdAt) | .[].number' 2>/dev/null)
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
