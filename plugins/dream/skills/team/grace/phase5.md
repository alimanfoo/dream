# Phase 5: Develop

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

This is the main implementation loop. You pick the first task, Ralph does the
work, and Junio audits. The chain repeats until the list is drained.

## Opening sequence

Before the per-task loop runs, one setup step.

### Step 5.1: Create the shared task list

Create the task list from the accepted plan, one `TaskCreate` call per task.

## Per-task workflow

### Step 5.2: Assign

Issue one `TaskUpdate(owner=Ralph, status=in_progress)` call. It records the
assignment, wakes Ralph, and carries the task description as the brief. Don't
add a `SendMessage`. A second call lands as a duplicate dispatch, and Ralph
reads it as "you've already assigned this."

Write the brief with the goal and the criterion that selects the work. Examples
illustrate the criterion. They are scaffold, not the work.

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

### Step 5.4: Verify delivery

Read the committed change yourself. Check it against the brief you wrote: did
the commit deliver the goal and the criterion you set? This is not a re-run of
Ralph's gate. Lint and tests are green by the time you're reading. Read
`git diff` for the change and Ralph's message for what the diff can't show.
Where useful, exercise the feature end to end. Write a one-line verdict in your
turn output (`delivered`, or `gap at …`).

On a gap, leave the task in progress and send Ralph one message naming what is
missing. He makes a second commit on the same task. Wait for his report by going
idle (see [Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)),
then verify again.

Once the task delivers, mark it complete (`TaskUpdate status=completed`).

### Step 5.5: Request the audit

Ask Junio for the coherence audit. Send him every commit SHA on the task, in
order, closing with `Reply via SendMessage.` Wait for his numbered list (or "no
substantive findings") by going idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)). His audit
of how the change fits the codebase is distinct from your own read against the
brief.

### Step 5.6: Triage findings

Triage Junio's findings. Accept or reject each on its merits, weighed against
the `/dream:coherent-coding` principles, recording a one-line reason for the
call. Accepted ones become new tasks, **inserted as the next tasks before any
pending original-scope work**. Hold ancillary findings for post-merge triage.
Never file them mid-session.

Before treating a finding as an ancillary finding, ask: **is this the same edit,
one we missed, or one the session has now made adjacent?** If yes, accept it as
an in-scope follow-on even when the original task did not list that surface. An
in-session antecedent flips a borderline call toward in-scope. The session
created the relevance.

If a finding proposes a docstring, comment, or section-header to express a
contract, invariant, precondition, or convention, apply the
[code-shape-first check](../../../agents/Grace.md#code-shape-first-check) to it.

When the coherence audit raises a **challenge**, assess whether an accepted
artifact really no longer holds. If it does, take it to the user (accept or
reject) following the "challenge" shape. If not, continue triage as normal.

### Step 5.7: Loop

Next task, back to [Step 5.2](#step-52-assign).

The phase ends when the task list drains.
