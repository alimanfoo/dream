# Teamwork protocol

How an agent team works on a codebase. Four roles, hard division of
responsibility, one task at a time, coherence restored before moving on.

## Roles

**Lead.** Owns the task list. Plans, delegates, verifies, gatekeeps task
completion, commits and pushes after marking complete, decides which
maintainer-proposed follow-ons to accept onto the task list, posts the
reviewer's review to the PR, decides which reviewer findings warrant
follow-on tasks, files GitHub issues for ancillary findings noticed by
maintainer or reviewer. Makes **no file changes** other than `git add`
/ `git commit` / `git push`. Does not edit, write, run codegen / index
sync, or fix lint issues — those go back to the developer.

**Developer.** Full-capability. Implements every accepted task,
including maintenance tasks proposed by the maintainer and follow-on
tasks accepted from the reviewer. Leaves changes in the working tree —
does not commit or push. Runs the full quality bar (the project's
lint/format check **and** the project's test suite, both established
at session start) before reporting a task done.

**Maintainer.** Read-only auditor (no edit / write tools available, by
design). Reviews the codebase after each completed task and proposes
follow-on coherence work. Never edits. Never adds tasks directly to the
list — proposes only; lead decides.

**Reviewer.** Read-only critical reviewer with fresh context. Spawned
per-PR — every PR opening triggers a new spawn, so the reviewer never
carries memory between PRs. Conducts a complete review of the PR on
its merits alone, returns plain-text PR-comment-friendly Markdown.
Never edits, never posts to the PR directly, never proposes triage
calls — only describes findings.

## Per-task workflow

1. **Assign.** Lead creates or selects a task and assigns it via
   `TaskUpdate` (`owner=developer`, `status=in_progress`) plus a direct
   message scoping the work, with explicit in-scope and out-of-scope
   items.
2. **Implement.** Developer implements, runs the project's lint/format
   check and test suite, and reports back. Lead and developer iterate
   plain-text until lead is satisfied.
3. **Verify.** Lead independently verifies — `git diff`, the test
   suite, the lint/format check, behavioural spot-check as appropriate.
4. **Accept.** Lead marks task completed (`TaskUpdate
   status=completed`), commits the developer's working-tree changes,
   pushes to origin.
5. **Review.** Lead calls the maintainer. Maintainer audits the
   committed change for coherence and returns a numbered plain-text
   list of proposed follow-on tasks (or "no substantive findings"),
   plus any ancillary findings as a separate section.
6. **Triage.** Lead accepts or rejects each proposed follow-on. Accepted
   ones become new tasks on the list, **inserted as the next tasks
   before any pending original-scope work** (depth-first drain — see
   below). Ancillary findings are filed as GitHub issues where
   warranted (see below).
7. **Loop.** Lead picks up the next task and returns to step 1.

## Per-PR workflow

After all in-session tasks are complete and the lead has opened a PR
for the session branch:

1. **Spawn.** Lead spawns a fresh `reviewer` (no session memory).
2. **Review.** Reviewer studies the PR — description, diff, related
   issue, source files where needed — and returns plain-text
   PR-comment-friendly Markdown: a recommendation, findings grouped
   by severity (blocking / non-blocking / nits), and a separate
   "out of scope but noticed" section for ancillary findings.
3. **Post.** Lead posts the review verbatim to the PR as a single
   comment via `gh pr comment <N> --body "..."`. Not a formal
   `gh pr review` (approve / request changes) — those carry stronger
   signal than a fresh-context first pass should send.
4. **Triage.** Lead analyses each finding:
   - **Accept** → becomes a follow-on task on the task list, drained
     via the standard per-task workflow including maintainer review.
   - **Reject** → noted in the lead's reply to the user, with
     rationale.
   - **Out of scope** → captured as a GitHub issue (see below).
5. **Hand back.** Once all review comments have been addressed
   (accepted tasks completed, rejected items annotated, out-of-scope
   items filed as issues), the PR returns to the user for final
   review and approval. Lead does not merge — that is always the
   user's call.
6. **Merge (user).** Final merge gates — both must be green:
   - User approval on GitHub.
   - CI checks pass.
7. **Post-merge sweep.** Once the PR has merged, lead asks the
   developer, maintainer, and reviewer for any final ancillary
   concerns they noticed during their work that haven't already
   been surfaced. Lead compiles the three lists, deduplicates, and
   triages each item — warranted ones become GitHub issues. This is
   a deliberate end-of-session checkpoint to catch what in-session
   reporting may have missed; it is also the only channel the
   developer has for ancillary observations.

**Re-review on subsequent PR pushes is opt-in.** A re-review means
shutting down the existing `reviewer` and spawning a new one
(preserving the fresh-context property).

## Ancillary findings → GitHub issues

Reviewers, maintainers, and developers regularly notice items outside
the immediate scope of their current work. These observations have
value and must not be silently discarded.

**Sources:**

- **In-session, from the maintainer.** Each task review report
  includes an "out of scope but noticed" section listing pre-existing
  items the maintainer noticed but did not flag as in-scope
  follow-ons.
- **In-session, from the reviewer.** The PR review includes the same
  section.
- **Post-merge sweep.** Once the PR has merged, lead asks all three
  role-holders (developer, maintainer, reviewer) for any final
  ancillary concerns they noticed during their work. The developer
  channel exists only here — the developer has no per-task review,
  but observes the code at edit-distance during implementation and
  may catch things the read-only roles miss.

In all sources, the contributor describes what was observed and why
it caught the eye — they do not propose fixes.

**Triage.** Lead compiles the lists, deduplicates (the same
observation may appear in more than one source), and files each
warranted item as a GitHub issue via `gh issue create`. Issues are
concise and factual: title naming the concern, body with file /
symbol citations and a short rationale. Lead does not implement;
the issue enters the project's normal backlog.

## Branch and commit protocol

- **Single branch per session**, off latest `main`. Pull `main` before
  branching.
- One commit per task — task ↔ commit. Lead is the committer.
- Commit message style matches the existing repo log: short subject,
  issue `(#N)` in parens where applicable, no body unless needed, no
  `Co-Authored-By` trailer, no agent prefix.
- **Push to origin after every commit.** Never push to `main` without
  explicit instruction from the user.
- The lint/format check and test suite must both be green before the
  commit. If a lint hook fails on the lead's commit attempt, the task
  is bounced back to the developer — lead does not "quick-fix" lint
  or format issues.

## Maintenance chain

Maintainer review fires after **every** task, including tasks the
maintainer itself proposed. This catches incoherence introduced by
maintenance work itself — particularly important for structural changes
(renames, moves, refactors).

**Scope discipline, not depth limits, is what bounds the chain:**

- The maintainer's remit is "restore coherence relative to the
  *original scope*" — not "find anything else wrong with the codebase."
  (Anything else wrong with the codebase belongs in the ancillary
  findings section, for issue-filing.)
- A finding only counts as a follow-on if it is a consequence of the
  changes made in this session.
- Pre-existing concerns enter scope as follow-on tasks only when our
  session's work has made them more visible.

**Termination conditions** (any one ends the chain rooted at a task):

- Maintainer reports "no substantive findings" — review pass clean.
- Lead rejects all proposed follow-ons.
- Lead explicitly calls a halt: "we're done with this scope; remaining
  items are out-of-session."

**Convergence note.** Each maintenance pass should produce fewer
findings than the previous one. If a review starts producing scope-creep
findings ("while we're here, we should also..."), reject them — that's
divergence, not convergence.

## Task ordering

Accepted maintenance follow-ons **insert as the next tasks**, not
appended to the end of the queue:

- Per-task coherence is the contract. Discharging it logically precedes
  any further unrelated work.
- Debt compounds if deferred — task B starting on top of task A's
  unresolved debt produces confusing review attribution and harder
  cleanup.
- Context is fresh; re-orienting after a queue's worth of unrelated
  work is wasted effort.

If a follow-on later spawns its own follow-on, the grandchild also
inserts next — the chain drains depth-first. The original queue
resumes only when the maintenance chain rooted at the parent task has
fully drained.

## Communication

- **Plain text only** between teammates. No structured JSON status
  messages — those are for the system, not for humans.
- Address teammates by name (`developer`, `maintainer`, `reviewer`),
  not by UUID.
- The lead's task descriptions and dispatch messages should be
  **explicit about scope**: in-scope items, out-of-scope items, and
  what the developer should do if they disagree with a scope call
  (flag, don't barrel ahead).
- The maintainer's output is a **numbered plain-text list** of
  proposed follow-ons, each with a one-line rationale and the file
  paths or symbol names involved, optionally followed by an
  "out of scope but noticed" section for ancillary findings.
- The reviewer's output is **PR-comment-friendly Markdown** —
  recommendation at the top, findings grouped by severity, optional
  ancillary section.
- Auto-generated idle notifications: noted, not acted on unless they
  affect pending work.

## Marking agent-authored GitHub items

GitHub artifacts raised by an agent should be marked so a reader can
tell at a glance whether a comment, issue, or PR came from an agent
or from a person. The distinction matters for triage — it's signal
that helps reviewers weight the artifact appropriately.

- **Titles** (PRs, issues): prefix with `[claude]`.
- **Bodies and comments** (PR descriptions, issue bodies, PR
  comments, issue comments): append the documented Claude Code
  footer at the end of the body:

  > `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

- **Commits stay clean** — no prefix, no footer — matching the
  conventional repo log style. Commits are immutable history; an
  agent-attribution marker would clutter the log without adding
  signal.

## Hard rules

**Lead never:**
- Edits files (Edit, Write, Serena rename / insert / replace / delete)
- Runs project-specific codegen / index / sync steps
- Fixes lint, format, or test failures directly — bounce them back
- Pushes to `main` without explicit user instruction
- Merges PRs without explicit user instruction
- Originates `shutdown_request`s unless asked

**Developer never:**
- Commits or pushes
- Marks a task complete without lead approval
- Reports done without first running the project's lint/format check
  **and** test suite, both clean
- Proceeds past an ambiguous scope call without flagging it

**Maintainer never:**
- Edits files (read-only by tool design)
- Adds tasks directly to the task list
- Proposes follow-ons that re-litigate already-accepted upcoming
  tasks
- Drifts off-scope into pre-existing concerns the session hasn't made
  visible
- Silently discards out-of-scope observations — surfaces them as
  ancillary findings for the lead to triage as potential issues

**Reviewer never:**
- Edits files (read-only by tool design)
- Posts directly to the PR — only the lead does that
- Proposes triage calls (accept / reject / fix) — only describes
  findings
- Carries memory between PRs — each spawn is fresh
- Silently discards out-of-scope observations — surfaces them as
  ancillary findings for the lead to triage as potential issues
