# Phase 6: Review

Write every turn output, message and artefact in this phase using
`dream:plain-english`.

Follow the steps below when development is complete. Ralph copy-edits the
branch's prose first. Then Ada and Junio review in parallel, then the user. You
triage all three reviews the same way.

## Step 6.1: Ask Ralph to copy-edit the branch's prose

Ask Ralph to run the `dream:copy-edit` skill over the whole branch, and to
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

## Step 6.3: Triage each finding

Raise a challenge before deciding a finding when it shows that a settled
artifact no longer holds. Take it to the user per the "challenge" shape.

Decide each finding from both reviews on its merits, weighed against the
`dream:coherent-coding` principles. Each final decision takes one of these
paths:

- Accept: make it a follow-on task and run it through the standard per-task
  workflow.
- Reject: record the reason.
- Out of scope: hold it for post-merge triage.

For each finding you called out of scope, apply the
[same-edit check](../../../agents/Grace.md#same-edit-check).

Keep one response note per finding as you triage. Accepted findings record the
follow-on task and, once complete, the commit or evidence on the PR that
addressed it. Rejected findings record the reason. Out-of-scope findings record
that they are held for post-merge triage. These notes are the raw material for
the review comments you post after triage.

If a finding proposes a docstring, comment, or section-header to express a
contract, invariant, precondition, or convention, apply the
[code-shape-first check](../../../agents/Grace.md#code-shape-first-check) to it.

## Step 6.4: Post each review and response as a PR comment

Post each review and its response as one PR comment after you have handled all
accepted findings through the standard per-task workflow. Head the code review
comment `Code review` and the coherence review comment `Coherence review`. Use
this shape:

```text
## {heading}

> {the finding, verbatim}

Accepted. {what you did}

> {the finding, verbatim}

Rejected. {the reason}

> {the finding, verbatim}

Out of scope. Held for post-merge triage.

...and so on, one block per finding.
```

Quote each finding verbatim, so the reader can tell the review's words from
yours.

If a review raised no findings, post the heading and one line saying so.

Keep agent names off GitHub. Use the headings to name each review, not the agent
who wrote it. Post per
[Writing to GitHub](../../../agents/Grace.md#writing-to-github). Do not use
`gh pr review`. It carries more weight than these advisory reviews should.

## Step 6.5: Write the PR description

Write the description for the PR you opened in Phase 1
[Step 1.1](phase1.md#step-11-open-the-session-pr), replacing the `WIP`
placeholder.

Write it for a reviewer who has not read the thread. Check whether the repo has
contribution rules (`CONTRIBUTING.md`, a PR template) and follow them. Include
this content:

- Add a bullet list of issues addressed, one per line. Use `- Closes #N` for
  each issue the PR fully resolves, and `- Related to #N` for any it partly
  addresses. `Closes` triggers GitHub auto-close on merge; `Related to` does
  not.
- Follow with one to three sentences stating what the PR does and why, without
  implementation details, so a reviewer can understand it without reading the
  thread.
- If the approach is not clear, add one sentence that names the key design
  choice and links to the design comment that explains why.

Read and follow the [reviewer's guide](../../../reviewers-guide.md).

Follow written contribution rules instead of copying the style of existing PRs.

Follow [Writing to GitHub](../../../agents/Grace.md#writing-to-github). After
writing the description, run `gh pr view <N> --json closingIssuesReferences`.
Confirm that GitHub recognises every issue the PR fully resolves.

## Step 6.6: Mark the PR ready for review

Once all accepted follow-ons from triage are complete, run `gh pr ready <N>`.
Flipping from draft to ready signals to the user that the PR is now worth their
attention. If no findings were accepted, flip immediately.

## Step 6.7: Handle the user's review

The PR is ready once you have addressed every comment from Ada and Junio. The
user's review is the last of the three.

Go idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)). The watch
has been running since the PR opened. It brings the user's review back when it
lands, and carries the PR on through the merge or a close (see
[The watch](../../../agents/Grace.md#the-watch)).

Address each finding in the user's review the way you addressed the earlier
review findings. Triage each finding. Make a task for each one you accept. Post
any question you can't resolve without the user to the PR as a comment, the same
as [Step 1.3](phase1.md#step-13-elicit-answers-to-open-questions). After an
accepted task is complete, refresh the description per
[Keep it current](../../../reviewers-guide.md#keep-it-current). Then post one
response comment for the whole set of findings. Use the outcome lines from
[Step 6.4](#step-64-post-each-review-and-response-as-a-pr-comment), but name
each user finding briefly instead of quoting it. The finding is already public
in the PR thread.

The branch freezes once every review is addressed, the user's included. From
then on you fold no new development into the PR, and a finding becomes an issue
rather than a follow-on task. Resolving a merge conflict is the merge itself,
not new development.
