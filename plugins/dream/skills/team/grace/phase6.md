# Phase 6: Develop

Write every turn output, message and artefact in this phase to the writing style
guide ([`writing-style.md`](../writing-style.md)).

The main implementation loop. After one setup step, you pick the first task,
Ralph does the work, Junio audits, and the chain repeats until the list is
drained. The session branch and draft PR already exist. You created them at
requirements acceptance (Phase 1).

## Opening sequence

Before the per-task loop runs, one setup step.

### Step 6.1: Create the shared task list

Issue the `TaskCreate` calls for the accepted task list.

## Per-task workflow

### Step 6.2: Assign

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

### Step 6.3: Implement

Ralph does the work, runs the project's quality checks, and reports back via
`SendMessage`. You wait. That `SendMessage` is the only completion channel.
Don't poll the working tree or the task list. The message is the signal.

### Step 6.4: Verify

Read their message together with `git diff`. The message carries any audit
content, deviations from the brief, or things they noticed. The diff carries the
change. Where useful, exercise the feature end to end. Don't re-run lint or
tests. Those are Ralph's gate, green by the time you're reading. If something
looks off, bounce back rather than fixing.

### Step 6.5: Commit

Re-diff before staging. The working tree is live between verify and commit. Any
changes in that window land silently if you stage on the earlier read. Then
`TaskUpdate status=completed`, stage Ralph's changes, commit, and push.

### Step 6.6: Coherence audit

Send Junio a message asking for the coherence audit on the just-committed
change. Sign off per "Communication between teammates (agents)":
`From Grace. RSVP via SendMessage.` Wait for their numbered list (or "no
substantive findings"). The coherence audit may also raise a **Challenge**, for
example when repeated coherence audits circle the same surface, suggesting the
Session Scope is too narrow to reach the root cause (see
[Step 6.7](#step-67-triage-findings)).

### Step 6.7: Triage findings

Accept or reject each proposed follow-on on its merits, recording a one-line
reason for the call. Accepted ones become new tasks, **inserted as the next
tasks before any pending original-scope work** (depth-first drain). Hold
Ancillary Findings for post-merge triage. Never file them mid-session.

Before treating a finding as an Ancillary Finding, ask: **is this the same edit,
one we missed, or one the session has now made adjacent?** If yes, accept it as
an in-scope follow-on even when the original task did not list that surface. An
in-session antecedent flips a borderline call toward in-scope. The session
created the relevance.

When a finding proposes adding or expanding a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention,
apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding.

When the coherence audit raises a **Challenge**, assess whether an accepted
artifact really no longer holds. If it does, take it to the user (accept or
reject) following the "Challenge" shape. If not, continue triage as normal.

### Step 6.8: Loop

Next task, back to [Step 6.2](#step-62-assign).

## Finalize the PR

At the end of Develop, after all in-session tasks are complete and the branch
has been pushed, finalize the PR you opened back in Phase 1 (see
[Step 1.12](phase1.md#step-112-open-the-draft-pr)). The label, the closing
keywords, and the body's requirements analysis were all set at PR-open.
Finalizing means two things: bring the description to its final accepted state,
and append the dream metadata line.

**Final accepted state.** If the requirements were revised after the PR opened
(through a Challenge, say), edit the description so it shows the final accepted
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
