#!/usr/bin/env bash
#
# dream:dedup-issues: the bookkeeping for a duplicate-issue scan.
#
# Two subcommands. `scan` fetches the open issues and prints the facts a scan
# needs, as one JSON object. `mark-checked` records how far the scan got.
# Whether two issues are duplicates is a reading of their meaning, so the caller
# decides that. This script fetches the bodies and never judges them.
#
# Issue numbers only ever increase, so "every open issue up to N has been
# checked against the issues below it" is a single number. That number is the
# whole record, so a second run over an unchanged tracker has nothing to check.
#
# One case that invariant does not cover: an issue closed during one run and
# reopened later sits below the record, so it never becomes a target again, and
# every comparison it takes part in is against a higher-numbered issue. `since`
# is how a maintainer re-checks it.
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
# open issue's title, the path to every body, and the numbers above the record
# as the targets to check. Titles are cheap. The caller reads only the bodies
# its judgement needs.
#
# Fetching the bodies costs nothing extra, because they come back in the same
# `gh` call as the titles. The script writes each to its own file, so the caller
# can hand a path to an agent that holds no tool for reaching the tracker.
# `scan` clears the bodies directory first, so it holds exactly what this run
# fetched, and no stale file from an earlier run can be read by mistake.

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

  scan          Fetch the open issues, write each body to a file, and print what
                a scan needs, as one JSON object: repo, the record as
                checkedThrough, issues (every open issue as number, title and
                bodyFile, in ascending order), and targets (the issue numbers
                above the record).
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

# Die unless the value is a repository name of the shape `gh` returns: an owner
# of letters, digits and hyphens, then a name that may also hold a dot or an
# underscore, and no second slash. Both halves become path segments of the state
# directory, and the scan deletes the bodies directory it builds there, so a
# value of another shape must not reach either path.
require_repo_name() { [[ "$1" =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ && "$1" != */. && "$1" != */.. ]] || die "the repository name must be owner/name, got '$1'"; }

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
require_repo_name "$repo"

state_dir="$HOME/.dream/dedup-issues/$repo"
record_file="$state_dir/record"
bodies_dir="$state_dir/bodies"

if [ "$subcommand" = mark-checked ]; then
  mkdir -p "$state_dir" || die "cannot create the state directory $state_dir"
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
raw=$(gh issue list --repo "$repo" --state open --limit "$((limit + 1))" --json number,title,body 2>/dev/null) \
  || die "cannot list the open issues in $repo"

count=$(printf '%s' "$raw" | jq 'length') || die "cannot count the open issues"
[ "$count" -le "$limit" ] \
  || die "$repo has more than $limit open issues; raise --limit rather than scan part of the tracker"

# Start the bodies directory empty, so it ends the run holding this scan's
# bodies and nothing else. Clearing after the fetch leaves the last run's bodies
# in place when the fetch fails, rather than emptying the directory for nothing.
rm -rf "$bodies_dir" || die "cannot clear the bodies directory $bodies_dir"
mkdir -p "$bodies_dir" || die "cannot create the bodies directory $bodies_dir"

# One compact JSON object per issue, in ascending number order, each carrying
# the path its body belongs at. This expression is the one home for that path:
# the loop below writes to the path it finds here, and the output repeats it, so
# nothing derives the path from a naming scheme of its own.
#
# The lines are built before the loop reads them, so a failure to build them
# dies here. A body's own newlines cannot split a line, because jq escapes them
# inside the object.
issues=$(printf '%s' "$raw" | jq -c --arg bodies_dir "$bodies_dir" '
  map({
    number,
    title,
    bodyFile: ($bodies_dir + "/" + (.number | tostring) + ".md"),
    body: (.body // ""),
  })
  | sort_by(.number)[]
') || die "cannot read the open issues in $repo"

# An empty tracker builds no lines at all, so skip the loop rather than feed it
# one empty line.
if [ -n "$issues" ]; then
  while IFS= read -r issue; do
    body_file=$(printf '%s' "$issue" | jq -r '.bodyFile') \
      || die "cannot read a body file path from the issue list"
    printf '%s' "$issue" | jq -r '.body' > "$body_file" \
      || die "cannot write the body file $body_file"
  done <<< "$issues"
fi

# The bodies are on disk, so the output can name them. With no record,
# checkedThrough is null, which sorts below every number, so the one comparison
# makes every open issue a target on the first run.
printf '%s' "$issues" | jq -s \
  --arg repo "$repo" \
  --argjson checked_through "${checked:-null}" '
  map({number, title, bodyFile}) as $issues
  | {
      repo: $repo,
      checkedThrough: $checked_through,
      issues: $issues,
      targets: [$issues[] | select(.number > $checked_through) | .number],
    }
' || die "cannot build the scan output"
