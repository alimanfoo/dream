# Pull request handoff

## Review

Run the reviews below in sequence.

Find and fetch the pull request's base by following
[Review base](branch-bases.md#review-base). Use `origin/<base>...HEAD` as the
target for both reviews.

First, run the `dream:code-review` skill over that target.

Start the comment as soon as the skill returns, before you weigh any finding or
change any code. Write it to a temporary file outside the repo, named after the
comment's heading so one review's file never overwrites another's. Head it
`Code review`. When the review returned findings, add each finding verbatim as a
blockquote and leave one blank line under it for the response. When the review
returned no findings, the comment is the heading and one line saying so.

Weigh each finding on its merits and apply the ones the evidence supports. Reach
for the coherent fix even when it goes wider than the site the finding names.
Defer one that holds but needs a PR of its own. Once you settle a finding, write
one response line under its blockquote. Use exactly one of these forms:

- `Accepted: {what you did}`
- `Rejected: {reason}`
- `Deferred: {why it needs a PR of its own or the user's decision}`

Keep the response to one sentence.

Before you post a comment that has findings, reread the file. Between the
heading and the required footer, keep only repeating finding-and-response
blocks. Keep each finding verbatim and make each response match one of the forms
above. A finished comment looks like this:

```text
## Code review

> The parser drops empty fields, so callers cannot preserve them.

Accepted: Preserved empty fields in `parse_row`.

> `parse_row` should reject rows with empty fields.

Rejected: Empty fields are valid input.

> `parse_row` accepts duplicate fields, so a later value replaces the first.

Deferred: Rejecting duplicate fields changes the input contract and needs a PR of its own.
```

Commit and push the fixes, then post the file as a PR comment.

Second, run the `dream:coherence-review` skill the same way, and head its
comment `Coherence review`. It follows the code review so that it reads the
fixes that review led to.

## Simplification review

Reread the finished change once the reviews are done. Ask whether the PR could
remove a lot of code or complexity by changing the design or constraints given
in the input that defines the change or delivering less, while losing little
functionality.

Write and settle the opportunities as findings in a review comment headed
`Simplification review`, in the same way as the reviews above. Accept only an
opportunity that stays within what the input asks for. Defer one that changes
the input's constraints or delivers less than it asks for, since that needs the
user's decision. Commit and push accepted changes before posting the comment.

## Write the PR description

Draft the description, now that the work is final. Check the repo for
contribution rules (`CONTRIBUTING.md`, a PR template) and follow them. Include
this content:

- Add a bullet list of issues addressed. Use `Closes #N` for each one the PR
  fully resolves, and `Related to #N` for any it partly addresses. Keep any
  `Closes #N` link that the description already has.
- Follow with a summary, one to three sentences on what the PR does and why, for
  a reader new to the change.

Add a short `## Reviewer's guide` to the description. Put it near the start,
after the issue references and summary, unless the repo's template says
otherwise. Use these sections:

- `### Read first`: name the smallest set of files or parts the reviewer should
  read. Put them in order, and say what each one contains. Include generated
  output when it needs review.
- `### Check carefully`: name any behaviour or design choices that need closer
  review than the rest. Point to evidence the reviewer can inspect, such as a
  code path, a command they can run, or a PR comment. Say
  `Nothing beyond the diff` when no part needs closer review.
- `### Safe to skip`: name only changes where review would add no value, and say
  why. A generated or mechanical change is not safe to skip by default. Say
  `Nothing` when the reviewer should read the whole diff.

Replace the PR's description with the draft.

Reread the description after any later commit. Update the summary and reviewer's
guide when the diff changes what they say.
