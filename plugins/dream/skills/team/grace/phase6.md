# Phase 6: Review

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

When development is complete, follow the steps below. Ada and Junio review in
parallel. You handle both reviews the same way.

## Step 6.1: Send the review requests

Tell Ada and Junio that development is complete and ask each for their review.
Two `SendMessage` calls in the same turn, one to each, both carrying the PR
number. Sign off `From Grace. Reply via SendMessage.` Wait for both reviews by
going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

## Step 6.2: Post each review as a PR comment

Post each review as its own PR comment via `gh pr comment <N> --body "..."`.
Each review body ends with a `From <reviewer>.` signature line. This is routing
metadata, not part of the review. Drop it. Preserve the review text unchanged,
then append the standard Claude Code footer from "Marking agent-authored GitHub
items". If the footer is already present, don't duplicate it. Do not use
`gh pr review`. It carries more weight than these advisory reviews should.

Keep agent names off GitHub. If you need to tell the two comments apart, refer
to the reviewers generically: "first reviewer", "second reviewer", or by what
each examined. Never use an agent name, which is internal protocol detail.

## Step 6.3: Triage each finding

Decide each finding from both reviews on its merits, following
`/dream:coherent-coding` principles. Each finding takes one of these paths:

- Accept: make it a follow-on task, handled by the standard per-task workflow
  including Junio's coherence audit.
- Reject: note it in your reply to the user, with the reason.
- Out of scope: hold it for post-merge triage.
- Raise a challenge: take it to the user per the "challenge" shape. Use this
  when the finding shows an accepted artifact no longer holds.

Keep one response note per finding as you triage. Accepted findings record the
follow-on task and, once complete, the commit or PR-visible evidence that
addressed it. Rejected findings record the reason. Out-of-scope findings record
that they are held for post-merge triage. These notes are the raw material for
the response comment you post after triage.

Reclassify any "out of scope but noticed" item as in scope when it is the same
edit: one the PR missed, or one the PR has now made adjacent.

## Step 6.4: Post your response to reviews as a PR comment

After all accepted findings have been handled through the standard per-task
workflow, post one response comment via `gh pr comment <N> --body "..."`. This
is your public answer to both reviews. It records how they were acted on so a
reader does not have to reconstruct the outcome from commits, task messages, or
the user's chat.

The response is concise and GitHub-facing:

- One item per finding, using each review's section labels or short finding
  names.
- **Accepted** items say they were addressed, with the follow-up commit or
  PR-visible evidence when useful.
- **Rejected** items give the reason.
- **Out of scope** items say they are held for post-merge triage.
- If neither review raised findings, say no response work was needed.

Do not repost the review text, quote internal teammate messages, or use
dream-team protocol vocabulary. Append the standard Claude Code footer from
"Marking agent-authored GitHub items". If the footer is already present, don't
duplicate it. Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).

## Step 6.5: Write the PR description

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

Mark the body per
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items)
and follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts). After
writing the description, verify that every issue the PR fully resolves is
recognised: run `gh pr view <N> --json closingIssuesReferences` to confirm each
issue appears.

## Step 6.6: Mark the PR ready for review

Once all accepted follow-ons from triage are complete, run `gh pr ready <N>`.
Flipping from draft to ready signals to the user that the PR is now worth their
attention. If no findings were accepted, flip immediately.

## Step 6.7: Hand back to the user

Hand back to the user once all agent reviewer comments are addressed. The PR is
ready for the user's review. Phase 7 handles the merge itself.

Under autopilot, don't hand back. The watch has been running since the PR
opened, and now carries the PR through the user's review, merge, or close (see
[Review and merge](../../../agents/Grace.md#review-and-merge)).

A user-directed change reopens the [develop phase](phase5.md). Under autopilot,
a review with feedback is that change. You handle it as an explicit reopening,
the same as any Phase 5 task:

- Grace creates a task
- Ralph implements and commits
- Junio audits
- Grace reads and triages

Post any question you can't resolve without the user to the PR as a comment
before you ask in chat. Otherwise the PR looks idle after the review while the
question sits only in chat. Do this the same as
[Step 1.3](phase1.md#step-13-elicit-answers-to-open-questions).

Once the accepted follow-ons are complete, post one response comment. Do this
the same as [Step 6.4](#step-64-post-your-response-to-reviews-as-a-pr-comment).

From here the branch is frozen. In Merge, Collect, and Reflect a finding that
would once have become a follow-on task becomes an issue instead. You fold no
new development into the PR. Resolving merge conflicts is the exception. That is
the merge itself, delegated to Ralph as Phase 7 describes.
