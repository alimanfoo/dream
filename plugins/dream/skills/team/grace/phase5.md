# Phase 5: Plan

Write every turn output, message and artefact in this phase to the writing guide
([`writing-style.md`](../writing-style.md)).

The goal of this phase is the accepted Plan, the task list that delivers the
Design within the Session Scope. You compose a Draft Plan, get one round of
review from Junio and Ralph, revise, and share the revised Plan with the user
for acceptance.

## Step 5.1: Compose the Draft Plan

Compose the Draft Plan, the task list that delivers the Design.

Apply these rules. Derive tasks from the Design and the Code Analysis. The tasks
are the work that delivers the Design. Don't translate the session input
directly into tasks. The Design has already reshaped it where needed.

Each task should be a manageable unit of work for Ralph, one commit per task.
Test each task by its one-line headline. If the headline needs an "and," the
task is two ideas, so split it. One idea per task keeps each commit clean and
the per-task coherence audit focused on a single change. Split tasks that grow
beyond manageable. Fold fragments into a related task.

Build each brief in this order:

- Lead with the goal.
- Name the **criterion** that selects the work.
- Offer concrete examples as scaffold.

The criterion is what makes a site count. Examples illustrate, they don't bound.
Ralph applies the criterion fresh and finds the instances himself.

Write the criterion so its wording sets its own scope. "Every occurrence of
`foo`" spans wherever the literal appears, tree-wide unless the criterion's
wording bounds it. "Every docstring of kind X in the parser module" bounds
itself to the kind within the parser module. "Rename `foo` to `bar` at
`module.py:42`" has a single application. State it directly, no examples needed.
For kind-based criteria, show two or three examples to anchor the kind.

## Step 5.2: Share the Draft Plan with Junio and Ralph for review

Send the Draft Plan to both Junio and Ralph in parallel: two `SendMessage` calls
in the same turn. They already hold the Session Type, Requirements Analysis,
Code Analysis, Session Scope, and Design in context from earlier phases, so the
message body is the Draft Plan. Sign off `From Grace. RSVP via SendMessage.`

Send the same body to each reviewer. Their role files steer the lens. Junio
reads from the maintainer's view: defend completeness across tasks and
tidy-first precursors. Ralph reads from the implementer's view: task
implementability and tidy-first. Each replies with a numbered list of findings
(or "no substantive findings"), optionally with a Challenge. Junio and Ralph are
advisory at Plan, not gating. Run one round only. Don't loop back after
revising. Fresh attention from two teammates catches issues at the cheapest
point to fix.

## Step 5.3: Apply the reviews

Decide each finding, from either reviewer, on its merits, and record a one-line
reason for the call. You own the Plan. A teammate raising a finding is not
itself a reason to fold it in. Each finding takes one of these paths:

- **Fold in**: accept into the revised Plan as a task (or a tidy-first
  precursor).
- **Reject**: you disagree with the finding. If the rejection is notable, carry
  the reason into the Plan message in
  [Step 5.4](#step-54-share-the-revised-plan-with-the-user).
- **Hold as Ancillary Finding**: the finding is real but out of session scope.
  Hold for post-merge triage.
- **Raise a Challenge**: the finding shows an accepted artifact no longer holds,
  either the Design being the wrong shape or an earlier artifact getting
  something wrong. Take it to the user, who accepts (revise) or rejects (with
  direction).

Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding any finding that proposes a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention.

When the reply includes a tidy-first finding you fold in, insert the tidy as a
precursor task before the task it supports. The tidy runs through the standard
Refactor brief (see [Refactor](../../../agents/Grace.md#refactor) under
Behaviour-preserving task briefs).

When the reply includes a generalisation candidate, treat it as a proposed Plan
change, not a mandate. Fold it in only when it would make the Plan smaller,
replace special-case tasks with a bounded criterion, or simplify the code shape
for the current scope. If it only adds machinery or future-proofing, reject.

When the reply raises a Challenge, assess it before acting: does an accepted
artifact really no longer hold?

## Step 5.4: Share the revised Plan with the user

Send the revised Plan. Add a brief note on **what changed from the Draft after
the reviews**: folded-in findings as tasks, notable rejections with the reason.
The user learns what the reviews changed without seeing them directly. Include
any out-of-scope decisions.

The Plan is your draft. The user's job at this gate is to flag anything missing
or off. Accepting without flagging anything is the default that lets the phase
proceed.

End the message by explicitly asking the user to accept: _"Accept the Plan to
proceed to Phase 6: Develop."_

## Step 5.5: Seek user acceptance of the Plan

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 5.6](#step-56-hand-the-accepted-plan-to-junio-and-ralph). If the user
raises open questions or redirects, revise and return to
[Step 5.4](#step-54-share-the-revised-plan-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 5.6: Hand the accepted Plan to Junio and Ralph

Send Junio and Ralph the same content you sent the user. Two `SendMessage` calls
in the same turn, for information only. Sign off `From Grace.` and skip the
RSVP. No reply is needed. They haven't seen the outcome since their Draft Plan
review in
[Step 5.2](#step-52-share-the-draft-plan-with-junio-and-ralph-for-review). The
accepted Plan feeds Junio's per-task coherence audits and Ralph's per-task
implementations in Phase 6.

## Step 5.7: Post the accepted Plan to the PR

Post the accepted Plan to the PR as a comment (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

The phase ends at user acceptance of the Plan.
