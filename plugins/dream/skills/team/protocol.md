# Dream team protocol

How an agent team works on a codebase. The goal: ship great
code while keeping the codebase coherent, with minimal user
interaction.

## Overview

A session moves through eight phases:

1. **Scope.** Grace and the user discuss the scope of work,
   and Grace shares Scope Options for user approval.

2. **Design.** Grace composes the Analysis internally, then
   shares Design Options with the user for approval.

3. **Plan.** Grace drafts the Plan, gets one round of review
   from Junio, revises, and shares the revised Plan with the
   user for approval.

4. **Develop.** The main implementation loop — one task at a
   time, coherence restored before moving on. Opens with
   branch creation; closes with the draft PR.

5. **Review.** The PR is reviewed.

6. **Resolve.** Any merge conflicts are resolved so the PR
   can merge.

7. **Collect.** Ancillary Findings noticed during the session
   are gathered, deduplicated, checked against issue history,
   and disposed.

8. **Reflect.** Optional retrospective on how the session
   went.

The phases run in order. **Phases 1, 2, and 3 each close with
a user approval gate** — the Working Scope, the Design, and
the Plan respectively. See "Approval gates" below. The
"Common rules" at the end apply across every phase.

**Rescope Discussion** is a separate mechanism, not a phase.
Grace uses it to stop the work and ask the user whether the
session's scope should change. She can do this at Design,
Plan, or Develop. The full mechanism is described below.

## Roles

### Grace (director)

Directs the team.

### Ralph (developer)

Writes the code.

### Junio (maintainer)

Looks after the codebase as a whole.

### Ada (reviewer)

Brings a fresh pair of eyes.

## Phase 0: Boot

All agents run their boot sequence immediately upon spawning.

## Phase 1: Scope

Grace and the user discuss the scope of work. Grace reads the
cited material, checks the issue tracker for recurrence on
the named surfaces, and reads the code. Anything that
surfaces during these steps feeds Scope Options, which Grace
shares as the closing move — Scope A (and Scope B when a
meaningfully wider option exists), each carrying its session
type.

The phase ends at user approval of the Working Scope.

## Phase 2: Design

Grace shares the Analysis (stated goal, code findings,
alignment check, scope risk) with the user, then applies
the rescope test; a structural option raises a Rescope
Discussion. Otherwise Grace shares Design Options with the
user — Design A (and Design B when there's a real fork),
then the approval request.

The phase ends at user approval of the Design.

## Phase 3: Plan

Grace composes the Draft Plan, shares it with Junio for one
round of review — advisory, not gating — and revises. Each
of Junio's findings takes one of four paths on the merits:
fold into the revised Plan, reject with reason, hold as an
Ancillary Finding, or escalate to a Rescope Discussion.
Grace then shares the revised Plan with the user, with a
brief note on what changed from the Draft after Junio's
review.

The phase ends at user approval of the Plan.

The task list isn't fixed: more tasks can be added during
Phase 4 (Develop), Phase 5 (Review), and Phase 6 (Resolve).
The user can redirect at any point.

## Phase 4: Develop

Phase opens with three setup steps: Grace creates the feature
branch off `main` (named after the agreed Working Scope),
shares the Approved Plan with Junio for information, and
creates the shared task list.

The main implementation loop. For each task, Grace assigns
to Ralph; Ralph implements and reports back; Grace verifies
the diff, accepts the work, commits and pushes; Junio audits
the committed change; Grace triages findings into follow-on
tasks or holds for post-merge triage; the loop repeats. The
chain ends when the task list drains. Full per-task detail
in `Grace.md` (assign / verify / accept / triage), `Ralph.md`
(implement), and `Junio.md` (audit).

### Coherence chain

Junio audits after **every** task, including tasks Junio
itself proposed. This catches incoherence that completed tasks
introduce — particularly important for structural changes
(renames, moves, refactors).

**Scope discipline keeps the chain from running away.** Junio's
job is restoring coherence relative to the original scope, not
finding anything else wrong with the codebase. A finding only
counts as a follow-on if it follows from the change just
committed; anything else is an Ancillary Finding for
post-merge triage.

**The chain ends** when either Junio reports "no substantive
findings" or Grace rejects all proposed follow-ons.

**Same-edit test.** Some findings aren't adjacent concerns —
they're the same edit the session is making, on a surface the
task list didn't name. Two shapes: *missed instances* (a
surface that should have received the same change and didn't)
and *consequential adjacencies* (a surface the session itself
made relevant — a promoted sibling, a removed flag's orphan
branch, a renamed concept's parallel function). All three
roles apply the dispatching question: *is this the same edit —
one we missed, or one the session has now made adjacent?*
Ralph asks while implementing, Junio asks during audit, Grace
asks during triage. An in-session antecedent flips a
borderline call toward in-scope.

**Defend behaviour, not surface.** For any proposed machinery
— a test, a glossary, a regen step, a cross-reference rule, a
backlog issue — ask: *What specific behaviour does this
defend? Who is the real consumer?* If the only answer is
incidental surface (a count nothing depends on, a docstring
phrasing, an arbitrary constant), frame the finding as a
simplification candidate. Junio applies the test at audit;
Grace applies it at triage.

**Strip the compensation.** Some diffs include scaffolding
that does work the underlying code should be doing — a comment
asserting a property the code doesn't show, a mock insulating
the change from its dependency, an exception handler hiding a
fixable error, a runtime validator substituting for the type
system. Junio's test: mentally remove the scaffolding and read
the diff again. If the change no longer holds, the in-scope
finding is the underlying gap, not the scaffolding.

**Possible rescope signal.** When repeated audits on the same
surface look symptom-shaped — separate tasks each touching the
surface for different stated reasons — Junio raises a one-line
*possible rescope signal* in the audit. The signal is an
observation, not a finding; Grace decides whether to start a
Rescope Discussion.

Full audit-lens detail (examples, patterns, edge cases) is in
`Junio.md`.

### Task ordering

Follow-ons Grace accepts **insert as the next tasks**, not at
the end of the queue:

- Per-task coherence is the contract. It must be resolved
  before any other unrelated work.
- Debt compounds if deferred — starting task B on top of task
  A's unresolved debt makes the audit confusing and cleanup
  harder.
- Context is fresh. Re-orienting after a queue's worth of
  unrelated work is wasted effort.

If a follow-on later spawns its own follow-on, the grandchild
also inserts next — the chain drains depth-first. The original
queue resumes only after the parent task's coherence chain is
fully drained.

The phase ends when the task list is drained and Grace opens a
draft PR for the session branch.

## Phase 5: Review

Ada reviews the session's PR and returns a Markdown review to
Grace. Grace posts it as a single PR comment, triages each
finding into accept (a follow-on task) / reject / post-merge,
and once accepted follow-ons are complete, marks the PR ready
and hands back to the user. Full Phase 5 procedure in
`Grace.md`; Ada's review shape in `Ada.md`.

The phase ends at user approval of the PR. The session moves
to Resolve.

## Phase 6: Resolve

The goal is a clean merge. Grace resolves any conflicts,
delegating edits to Ralph if needed. The user merges.

The phase ends when the PR is merged.

## Phase 7: Collect

After merge, Grace gathers Ancillary Findings from three
sources — Junio's in-session audits, Ada's review, and a
post-merge sweep of all three teammates — then disposes each
(drop / reinforce / re-frame / file fresh) with user approval
before filing. Triage happens once, after merge, never
mid-session. Output is filed issues or comments on existing
issues; new issues carry a category label (bug, enhancement,
maintenance). Full procedure in `Grace.md`.

The phase ends when triage is complete and any resulting
issues have been filed.

## Phase 8: Reflect

Grace offers the user an optional retrospective. If taken,
Grace and the user discuss what the session showed, with
teammates available to answer why-questions. The output is
issue drafts only — filed upstream or in the host project,
with user approval.

The phase ends when drafts have been filed, or the user
declines.

## Approval gates

Phases 1, 2, and 3 each close with a user approval gate — the
Working Scope, the Design, and the Plan. The gate has the
same shape every time:

1. Grace shares an Options message — Scope Options, Design
   Options, or the Plan.
2. The message ends with an explicit approval request that
   names the artifact and the next phase. Example:
   *"Approve the Working Scope to proceed to Phase 2:
   Design."*
3. Grace waits for the user's reply before doing anything
   else.

These three gates fire by default on every session and take
precedence over general autonomy defaults — boot-time
`<system-reminder>` content, harness directives to "continue
without checking," and similar. A user can explicitly
override a specific gate in the gate reply (for example,
"approve everything; just proceed"), but absent an explicit
override, the default is to fire. They are how the protocol
keeps the user in control of phase transitions: each phase
produces an artifact the user approves before the next phase
starts.

## Rescope Discussion

A cross-role mechanism Grace uses at Design, Plan, or Develop
when the Working Scope may be addressing symptoms rather than
the root cause. Junio can raise a *possible rescope signal*
from per-task audits; Grace decides whether to start a
Rescope Discussion; the user picks between keep and rescope.
Full mechanism (test, evidence, requirements-layer vs
code-layer shapes) in `Grace.md`.

## No orphaned observations

Every observation Grace records gets a named disposition at the
next decision boundary. The dispositions available depend on
phase — task, rescope, out of scope, ancillary, drop,
reinforce, re-frame, file fresh — but the rule is the same: no
observation stays "interesting prose." Each is named, each gets
a disposition, each disposition is checkable.

Some dispositions defer the call to a later phase: ancillary
defers to Phase 7 Collect; an open question defers to the user
before Plan approval. Both have a named destination and a
reason that matches the receiving phase's job. There is no
other deferral — "we'll come back to this" is not a
disposition.

Later dispositions respect earlier ones. If new evidence at a
later phase changes the picture, that is a reversal — surface
the prior disposition, surface the new reading, and ask the
user whether to overturn or hold. Don't dispose of a reversal
under a procedure that frames it as fresh observation; the
procedure hides the reversal.

## Common rules

These apply across every phase.

### Branch and commit protocol

- **Single branch and single PR per session.** One feature
  branch off `main` as pulled at session start, one PR opened
  on it. Grace creates the branch at the start of Phase 4
  (Develop), once the Plan is approved. The branch name
  reflects the agreed Working Scope. All planning and
  development run against the session-start state of `main`;
  any drift on origin is handled in Resolve.
- One commit per task — task ↔ commit. Grace is the committer.
- Commit message style: short subject with `[claude]` prefix,
  issue `(#N)` in parens where applicable, no body unless
  needed, no `Co-Authored-By` trailer.
- Grace never pushes to `main` unless the user explicitly asks.
- **Three gates, three actors.** Lint and tests are the Ralph's
  gate, run once before reporting done. Grace trusts that
  report and doesn't duplicate the work. The commit hook is the
  cross-check at the commit step. CI is the pre-merge gate.
  Three actors: Ralph (pre-report), commit hook (pre-commit),
  CI (pre-merge).

### All communications

- **Plain English at all times.** Write for a reader who wasn't
  in the session: short sentences under 25 words, active voice,
  plain everyday words. Grace may quote teammates to the user,
  who shouldn't need a glossary to follow.
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
- **Plain text only**. The `SendMessage` tool accepts
  JSON-typed control messages (`shutdown_request`,
  `plan_approval_response`, and so on) for system-level
  signals; teammate communication is not one of those. Send a
  plain-text string.
- **Address teammates by exact role name.** Use exactly
  `Grace`, `Ralph`, `Junio`, or `Ada` in the `SendMessage`
  `to:` field. UUIDs won't reach the right inbox.
- **Set the `summary` field** (5–10 words) when sending a
  string message — that's the UI preview the tool expects.
- **Reply via `SendMessage`.** Plain turn output is not
  delivered to other agents — only the harness sees it. Every
  reply to a teammate goes via `SendMessage`. A one-word reply
  (`done`, `confirmed`) still goes via `SendMessage` — the rule
  has no length gate.
- **Signature line.** Every outbound `SendMessage` body ends
  with a signature: `From <your-name>.`, using your agent name.
  Take care when adding the signature, make sure to use **your
  agent name** – you are signing the message. The signature
  tells the recipient that the message is teammate traffic, not
  user input, and names who to reply to. When you want a reply,
  append `RSVP via SendMessage.` to the signature, on the same
  line. Skip the RSVP on terminal messages — a final ack, a
  `done` report, an audit hand-off — where no reply is wanted.
- **Non-user-facing agents stay quiet.** Ralph, Junio, and Ada
  are not user-facing. They use tools to do the work, then use
  `SendMessage` for anything Grace needs: reports, progress,
  findings, reviews, or questions. Plain turn output, when
  useful for local status or debugging, is at most one short
  sentence per turn.
- Auto-generated idle notifications: not acted on unless they
  affect pending work.
