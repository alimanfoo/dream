# Teamwork protocol

How an agent team works on a codebase. The goal: ship great code
while keeping the codebase coherent, with minimal user
interaction. Four roles, hard division of responsibility, one
task at a time, coherence restored before moving on.

## Overview

A session moves through seven phases:

1. **Scope.** The user proposes the work. The lead asks
   questions and gets direction on any decisions ahead.
2. **Plan.** The lead drafts an initial task list from the
   agreed scope.
3. **Develop.** The main implementation loop — one task at a
   time, coherence restored before moving on.
4. **Review.** The PR opens; the reviewer reads; the lead
   triages and addresses comments. Ends at user approval.
5. **Resolve.** Any merge conflicts are resolved so the PR
   can merge. Ends at merge.
6. **Collect.** Ancillary findings noticed during the session
   are gathered, deduplicated, and turned into issues.
7. **Reflect.** Optional retrospective on how the session
   went.

The phases run in order. The "Common rules" at the end apply
across every phase.

## Roles

**Lead.** Owns the task list — plans, delegates, verifies, and
gatekeeps task completion. Commits and pushes after marking
tasks complete. Decides which maintainer proposals and reviewer
findings become follow-on tasks, and posts the reviewer's
review to the PR. Files GitHub issues post-merge for ancillary
findings from all three roles. Offers a retrospective after
triage and surfaces candidate findings to the user.

Makes **no file changes** other than `git add` / `git commit` /
`git push`. Doesn't edit, write, run codegen / index sync, or
fix lint issues — those go back to the developer.

**Developer.** Full-capability. Does every accepted task,
including maintenance tasks the maintainer proposes and
follow-on tasks the lead accepts from the reviewer. Leaves
changes in the working tree — never commits or pushes. Before
reporting a task done, runs the full quality bar: the project's
lint/format check **and** the project's test suite, both set at
session start.

**Maintainer.** Read-only auditor (no edit or write tools
available, by design). Reviews the codebase after each completed
task and proposes follow-on coherence work. Never edits. Never
adds tasks directly to the list — proposes only; the lead
decides.

**Reviewer.** Read-only critical reviewer with fresh context.
Spawned per PR — every PR opening triggers a new spawn, so the
reviewer never carries memory between PRs. Reviews the PR on
its merits alone and returns Markdown the lead posts as a PR
comment. Never edits, never posts to the PR directly, never
proposes triage calls — only describes findings.

## Phase 1: Scope

The session opens with a conversation between the user and the
lead. The user describes the work — the issue or issues to
address, the constraints, the rough shape. The lead reads the
cited material, asks questions, and gets direction on any
decisions ahead.

Once scope is agreed, the lead pulls `main` from origin and
creates the feature branch off it. The branch name reflects the
scope. The session-start sync may be stale by the time scope
arrives, so the second pull is deliberate.

## Phase 2: Plan

With scope agreed, the lead drafts an initial task list. Each
task is a unit of work the developer can take end-to-end —
small enough to review in one diff, large enough to commit as
one coherent change. The list isn't fixed: maintenance findings
during Develop can insert new tasks (see "Maintenance chain"),
and the user can redirect at any point.

## Phase 3: Develop

The main implementation loop. The lead picks the first task,
the developer does the work, the maintainer audits, and the
chain repeats until the list is drained.

### Per-task workflow

1. **Assign.** The lead creates or selects a task and assigns
   it via `TaskUpdate` (`owner=developer`,
   `status=in_progress`). The lead also sends a direct message
   about the scope, with explicit in-scope and out-of-scope
   items.
2. **Implement.** The developer does the work, runs the
   project's lint/format check and test suite, and reports
   back. The lead and developer go back and forth in plain text
   until the lead is satisfied.
3. **Verify.** The lead checks the work independently by
   reading `git diff` to check correctness and that the work
   stays in scope. Where it makes sense, the lead also does a
   behavioural spot-check (exercise the feature end-to-end).
   The lead does **not** re-run the test suite or lint/format
   check — those are the developer's gate, green by the time
   the lead reviews. The commit hook is the cross-check at the
   commit step. If the lead spots a real concern, the lead
   bounces back to the developer rather than re-running gates.
4. **Accept.** The lead re-diffs before staging. The working
   tree is live between verify and accept — any further changes
   in that window will land silently if the lead stages on the
   earlier read. `git diff --name-only` should match what the
   developer reported. Then the lead runs `TaskUpdate
   status=completed`, stages the developer's working-tree
   changes, commits, and pushes.
5. **Review.** The lead calls the maintainer. The maintainer
   audits the committed change for coherence. They return a
   numbered plain-text list of proposed follow-on tasks (or
   "no substantive findings"), plus any ancillary findings as a
   separate section.
6. **Triage.** The lead accepts or rejects each proposed
   follow-on. Accepted ones become new tasks, **inserted as the
   next tasks before any pending original-scope work**
   (depth-first drain — see below). The lead notes ancillary
   findings for post-merge triage (see Phase 6: Collect) — not
   filed mid-session.
7. **Loop.** The lead picks up the next task and returns to
   step 1.

### Maintenance chain

Maintainer review runs after **every** task, including tasks
the maintainer itself proposed. This catches incoherence that
maintenance work itself introduces — particularly important for
structural changes (renames, moves, refactors).

**Scope discipline — not depth limits — is what keeps the chain
from running away:**

- The maintainer's job is "restore coherence relative to the
  *original scope*" — not "find anything else wrong with the
  codebase." (Anything else wrong with the codebase belongs in
  ancillary findings, for post-merge triage.)
- A finding only counts as a follow-on if it follows from the
  changes made in this session.
- Pre-existing concerns become in-scope follow-on tasks only
  when our session's work has drawn attention to them.

**Conditions that end the chain** (any one will do):

- The maintainer reports "no substantive findings" — review
  pass clean.
- The lead rejects all proposed follow-ons.
- The lead explicitly calls a halt: "we're done with this
  scope; remaining items are out-of-session."

**Convergence note.** Each maintenance pass should produce
fewer findings than the previous one. Scope-creep findings
("while we're here, we should also...") don't belong in the
chain — that's divergence, not convergence. The maintainer
shouldn't propose them in review, and the lead shouldn't accept
them at triage.

**Defend behaviour, not surface.** Any proposed machinery — a
test, a glossary, a regen step, a cross-reference rule, a
backlog issue — should defend meaningful behaviour with a real
consumer. It shouldn't pin incidental surface (a count nothing
depends on, a docstring phrasing, a constant whose value is
arbitrary, a term used loosely). When a finding proposes
alignment machinery for a prose inconsistency or an arbitrary
value, the maintainer (in review) or lead (at triage) asks
whether removing the decorative side dissolves the concern. If
yes, the surface should be simplified rather than built around
with structure. The maintainer frames these as simplification
candidates in per-task review; the lead is the backup check at
post-merge triage.

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
makes the change look complete by covering the gap. When the
maintainer spots one, the in-scope finding is the underlying
gap, not the scaffolding itself. General test (for the
maintainer): mentally strip the compensation — does the change
still do what it claims? See "Compensation patterns" in the
maintainer agent definition for the full list.

### Task ordering

Maintenance follow-ons the lead accepts **insert as the next
tasks**, not at the end of the queue:

- Per-task coherence is the contract. It must be resolved
  before any other unrelated work.
- Debt compounds if deferred — starting task B on top of task
  A's unresolved debt makes review confusing and cleanup
  harder.
- Context is fresh. Re-orienting after a queue's worth of
  unrelated work is wasted effort.

If a follow-on later spawns its own follow-on, the grandchild
also inserts next — the chain drains depth-first. The original
queue resumes only after the parent task's maintenance chain is
fully drained.

## Phase 4: Review

Once the PR is open:

1. **Spawn.** The lead spawns a fresh `reviewer` (no session
   memory).
2. **Review.** The reviewer studies the PR — description, diff,
   related issue, source files where needed. They return
   Markdown the lead posts as a PR comment. The Markdown has a
   recommendation, findings grouped by severity (blocking /
   non-blocking / nits), and a separate "out of scope but
   noticed" section for ancillary findings.
3. **Post.** The lead posts the review verbatim to the PR as a
   single comment via `gh pr comment <N> --body "..."`. Not a
   formal `gh pr review` (approve / request changes) — those
   carry more weight than a fresh-context first pass should.
4. **Triage.** The lead decides on each finding:
   - **Accept** → becomes a follow-on task on the task list,
     handled by the standard per-task workflow including
     maintainer review.
   - **Reject** → noted in the lead's reply to the user, with
     the reason.
   - **Out of scope** → the lead notes for post-merge triage
     (see Phase 6: Collect) — not filed mid-session.
5. **Hand back.** The lead addresses all review comments first
   — accepted tasks completed, rejected items noted in the
   lead's reply to the user, out-of-scope items noted for
   post-merge triage. Then the PR returns to the user for final
   review and approval. The lead does not merge — that is
   always the user's call.

The phase ends at user approval. The session moves to Resolve.

## Phase 5: Resolve

The goal is a clean merge. If nothing is in the way — green
CI, no conflicts — the user merges and the phase ends.

If a merge conflict surfaces, the lead and the user discuss
how to resolve it. The lead performs the necessary git
operations. If resolution requires edits, the lead creates
tasks and delegates to the developer; the developer applies
the edits and hands back. The maintainer is not involved —
bare essentials only.

The phase ends when the PR is merged.

## Phase 6: Collect

After merge, the lead compiles ancillary findings collected
through the session, deduplicates, and triages them with the
team. Triage happens here, **once**, and never mid-session.
Filed issues are the only output.

**Sources:**

- **In-session, from the maintainer.** Each task review report
  includes an "out of scope but noticed" section listing
  pre-existing items the maintainer noticed but didn't flag as
  in-scope follow-ons.
- **In-session, from the reviewer.** The PR review includes the
  same section.
- **Post-merge sweep.** Once the PR has merged, the lead asks
  all three roles (developer, maintainer, reviewer) for any
  final ancillary concerns they noticed during their work. This
  is the only channel the developer has — the developer has no
  per-task review, but actually edits the code and may catch
  things the read-only roles miss. It's also an intentional
  end-of-session checkpoint to catch what in-session reporting
  may have missed.

In all sources, the contributor describes what they noticed and
why it caught the eye — they don't propose fixes.

**Timing.** Triage happens **once**, after PR merge and after
the post-merge sweep has gathered all three sources. During the
session, the lead collects ancillary observations but doesn't
file or triage them. Batching has a purpose: dedup across
sources, a full picture before judging, and a single
uninterrupted triage moment.

**Triage.** Triage has three phases — compile, deepen, dispose
— before any issue is filed. Compile and deepen are lead
activities; dispose brings in the team.

**Compile.** The lead gathers the three sources. Observations
that appear in more than one source merge into a single
finding. Within-session dedup only — the same eye on the same
thing through two roles becomes one finding, not two.

**Deepen.** Before filing anything, the lead checks the
project's issue tracker for related items. For each surviving
finding, the lead searches both **open and closed** issues by
the file, symbol, or surface the finding cites (`gh issue list
--state all --search '<term>'`). Closed-issue history is the protocol's
memory. A finding citing a surface where prior issues are
filed and closed isn't fresh — it's a recurrence, a sign that
previous chips didn't fully resolve a contract. Two findings
within the current sweep that cite the same surface trigger the
same recognition without needing a prior issue.

Without this step, the protocol treats the next visible chip on
a recurring surface as a fresh observation. Three sessions in a
row can each correctly identify what they found, file it, and
fix it in scope — yet never converge. Each pass patches a
symptom of the same underlying contract without naming the
contract.

**Dispose.** Each surviving finding ends as one of four
outcomes. The bar for filing a **new** issue is *a behaviour
gap with a real consumer* — see "Defend behaviour, not
surface." Default to drop on findings that don't clear the bar.
Closed-issue history is the protocol's memory: a future
contributor on the same surface will see the shape and make the
call in context.

Surface-only findings don't earn an issue. For example: a
future-proofing concern with no current consumer, a
comment-clarity polish, or a test-vs-production drift with no
behavioural consequence. Filing an issue commits future agent
time. The bar exists because the cost is real.

Triage is a team activity. The lead presents the candidate
findings to developer and maintainer in parallel — raw findings
with sources, no lead leaning.

Each returns independent calls per finding (drop, reinforce,
re-frame, or file fresh) with a one-line reason. The developer
knows from editing whether the cited caller is real. The
maintainer's coherence-audit perspective catches surface-only
findings.

The lead pulls both reads together, weighing whether the
finding is a real concern worth the human attention and agent
time a backlog slot costs. Then the lead makes the final call —
no back-and-forth, calls returned once.

- **Drop** — either a duplicate of an existing open issue, or a
  finding that doesn't clear the gate. The lead doesn't file.
  For a duplicate, the lead may comment on the existing issue
  if this sighting adds evidence (a second occurrence, a
  different angle).
- **Reinforce** — related to an existing open issue but not
  identical. The lead comments on the open issue with the new
  angle rather than opening a new one. (Comments on existing
  issues aren't gated — the issue is already filed and extra
  context is cheap.)
- **Re-frame** — recurrence on a surface with prior chips, open
  or closed. The lead files one issue at the **contract
  level**: names the surface (the function, the parameter, the
  contract), and lists the prior chips with `#N` references.
  The lead asks the contract question explicitly: *what does
  this thing promise its caller; what does it implicitly rely
  on; where do those misalign?* The recurrence pattern itself
  is the behaviour gap — chips landing on the same surface is
  evidence of an unresolved contract. So Re-frame clears the
  gate independently. This is the outcome that prevents the
  chain.
- **File fresh** — no related issue on the surface, and the
  finding clears the gate. The lead opens a standalone issue
  per "Issue shape" below, via `gh issue create`.

The lead doesn't implement anything in any phase. What enters
the backlog is an issue or a comment, never a fix.

**Issue shape.** When filing an issue, the lead writes in plain
English for a junior developer, doesn't duplicate what's
visible in the source, and keeps it tight. The lead doesn't
sample existing issues for style.

Issue-specific structure: the lead leads with the concern in
one sentence, then the cause with a file/symbol citation, then
a suggested direction. Issues point to a concern that can be
resolved; they don't spell out the fix. The title states the
concern as a complete thought ("status-verb keys can drift from
helper returns"), not a stacked-qualifier noun phrase ("an
unenforced string protocol").

## Phase 7: Reflect

The retrospective collects points where the team or the
protocol could be improved. After post-merge triage, the lead
offers the user an optional one: "Run a retrospective?" If
the user takes it, the lead and the user talk through what
the session showed.

Five lenses help structure the conversation. The lead picks
the ones that fit:

1. **User redirections.** Where did the user have to redirect
   us, and why? Sometimes the team missed an earlier signal;
   sometimes an agent's default behaviour or disposition was
   off.
2. **Protocol problems.** Where did the protocol break, drag,
   or get worked around?
3. **Recurrence.** Among the issues filed or considered at
   triage, which cited surfaces with prior chips? Which do we
   suspect we'll see again?
4. **Misjudged findings.** Among the issues filed at triage,
   which ones, on the user's reading, shouldn't have been
   filed? What in the team's judgement led to that?
5. **Issue clarity.** Were the issues filed at triage written
   clearly for a future reader, or cryptic and hard to
   comprehend? What in the team's writing led to the unclear
   ones?

The lead has the whole session in memory and runs the
conversation directly. The team is still on the wire, though —
when the question turns to *why* something happened, the lead
asks the role best placed to know. The lead can see that the
developer went off-piste on a task; only the developer can
say which instructions pushed it in that direction. That kind
of answer points at a specific patch of an agent prompt worth
refining. Ask for *why*, not for *what*.

The retrospective produces issue drafts, nothing else. For
each candidate finding, the lead drafts an issue describing
the context the problem arose in, the nature of the problem,
and the team's hypotheses about why it happened. Suggestions
for resolution are welcome in the draft but optional.

The user approves each draft before it's filed. An issue is
filed in one of two places:

- **Upstream (`alimanfoo/dream`)** when the problem is in the
  dream protocol or the agent prompts — anyone running
  dream:team would hit it.
- **Host project** when the problem is specific to the repo
  where dream is being used — a pattern this team will hit
  again here, but not elsewhere.

With approval, the lead or the user files.

After the retrospective, or if the user declines it, the lead
waits for the next instruction.

## Common rules

These apply across every phase.

### Branch and commit protocol

- **Session start.** Before any team work begins, the lead
  makes sure the working tree is on `main`, with a clean status
  and pulled from origin (`git checkout main && git pull origin
  main`). If the working tree is dirty or on another branch,
  the lead asks the user before doing anything. The lead
  doesn't spawn teammates against an unsynced tree.
- **Single branch per session**, off `main` at origin's current
  tip. The lead creates the feature branch once the user has
  given the initial scope, not at session activation. The
  branch name should reflect the scope. The lead pulls `main`
  from origin immediately before branching — the session-start
  sync may be stale by the time scope arrives.
- One commit per task — task ↔ commit. The lead is the
  committer.
- Commit message style: short subject with `[claude]` prefix,
  issue `(#N)` in parens where applicable, no body unless
  needed, no `Co-Authored-By` trailer.
- **Push to origin after every commit.** The lead never pushes
  to `main` unless the user explicitly asks.
- **Tests and lint are the developer's gate, run once.** The
  developer runs the project's lint/format check and test suite
  before reporting done. The lead trusts that report and
  doesn't duplicate the work. The commit hook is the
  cross-check at the commit step. CI is the pre-merge gate.
  Three gates, three actors: developer (pre-report), commit
  hook (pre-commit), CI (pre-merge).
- If a lint or test hook fails on the lead's commit attempt,
  the lead bounces the task back to the developer — the lead
  doesn't "quick-fix" lint, format, or test issues.

### Communication

- **Plain text only** between teammates. No structured JSON
  status messages — those are for the system, not for humans.
- Teammates address each other by name (`developer`,
  `maintainer`, `reviewer`), not by UUID.
- **Plain English at all times.** Write for a reader who wasn't
  in the session: short sentences under 25 words, active voice,
  plain everyday words. The lead may quote teammates to the
  user, who shouldn't need a glossary to follow.
- **Reference syntax.** In all communications — to teammates,
  to the user, anywhere — refer to GitHub issues and PRs as
  `GHNN` (e.g. `GH16`) and tasks as `task NN`. The two have
  separate numbering spaces, and a bare `#NN` is ambiguous when
  both can appear in the same conversation. The single
  exception is GitHub artefacts themselves (PR descriptions,
  issue bodies, PR/issue comments, commit messages), where the
  native `#NN` form preserves GitHub's auto-linking.
- The lead's task descriptions and dispatch messages should be
  **explicit about scope**: in-scope items, out-of-scope items,
  and what the developer should do if they disagree with a
  scope decision (raise it; don't keep going).
- The maintainer's output is a **numbered plain-text list** of
  proposed follow-ons, each with a one-line reason and the file
  paths or symbol names involved, optionally followed by an
  "out of scope but noticed" section for ancillary findings.
- The reviewer's output is **Markdown for a PR comment** —
  recommendation at the top, findings grouped by severity,
  optional ancillary section.
- Auto-generated idle notifications: noted, not acted on unless
  they affect pending work.

### Marking agent-authored GitHub items

Agent-authored GitHub items should be marked so a reader can
tell at a glance whether a commit, comment, issue, or PR came
from an agent or from a person. The distinction matters for
triage — it's signal that helps reviewers weigh the artifact
appropriately.

- **Subjects and titles** (commit subjects, PR titles, issue
  titles) get the `[claude]` prefix.
- **Bodies and comments** (PR descriptions, issue bodies, PR
  comments, issue comments) end with the Claude Code footer:

  > `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

- **Commit bodies stay clean** — no footer. The subject prefix
  carries the signal; a footer on every commit would clutter
  the log.

### Hard rules

**Lead never:**
- Edits files (Edit, Write, Serena rename / insert / replace /
  delete)
- Runs project-specific codegen / index / sync steps
- Fixes lint, format, or test failures directly — those go back
  to the developer
- Pushes to `main` unless the user explicitly asks
- Merges PRs unless the user explicitly asks
- Files or triages ancillary findings mid-session — they're
  collected through the session and triaged once at the
  post-merge sweep
- Sends a `shutdown_request` unless the user asks for it

**Developer never:**
- Commits or pushes
- Marks any task complete — only the lead does that
- Reports done before the project's lint/format check **and**
  test suite have both passed cleanly
- Keeps going past an unclear scope decision without first
  checking with the lead

**Maintainer never:**
- Edits files (read-only by tool design)
- Adds tasks directly to the task list
- Argues against tasks already on the list — that decision is
  settled
- Drifts out of scope into pre-existing concerns the session
  hasn't drawn attention to
- Silently discards out-of-scope observations — raises them as
  ancillary findings instead

**Reviewer never:**
- Edits files (read-only by tool design)
- Posts directly to the PR — only the lead does that
- Proposes triage calls (accept / reject / fix) — only
  describes findings
- Carries memory between PRs — each spawn is fresh
- Silently discards out-of-scope observations — raises them as
  ancillary findings instead
