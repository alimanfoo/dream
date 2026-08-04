#!/usr/bin/env bash
#
# dream:watcher: return the user's new activity on a pull request.
#
# One query, one command, no subcommand. Given a pull request number, it returns
# the pull request state and everything the user wrote on it newer than a
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
# The user writes in three places, so the script reads three sources: the
# conversation comments and the review bodies, both from `gh pr view`, and the
# inline comments on the diff, which `gh pr view` does not carry and a second
# call fetches.
#
# One rule picks the user's items out of all three. The session and the user
# post through the same GitHub account, so the rule reads the body: an item is
# the user's when it comes from that account, has a body, and that body lacks
# the Claude Code footer. The caller marks everything it posts with that footer,
# so its own items drop out.
#
# Matching the account also drops anything from another account, a bot or
# another collaborator, which isn't the user's reply.
#
# The footer string is therefore essential: a change to it would break the
# filter, and the caller's own comments would read back as the user's input.
#
# Requiring a body is what drops the review GitHub wraps around a single inline
# comment. GitHub creates such a review whenever anyone comments on one line,
# the caller replying to the user included, and gives it an empty body. Nothing
# is lost: the review's content is its inline comments, which come through as
# their own items, and a review with no body of its own carries nothing to act
# on.
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

# The footer string that marks a body as the caller's own. It must match the
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

# The inline comments, which `gh pr view` does not carry. `--slurp` returns one
# array per page, which the filter joins back into one list.
inline=$(gh api "repos/$repo/pulls/$pr/comments?per_page=100" --paginate --slurp 2>/dev/null) \
  || die "cannot read the inline comments on pull request #$pr in $repo"

# Select the user's new items and record the newest timestamp among them, so the
# watermark can advance to it. `max` over an empty array is null, which leaves
# the watermark unchanged.
#
# Both documents go in on stdin, the pull request first and the inline comment
# pages second, so neither has to fit in an argument.
#
# An inline comment comes from the REST API, which returns far more than the
# caller acts on, so the filter keeps only the fields it needs: the body, where
# it sits, and the id to reply to it by. Its `line` is null once later commits
# have moved the line it was written on, so the filter falls back to the line it
# was written on, rather than reporting nothing.
result=$(printf '%s\n%s\n' "$raw" "$inline" \
  | jq --arg cutoff "$cutoff" --arg footer "$footer" --arg me "$me" '
  def from_user($author; $at):
    select($author == $me and $at > $cutoff
           and (.body // "") != "" and (.body | contains($footer) | not));

  . as $pr
  | (input | add // []) as $inline
  | ($pr.comments | map(from_user(.author.login; .createdAt))) as $comments
  | ($pr.reviews | map(from_user(.author.login; .submittedAt))) as $reviews
  | ($inline
     | map(from_user(.user.login; .created_at)
           | {id, path, line: (.line // .original_line), body,
              createdAt: .created_at})) as $inline_comments
  | {
      state: $pr.state,
      comments: $comments,
      reviews: $reviews,
      inlineComments: $inline_comments,
      newest: ([$comments[].createdAt, $reviews[].submittedAt, $inline_comments[].createdAt] | max),
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
  '{state, comments, reviews, inlineComments, watermarkFile: $watermark_file}'
