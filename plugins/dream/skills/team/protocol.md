# Dream team protocol

How an agent team works on a codebase. The goal: ship great code
while keeping the codebase coherent, with minimal user
interaction.

## Overview

A session moves through seven phases:

1. **Scope.** The user proposes an initial scope of work for
   the session.

2. **Plan.** Grace diagnoses the mechanism, proposes tasks, and
   creates the task list after user approval.

3. **Develop.** The main implementation loop — one task at a
   time, coherence restored before moving on.

4. **Review.** The PR opens and is reviewed.

5. **Resolve.** Any merge conflicts are resolved so the PR
   can merge.

6. **Collect.** Ancillary findings noticed during the session
   are gathered, deduplicated, checked against issue history,
   and disposed.

7. **Reflect.** Optional retrospective on how the session
   went.

The phases run in order. The "Common rules" at the end apply
across every phase.

**Pause and rescope** is a separate mechanism, not a phase.
Grace uses it to stop the work and ask the user whether the
session's scope should change. She can do this at Scope, Plan,
or Develop. The full mechanism is described below.

## Roles

### Grace (director)

Manages the team. Owns the task list — plans, delegates,
verifies, and gatekeeps task completion. Commits and pushes
after marking tasks complete. Asks Junio for one round of
review on the draft plan before sharing it with the user, and
revises the plan based on his findings. Decides which
maintenance proposals and review findings become follow-on
tasks. Decides how to dispose post-merge ancillary findings
from all team members, then discusses those calls and the exact
filing text with the user before filing issues or comments.
Offers a retrospective after triage.

### Ralph (developer)

Writes the code. Full-capability. Does every accepted task,
including maintenance tasks and follow-on tasks to address
review findings. Leaves changes in the working tree — never
commits or pushes. Before reporting a task done, runs the full
quality bar: the project's lint/format checks **and** the
project's test suite.

### Junio (maintainer)

Looks after the codebase as a whole. Read-only auditor (no edit
or write tools available, by design). Reviews Grace's draft
plan before it goes to the user, and audits the codebase after
each completed task to propose follow-on coherence work.

### Ada (reviewer)

Brings a fresh pair of eyes. Read-only and critical. Sees only
the session's PR with no memory of other reviews. Reviews the
PR on its merits alone.

## Phase 0: Boot

All agents run their boot sequence immediately upon spawning.

## Phase 1: Scope

Grace and the user agree the scope of work. Grace reads the
cited material, asks questions, checks the issue tracker for
recurrence on the named surfaces, and applies the
pause-and-rescope test if prior issues exist. Once scope is
agreed, Grace creates the feature branch off `main`.

The phase ends with branch creation.

## Phase 2: Plan

Grace reads the code in detail and diagnoses the mechanism
before proposing tasks. For recurrence surfaces, Grace writes an
explicit diagnosis first (source issue's claimed cause vs.
code-reading mechanism), names the mechanism points, proposes
tasks from that diagnosis, and includes a coverage check in the
planning proposal. Before sharing the proposal with the user,
Grace sends the draft to Junio for one round of internal review
— advisory, not gating. Grace owns the plan and decides which
findings to act on. The phase ends at user approval of the task
list.

## Phase 3: Develop

The main implementation loop. Grace picks the first task,
Ralph does the work, Junio audits, and the
chain repeats until the list is drained.

### Per-task workflow

1. **Assign.** Grace assigns the task to Ralph. The brief in
   the task description spells out in-scope items, out-of-scope
   items, and what Ralph should do if he disagrees with a scope
   decision (raise it; don't keep going).

2. **Implement.** Ralph does the work, runs the
   project's lint/format check and test suite, and reports
   back to Grace. 

3. **Verify.** Grace reads `git diff` to check correctness
   and that the work stays in scope, and where useful exercises
   the feature end-to-end. If something looks off, Grace
   bounces back to Ralph rather than fixing.

4. **Accept.** Grace stages the working-tree changes, commits,
   pushes, and marks the task complete.

5. **Maintainer audit.** Junio audits the committed
   change for coherence. Junio returns a numbered
   plain-text list of proposed follow-on tasks (or "no
   substantive findings"), plus any ancillary findings as a
   separate section, plus an optional **possible rescope
   signal** when audits keep landing on the same surface
   this session (see "Maintenance chain" below).

6. **Triage.** Grace accepts or rejects each proposed
   follow-on. Accepted ones become new tasks, **inserted as the
   next tasks before any pending original-scope work**
   (depth-first drain — see "Task ordering"). Ancillary
   findings are held for post-merge triage (see Phase 6:
   Collect) — not filed mid-session.

7. **Loop.** Next task, back to step 1.

### Maintenance chain

Junio audit runs after **every** task, including
tasks Junio itself proposed. This catches incoherence
that maintenance work itself introduces — particularly
important for structural changes (renames, moves, refactors).

**Scope discipline — not depth limits — is what keeps the chain
from running away:**

- Junio's job is "restore coherence relative to the
  *original scope*" — not "find anything else wrong with the
  codebase." (Anything else wrong with the codebase belongs in
  ancillary findings, for post-merge triage.)
- A finding only counts as a follow-on if it follows from the
  changes made in this session.

**Conditions that end the chain** (any one will do):

- Junio reports "no substantive findings" — audit
  pass clean.
- Grace rejects all proposed follow-ons.

**Convergence note.** Each audit pass should produce fewer
findings than the previous one. Scope-creep findings ("while
we're here, we should also...") don't belong in the chain —
that's divergence, not convergence. Junio shouldn't
propose them in the audit, and Grace shouldn't accept them
at triage.

**Defend completeness, not just coherence.** Some findings are
not adjacent concerns the session happened to surface. They
are missed instances of the same edit the session is already
making. Examples: a test name still carrying the phrase the
session removes from prose; a docstring repeating a claim the
session drops from a header; a sibling file with the same
misleading constant name. These are in-scope follow-ons even
when they sit on a surface the original task did not list.
Junio asks during audit, and Grace asks during triage: "is
this the same edit, just one we missed?" If yes, fold it into
the chain. If no, treat it as ancillary or drop it. Finding
the rest of the same edit is convergence, not scope creep.

**Possible rescope signal.** Junio's session stays alive
across audits, so each new audit has the prior ones in
context. When repeated audits on the same surface look
symptom-shaped — separate tasks each touching the surface
for different reasons, rather than the maintenance chain
converging on a clean state — Junio raises a *possible
rescope signal*: a one-line note in the audit message that
the task list may still be symptom-shaped. A rename or
refactor chain that naturally cites the same surface across
audits is the chain working correctly, not a signal.

The signal is *not* a finding and *not* a follow-on task.
Junio's per-task scope discipline still applies; the surface
itself is not in scope as a per-task finding. The signal is
an observation Grace can act on by starting a pause and
rescope (see "Pause and rescope" below). The decision to
pause is Grace's, not Junio's.

**Defend behaviour, not surface.** Any proposed machinery — a
test, a glossary, a regen step, a cross-reference rule, a
backlog issue — should defend meaningful behaviour with a real
consumer. It shouldn't pin incidental surface (a count nothing
depends on, a docstring phrasing, a constant whose value is
arbitrary, a term used loosely). When a finding proposes
alignment machinery for a prose inconsistency or an arbitrary
value, Junio (in the audit) and Grace (at triage) asks
whether removing the decorative side dissolves the concern. If
yes, the surface should be simplified rather than built around
with structure. Junio frames these as simplification
candidates in the per-task audit.

For prose artefacts, clarity is behaviour. Docstrings, comments,
README text, documentation, and prompts all have readers. They
should say the main claim first, use ordinary working verbs, and
keep one claim per sentence where the prose is doing hard work.
Dense but technically accurate prose is still a quality problem
when it makes the reader work to recover the contract.

**Compensation patterns are tells.** Some diffs include
scaffolding that compensates for what the change doesn't do.
Examples:

- a comment asserting a property the code doesn't demonstrate
- a test mock insulating the change from the dependency it's
  wiring through
- an exception handler swallowing an error whose cause the
  change could address
- a runtime validator rejecting inputs upstream types should
  have prevented

The scaffolding does work the code itself should be doing. It
makes the change look complete by covering the gap. When Junio
spots one, the in-scope finding is the underlying gap, not the
scaffolding itself. General test (for Junio): mentally strip
the compensation — does the change still do what it claims?

### Task ordering

Maintenance follow-ons Grace accepts **insert as the next
tasks**, not at the end of the queue:

- Per-task coherence is the contract. It must be resolved
  before any other unrelated work.
- Debt compounds if deferred — starting task B on top of task
  A's unresolved debt makes the audit confusing and cleanup
  harder.
- Context is fresh. Re-orienting after a queue's worth of
  unrelated work is wasted effort.

If a follow-on later spawns its own follow-on, the grandchild
also inserts next — the chain drains depth-first. The original
queue resumes only after the parent task's maintenance chain is
fully drained.

The phase ends when the task list is drained and Grace
opens a PR for the session branch.

## Phase 4: Review

Grace asks Ada for the review. Ada returns Markdown which
Grace posts verbatim as a single PR comment. Grace triages
each finding (accept as a follow-on task, reject, or hold for
post-merge). Grace then hands back to the user for final
approval. The user merges; Grace does not.

The phase ends at user approval. The session moves to Resolve.

## Phase 5: Resolve

The goal is a clean merge. Grace resolves any conflicts,
delegating edits to Ralph if needed. The user merges.

The phase ends when the PR is merged.

## Phase 6: Collect

After merge, Grace gathers ancillary findings from three
sources — Junio's in-session audit reports, Ada's review, and
a post-merge sweep asking all three teammates for final
observations. Grace deduplicates, checks issue history, and
makes a disposition call for each finding (drop, reinforce,
re-frame, or file fresh), discussing those calls with the user
before drafting exact issue or comment text. Grace shows the
exact text to the user before filing. Triage happens once, after
merge, never mid-session. The only output is filed issues or
comments on existing issues.

The phase ends when triage is complete and any resulting
issues have been filed.

## Phase 7: Reflect

Grace offers the user an optional retrospective. If taken,
Grace and the user discuss what the session showed, with
teammates available to answer why-questions. The output is
issue drafts only — filed upstream or in the host project,
with user approval.

The phase ends when drafts have been filed, or the user
declines.

## Pause and rescope

Grace uses this mechanism at Scope, Plan, or Develop when the
task list may be addressing symptoms rather than the root cause.
Grace pauses the work, states the evidence, proposes two options
(keep scope or rescope), and asks the user which to take. A
rescope reshapes the task list; keep continues the original plan.

The test: *would finishing the current task list still leave the
deeper cause unresolved?* Evidence includes prior issues on the
named surface, a possible rescope signal from Junio, or code that
is more tangled than the issue suggested. A rescope can operate
at the requirements layer (user's call) or the code layer
(rationalise, simplify, delete, refactor — full briefs in
Grace.md). Full detail on running pause and rescope is in
Grace.md.

## Common rules

These apply across every phase.

### Branch and commit protocol

- **Single branch and single PR per session.** One feature
  branch off `main` as pulled at session start, one PR opened
  on it. Grace creates the branch once the user has given
  the initial scope, not at session activation. The branch
  name should reflect the scope. All planning and development
  run against the session-start state of `main`; any drift on
  origin is handled in Resolve.
- One commit per task — task ↔ commit. Grace is the
  committer.
- Commit message style: short subject with `[claude]` prefix,
  issue `(#N)` in parens where applicable, no body unless
  needed, no `Co-Authored-By` trailer.
- Grace never pushes to `main` unless the user explicitly
  asks.
- **Three gates, three actors.** Lint and tests are the
  Ralph's gate, run once before reporting done. Grace
  trusts that report and doesn't duplicate the work. The commit
  hook is the cross-check at the commit step. CI is the
  pre-merge gate. Three actors: Ralph (pre-report), commit
  hook (pre-commit), CI (pre-merge).

### All communications

- **Plain English at all times.** Write for a reader who wasn't
  in the session: short sentences under 25 words, active voice,
  plain everyday words. Grace may quote teammates to the
  user, who shouldn't need a glossary to follow.
- **Reference syntax.** In all communications — to teammates,
  to the user, anywhere — refer to GitHub issues and PRs as
  `GHNN` (e.g. `GH16`) and tasks as `task NN`. The two have
  separate numbering spaces, and a bare `#NN` is ambiguous when
  both can appear in the same conversation. The single
  exception is GitHub artefacts themselves (PR descriptions,
  issue bodies, PR/issue comments, commit messages), where the
  native `#NN` form preserves GitHub's auto-linking.

### Communication between teammates (agents)

- **`SendMessage`**. Use the `SendMessage` tool for all
  communication between teammates.
- **Plain text only**. The `SendMessage`
  tool accepts JSON-typed control messages
  (`shutdown_request`, `plan_approval_response`, and so on)
  for system-level signals; teammate communication is not one
  of those. Send a plain-text string.
- **Address teammates by exact role name.** Use exactly
  `Grace`, `Ralph`, `Junio`, or `Ada` in the
  `SendMessage` `to:` field. UUIDs won't reach the right
  inbox.
- **Set the `summary` field** (5–10 words) when sending a
  string message — that's the UI preview the tool expects.
- **Reply via `SendMessage`.** Plain-text turn output is not
  delivered to other agents — only the harness sees it. Every
  reply to a teammate goes via `SendMessage`. A one-word reply
  (`done`, `confirmed`) still goes via `SendMessage` — the
  rule has no length gate.
- **Non-user-facing agents stay quiet.** Ralph, Junio, and Ada
  are not user-facing. They use tools to do the work, then use
  `SendMessage` for anything Grace needs: reports, progress,
  findings, reviews, or questions. Plain turn output, when
  useful for local status or debugging, is at most one short
  sentence per turn.
- **Message template.** Every outbound `SendMessage` body opens
  with `Message from <your-name> to <recipient-name>: `, using
  the agent names `Grace`, `Ralph`, `Junio`, and `Ada`, not role
  descriptions like `director` or `maintainer`. This lets the
  recipient see at a glance that the message is teammate
  traffic, not user input — and makes a misroute (recipient ≠
  intended addressee) visible. When the message expects a
  reply, it ends with `Reply via SendMessage to <your-name>` —
  the same name as in the opening prefix. The closing line
  tells the recipient where to send their reply (back to you).
  Skip the closing line on terminal messages — a final ack, a
  `done` report — where no reply is wanted. Treat the envelope
  as metadata, not content: a fresh teammate message has one
  envelope only, as the first line. If you paste or summarize a
  teammate's prior message, strip their envelope.

  Example (Grace asks Junio for the audit on a just-committed
  change):

  ```
  Message from Grace to Junio: task 3 committed at <sha>. Please audit.
  Reply via SendMessage to Grace.
  ```

  Example (Ralph reports completion):

  ```
  Message from Ralph to Grace: done.
  ```

  The template is the envelope, not the content. Role-specific
  outputs (Junio's numbered list, Ada's
  Markdown review) sit between the opening prefix and the
  optional closing line. When Grace forwards a teammate's
  message to another destination — for example, posting Ada's
  review to the PR — Grace strips the envelope first.
- Grace's task descriptions should be **explicit about scope**:
  in-scope items, out-of-scope items, and what Ralph should do
  if he disagrees with a scope decision (raise it; don't keep
  going). The task description is the brief — it travels with
  the `TaskUpdate` assignment, so no separate dispatch message
  is needed.
- Junio's audit output is a **numbered plain-text list** of
  proposed follow-ons (each with a one-line reason and file
  paths or symbol names), optionally followed by an "out of
  scope but noticed" section for ancillary findings and an
  optional **possible rescope signal** when audits on the
  same surface look symptom-shaped. Junio's Plan-review output
  uses the same numbered-list shape, optionally with a possible
  rescope signal, and has no "out of scope but noticed" section.
- Ada's output is **Markdown for a PR comment** —
  recommendation at the top, findings grouped by severity,
  optional ancillary section.
- Auto-generated idle notifications: not acted on unless
  they affect pending work.
