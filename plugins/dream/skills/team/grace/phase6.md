# Phase 6: Review

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

When development is complete, follow the steps below. Ralph copy-edits the
branch's prose first. Then Ada and Junio review in parallel, then the user. You
handle all three reviews the same way.

## Step 6.1: Ask Ralph to copy-edit the branch's prose

Ask Ralph to run the `/dream:copy-edit` skill over the whole branch, and to
commit and push what it changes. One `SendMessage`, closed with
`Reply via SendMessage.` Wait for his report by going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

Triage nothing from this. Ralph is the author, so he resolves the findings
himself.

## Step 6.2: Send the review requests

Tell Ada and Junio that development is complete and ask each for their review.
Two `SendMessage` calls in the same turn, one to each, both carrying the PR
number. Close each with `Reply via SendMessage.` Wait for both reviews by going
idle (see [Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

## Step 6.3: Post each review as a PR comment

Post each review as its own PR comment. Head Ada's comment `Code review` and
Junio's `Coherence review`, then the review text unchanged below the heading.
Post per [Writing to GitHub](../../../agents/Grace.md#writing-to-github). Do not
use `gh pr review`. It carries more weight than these advisory reviews should.

Keep agent names off GitHub. The headings name what was reviewed, not who
reviewed it.

## Step 6.4: Triage each finding

Decide each finding from both reviews on its merits, weighed against the
`/dream:coherent-coding` principles. Each finding takes one of these paths:

- Accept: make it a follow-on task and run it through the standard per-task
  workflow.
- Reject: note it in the response comment, with the reason.
- Out of scope: hold it for post-merge triage.
- Raise a challenge: take it to the user per the "challenge" shape. Use this
  when the finding shows a settled artifact no longer holds.

For each finding you called out of scope, apply the
[same-edit check](../../../agents/Grace.md#same-edit-check).

Keep one response note per finding as you triage. Accepted findings record the
follow-on task and, once complete, the commit or PR-visible evidence that
addressed it. Rejected findings record the reason. Out-of-scope findings record
that they are held for post-merge triage. These notes are the raw material for
the response comment you post after triage.

If a finding proposes a docstring, comment, or section-header to express a
contract, invariant, precondition, or convention, apply the
[code-shape-first check](../../../agents/Grace.md#code-shape-first-check) to it.

## Step 6.5: Post your response to reviews as a PR comment

After all accepted findings have been handled through the standard per-task
workflow, post one response comment. This is your public answer to both reviews.
It records how they were acted on so a reader does not have to reconstruct the
outcome from commits, task messages, or the user's chat.

The response is concise and GitHub-facing:

- One item per finding, using a short name for it.
- **Accepted** items say they were addressed, with the follow-up commit or
  PR-visible evidence when useful.
- **Rejected** items give the reason.
- **Out of scope** items say they are held for post-merge triage.
- If neither review raised findings, say no response work was needed.

Do not repost the review text or quote internal teammate messages. Post it per
[Writing to GitHub](../../../agents/Grace.md#writing-to-github).

## Step 6.6: Write the PR description

Write the description for the PR you opened in Phase 1
[Step 1.1](phase1.md#step-11-open-the-session-pr), replacing the `WIP`
placeholder.

Write it for a cold reviewer who has not read the thread. Check whether the repo
has contribution rules (`CONTRIBUTING.md`, a PR template) and follow them.
Otherwise use this shape:

- Open with a bullet list of issues addressed, one per line. Use `- Closes #N`
  for each issue the PR fully resolves, and `- Related to #N` for any it partly
  addresses. `Closes` triggers GitHub auto-close on merge; `Related to` does
  not.
- Follow with one to three sentences stating what the PR does and why, in
  mechanism-neutral terms, so a cold reviewer can orient without reading the
  thread.
- Add one optional sentence naming the key design choice if the approach is
  non-obvious, with a pointer to the design comment for the rationale.

Don't sample existing PRs for style. Written contribution rules are real. The
existing PR log is not a style reference.

Write it per [Writing to GitHub](../../../agents/Grace.md#writing-to-github).
After writing the description, verify that every issue the PR fully resolves is
recognised: run `gh pr view <N> --json closingIssuesReferences` to confirm each
issue appears.

## Step 6.7: Mark the PR ready for review

Once all accepted follow-ons from triage are complete, run `gh pr ready <N>`.
Flipping from draft to ready signals to the user that the PR is now worth their
attention. If no findings were accepted, flip immediately.

## Step 6.8: Handle the user's review

The PR is ready once you have addressed every comment from Ada and Junio. The
user's review is the last of the three.

Go idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)). The watch
has been running since the PR opened. It brings the user's review back when it
lands, and carries the PR on through the merge or a close (see
[The watch](../../../agents/Grace.md#the-watch)).

Address the user's comments the way you addressed Ada's and Junio's. Triage
each, and make a task for each one you accept. Post any question you can't
resolve without the user to the PR as a comment, the same as
[Step 1.3](phase1.md#step-13-elicit-answers-to-open-questions). Then post one
response comment, the same as
[Step 6.5](#step-65-post-your-response-to-reviews-as-a-pr-comment).

The branch freezes once every review is addressed, the user's included. From
then on you fold no new development into the PR, and a finding becomes an issue
rather than a follow-on task. Resolving a merge conflict is the merge itself,
not new development.
