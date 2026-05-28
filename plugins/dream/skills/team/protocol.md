# Dream team protocol

How an agent team works on a codebase. The goal: deliver great
code while keeping the codebase coherent, with minimal user input.

## Overview

A session moves through ten phases:

1. **Requirements.** Grace reads the cited material and the
   code with a consumer lens, then shares the Requirements
   Analysis — consumers, use cases, non-goals, open
   questions — with the user for acceptance.

2. **Code Analysis.** Grace reads the code with a structural
   lens — mechanism, layers, siblings, patterns — and shares
   the Code Analysis with the user for acceptance.

3. **Scope.** Grace drafts the Scope Options, gets one round
   of review from Junio and Ralph, revises, and shares the
   revised Scope Options with the user for acceptance.

4. **Design.** Grace drafts the Proposed Design, gets one
   round of review from Junio and Ralph, revises, and shares
   the revised Design Options — the Proposed Design and any
   Alternative Designs — with the user for acceptance.

5. **Plan.** Grace drafts the Plan, gets one round of review
   from Junio and Ralph, revises, and shares the revised Plan
   with the user for acceptance.

6. **Develop.** The main implementation loop — one task at a
   time, coherence restored before moving on. Opens with
   branch creation; closes with the draft PR.

7. **Review.** The PR is reviewed.

8. **Merge.** The user merges the PR. Any conflicts are
   resolved first.

9. **Collect.** Ancillary Findings noticed during the session
   are gathered, deduplicated, checked against issue history,
   and decided.

10. **Reflect.** Optional retrospective on how the session
    went.

The phases run in order.

Within a phase, steps run sequentially. Grace completes each
step, then moves to the next. Some steps explicitly call for
waiting — acceptance gates, questions to the user, teammate
replies via `SendMessage`. Other steps complete and Grace
moves on without pausing.

**User acceptance gates run by default** — the Requirements
Analysis (closing Phase 1), the Code Analysis (closing Phase 2),
the Working Scope (closing Phase 3), the Design (closing Phase
4), and the Plan (closing Phase 5). See "Acceptance gates" below.
The "Common rules" at the end apply across every phase.

**Challenge** is a separate mechanism, not a phase. A
teammate raises one when the work surfaces something new
that breaks an accepted artifact — the Requirements
Analysis, Code Analysis, Working Scope, Design, or Plan.
Grace takes a real Challenge to the user, who accepts it
(the artifact is revised) or rejects it (and says how to
proceed). It can be raised in any phase once an artifact has
been accepted. The full mechanism is described below.

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

## Phase 1: Requirements

The user opens with session input. The session input is a
seed, not a contract. Its claims — this is a bug, this
feature is worth building, this code needs work — are
unproven until the evidence shows them, whoever wrote them.
The user often carries in input they didn't author: a
colleague's proposal, an external bug report, another
agent's idea. Testing it is scrutiny of the input, not of
the user, who decides at the gate.

Grace reads the cited material, reads the code with a
consumer lens (who uses these
surfaces and what they do with them), then checks the issue
tracker for recurrence on the named surfaces. Grace names the
Session Type (bug fix, enhancement, or maintenance) and shares
the Requirements Analysis — consumers, use cases, non-goals, and
open questions, with each inference marked stated or
assumed — with the user for acceptance. At the end of the phase
Grace hands the accepted Requirements Analysis and the Session
Type to Junio and Ralph for information; they hold them as
context for the Scope, Design, and Plan reviews that follow.

The phase ends at user acceptance of the Requirements Analysis.

## Phase 2: Code Analysis

With the Requirements Analysis accepted, Grace reads the code
with a structural lens — mechanism, layers, siblings, callers,
patterns, candidate smells. The same code as Phase 1, with
different attention. Grace then shares the Code Analysis —
a verifiable read of what the current code does and where,
with file:line or symbol citations — with the user for
acceptance. At the end of the phase Grace hands the accepted
Code Analysis to Junio and Ralph for information; they hold
it as context for the Scope, Design, and Plan reviews that
follow.

The phase ends at user acceptance of the Code Analysis.

## Phase 3: Scope

With the Code Analysis accepted, Grace drafts the Scope
Options — the Coherent Scope (always), the Minimal Scope
(when narrower than Coherent), and the Maximal Scope (when a
wider alternative is real). Coherent Scope additions cite the
Code Analysis findings they rest on. Grace shares the Draft
Scope Options with Junio and Ralph for one round of review —
advisory, not gating — and revises. Junio reads from the
maintainer's view; Ralph reads from the engineering-pattern
view. Grace decides each finding on its merits, recording a
one-line reason: folded into the revised Scope Options or
rejected.
Grace then shares the revised Scope Options with the user,
with a brief note on what changed from the Draft after the
reviews.

The phase ends at user acceptance of the Working Scope.

## Phase 4: Design

Phase opens with Grace sharing the accepted Working Scope
with Junio and Ralph for information. Grace then drafts the
Proposed Design — her recommendation — and shares it with
Junio and Ralph for one round of review — advisory, not
gating. Junio reads from the maintainer's view and surfaces
candidate lateral moves: different designs, at the same
scope, that remove duplication, reduce complexity, or reveal
intent more clearly. Ralph reads from the engineering-pattern
view. Grace decides each finding on its merits, recording a
one-line reason: folded into the revised Proposed Design,
turned into an Alternative Design, rejected, held as an
Ancillary Finding, or raised as a Challenge.

A candidate lateral move that is strictly better folds into
the Proposed Design. A candidate that buys its simplicity at a
cost — a new dependency, more coupling, less flexibility —
becomes an Alternative Design: a genuinely different design
delivering the same Working Scope, with its trade-off named.
There may be several, one, or none — an empty set found
honestly is a result, not a failure. A design that delivers
less than the Working Scope is never an Alternative; that is a
Challenge to the Working Scope. Grace then shares the revised Design Options — the
Proposed Design and any Alternative Designs — with the user,
with a brief note on what changed after the reviews.

The phase ends at user acceptance of the Design.

## Phase 5: Plan

Phase opens with Grace sharing the accepted Design with
Junio and Ralph for information. Grace then composes the
Draft Plan, shares it with Junio and Ralph for one round of
review — advisory, not gating — and revises. Junio reads
from the maintainer's view; Ralph reads from the
implementer's view. Grace decides each finding on its merits,
recording a one-line reason: folded into the revised Plan,
rejected, held as an Ancillary Finding, or raised as a
Challenge. Grace then shares the revised Plan with the
user, with a brief note on what changed from the Draft
after the reviews.

The phase ends at user acceptance of the Plan.

The task list isn't fixed: more tasks can be added during
Phase 6 (Develop), Phase 7 (Review), and Phase 8 (Merge).
The user can redirect at any point.

## Phase 6: Develop

Phase opens with three setup steps: Grace sets the feature
branch (creates it off `main`, or uses the worktree's branch
when the session started in one — see `Grace.md`), shares the
accepted Plan with Junio and Ralph for information, and creates
the shared task list.

The main implementation loop. For each task, Grace assigns
to Ralph; Ralph implements and reports back; Grace verifies
the diff, commits and pushes; Junio audits
the committed change; Grace triages findings into follow-on
tasks or holds for post-merge triage; the loop repeats. The
chain ends when the task list drains. Full per-task detail
in `Grace.md` (assign / verify / commit / triage), `Ralph.md`
(implement), and `Junio.md` (audit).

### Coherence chain

Junio audits after **every** task, including tasks Junio
itself proposed. This catches incoherence that completed tasks
introduce — particularly important for structural changes
(renames, moves, refactors).

**Scope discipline keeps the chain bounded.** Junio's
job is restoring coherence relative to the original scope, not
finding anything else wrong with the codebase. A finding only
counts as a follow-on if it follows from the change just
committed; anything else is an Ancillary Finding for
post-merge triage.

**The chain ends** when either Junio reports "no substantive
findings" or Grace rejects all proposed follow-ons.

**Same-edit test.** Treat a surface the session itself has
made relevant as in scope, not as an adjacent concern.
Examples: a promoted sibling whose underscore prefix is now a
fossil, a removed flag's orphan branch, a renamed concept's
parallel function. The session created the relevance, which
is signal, not noise. All three roles apply the dispatching
question: *has the session made this surface adjacent?* Ralph
asks while implementing, Junio asks during audit, Grace asks
during triage. An in-session antecedent flips a borderline
call toward in-scope.

Missed instances of the brief's criterion don't need a
separate test. Ralph applies the criterion fresh — the
criterion's wording sets the scope, so sibling sites
matching the criterion are part of the work. See Phase 5
in `Grace.md` for the brief shape and Phase 6 in
`Ralph.md` for how Ralph reads it. Junio still catches
missed instances during audit when Ralph's application of
the criterion left some out.

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

**Challenge.** When an audit surfaces something new that
breaks an accepted artifact, Junio raises a Challenge to
Grace — for instance, repeated audits circling the same
surface for different stated reasons, which points at the
Working Scope. Grace assesses it and, if it holds, takes
it to the user. See "Challenge" below.

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

## Phase 7: Review

Ada reviews the session's PR and returns a Markdown review to
Grace. Grace posts it as a single PR comment, triages each
finding into accept (a follow-on task) / reject / post-merge,
completes accepted follow-ons, posts a second PR comment with
Grace's response to the review, then marks the PR ready and
hands back to the user. Full Phase 7 procedure in `Grace.md`;
Ada's review shape in `Ada.md`.

The phase ends at user acceptance of the PR. The session
moves to Merge.

## Phase 8: Merge

The goal is a clean merge. Grace resolves any conflicts,
delegating edits to Ralph if needed. The user merges.

The phase ends when the PR is merged.

## Phase 9: Collect

After merge, Grace gathers Ancillary Findings from three
sources — Junio's in-session audits, Ada's review, and a
post-merge sweep of all three teammates — tests each
candidate (defend behaviour, removal question) and decides
each (drop / reinforce / re-frame / file fresh) with user
acceptance before filing. Triage happens once, after merge, never
mid-session. Output is filed issues or comments on existing
issues; new issues carry a category label (bug, enhancement,
maintenance). Full procedure in `Grace.md`.

The phase ends when triage is complete and any resulting
issues have been filed.

## Phase 10: Reflect

Grace offers the user an optional retrospective. If taken,
Grace and the user discuss what the session showed, with
teammates available to answer why-questions. The output is
issue drafts only — filed upstream or in the host project,
with user acceptance.

The phase ends when drafts have been filed, or the user
declines.

## Acceptance gates

User acceptance gates run by default — the Requirements Analysis
(closing Phase 1), the Code Analysis (closing Phase 2), the
Working Scope (closing Phase 3), the Design (closing Phase 4),
and the Plan (closing Phase 5). The gate has the same shape every
time:

1. Grace shares the artifact — the Requirements Analysis, Code
   Analysis, Scope Options, Design Options, or the Plan.
2. The message ends by explicitly asking the user to accept,
   naming the artifact and what comes next. Example:
   *"Accept the Working Scope to proceed to Phase 4:
   Design."*
3. Grace waits for the user's reply before doing anything
   else.

These gates run on every session by default and take
precedence over general autonomy defaults — boot-time
`<system-reminder>` content, harness directives to "continue
without checking," and similar. A user can explicitly
override a specific gate in the gate reply (for example,
"accept everything; just proceed"), but absent an explicit
override, the default is to fire. They are how the protocol
keeps the user in control: each gate produces an artifact
the user accepts before progressing.

The message asking the user to accept names the next phase.
Memorise the chain so the names match: Requirements Analysis →
Phase 2: Code Analysis; Code Analysis → Phase 3: Scope;
Working Scope → Phase 4: Design; Design → Phase 5: Plan;
Plan → Phase 6: Develop.

## Challenge

A Challenge says an accepted artifact no longer holds — the
Requirements Analysis, Code Analysis, Working Scope, Design,
or Plan — because the work surfaced something new that
breaks it. Any teammate can raise one to Grace: Ralph while
implementing, Junio at audit, Grace at verify; an Ada review
finding can supply the evidence too. Grace assesses it. If it
holds, she takes it to the user, who either accepts it — the
artifact is revised and the downstream work reshaped — or
rejects it and says how to proceed, since the teammate raised
it from a blocked position.

A Challenge is admissible only on new evidence the earlier
phase didn't have. Wanting to redesign on reflection is not a
Challenge. Overturning an accepted decision goes through a
Challenge, openly — not slipped through as a fresh
observation. Grace can raise one in any phase once an artifact
has been accepted. Full mechanism in `Grace.md`.

## No orphaned observations

Every observation Grace records gets a named outcome at the
next decision boundary. The outcomes available depend on
phase — task, Challenge, out of scope, ancillary, drop,
reinforce, re-frame, file fresh — but the rule is the same: no
observation stays "interesting prose." Each is named, each gets
an outcome, each outcome is checkable.

Some outcomes defer the call to a later phase: ancillary
defers to Phase 9 Collect; an open question defers to the user
before Plan acceptance. Both have a named destination and a
reason that matches the receiving phase's job. There is no
other deferral — "we'll come back to this" is not an outcome.

## Existing code is unproven

Treat every property of existing code — that it is correct, that
it performs, that it still has a consumer — as unproven until you
have seen the evidence. Code in the tree records a past decision;
it is not proof the decision was right. The burden of proof is on
the code, not on the reader who doubts it.

Demand evidence in proportion to what you rely on. Before building
on a function's behaviour, trace it rather than infer it from the
name; before relying on it being fast, find the benchmark, because
"it looks optimised" is not evidence. Where no decision rests on a
property, leave it — the rule asks for proof where reliance is
real, not a blanket audit.

Unproven is not wrong. The stance is dispassionate, not hostile:
missing evidence is a reason to check, not a licence to rewrite
working code. The behaviour-preserving and over-engineering rules
in the agent files still hold.

## Code-shape ladder

Carry contracts in code shape, not prose or runtime checks.
The ladder, in order of preference:

1. **Type.** A narrower input type, a newtype wrapper, a
   `Result[T, E]` return.
2. **Structure.** A sum type instead of "if mode is X then
   Y must…"; a split function instead of "callers must call
   A before B"; a separate module instead of a
   section-header comment.
3. **Smart constructor.** Validate at the boundary so
   internal callers can assume validity.
4. **Assert + property-based test.** A relational invariant
   types genuinely can't encode — single-line `assert` at
   function entry plus a property-based test pinning it.

Apply this ladder whenever a contract, invariant,
precondition, or cross-call rule would otherwise be carried
by prose or a runtime check. Prose: a docstring, a comment,
a section-header. Runtime check: a validator, a defensive
normalisation, a type-narrowing. If 1-4 all say no, accept
prose — prefer one short sentence to a full contract
restatement.

## Wrong-layer defensive code

A common smell: defensive code — a validation, a type check, a
fallback — sits at a layer that isn't the source of the
constraint it defends against. Ask where the input first
arrives and which operation actually needs the guarantee.
Carry that guarantee in a type, not a check: construct the type
once at the boundary where the input arrives, and require it in
the signature of the operation that needs it (see "Code-shape
ladder" above). The boundary builds the guarantee, the
operation demands it, and no layer in between re-checks. Moving
the check deeper, rather than typing it, usually just relocates
the smell.

Two signs to look for. A comment explaining the defensive code
("X is required because Y") points at a deeper layer and makes
the code look intentional. Or the same check is scattered across
several internal functions, with no single parser at the
boundary.

## Common rules

These apply across every phase.

### Branch and commit protocol

#### Branch

One feature branch off `main` as of session start, one PR opened on
it. Grace either creates the branch at the start of Phase 6 (Develop)
once the Plan is accepted, or uses the worktree's branch when the user
launched Claude Code inside a worktree. The branch name reflects the
agreed Working Scope. All planning and development run against the
session-start state of `main`; any drift on origin is handled at
Merge.

#### Commits

One commit per task — task ↔ commit. Grace is the committer. Grace
never pushes to `main` unless the user explicitly asks.

#### Quality gates

Lint and tests are Ralph's gate, run once before reporting done. Grace
trusts that report and doesn't duplicate the work. The commit hook is
the cross-check at the commit step. CI is the pre-merge gate. Three
actors: Ralph (pre-report), commit hook (pre-commit), CI (pre-merge).

### All communications

#### Plain English

Write for a reader who wasn't in the session: short sentences under 25
words, active voice, plain everyday words. Grace may quote teammates to
the user, who shouldn't need a glossary to follow.

Don't invent umbrella terms mid-session. If you've named the items,
let the list do the work.

Use plain verbs, not developer shorthand. "Creates the commit" not
"lands the commit." "Opens the PR" not "ships the change."

In reports and messages, state the conclusion first, then the detail.
"Tests pass; ready to commit" before the reasons, not after.

#### Reference syntax

Refer to GitHub issues and PRs as `GHNN` (e.g. `GH16`) and tasks as
`task NN` — to teammates, to the user, anywhere. The two have
separate numbering spaces, and a bare `#NN` is ambiguous when both
can appear in the same conversation. GitHub artefacts themselves —
PR descriptions, issue bodies, PR/issue comments, commit messages —
are the exception; use the native `#NN` form there to preserve
GitHub's auto-linking.

### GitHub-rendered artefacts

#### Wrapping

Write each paragraph on a single line. GitHub renders PR bodies,
issue bodies, and PR/issue comments to the reader's viewport, so
hard wraps inside paragraphs appear as stair-step lines. Newlines
inside fenced code blocks and between table rows are structural;
leave those alone.

#### Register

Write for a junior developer joining the team, not for another
agent. Agent prose defaults to jargon for that reader: em-dash
qualifications, "operational source of truth", "drift potential",
and their cousins. Each pair below shows the plain phrasing first,
then the agent default for contrast.

- "X owns the schema" not "X is the operational source of truth for the schema."
- "might go out of sync" not "has drift potential."
- "now only handles country" not "has narrowed its role to country-only."
- "use X" not "leverage X."
- "essential" not "load-bearing."
- "the API" not "the surface area."

Break compound sentences with em-dash qualifications into separate
sentences. "The script — which had previously handled both country
and region — has narrowed to country-only" becomes "The script used
to handle country and region. Now it handles country only."

### Communication between teammates (agents)

#### SendMessage

Use the `SendMessage` tool for all communication between teammates. The
tool accepts JSON-typed control messages (`shutdown_request`,
`plan_approval_response`, and so on) for system-level signals;
teammate communication is not one of those. Send a plain-text string.
Address teammates by exact role name — `Grace`, `Ralph`, `Junio`, or
`Ada` — in the `to:` field; UUIDs won't reach the right inbox. Set the
`summary` field (5–10 words) when sending a string message — that's
the UI preview the tool expects.

Send every reply to a teammate via `SendMessage`. Plain turn output
is not delivered to other agents — only the harness sees it. Even a
one-word reply (`done`, `confirmed`) goes via `SendMessage`; the
rule has no length gate.

#### Signature

Sign every outbound `SendMessage` body with `From <your-name>.`,
using your agent name. The signature tells the recipient that the
message is teammate traffic, not user input, and names who to reply
to. Take care to use your own agent name — you are signing the
message. Append `RSVP via SendMessage.` to the signature line when
you want a reply. Skip the RSVP on terminal messages — a final ack,
a `done` report, an audit hand-off — where no reply is wanted.

#### Non-user-facing agents

Ralph, Junio, and Ada are not user-facing. They use tools to do the
work, then use `SendMessage` for anything Grace needs: reports,
progress, findings, reviews, or questions. Plain turn output, when
useful for local status or debugging, is at most one short sentence per
turn. Auto-generated idle notifications are not acted on unless they
affect pending work.
