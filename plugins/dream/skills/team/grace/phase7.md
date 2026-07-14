# Phase 7: Review

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

When development is complete, follow the steps below. Ada and Junio review in
parallel. Ada reads with fresh eyes. Junio reviews the whole diff for coherence.
You handle both reviews the same way.

## Step 7.1: Send the review requests

Tell Ada and Junio that development is complete and ask each for their review.
Two `SendMessage` calls in the same turn, one to each, both carrying the PR
number. Sign off per "Communication between teammates (agents)":
`From Grace. RSVP via SendMessage.` Wait for both reviews by going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

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

Decide each finding from both reviews on its merits. A reviewer raising it is
not itself a reason to accept it. Each finding takes one of these paths:

- Accept: make it a follow-on task, handled by the standard per-task workflow
  including Junio's coherence audit. Note its origin with the task
  (`junio-review` or `ada-review`) for the commit counts.
- Reject: note it in your reply to the user, with the reason.
- Out of scope: hold it for post-merge triage.
- Raise a Challenge: take it to the user per the "Challenge" shape. Use this
  when the finding shows an accepted artifact no longer holds, not a fixable
  defect.

A cluster of Junio's coherence findings circling one surface can be the evidence
for a Challenge. It can show the Session Scope was too narrow to reach the root
cause, not just a list of follow-ons.

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

## Step 7.5: Write the PR description

Write the description for the PR you opened in Phase 1
[Step 1.1](phase1.md#step-11-open-the-session-pr), replacing the `WIP`
placeholder. Every follow-on is complete, so the PR's content is final.

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
  non-obvious, with a pointer to the Design comment for the rationale.

Don't sample existing PRs for style. Written contribution rules are real. The
existing PR log is not a style reference.

Mark the body per
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items)
and follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts). After
writing the description, verify that every issue the PR fully resolves is
recognised: run `gh pr view <N> --json closingIssuesReferences` to confirm each
issue appears.

Then write the dream metadata line. PR ready is the first point where every
field is final, including the commit counts, which cover this phase's review
follow-ons. Append it to the PR body, after the Claude Code footer:

```text
<!-- dream:<version> type:<type> req:<n> ca:<n> scope:<n> design:<n> plan:<n> commits:plan=<n>,junio-audit=<n>,grace-read=<n>,junio-review=<n>,ada-review=<n> challenge:<value> autopilot:<value> -->
```

Plugin version from `../../.claude-plugin/plugin.json` relative to the protocol
file. Gate counts are revision rounds per acceptance gate:

- `req`: Requirements Analysis (closing Phase 1)
- `ca`: Code Analysis (closing Phase 2)
- `scope`: Session Scope (closing Phase 3)
- `design`: Phase 4
- `plan`: Phase 5

A revision round is one iteration where the user pushed back before accepting.

Commit counts are one tally per origin, taken from the origin you recorded with
each task at triage. Each task is one commit. `plan` is every accepted Plan
task. The rest are the follow-ons you labelled. They measure the coherence
rework the team's own review caught before handing the PR over:

- `plan`: accepted Plan task
- `junio-audit`: Junio coherence-audit follow-on
- `grace-read`: your own follow-on from checking the commit against the brief
- `junio-review`: Junio PR-review follow-on
- `ada-review`: Ada PR-review follow-on

Post-handoff commits are out of the tally: a user-directed change after PR
ready, and Phase 8 conflict resolution. They are not secondary-review rework.

Challenge value: `no`, or `at-<phase>` for the phase where an accepted Challenge
overturned an artifact. For example: `at-scope` or `at-develop`. Autopilot
value: `no`, or `from-<phase>` for the phase where autopilot first engaged. For
example: `from-input` when set in the session input, or `from-scope` when set
mid-session. If autopilot was turned off and on again, record the earliest
engagement.

## Step 7.6: Mark the PR ready for review

Once all accepted follow-ons from triage are complete, run `gh pr ready <N>`.
Flipping from draft to ready signals to the user that the PR is now worth their
attention. If no findings were accepted, flip immediately.

## Step 7.7: Hand back to the user

Hand back to the user once all comments are addressed. The PR is ready for the
user's acceptance. Phase 8 handles the merge itself.

Under autopilot, don't hand back. Enter the review-and-merge watch instead (see
[Review and merge](../../../agents/Grace.md#review-and-merge)). It carries the
PR through the user's review, merge, or close.

Marking the PR ready hands off the branch, and from here it is frozen (see
[Phase 8: Merge](../protocol.md#phase-8-merge)). In Merge, Collect, and Reflect
a finding that would once have become a follow-on task becomes an issue instead.
You fold no new development into the PR. Resolving merge conflicts is the
exception. That is the merge itself, delegated to Ralph as Phase 8 describes.
Only a user-directed change reopens Develop. Under autopilot, a review with
feedback is that change. You handle it as an explicit reopening, the same as any
Phase 6 task:

- Grace creates a task
- Ralph implements and commits
- Junio audits
- Grace reads and triages

Post any question you can't resolve without the user to the PR as a comment
before you ask in chat. Otherwise the PR looks idle after the review while the
question sits only in chat. Do this the same as
[Step 1.11](phase1.md#step-111-elicit-answers-to-open-questions).

Once the accepted follow-ons are complete, post one response comment. Do this
the same as [Step 7.4](#step-74-post-graces-response-as-a-pr-comment). Leave the
`dream:` metadata line as it is. These commits are post-handoff, so they're out
of its tally (see [Step 7.5](#step-75-write-the-pr-description)).

Absent that direction, the default is freeze.

The freeze stops new code, not updates to the PR's record. If a Challenge is
accepted at Phase 7 or later, still post its superseding comment and edit the PR
description. That records the decision, not development. Any code the Challenge
needs goes through the user-directed reopening above.
