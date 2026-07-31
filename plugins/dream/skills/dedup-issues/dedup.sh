#!/usr/bin/env bash
#
# dream:dedup-issues: the bookkeeping for a duplicate-issue scan.
#
# Two subcommands. `scan` prints the facts a scan needs, as one JSON object.
# `mark-checked` records how far the scan got. Whether two issues are duplicates
# is a reading of their meaning, so the caller decides that. This script never
# reads an issue body.
#
# Issue numbers only ever increase, so "every open issue up to N has been
# checked against the issues below it" is a single number. That number is the
# whole record, so a second run over an unchanged tracker has nothing to check.
#
# The record lives under $HOME, so it survives between runs in separate
# processes and is never committed to the repository being scanned. Its path
# keeps the repository name as a real path segment (owner/name), rather than
# flattening it, so two repositories never collide. The number then sits in a
# named file inside that directory, so anything else keeping state per
# repository does not collide with it either.
#
# A missing file reads as no record, and the run then checks every open issue.
# So there is no setup step, and a lost record costs a full re-scan rather than
# a wrong answer.
#
# The record is advisory. The optional `since` argument replaces it, which
# covers a maintainer on a second machine and a deliberate re-check.
#
# Reading an issue body is the caller's expensive act, so `scan` hands it every
# open issue's title in one `gh` call, and the numbers above the record as the
# targets to check. Titles are cheap. The caller decides which bodies to read.

set -uo pipefail

# --- configuration ---------------------------------------------------------

# The default has its own home, which usage() reads, so --help always shows the
# true default whatever the parsing loop sets.
default_limit=500

usage() {
  cat <<EOF
dream:dedup-issues: bookkeeping for a duplicate-issue scan.

Usage:
  dedup.sh scan [--limit <n>] [<since>]
  dedup.sh mark-checked <number>
  dedup.sh --help

  scan          Print what a scan needs, as one JSON object: repo, the record as
                checkedThrough, issues (every open issue as number and title, in
                ascending order), and targets (the issue numbers above the
                record).
  --limit       Most open issues to scan. A tracker holding more than this is an
                error, not a partial scan. Default: $default_limit.
  <since>       Issue number to use in place of the record, so the targets are
                the issues numbered above it.
  mark-checked  Record <number> as the highest issue checked.
EOF
}

die() { printf 'dream:dedup-issues: %s\n' "$*" >&2; exit 2; }

# Die unless the value is a positive whole number. One home for the check every
# number this script reads shares: an issue number and a limit are both counts
# that start at one.
require_positive_int() { [[ "$2" =~ ^[1-9][0-9]*$ ]] || die "$1 must be a positive whole number, got '$2'"; }

# --- arguments -------------------------------------------------------------

limit=$default_limit
since=""
number=""

[ $# -ge 1 ] || { usage >&2; exit 2; }
subcommand=$1
shift

case "$subcommand" in
  -h|--help)
    usage
    exit 0
    ;;
  scan)
    while [ $# -gt 0 ]; do
      case "$1" in
        --limit) [ $# -ge 2 ] || die "--limit requires a value"; limit=$2; shift 2;;
        -*)      die "unknown argument: $1";;
        *)       [ -z "$since" ] || die "scan takes at most one issue number"; since=$1; shift;;
      esac
    done
    require_positive_int --limit "$limit"
    [ -z "$since" ] || require_positive_int since "$since"
    ;;
  mark-checked)
    [ $# -eq 1 ] || die "mark-checked takes one issue number"
    number=$1
    require_positive_int "the issue number" "$number"
    ;;
  *)
    die "unknown command: '$subcommand'"
    ;;
esac

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) \
  || die "cannot read the GitHub repository from the current directory"

record_file="$HOME/.dream/dedup-issues/$repo/record"

if [ "$subcommand" = mark-checked ]; then
  mkdir -p "$(dirname "$record_file")" || die "cannot create the directory for $record_file"
  printf '%s' "$number" > "$record_file" || die "cannot write the record file $record_file"
  exit 0
fi

# --- scan ------------------------------------------------------------------

checked=$(cat "$record_file" 2>/dev/null)
if [ -n "$since" ]; then
  checked=$since
elif [ -n "$checked" ]; then
  # mark-checked is the only writer, so a value that is not a number means the
  # file was edited by hand. Name the file now, rather than failing later with a
  # jq parse error that hides where the bad value came from.
  require_positive_int "the record in $record_file" "$checked"
fi

# Ask for one more issue than the limit allows, so a tracker holding more than
# the limit is visible here. A partial list would otherwise read as the whole
# tracker, and every duplicate it cut off would go unreported.
raw=$(gh issue list --repo "$repo" --state open --limit "$((limit + 1))" --json number,title 2>/dev/null) \
  || die "cannot list the open issues in $repo"

count=$(printf '%s' "$raw" | jq 'length') || die "cannot count the open issues"
[ "$count" -le "$limit" ] \
  || die "$repo has more than $limit open issues; raise --limit rather than scan part of the tracker"

# With no record, checkedThrough is null, which sorts below every number, so the
# same comparison makes every open issue a target on the first run.
printf '%s' "$raw" | jq \
  --arg repo "$repo" \
  --argjson checked_through "${checked:-null}" '
  (map({number, title}) | sort_by(.number)) as $issues
  | {
      repo: $repo,
      checkedThrough: $checked_through,
      issues: $issues,
      targets: [$issues[] | select(.number > $checked_through) | .number],
    }
' || die "cannot build the scan output"
