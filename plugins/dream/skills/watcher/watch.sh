#!/usr/bin/env bash
#
# dream:watcher: return what the user newly posted on a pull request.
#
# One query, one command, no subcommand. Given a pull request number, it returns
# the pull request state and everything the user wrote on it newer than a
# per-pull-request watermark. It then advances the watermark to the newest post
# it returned. The caller runs it on a recurring cron to watch a pull request
# while the session works elsewhere.
#
# The watermark is the newest post seen, never the wall clock. So a post that
# lands while the caller is busy handling an earlier batch still stays above the
# watermark. It surfaces on the next run, instead of falling into the gap
# between one run and the next.
#
# With no watermark yet, an absent watermark reads as the beginning of time, so
# the first run returns every post on the pull request so far. There is no
# separate baseline or init step.
#
# The watermark file lives under $HOME so it survives the days a slow reviewer
# may take, across many cron firings in separate processes. The key is the
# repository and pull request, so two worktree sessions on the same repository
# never collide. The script emits its path as `watermarkFile`, so the caller can
# delete it at teardown without re-deriving the key.
#
# The script reads every place the user writes: the conversation comments, the
# review bodies, and the inline comments on the diff. Each is its own REST list,
# and one more call reads the pull request state.
#
# They come back as one list, `posts`, oldest first. Each post names its `kind`,
# so the caller reads the user's words in the order they were written, and still
# knows how to answer each one.
#
# One rule picks the user's posts out of the three sources. The session and the
# user write through the same account, so the rule reads the body: a post is the
# user's when it comes from that account and its body lacks an agent-written
# footer. The caller marks everything it writes with that footer, so its own
# posts drop out.
#
# Matching the account also drops anything from another account, a bot or
# another collaborator, which the user did not write.
#
# A second rule drops any post the user said nothing in. GitHub wraps a single
# inline comment in a review of its own, with an empty body, whenever anyone
# comments on one line. This also happens when the caller replies to the user.
# Without the rule, the wrapper around that reply would come back as user input.
# The wrapper says nothing, so it goes, while the inline comments it wrapped come
# through on their own. A review with an APPROVED or CHANGES_REQUESTED verdict
# says something, so it stays even with an empty body. Any other review with no
# body, such as one GitHub dismissed when a later commit landed, says nothing and
# goes.
#
# Timestamps are ISO-8601 with a trailing Z. They sort correctly as strings, so
# the script can compare them without date arithmetic.
#
# Every failure leaves through `die`, which writes one line to stderr and stops.
# So the script writes to stdout only once it has succeeded, and a caller can
# merge the two streams and still parse what it gets. Keep it that way: write
# nothing to stderr on a run that goes on to succeed, and redirect the stderr of
# each command this script runs.

set -uo pipefail

die() { printf 'dream:watcher: %s\n' "$*" >&2; exit 2; }

[ $# -eq 1 ] || die "usage: watch.sh <pr>"
pr=$1
[[ "$pr" =~ ^[1-9][0-9]*$ ]] || die "pull request must be a positive whole number, got '$pr'"

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not on the PATH"
done

# Read the footer from the same file as the callers.
script_dir=$(CDPATH=; cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) \
  || die "cannot resolve the watcher script directory"
marks_file="$script_dir/../../agent-written-marks.json"
[ -f "$marks_file" ] || die "cannot find the agent-written marks file"
footer=$(jq -r '.commentFooter // empty' "$marks_file") \
  || die "cannot read the agent-written comment footer"
[ -n "$footer" ] || die "the agent-written comment footer is empty"

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) \
  || die "cannot read the GitHub repository from the current directory"

# The account the session posts through, which is also the user's. The filter
# matches it to drop activity from any other account.
me=$(gh api user --jq .login 2>/dev/null) \
  || die "cannot read the authenticated GitHub account"

# The watermark file, keyed by repository and pull request. The repository name
# stays a real path segment (owner/name), rather than flattening it, so two
# repositories never collide: acme-corp/api and acme/corp-api are distinct
# paths, not one shared key. A nameWithOwner holds exactly one slash and neither
# half can be "..", so the path never escapes the directory.
dir="$HOME/.dream/watcher/$repo"
mkdir -p "$dir" || die "cannot create the watermark directory $dir"
watermark_file="$dir/pr${pr}"

cutoff=$(cat "$watermark_file" 2>/dev/null)

state=$(gh pr view "$pr" --repo "$repo" --json state --jq .state 2>/dev/null) \
  || die "cannot read pull request #$pr in $repo"

# The three places the user writes. Each is its own REST list, and `--slurp`
# returns one array per page, which the filter joins back into one list.
conversation_pages=$(gh api "repos/$repo/issues/$pr/comments?per_page=100" --paginate --slurp 2>/dev/null) \
  || die "cannot read the conversation comments on pull request #$pr in $repo"

review_pages=$(gh api "repos/$repo/pulls/$pr/reviews?per_page=100" --paginate --slurp 2>/dev/null) \
  || die "cannot read the reviews on pull request #$pr in $repo"

inline_pages=$(gh api "repos/$repo/pulls/$pr/comments?per_page=100" --paginate --slurp 2>/dev/null) \
  || die "cannot read the inline comments on pull request #$pr in $repo"

# Select the user's new posts and record the newest timestamp among them, so the
# watermark can advance to it. `max` over an empty array is null, which leaves
# the watermark unchanged.
#
# The three documents go in on stdin, in the order the variables above read
# them, so none has to fit in an argument.
#
# Each post keeps GitHub's own field names and values. The caller is a model
# that has read this API's JSON many times over, so GitHub's names cost it
# nothing to read, and a name this script invented would. The script adds one
# field, `kind`, because the three sources arrive as one list and nothing in the
# payload says which source a post came from.
#
# The REST API returns far more than the caller acts on, so each source keeps
# only the fields it acts on. Everything kept is passed through untouched.
#
# The one author field, `user.login`, and the one footer rule read the same way
# across all three sources, because all three come from the same API. Only the
# timestamp differs: a review records when it was submitted, and the other two
# when they were created.
result=$(printf '%s\n%s\n%s\n' "$conversation_pages" "$review_pages" "$inline_pages" \
  | jq --arg cutoff "$cutoff" --arg footer "$footer" --arg me "$me" \
       --arg state "$state" '
  def written_at:
    .created_at // .submitted_at;

  def is_new_from_user:
    .user.login == $me and written_at > $cutoff
    and (((.body // "") | contains($footer)) | not);

  def says_something:
    (.body // "") != "" or .state == "APPROVED" or .state == "CHANGES_REQUESTED";

  (. | add // []) as $conversation
  | (input | add // []) as $reviews
  | (input | add // []) as $inline_comments
  | [ ($conversation[]
       | select(is_new_from_user)
       | {kind: "comment", id, created_at, body})
    , ($reviews[]
       | select(is_new_from_user)
       | {kind: "review", id, submitted_at, body, state})
    , ($inline_comments[]
       | select(is_new_from_user)
       | {kind: "inlineComment", id, created_at, body, path, subject_type,
          side, start_side, start_line, line,
          original_start_line, original_line, diff_hunk})
    ]
  | map(select(says_something))
  | sort_by(written_at) as $posts
  | {
      state: $state,
      posts: $posts,
      newest: ($posts | map(written_at) | max),
    }
') || die "cannot parse the pull request activity"

newest=$(printf '%s' "$result" | jq -r '.newest // empty')
if [ -n "$newest" ]; then
  printf '%s' "$newest" > "$watermark_file" \
    || die "cannot write the watermark file $watermark_file"
fi

# Emit what the caller acts on: the state, the new posts, and the watermark path
# for teardown. This drops the internal `newest` field.
printf '%s' "$result" | jq --arg watermark_file "$watermark_file" \
  '{state, posts, watermarkFile: $watermark_file}'
