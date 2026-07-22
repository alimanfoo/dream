#!/usr/bin/env bash
#
# dream:watcher: return the user's new activity on a pull request.
#
# One query, one command, no subcommand. Given a pull request number, it returns
# the pull request state and the user's comments and reviews newer than a
# per-pull-request watermark. It then advances the watermark to the newest item
# it returned. The caller runs it on a recurring cron to watch a pull request
# for the user's replies while the session works elsewhere.
#
# The watermark is the newest item seen, never the wall clock. So a reply that
# lands while the caller is busy handling an earlier batch still stays above the
# watermark. It surfaces on the next run, instead of falling into the gap
# between one run and the next.
#
# With no watermark yet, an absent watermark reads as the beginning of time, so
# the first run returns every item on the pull request so far. There is no
# separate baseline or init step.
#
# The watermark file lives under $HOME so it survives the days a slow reviewer
# may take, across many cron firings in separate processes. It is keyed by the
# repository and pull request, so two worktree sessions on the same repository
# never collide. The script emits its path as `watermarkFile`, so the caller can
# delete it at teardown without re-deriving the key.
#
# The "user only" filter is mechanical. The session and the user post through
# the same GitHub account, so the filter keeps both halves:
#
# - Reviews from that account are the user's. The caller posts none, so every
#   review from the account is the user's.
# - Comments from that account are the user's when they lack the Claude Code
#   footer. The caller marks its own comments with that footer, so a comment
#   from the account carrying the footer is the caller's own and is dropped.
#
# Matching the account also drops anything from another account, a bot or
# another collaborator, which isn't the user's reply.
#
# The footer string is therefore essential: a change to it would break the
# filter, and the caller's own comments would read back as the user's input.
#
# One rare misread remains: a user comment that quotes an earlier caller
# comment, footer and all, reads as the caller's own and is dropped, until a
# later comment carries the watermark past it. Uncommon on a session's own pull
# request.
#
# Timestamps are ISO-8601 with a trailing Z, which sort correctly as strings, so
# the cutoff comparison needs no date arithmetic.

set -uo pipefail

die() { printf 'dream:watcher: %s\n' "$*" >&2; exit 2; }

[ $# -eq 1 ] || die "usage: watch.sh <pr>"
pr=$1
[[ "$pr" =~ ^[1-9][0-9]*$ ]] || die "pull request must be a positive whole number, got '$pr'"

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

# The footer string that marks a comment as the caller's own. It must match the
# Claude Code footer the plugin appends to comments, set in the agents' and
# skills' "mark your work" rules. A change there has to change here too, or the
# filter breaks.
footer="claude.com/claude-code"

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) \
  || die "cannot read the GitHub repository from the current directory"

# The account the session posts through, which is also the user's. The filter
# matches it to drop activity from any other account.
me=$(gh api user --jq .login 2>/dev/null) \
  || die "cannot read the authenticated GitHub account"

# The watermark file, keyed by repository and pull request. The repository name
# stays a real path segment (owner/name), rather than being flattened, so two
# repositories never collide: acme-corp/api and acme/corp-api are distinct
# paths, not one shared key. A nameWithOwner holds exactly one slash and neither
# half can be "..", so the path never escapes the directory.
dir="$HOME/.dream/watcher/$repo"
mkdir -p "$dir" || die "cannot create the watermark directory $dir"
watermark_file="$dir/pr${pr}"

cutoff=$(cat "$watermark_file" 2>/dev/null)

raw=$(gh pr view "$pr" --repo "$repo" --json state,comments,reviews 2>/dev/null) \
  || die "cannot read pull request #$pr in $repo"

# Select the user's new items and record the newest timestamp among them, so the
# watermark can advance to it. `max` over an empty array is null, which leaves
# the watermark unchanged.
result=$(printf '%s' "$raw" | jq --arg cutoff "$cutoff" --arg footer "$footer" --arg me "$me" '
  (.comments | map(select(.author.login == $me and (.body | contains($footer) | not) and .createdAt > $cutoff))) as $comments
  | (.reviews | map(select(.author.login == $me and .submittedAt > $cutoff))) as $reviews
  | {
      state: .state,
      comments: $comments,
      reviews: $reviews,
      newest: ([$comments[].createdAt, $reviews[].submittedAt] | max),
    }
') || die "cannot parse the pull request activity"

newest=$(printf '%s' "$result" | jq -r '.newest // empty')
if [ -n "$newest" ]; then
  printf '%s' "$newest" > "$watermark_file" \
    || die "cannot write the watermark file $watermark_file"
fi

# Emit what the caller acts on: the state, the new items, and the watermark path
# for teardown. The internal `newest` field is dropped.
printf '%s' "$result" | jq --arg watermark_file "$watermark_file" \
  '{state, comments, reviews, watermarkFile: $watermark_file}'
