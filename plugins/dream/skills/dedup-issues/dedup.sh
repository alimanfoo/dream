#!/usr/bin/env bash
#
# dream:dedup-issues: read a repository's issues and track how far a run has read.
#
# This helper owns the mechanical jobs the dedup-issues skill needs: reading the
# issue tracker, and remembering how far a run has already read. The skill body
# drives the judgement. This helper never decides whether two issues match.
#
# The default mode scans. It reads the watermark, the highest issue number that
# existed at the last run, or zero when there is none. It makes one `gh issue
# list` call, up to a fixed ceiling. A tracker at that ceiling may have lost
# issues to truncation, so the scan fails instead of deduping a partial list. It
# writes each issue's body to its own file. It prints a JSON object: the repo
# name, the watermark, highWater (the highest issue number it saw), and the issue
# list. Each issue carries its number, title, state, and the path to its body
# file. The skill body reads that path and hands it to a subagent, so the bodies
# stay out of the session's own context. The skill body passes highWater back to
# `--advance`.
#
# The `--advance` mode writes the watermark. It takes the paired scan's highWater
# as an argument and writes it, so the watermark moves only as far as that scan
# read. An issue filed between the scan and the advance keeps a higher number. So
# it stays a target next run, rather than a run marking it checked without
# examining it. The advance runs after the scan prints the report, so an
# interrupted run repeats rather than skips. An omitted or empty value means the
# scan saw no issues, so the watermark stays unchanged.
#
# The `--full` flag makes the scan report the watermark as zero, so the run
# rechecks every open issue against all earlier ones.
#
# The state lives under $HOME, keyed by the repository as a real two-segment path
# (owner/name). Two repositories or two worktree sessions never collide, and the
# key never escapes its directory. The body files sit in a `bodies` subdirectory
# the scan clears each run, so at most one tracker's bodies sit on disk at a time.
#
# Writing nothing to the tracker keeps the skill a reader of the issues, never a
# writer.

set -uo pipefail

die() { printf 'dream:dedup-issues: %s\n' "$*" >&2; exit 2; }

mode=scan
full=false
# The highWater --advance writes, taken from the paired scan. Empty means the scan
# saw no issues, so leave the watermark unchanged.
advance_value=""
while [ $# -gt 0 ]; do
  case "$1" in
    --advance) mode=advance ;;
    --full) full=true ;;
    # An empty value, which an empty tracker's highWater produces, is a no-op.
    "") ;;
    [0-9]*) advance_value=$1 ;;
    *) die "unknown argument '$1'" ;;
  esac
  shift
done

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) \
  || die "cannot read the GitHub repository from the current directory"

# The state is keyed by the repository, the same way watch.sh keys its state. The
# repository name stays a real path segment (owner/name), so acme-corp/api and
# acme/corp-api are distinct paths, not one shared key. A nameWithOwner holds
# exactly one slash and neither half can be "..", so the path never escapes the
# directory.
dir="$HOME/.dream/dedup-issues/$repo"
mkdir -p "$dir" || die "cannot create the state directory $dir"
watermark_file="$dir/watermark"

# This is a generous ceiling for one list call. This repo's tracker is well under
# it. A tracker larger than this is beyond the current design.
issue_limit=10000

if [ "$mode" = advance ]; then
  # Write the paired scan's highWater, passed as an argument, so the watermark
  # moves only as far as that scan read. An empty value means the scan saw no
  # issues, so leave the watermark unchanged.
  if [ -n "$advance_value" ]; then
    [[ "$advance_value" =~ ^[0-9]+$ ]] \
      || die "the --advance value must be a non-negative integer, got '$advance_value'"
    printf '%s\n' "$advance_value" > "$watermark_file" \
      || die "cannot write the watermark file $watermark_file"
  fi
  exit 0
fi

# Scan mode.
watermark=$(cat "$watermark_file" 2>/dev/null)
# A missing or hand-edited watermark file reads as zero, so the run treats every
# issue as new rather than trusting a value it cannot parse.
[[ "$watermark" =~ ^[0-9]+$ ]] || watermark=0
if $full; then
  watermark=0
fi

# Bodies sit in their own subdirectory that the scan clears each run, so a
# repeated run never accumulates old bodies. The watermark file, one level up,
# survives untouched.
bodies_dir="$dir/bodies"
rm -rf "$bodies_dir" || die "cannot clear the bodies directory $bodies_dir"
mkdir -p "$bodies_dir" || die "cannot create the bodies directory $bodies_dir"

# The scan makes one list call over all issues, open and closed, so an open issue
# can match an earlier closed one. The body comes back with each issue, so the
# scan needs no second call.
raw=$(gh issue list --repo "$repo" --state all --limit "$issue_limit" \
  --json number,title,state,body 2>/dev/null) \
  || die "cannot read the issues in $repo"

# A returned count at the ceiling means gh may have truncated the list, dropping
# issues from the scan with no other signal. Stop rather than dedup a partial
# tracker.
count=$(printf '%s' "$raw" | jq 'length') \
  || die "cannot count the issues in the snapshot"
if [ "$count" -eq "$issue_limit" ]; then
  die "raise issue_limit in dedup.sh. The tracker returned $issue_limit issues, the current ceiling. gh may have truncated the list."
fi

# Enumerate the issues as one compact JSON object per line. Materialise this
# before the loop, so a failure to enumerate dies here rather than feeding the
# loop an early end and leaving bodies unwritten. A process substitution would
# hide that failure, since pipefail does not reach into it.
issue_lines=$(printf '%s' "$raw" | jq -c '.[]') \
  || die "cannot enumerate the issues in the snapshot"

# Write each issue's body to its own file. Each issue is one compact JSON object,
# so a body's own newlines never split a record. An empty tracker enumerates to
# nothing, so the loop is skipped.
if [ -n "$issue_lines" ]; then
  while IFS= read -r issue; do
    number=$(printf '%s' "$issue" | jq -r '.number') \
      || die "cannot read an issue number from the list"
    printf '%s' "$issue" | jq -r '.body // ""' > "$bodies_dir/${number}.md" \
      || die "cannot write the body file for issue $number"
  done <<< "$issue_lines"
fi

# Emit the report. Each issue carries a bodyFile path. The scan sorts issues by
# number, so the skill body reads earlier issues before later ones. This JSON is
# the one home for each bodyFile path and for highWater, the snapshot's highest
# issue number. The skill body reads the paths this scan wrote, and passes
# highWater to --advance.
printf '%s' "$raw" | jq \
  --arg repo "$repo" \
  --argjson watermark "$watermark" \
  --arg bodies_dir "$bodies_dir" '
  {
    repo: $repo,
    watermark: $watermark,
    highWater: (map(.number) | max),
    issues: [.[] | {
      number: .number,
      title: .title,
      state: .state,
      bodyFile: ($bodies_dir + "/" + (.number | tostring) + ".md")
    }] | sort_by(.number)
  }
' || die "cannot build the issue list"
