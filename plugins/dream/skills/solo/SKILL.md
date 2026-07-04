---
name: solo
description:
  Take one issue to a reviewed pull request with a single agent, hands-off. Runs
  a slimmed version of the dream team protocol, from understanding the task
  through building it, then reviewing with fresh subagents and collecting
  findings after merge. Needs no teams feature. Use for a small, well-specified
  task you don't want to one-shot, or when the user runs /dream:solo.
---

# Solo

You run solo: one agent, no team. You take one small task from an issue to a
merged pull request, hands-off, and you keep the codebase coherent as you go.
You spawn subagents only to review, because a fresh reader catches what you
cannot see in your own work.

You run in full auto. You never wait at a gate. You post your reasoning to the
pull request as you go, so the record stands without you. You stop for one thing
only: a decision that is the user's to make. See
[Stop and surface](#stop-and-surface).

The stages below run in order.

## Set up

Ready yourself before you touch the task.

1. Read the writing style guide at `../../writing-style.md`. It sets the
   standard for everything you write.
2. Check the working tree is clean. If it has uncommitted changes, stop and tell
   the user.
3. Detect your setup. On `main`, run `git pull origin main`. In a worktree on a
   branch off `main`, run `git fetch origin main`. On any other setup, stop and
   tell the user.
4. Find the session input. Read the branch name for a `gh<number>` token, such
   as `GH510` or `gh83-fix`, and take that issue as the input. With no token,
   take the input the user gave when they invoked the skill. With neither, stop
   and tell the user you need an issue or a task description.
5. Find how the project tests, lints, and generates code. Look in the README,
   `CLAUDE.md`, `AGENTS.md`, the `Makefile`, or the package manifest. You run
   these yourself before you commit.

## Open the pull request

Open the pull request before you plan, so your reasoning has a home and a
mid-flow stop still leaves a record.

1. Set the session branch. On `main`, create a branch named after the issue
   (`GH510`) or a short slug, and switch to it. In a worktree, the branch
   already exists.
2. Make an empty bootstrap commit, so the draft PR has a commit to anchor to.
   Run `git commit --allow-empty` with a short subject and the `Co-Authored-By`
   trailer. Push the branch.
3. Open a draft PR with `WIP` as the body. Run `gh pr create --draft`. Derive
   the title from the session input.
4. Post the session input as the first comment, headed `What was asked`.

Mark the PR and the comment as agent-authored. See [Conventions](#conventions).

## Understand and plan

Write one Plan. It carries the thinking a good change needs before any code.
Keep it short. A small task needs a few sentences per part.

Cover these, in order:

- **What is asked.** The requirement behind the issue. Who uses the surface, and
  what they need from it. Read the issue and its comments, the cited code, and
  the callers.
- **What the code does now.** The behaviour and shape where the work lands.
  Trace it. Do not infer it from names.
- **Cause, not symptom.** Whether the issue names a symptom of a deeper cause.
  Aim the work at the cause.
- **Scope.** What this task changes, and what it leaves alone. Prefer removal
  where it serves.
- **Approach.** How you will build it. Name the key choice when the approach is
  not obvious.
- **Tasks.** The change as one or a few commit-sized steps.

Consult the project's history as you read. Search the issue tracker for the
surface with `gh issue list --state all --search '<surface>'`. Read the pull
request that last shaped it with `git blame` and `gh pr view <N> --json body`.
This builds on past decisions instead of guessing them again.

Post the Plan to the PR.

Stop here when the task is not small. A genuine fork, a requirement you cannot
resolve, or a scope that keeps widening needs the user. See
[Stop and surface](#stop-and-surface).

## Check the Plan

Spawn one subagent to check the Plan before you write code. A fresh reader
catches a misread you cannot, and catching it now is the cheapest it will be.

Give the subagent the issue, the Plan, and one question: does the Plan address
the issue, and does it fix the cause rather than a symptom? Ask it to read the
cited code itself, and to return concrete findings or say plainly that the Plan
holds. Spawn it read-only. It reads and reports, never edits.

Weigh each finding on its merit, not on the fact the subagent raised it. Revise
the Plan where a finding lands. Post a revision as a new comment that says it
supersedes the earlier Plan, so a reader can tell which is current.

## Build

Build the tasks one at a time. Restore coherence after each, so problems do not
pile onto the next.

For each task:

1. **Implement it.** Read a file before you change it. Find the callers before
   you change a signature.
2. **Keep the codebase coherent.** Apply the same edit everywhere it is due, not
   only where the issue named it. Give each fact one home, so no copy can drift.
   Carry a contract in the type or structure, not in prose. When no type can
   hold it, an assert pins it. When a rule must hold across many sites with no
   single home, enforce it with a check, so a new site cannot silently break it.
3. **Read your change cold.** Reread the diff as the reviewer will. Write down
   each spot where a fresh reader cannot tell a line is right, then fix each: a
   name that hides intent, a clever line, or nesting that buries the main path.
4. **Run the tests and any codegen.** They must pass before you commit.
5. **Commit and push.** One commit per task. Use a short imperative subject and
   the `Co-Authored-By` trailer. See [Conventions](#conventions).

If you notice you have written scaffolding that props up the change, the real
fix is the gap beneath it, not the scaffolding. Scaffolding is a comment
asserting what the code does not show, a mock hiding a real dependency, or a
handler swallowing a fixable error.

If the same surface keeps needing work across tasks, the cause is too big for
one small task. See [Stop and surface](#stop-and-surface).

## Review

Review the finished diff with fresh subagents. You have seen the whole plan, so
you cannot read your own work cold. A subagent that never saw the plan can, and
it stands in for the human who will review next.

Spawn one subagent for the diff. Spawn a few more only when the diff is large,
each matched to what the diff does. A parser invites a malformed-input lens.
Concurrent code invites a races lens. Do not spawn extra subagents for a
one-line fix.

Give each subagent the diff as a git range (`git diff origin/main...HEAD`) and
one lens. Spawn them read-only, on `sonnet`. The lenses:

- **Reconstruct.** Say what the diff does from the diff alone, and name every
  spot it could not tell. Each such spot is a place the code fails to explain
  itself.
- **Coherence.** Read beyond the diff to the siblings and callers. Read what the
  change removed, and confirm the new code still holds it. Find the same edit on
  a surface the diff missed. Check that new or changed tests pin a real
  contract, not decorative surface.
- **Completeness.** Check the diff against the issue, and list any part of the
  requirement it leaves unmet.

Ask each for findings with a file and line, and the concrete consequence of
each. Ask it to say plainly when the code is clean.

Weigh every finding yourself, and merge ones that point at the same spot. Give
each finding one outcome: fix it as a follow-on commit through the Build loop,
drop it with a reason, or hold it for Collect when it is real but out of scope.
When a finding shows the change should not ship as planned and no follow-on can
fix it, do not mark the PR ready. See [Stop and surface](#stop-and-surface).
Post each review as a PR comment, then one response comment saying how you acted
on each finding.

Write the PR description for a reader who has not seen the thread. Open with the
issues addressed, one per line: `Closes #N` for one the PR resolves, and
`Related to #N` for one it partly addresses. Follow with one to three sentences
on what the PR does and why. Then mark the PR ready with `gh pr ready <N>`.

## Deliver and watch

Watch the pull request after you mark it ready. You are hands-off, so you carry
it through the user's response.

Poll the PR for the user's comments, reviews, and state since you marked it
ready:

    gh pr view <N> --json comments,reviews,state

Read `state` first:

- **Merged.** Go to [Collect](#collect).
- **Closed without merge.** The user declined. Post a short closing comment and
  end.

When the PR is still open, act on what the user left:

- **Feedback.** Treat each point as a task through the Build loop. Post a
  response comment, then keep watching.
- **A request to resolve conflicts.** Update the branch so it merges cleanly,
  then keep watching.
- **A request to defer the merge.** Go to Collect with the PR left open. From
  here a new finding becomes an issue, not a commit on the open branch.
- **A question.** Answer it as a PR comment, then keep watching.

Set a recurring `CronCreate` check to run this poll while the session sits idle.
Embed the PR number, the user's login, and the ready timestamp in the cron
prompt. Filter the poll to items from that login and after that timestamp, so
you never act on your own comments. Cancel the cron once the PR merges or
closes, or once you finish Collect on a deferred merge.

## Collect

Collect what the session noticed, so nothing is lost. Run this unattended after
merge, or when the merge is deferred. You need no approval here.

1. **Compile.** Gather the concerns you noticed but left out of scope, the
   review findings you held as out of scope, and the follow-up work the change
   suggests. Merge items that appear more than once into one.
2. **Deepen.** Search open and closed issues for each item's surface with
   `gh issue list --state all --search '<term>'`. An item on a surface with
   prior issues is a recurrence, not a fresh sighting.
3. **Test each concern.** Could removing something resolve it more simply? If
   so, file it as a fresh issue framed around the removal, even when the surface
   defends real behaviour. Otherwise, does the surface defend real behaviour
   with a real consumer? A concern that defends nothing real drops. Follow-up
   work skips this test.
4. **Decide each.** Drop it, comment on an existing issue, or file a new one.
   File a recurrence at the contract level, naming the surface and the prior
   issues.
5. **File** the issues and comments. Label each with a category: `enhancement`,
   `maintenance`, or `bug`.
6. **Summarise.** Post one PR comment listing every issue and comment you filed.
   Skip it when you filed nothing.

## Stop and surface

Stop and surface when the task turns out to need the user. Full auto does not
mean guess. A real decision is the user's to make, and faking it is worse than
the delay.

Stop on:

- a genuine fork with no clear default,
- a requirement you cannot resolve from the issue and the code,
- a scope that keeps widening, or a cause too big for a small task.

Post a comment to the PR, headed `Decision needed`. State what the work
surfaced, and the options you can see. Then end the session. The draft PR holds
the record for when the user returns.

## Conventions

Follow these across every stage.

- **Write to the style guide.** It governs the Plan, the reviews, the PR text,
  and every message to the user.
- **Write GitHub text for an outsider.** The Plan, the reviews, the responses,
  and every comment reach someone who never saw the run. Say plainly what each
  one is. Keep internal words out, such as `lens`, `subagent`, and `session`.
- **Name issues and PRs correctly.** Use `GHNN` to the user. Use `#NN` in GitHub
  text, where it auto-links.
- **Mark agent-authored work.** End PR and issue bodies and comments with the
  footer `🤖 Generated with [Claude Code](https://claude.com/claude-code)`. Add
  the trailer `Co-Authored-By: Claude <claude@anthropic.com>` to commits.
- **Recover a failed GitHub write.** Tell the user, fix the cause, and retry. Do
  not advance as if it landed. The PR is the record.
- **Keep the user posted.** One sentence at each stage on what you are doing.
- **Never** push to `main` or merge the PR yourself.
