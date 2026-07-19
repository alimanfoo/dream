# Phase 5: Develop

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

This is the main implementation loop. You pick the first task, Ralph does the
work, and Junio audits. The chain repeats until the list is drained.

## Opening sequence

Before the per-task loop runs, one setup step.

### Step 5.1: Create the shared task list

Issue the `TaskCreate` calls for the accepted task list.

## Per-task workflow

### Step 5.2: Assign

Issue one `TaskUpdate(owner=Ralph, status=in_progress)` call. It records the
assignment, wakes Ralph, and carries the task description as the brief. Don't
add a `SendMessage`. A second call lands as a duplicate dispatch, and Ralph
reads it as "you've already assigned this."

Write the brief with three parts: the goal, the criterion that selects the work,
and the raise channel. Examples illustrate the criterion. They are scaffold, not
the work. Ralph applies the criterion fresh and raises anything he disagrees
with, anything ambiguous, or any surface this change makes adjacent that the
criterion doesn't cover. See the [same-edit test](../protocol.md#same-edit-test)
in the coherence chain.

The tool descriptions mislead. `SendMessage`'s own example shows
`{"to": "researcher", "summary": "assign task 1", ...}`. That example is the
source of the duplicate-dispatch instinct. Ignore it. `TaskUpdate` reads as pure
bookkeeping and never names the wake-up behaviour. It is the wake-up signal
here.

### Step 5.3: Implement

Ralph does the work, runs the tests, commits, and pushes, then reports back via
`SendMessage` with the commit SHA. That `SendMessage` is the only completion
channel, not the commit landing. Wait for that message by going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

### Step 5.4: Read and request the audit

Ask Junio for the coherence audit. Send him the commit SHA, signing off
`From Grace. RSVP via SendMessage.` Wait for his numbered list (or "no
substantive findings") by going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)).

His audit may also raise a **challenge**. For example, repeated audits circling
the same surface suggest the design is too narrow to reach the root cause.

Read the committed change yourself while Junio audits. Check it against the
brief you wrote: did the commit deliver the goal and the criterion you set? That
is distinct from Junio's audit of how the change fits the codebase. This is not
a re-run of Ralph's gate. Lint and tests are green by the time you're reading.
Read `git diff` for the change and Ralph's message for what the diff can't show:
deviations from the brief, things he noticed. Where useful, exercise the feature
end to end. Write a one-line verdict in your turn output (`delivered`, or
`gap at …`). A gap is a correction follow-on at triage, not a fix you make
yourself.

Mark the task complete (`TaskUpdate status=completed`).

### Step 5.5: Triage findings

Triage Junio's findings together with any gap from your own read. Accept or
reject each on its merits, recording a one-line reason for the call. Accepted
ones become new tasks, **inserted as the next tasks before any pending
original-scope work** (depth-first drain). A correction for a gap you found is
one such follow-on. Note the origin with each task as you accept it
(`junio-audit`, or `grace-read` for a correction from your own read). These feed
the Phase 6 commit counts. Hold ancillary findings for post-merge triage. Never
file them mid-session.

Before treating a finding as an ancillary finding, ask: **is this the same edit,
one we missed, or one the session has now made adjacent?** If yes, accept it as
an in-scope follow-on even when the original task did not list that surface. An
in-session antecedent flips a borderline call toward in-scope. The session
created the relevance.

When a finding proposes adding or expanding a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention,
apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding.

When the coherence audit raises a **challenge**, assess whether an accepted
artifact really no longer holds. If it does, take it to the user (accept or
reject) following the "challenge" shape. If not, continue triage as normal.

### Step 5.6: Loop

Next task, back to [Step 5.2](#step-52-assign).

The phase ends when the task list drains. Grace writes the PR description later,
at PR ready ([Step 6.5](phase6.md#step-65-write-the-pr-description)), once every
review follow-on is final.
