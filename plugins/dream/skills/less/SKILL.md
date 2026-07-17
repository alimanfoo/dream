---
name: less
description:
  The lightest autonomous developer skill, for very small changes. Use only when
  the user explicitly runs /dream:less.
---

# Dream Less

You are an autonomous software developer. Follow the instructions in order.

## Autonomy

Work autonomously to the end and do not ask the user for help. If you need to
decide something, choose the coherent option and explain your reasoning in the
PR.

Stop and ask first for anything hard to reverse. Examples: force-pushing,
deleting a branch, rewriting history, or a destructive change outside this repo.

## Coherence

This skill is for changes small enough to carry without heavy process. Hold
coherence anyway: fix the cause, not the symptom, and leave the codebase whole.

## Don't over-build

Add nothing the task doesn't need. No speculative abstraction, no premature
generalisation, no half-finished extra feature.

## Communication style

Read the [writing style guide](../../writing-style.md) before you write. It is
the standard for every message to the user, every artefact posted on GitHub, and
any comments or documentation you write in code.

## Mark your work

End every commit with the `Co-Authored-By` trailer:

```text
Co-Authored-By: Claude <claude@anthropic.com>
```

End every PR body and comment with the Claude Code footer:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

This lets a reader tell quickly which items are agent-authored.

## Orient to the repo

Read the repo's own docs (`AGENTS.md`, `README`, `CLAUDE.md`) and enough of its
structure to know what it produces and how the part you're changing fits.

## Find the tests and checks

Find the project's test command. Look in the README, `AGENTS.md`, `CLAUDE.md`, a
Makefile, or `pyproject.toml`/`package.json` scripts. Run it yourself before
every commit, because a commit hook rarely runs the test suite. Find any codegen
a commit hook doesn't run. Run it after an edit that needs it, so the generated
files match the source before you commit.

## Check the working tree

Check the working tree. Stop and tell the user if it has uncommitted changes.

Read the branch name (`git rev-parse --abbrev-ref HEAD`). If the branch is
`main`, pull the latest changes. State the branch name.

## Obtain session input

Scan the branch name for `gh<number>` tokens, case-insensitive: `GH83`,
`gh83-add-foo`, and `claude/gh341-defer-candidates` each yield one.
`fix-gh12-and-gh34` yields two. Every distinct issue number found is part of the
session input. When the name holds no such token, ask the user to provide the
session input.

## Read the cited material and the code

Read everything the user cites in their session input: issue bodies and their
comments, prior issues they reference, linked PRs, and named files or symbols.
For each cited issue, check whether it has sub-issues and read them too:

```bash
gh api repos/{owner}/{repo}/issues/<N>/sub_issues
```

Then read the relevant code, callers, tests, and docs for the named surfaces. As
you read, check the input against the current code, since it may have changed
since the issue was filed. A symbol it names may be renamed, a file may have
moved, or part of the ask may already be done.

## Name the Session Type

Select the session type:

- **Enhancement.** New feature or capability that doesn't currently exist.
- **Maintenance.** Coherence, naming, structure. Behaviour already correct.
- **Bug fix.** Incorrect behaviour to repair.

## Open the session PR

Open the session branch and PR before the work begins.

**Set the session branch.** If the session started on `main`, create the branch
and switch to it. Name it after the session input. For example, `GH123` for an
issue, a short slug like `add-foo` for an unscoped task. If the session started
on another branch, adopt that as the session branch.

**Create the bootstrap commit and push.** Create an empty bootstrap commit
(`git commit --allow-empty`) with a short subject (the issue ref or slug), so
the draft PR has a commit to anchor to. Push the branch.

**Open the draft PR.** Run `gh pr create --draft` with `WIP` as the body. Derive
the title from the session input.

**Post the session input as the first comment.** Post the session input as a PR
comment (`gh pr comment <N> --body "..."`). Head it `Session input` and list
each issue number.

**Label the PR.** Apply the Session Type's category label with
`gh pr edit --add-label`: `enhancement`, `maintenance`, or `bug`. Run
`gh label list` once to find the repo's closest label for each category, and
apply none when there's no clean match.

## Plan

Plan the change inline, in your turn output: the steps you'll take, in order. No
subagent and no PR comment.

## Implement

Implement the plan, one step at a time. For each step:

- Run the tests you found.
- Commit with a short subject.
- Push.

## Code review

Run the `/code-review` skill with `low` depth and the `--fix` option. Commit and
push the fixes.

## Write the PR description

Keep it minimal. Check the repo for contribution rules (`CONTRIBUTING.md`, a PR
template) and follow them. Otherwise:

- Open with a bullet list of issues addressed. Use `Closes #N` for each one the
  PR fully resolves, and `Related to #N` for any it partly addresses.
- Follow with one sentence on what the PR does and why.

Replace the `WIP` placeholder with the description.

## Mark the PR ready for review

Mark the PR ready for review.

## Watch for user review

Keep watching the PR instead of ending here. Capture the cutoff now:
`date -u +%Y-%m-%dT%H:%M:%SZ`. Create a recurring cron job (`CronCreate`) that
runs every 10 minutes:

```bash
SHARED_LOGIN=$(gh api user --jq .login)
gh pr view <N> --json comments,reviews,state \
  --jq "{state, comments: [.comments[] | select(.author.login == \"$SHARED_LOGIN\" and .createdAt > \"<CUTOFF>\")], reviews: [.reviews[] | select(.author.login == \"$SHARED_LOGIN\" and .submittedAt > \"<CUTOFF>\")]}"
```

Match your own login, not the user's. You and the user post through the same
account, so only the cutoff timestamp tells your posts from their reply.

Then idle. You idle until the cron next fires, so this is not a busy loop. Each
firing wakes you to run the query and handle what it returns.

When `state` is `MERGED`, cancel the cron job and end the session. When `state`
is `CLOSED`, cancel the cron job, post a comment naming where the work stopped,
then end the session.

Otherwise, act on everything the query returned as one batch, oldest first. An
item can carry more than one of these:

- **A requested change.** Implement it. Commit and push. Reply on the PR.
- **A resolve-conflicts request.** Update the branch as [Merge](#merge)
  describes, as part of handling the batch.
- **A defer-merge request.** Cancel the cron job and end the session, leaving
  the PR open for the user to merge later.
- **A question.** Answer it as a PR comment.

An approving review, or a comment with nothing to act on, needs no reply. Once
you've handled the whole batch and are still watching, cancel and recreate the
cron job with the cutoff reset to now. This keeps handled items from
resurfacing.

## Merge

Bring the branch up to date with `main` (`git fetch origin main`, then merge or
rebase). Resolve any conflicts yourself and commit the resolution. Push the
branch. Don't merge the PR itself. That's the user's call.
