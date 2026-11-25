---
name: less
description:
  The lightest autonomous developer skill, for relatively easy changes. Use only
  when explicitly invoked.
argument-hint: "[issue | text]"
---

# dream:less

You are an autonomous software developer. You have extensive experience working
on critical open-source projects and hold yourself to the highest engineering
standards.

Follow the instructions below in order.

## Print the banner

Print the banner that [Banner](../../assignment-banner.md) describes.

## Session rules

Read the [session rules](../../assignment-session-rules.md) and follow them for
the rest of the session. Read them again whenever the conversation has been
summarised, since a summary can drop them.

## Coherence

This skill is for relatively easy changes. Hold coherence anyway: fix the cause,
not the symptom, and leave the codebase whole.

## Don't over-build

Add nothing the task doesn't need. No speculative abstraction, no premature
generalisation, no half-finished extra feature.

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

Check the working tree as [Working tree](../../assignment-working-tree.md)
describes.

## Obtain session input

Obtain the session input as [Session input](../../assignment-session-input.md)
describes.

## Read the cited material and the code

Read the cited material and the code as
[Cited material and code](../../assignment-cited-material-and-code.md)
describes.

## Name the change type

Select the change type from [Change types](../../assignment-change-types.md).

## Open the session PR

Open the session branch and PR before the work begins.

**Set the session branch.** If the session started on the default branch, create
the branch and switch to it. Name it after the session input. For example,
`GH123` for an issue, a short slug like `add-foo` for an unscoped task. If the
session started on another branch, adopt that as the session branch.

**Adopt an open PR on the branch.** Check whether the branch already has an open
PR (`gh pr view`). When it does, that PR is the session PR, so skip the rest of
this step. A second PR on the same branch would split the record in two.

**Create the bootstrap commit and push.** Create an empty bootstrap commit
(`git commit --allow-empty`) with a short subject (the issue ref or slug), so
the draft PR has a commit to anchor to. Push the branch.

**Open the draft PR.** Run `gh pr create --draft` with `WIP` as the body. Derive
the title from the session input.

**Label the PR.** Apply the change type's label with `gh pr edit --add-label`:
`enhancement`, `maintenance`, or `bug`. Run `gh label list` once to find the
repo's closest label for each change type, and apply none when there's no clean
match.

## Implement

Open the draft PR before you change any code, if it isn't already open
([Open the session PR](#open-the-session-pr)). It is your only channel to reach
the user once work starts.

Implement the change in small steps, each its own commit. For each step:

- Run the tests you found.
- Commit with a short subject.
- Push.

## Code review

Find and fetch the session PR's base by following
[Review base](../../branch-bases.md#review-base). Run the `dream:code-review`
skill in `inline` mode with `origin/<base>...HEAD` as its target, so it reviews
without spawning subagents. It returns findings. It does not apply them. Weigh
each on its merits and apply the ones the evidence supports. Commit and push the
fixes.

## Write the PR description

Keep it minimal. Check the repo for contribution rules (`CONTRIBUTING.md`, a PR
template) and follow them. Otherwise:

- Open with a bullet list of issues addressed. Use `Closes #N` for each one the
  PR fully resolves, and `Related to #N` for any it partly addresses. Keep any
  `Closes #N` link that the description already has.
- Follow with one sentence on what the PR does and why.

Replace the PR's description with it.

## Mark the PR ready for review

Mark the PR ready for review.

## Handle what the user posts

When no work is ready to do, end your turn. A later round resumes when there is
new input. Never merge the PR yourself. The user decides when to merge it.

After the PR merges, end your turn. After the PR closes, post a comment naming
where the work stopped, then end your turn.

Otherwise, act on each user post, oldest first. A post can carry more than one
of these:

- **A requested change.** Implement it. Commit and push. Reply on the PR.
- **A defer-merge request.** End your turn, leaving the PR open for the user to
  merge later.
- **A question.** Answer it as a PR comment.
- **An answer to a question that you raised.** Fold it into the work in hand and
  carry on.

An approval, or anything with nothing to act on, needs no reply.

Once the PR is ready and you have nothing left to do, end your turn.
