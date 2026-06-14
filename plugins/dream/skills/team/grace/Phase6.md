# Phase 6: Develop

The main implementation loop. After two setup steps, you pick the first task,
Ralph does the work, Junio audits, and the chain repeats until the list is
drained. The session branch and draft PR already exist — you created them at
requirements acceptance (Phase 1).

## Opening sequence

Before the per-task loop runs, two setup steps.

### Step 6.1: Share the accepted Plan with Junio and Ralph for information

Send Junio and Ralph the same content you sent the user. Two `SendMessage` calls
in the same turn, for information only. Sign off `From Grace.` and skip the
RSVP; no reply is expected. They haven't seen the outcome since their Draft Plan
review in
[Step 5.3](Phase5.md#step-53-share-the-draft-plan-with-junio-and-ralph-for-review).
The accepted Plan feeds Junio's per-task coherence audits and Ralph's per-task
implementations below.

### Step 6.2: Create the shared task list

Issue the `TaskCreate` calls for the accepted task list.

## Per-task workflow

### Step 6.3: Assign

Issue one `TaskUpdate(owner=Ralph, status=in_progress)` call. It records the
assignment, wakes Ralph, and carries the task description as the brief. Don't
add a `SendMessage`; a second call lands as a duplicate dispatch and Ralph reads
it as "you've already assigned this."

Write the brief with three parts: the goal, the criterion that selects the work,
and the raise channel. Examples illustrate the criterion; they are scaffold, not
the work. Ralph applies the criterion fresh and raises anything he disagrees
with, anything ambiguous, or any surface this change makes adjacent that the
criterion doesn't cover — see the
[same-edit test](../protocol.md#same-edit-test) in the coherence chain.

The tool descriptions mislead. `SendMessage`'s own example shows
`{"to": "researcher", "summary": "assign task 1", ...}` — that example is the
source of the duplicate-dispatch instinct; ignore it. `TaskUpdate` reads as pure
bookkeeping and never names the wake-up behaviour. It is the wake-up signal
here.

### Step 6.4: Implement

Ralph does the work, runs the project's quality checks, and reports back via
`SendMessage`. You wait — that `SendMessage` is the only completion channel.
Don't poll the working tree or the task list; the message is the signal.

### Step 6.5: Verify

Read their message together with `git diff`: the message carries any audit
content, deviations from the brief, or things they noticed; the diff carries the
change. Where useful, exercise the feature end-to-end. Don't re-run lint or
tests — those are Ralph's gate, green by the time you're reading. If something
looks off, bounce back rather than fixing.

### Step 6.6: Commit

Re-diff before staging. The working tree is live between verify and commit — any
changes in that window land silently if you stage on the earlier read. Then
`TaskUpdate status=completed`, stage Ralph's changes, commit, and push.

### Step 6.7: Coherence audit

Send Junio a message asking for the coherence audit on the just-committed
change. Sign off per "Communication between teammates (agents)" below:
`From Grace. RSVP via SendMessage.` Wait for their numbered list (or "no
substantive findings"). The coherence audit may also raise a **Challenge** — for
instance when repeated coherence audits circle the same surface, suggesting the
Session Scope is too narrow to reach the root cause (see
[Step 6.8](#step-68-triage-findings)).

### Step 6.8: Triage findings

Accept or reject each proposed follow-on on its merits, recording a one-line
reason for the call. Accepted ones become new tasks, **inserted as the next
tasks before any pending original-scope work** (depth-first drain). Hold
Ancillary Findings for post-merge triage — never filed mid-session.

Before treating a finding as an Ancillary Finding, ask: **is this the same edit
— one we missed, or one the session has now made adjacent?** If yes, accept it
as an in-scope follow-on even when the original task did not list that surface.
An in-session antecedent flips a borderline call toward in-scope: the session
created the relevance, which is signal, not noise. The same edit on a wider
surface completes the current change; it is not scope creep.

When a finding proposes adding or expanding a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention,
apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding.

When the coherence audit raises a **Challenge**, assess it: does an accepted
artifact really no longer hold? If it does, take it to the user (accept or
reject) following the "Challenge" shape below. If not, continue triage as
normal.

### Step 6.9: Loop

Next task, back to [Step 6.3](#step-63-assign).

## Finalize the PR

At the end of Develop, after all in-session tasks are complete and the branch
has been pushed, finalize the PR you opened back in Phase 1 (see
[Step 1.12](Phase1.md#step-112-open-the-draft-pr)). The label, the closing
keywords, and the body's requirements analysis were all set at PR-open.
Finalizing means two things: bring the description to its final accepted state,
and append the dream metadata line.

**Final accepted state.** If the requirements were revised after the PR opened —
through a Challenge, say — edit the description so it shows the final accepted
requirements, not the state at PR-open.

**Append a dream metadata line to the PR body, after the Claude Code footer:**

```text
<!-- dream:<version> type:<type> req:<n> ca:<n> scope:<n> design:<n> plan:<n> challenge:<value> autopilot:<value> -->
```

Plugin version from `../../.claude-plugin/plugin.json` relative to the protocol
file. Gate counts are revision rounds per acceptance gate: `req` is Requirements
Analysis (closing Phase 1), `ca` is Code Analysis (closing Phase 2), `scope` is
Session Scope (closing Phase 3), `design` is Phase 4, `plan` is Phase 5. A
revision round is one iteration where the user pushed back before accepting.
Challenge value: `no`, or `at-<phase>` for the phase where an accepted Challenge
overturned an artifact (for example `at-scope` or `at-develop`). Autopilot
value: `no`, or `from-<phase>` for the phase where autopilot first engaged (for
example `from-input` when set in the session input, or `from-scope` when set
mid-session).
