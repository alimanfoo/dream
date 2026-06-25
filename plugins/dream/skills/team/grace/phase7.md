# Phase 7: Review

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

When development is complete, follow the steps below. Ada and Junio review in
parallel. Ada reads with fresh eyes. Junio reviews against the accepted
requirements, Session Scope, and the whole diff. You handle both reviews the
same way.

## Step 7.1: Send the review requests

Tell Ada and Junio that development is complete and ask each for their review.
Two `SendMessage` calls in the same turn, one to each, both carrying the PR
number. Sign off per "Communication between teammates (agents)":
`From Grace. RSVP via SendMessage.`

## Step 7.2: Post each review as a PR comment

Post each review as its own PR comment via `gh pr comment <N> --body "..."`.
Each review body ends with a `From <reviewer>.` signature line. This is routing
metadata, not part of the review. Drop it. Preserve the review text unchanged,
then append the standard Claude Code footer from "Marking agent-authored GitHub
items". If the footer is already present, don't duplicate it. Do not use
`gh pr review`. It carries more weight than these advisory reviews should.

Keep agent names off GitHub. If you need to tell the two comments apart, refer
to the reviewers generically: "first reviewer", "second reviewer", or by what
each examined. Never use an agent name, which is internal protocol detail.

## Step 7.3: Triage each finding

Read Ada's cold-read reconstruction first, then the divergences she reports
against the stated intent. She built the reconstruction from the diff alone,
then opened the PR description and compared it to the stated intent herself. So
each divergence is a reviewability finding: a place the code failed to explain
itself to a reader with no context. This deserves real attention. Ada stands in
for the human reviewer, who also comes to the change cold. Where her read
diverged, the human's will too. As agents write more of the code, the human
spends scarce attention on that review. Code that explains itself there keeps
the review cheap.

Triage each divergence the same as any finding. Accept one as a follow-on that
makes the code carry its own intent. Reject it where Ada simply misread code
that is already clear. A reconstruction that matched the intent with no
divergence needs no action.

Decide each finding from both reviews on its merits. A reviewer raising it is
not itself a reason to accept it. Each finding takes one of these paths:

- Accept: make it a follow-on task, handled by the standard per-task workflow
  including Junio's coherence audit.
- Reject: note it in your reply to the user, with the reason.
- Out of scope: hold it for post-merge triage.
- Raise a Challenge: take it to the user per the "Challenge" shape. Use this
  when the finding shows an accepted artifact no longer holds, not a fixable
  defect.

A cluster of Junio's completeness misses can be the evidence for a Challenge. It
can show the Session Scope was too narrow, not just a list of follow-ons.

Keep one response note per finding as you triage. Accepted findings record the
follow-on task and, once complete, the commit or PR-visible evidence that
addressed it. Rejected findings record the reason. Out-of-scope findings record
that they are held for post-merge triage. These notes become the public response
in [Step 7.4](#step-74-post-graces-response-as-a-pr-comment).

Reclassify any "out of scope but noticed" item as in scope when it is the same
edit: one the PR missed, or one the PR has now made adjacent. The review bucket
is for broader concerns, not incomplete instances of the agreed change.

A finding may propose adding or expanding a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention.
Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding.

## Step 7.4: Post Grace's response as a PR comment

After all accepted findings have been handled through the standard per-task
workflow, post one response comment via `gh pr comment <N> --body "..."`. This
is Grace's public answer to both reviews. It records how they were acted on so a
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

## Step 7.5: Mark the PR ready for review

Once all accepted follow-ons from triage are complete, run `gh pr ready <N>`.
Flipping from draft to ready signals to the user that the PR is now worth their
attention. If no findings were accepted, flip immediately.

## Step 7.6: Hand back to the user

Hand back to the user once all comments are addressed. The PR is ready for the
user's acceptance. Phase 8 handles the merge itself.

Marking the PR ready hands off the branch, and from here it is frozen (see
[Phase 8: Merge](../protocol.md#phase-8-merge)). In Merge, Collect, and Reflect
a finding that would once have become a follow-on task becomes an issue instead.
You fold no new development into the PR. Resolving merge conflicts is the
exception. That is the merge itself, delegated to Ralph as Phase 8 describes.
Only a user-directed change reopens Develop. You handle it as an explicit
reopening, the same as any Phase 6 task:

- create a task
- Ralph implements
- you commit
- Junio audits

Absent that direction, the default is freeze.

The freeze stops new code, not updates to the PR's record. If a Challenge is
accepted at Phase 7 or later, still post its superseding comment and edit the PR
description. That records the decision, not development. Any code the Challenge
needs goes through the user-directed reopening above.
