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
# list` call. It writes each issue's body to its own file. It prints a JSON
# object: the repo name, the watermark, the watermark-file path, and the issue
# list. Each issue carries its number, title, state, and the path to its body
# file. The skill body reads that path and hands it to a subagent, so the bodies
# stay out of the session's own context.
#
# The `--advance` mode writes the watermark. It re-reads the highest issue number
# in the repo and saves it, so the next run reads only issues added since. It
# runs after the report is printed, so an interrupted run repeats rather than
# skips. On an empty tracker it leaves the watermark unchanged.
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
while [ $# -gt 0 ]; do
  case "$1" in
    --advance) mode=advance ;;
    --full) full=true ;;
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
  # The most recently created issue has the highest number, across open and
  # closed alike, so one integer records how far a run has read.
  highest=$(gh issue list --repo "$repo" --state all --limit "$issue_limit" \
    --json number --jq 'map(.number) | max // empty' 2>/dev/null) \
    || die "cannot read the issues in $repo"
  # An empty tracker leaves the watermark untouched, so a later run still treats
  # every issue as new.
  if [ -n "$highest" ]; then
    printf '%s\n' "$highest" > "$watermark_file" \
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

# Write each issue's body to its own file. Each issue arrives as one compact JSON
# object per line, so a body's own newlines never split a record.
while IFS= read -r issue; do
  number=$(printf '%s' "$issue" | jq -r '.number') \
    || die "cannot read an issue number from the list"
  printf '%s' "$issue" | jq -r '.body // ""' > "$bodies_dir/${number}.md" \
    || die "cannot write the body file for issue $number"
done < <(printf '%s' "$raw" | jq -c '.[]')

# Emit the issue list with a bodyFile path per issue. Sort it by number, so the
# skill body reads earlier issues before later ones. This JSON is the one place
# that names each body file, so the skill body reads the same path this scan
# wrote.
printf '%s' "$raw" | jq \
  --arg repo "$repo" \
  --argjson watermark "$watermark" \
  --arg watermark_file "$watermark_file" \
  --arg bodies_dir "$bodies_dir" '
  {
    repo: $repo,
    watermark: $watermark,
    watermarkFile: $watermark_file,
    issues: [.[] | {
      number: .number,
      title: .title,
      state: .state,
      bodyFile: ($bodies_dir + "/" + (.number | tostring) + ".md")
    }] | sort_by(.number)
  }
' || die "cannot build the issue list"
