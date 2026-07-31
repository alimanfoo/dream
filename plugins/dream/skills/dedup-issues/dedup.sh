#!/usr/bin/env bash
#
# dream:dedup-issues: the bookkeeping for a duplicate-issue scan.
#
# Three subcommands. `scan` fetches the open issues and prints the facts a scan
# needs, as one JSON object. `mark-checked` records how far the scan got.
# `discard-bodies` throws away the issue text the scan fetched. Whether two
# issues are duplicates is a reading of their meaning, so the caller decides
# that. This script fetches the bodies and never judges them.
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
# The number sits in a named file in this skill's state directory, which
# repo-state.sh chooses, so the bodies directory beside it is a separate thing
# and neither can be read as the other.
#
# A missing file reads as no record, and the run then checks every open issue.
# So there is no setup step, and a lost record costs a full re-scan rather than
# a wrong answer.
#
# The record is advisory. The optional `since` argument replaces it, which
# covers a maintainer on a second machine and a deliberate re-check.
#
# A run started at `since` has checked nothing between the record and there, so
# the record must not advance past those issues: they would never be targets
# again, and nothing would ever report it. `mark-checked` therefore takes the
# number the run started above and advances the record only from that value, so
# the rule holds whatever the caller passes.
#
# Reading an issue body is the caller's expensive act, so `scan` hands it every
# open issue's title, and the issues above the number it starts after as the
# targets to check. Titles are cheap. The caller reads only the bodies its
# judgement needs.
#
# Fetching the bodies costs nothing extra, because they come back in the same
# `gh` call as the titles. The script writes each to its own file, so the caller
# can hand a path to an agent that holds no tool for reaching the tracker.
# `scan` empties the bodies directory before it writes any, so it holds exactly
# what this run fetched, and no stale file from an earlier run can be read by
# mistake.
#
# A body's only reader is a check on a target, so a scan with no targets writes
# no bodies at all. A run over an unchanged tracker then costs one `gh` call and
# leaves nothing behind, which is the path a repeat run takes.
#
# The bodies are one run's working copy of the tracker, not a store. Nothing
# reads them once the run that fetched them is over, so every run ends with
# `discard-bodies` and the issue text does not outlive it. Removing bodies that
# are not there succeeds, so that rule carries no condition and a caller cannot
# get it wrong. The record, one number, is the only thing a run leaves behind.

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
  dedup.sh mark-checked [--from <n>] <number>
  dedup.sh discard-bodies
  dedup.sh --help

  scan            Fetch the open issues and print what a scan needs, as one JSON
                  object: repo, startAfter (the number the scan starts above,
                  from the record or from <since>), issues (every open issue as
                  number and title, in ascending order), and targets (the issue
                  numbers above startAfter). With at least one target it also
                  writes every body to a file and gives each issue a bodyFile
                  path. With none it writes no body and leaves bodyFile out,
                  since a body's only reader is a check on a target.
  --limit         Most open issues to scan. A tracker holding more than this is
                  an error, not a partial scan. Default: $default_limit.
  <since>         Issue number to use in place of the record, so the targets are
                  the issues numbered above it.
  mark-checked    Record <number> as the highest issue checked.
  --from          The number the run started above, as scan reported it in
                  startAfter. Leave it off when scan reported none. The record
                  advances only when this matches what the record already says,
                  so a run that started somewhere else cannot claim the issues
                  in between. Such a run leaves the record alone and says so, at
                  status 0, because that is the right outcome and not a failure.
  discard-bodies  Remove the body files a scan wrote, which nothing reads once
                  the run that fetched them is over. Not an error when they are
                  already gone.
EOF
}

die() { printf 'dream:dedup-issues: %s\n' "$*" >&2; exit 2; }

# Die unless the value is a positive whole number. One home for the check every
# number this script reads shares: an issue number and a limit are both counts
# that start at one.
require_positive_int() { [[ "$2" =~ ^[1-9][0-9]*$ ]] || die "$1 must be a positive whole number, got '$2'"; }

# The state directory rules this skill shares with the other skills that keep
# per-repository state, found from this script's own location so the working
# directory does not matter.
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../../repo-state.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../repo-state.sh" \
  || die "cannot load the shared repo-state.sh beside the plugin's guides"

# --- arguments -------------------------------------------------------------

limit=$default_limit
since=""
number=""
started_after=""

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
    while [ $# -gt 0 ]; do
      case "$1" in
        --from) [ $# -ge 2 ] || die "--from requires a value"; started_after=$2; shift 2;;
        -*)     die "unknown argument: $1";;
        *)      [ -z "$number" ] || die "mark-checked takes one issue number"; number=$1; shift;;
      esac
    done
    [ -n "$number" ] || die "mark-checked takes one issue number"
    require_positive_int "the issue number" "$number"
    if [ -n "$started_after" ]; then
      require_positive_int --from "$started_after"
    fi
    ;;
  discard-bodies)
    [ $# -eq 0 ] || die "discard-bodies takes no arguments"
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

set_skill_state_dir dedup-issues "$repo"
record_file="$skill_state_dir/record"
bodies_dir="$skill_state_dir/bodies"

# What each subcommand does, in one place. Every subcommand has an arm, and the
# one that goes on to the scan says so here. So a subcommand added to the
# argument check and forgotten here dies, rather than exiting as though it had
# worked.
run_scan=false
case "$subcommand" in
  mark-checked)
    # The record advances only from the value the run started at, so no caller
    # can move it past issues nothing checked. A run that continued from the
    # record passes the record's own value and advances it. A run started
    # somewhere else, which is what `since` does, leaves the record alone.
    #
    # An absent record and an omitted `--from` are both the empty string, so the
    # one comparison also covers a first run, and covers a caller claiming a
    # record that is not there.
    recorded=$(cat "$record_file" 2>/dev/null)
    if [ "$recorded" = "$started_after" ]; then
      printf '%s' "$number" > "$record_file" || die "cannot write the record file $record_file"
    else
      # Not a failure: leaving the record alone is the right outcome, and the
      # caller has nothing to put right. Saying so keeps it from passing unseen.
      printf 'dream:dedup-issues: the record stays at %s, because this run started above %s rather than continuing from the record\n' \
        "${recorded:-nothing}" "${started_after:-nothing}" >&2
    fi
    ;;
  discard-bodies)
    # rm -rf succeeds on a path that is not there, so a run that scanned
    # nothing, and a second discard, both end quietly with nothing for the
    # caller to check.
    rm -rf "$bodies_dir" || die "cannot remove the bodies directory $bodies_dir"
    ;;
  scan)
    run_scan=true
    ;;
  *)
    die "no handler for '$subcommand'"
    ;;
esac

$run_scan || exit 0

# --- scan ------------------------------------------------------------------

# The number the scan starts above. It comes from the record, or from `since`
# when the caller gave one, and the two are the same kind of number, so nothing
# downstream has to know which it was.
start_after=$(cat "$record_file" 2>/dev/null)
if [ -n "$since" ]; then
  start_after=$since
elif [ -n "$start_after" ]; then
  # mark-checked is the only writer, so a value that is not a number means the
  # file was edited by hand. Name the file now, rather than failing later with a
  # jq parse error that hides where the bad value came from.
  require_positive_int "the record in $record_file" "$start_after"
fi

# From here the value is JSON, a number or null, and both jq calls below take
# this one value, so the boundary the targets are worked out from is the one the
# scan reports. With no record and no `since` it is null, which sorts below
# every number, so the one comparison makes every open issue a target on a first
# run.
[ -n "$start_after" ] || start_after=null

# Ask for one more issue than the limit allows, so a tracker holding more than
# the limit is visible here. A partial list would otherwise read as the whole
# tracker, and every duplicate it cut off would go unreported.
raw=$(gh issue list --repo "$repo" --state open --limit "$((limit + 1))" --json number,title,body 2>/dev/null) \
  || die "cannot list the open issues in $repo"

count=$(printf '%s' "$raw" | jq 'length') || die "cannot count the open issues"
[ "$count" -le "$limit" ] \
  || die "$repo has more than $limit open issues; raise --limit rather than scan part of the tracker"

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

# The targets, worked out once here and printed further down, so the rule that
# an issue above startAfter is a target has one home. An empty tracker slurps to
# an empty array, the same as a tracker with nothing new.
targets=$(printf '%s' "$issues" | jq -s -c --argjson start_after "$start_after" \
  '[.[] | select(.number > $start_after) | .number]') \
  || die "cannot work out which issues to check"

# Start with no bodies, so the directory reflects this scan whether it writes
# any or not. Clearing after the fetch leaves the last run's bodies in place
# when the fetch fails, rather than emptying the directory for nothing.
rm -rf "$bodies_dir" || die "cannot clear the bodies directory $bodies_dir"

# Whether this scan has bodies on disk, decided once. The writing below and the
# output after it both follow this one value, so neither can come to disagree
# about whether a bodyFile names a file that is there.
#
# `jq -c` prints an empty array as exactly `[]`, so the test is on the whole
# value.
if [ "$targets" = "[]" ]; then
  wrote_bodies=false
else
  wrote_bodies=true
fi

if $wrote_bodies; then
  mkdir -p "$bodies_dir" || die "cannot create the bodies directory $bodies_dir"
  while IFS= read -r issue; do
    body_file=$(printf '%s' "$issue" | jq -r '.bodyFile') \
      || die "cannot read a body file path from the issue list"
    printf '%s' "$issue" | jq -r '.body' > "$body_file" \
      || die "cannot write the body file $body_file"
  done <<< "$issues"
fi

# Each issue carries a bodyFile only when the bodies were written. A path naming
# a file that is not there would read as usable and fail at the point of use,
# where a missing field says plainly that this scan wrote no bodies.
printf '%s' "$issues" | jq -s \
  --arg repo "$repo" \
  --argjson start_after "$start_after" \
  --argjson targets "$targets" \
  --argjson wrote_bodies "$wrote_bodies" '
  {
    repo: $repo,
    startAfter: $start_after,
    issues: map(if $wrote_bodies then {number, title, bodyFile} else {number, title} end),
    targets: $targets,
  }
' || die "cannot build the scan output"
