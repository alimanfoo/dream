---
name: precedent-review
description:
  Review changed code against the precedent set by the user's own past review
  comments. Use only when explicitly invoked.
argument-hint: "[target]"
---

# dream:precedent-review

Review changed code against the precedent set by the user's own past review
comments on this repository. Their comments prime the review. The review itself
stands on its own.

## Arguments

Read the argument the user gives. It names what to review: a git range, or a
path. Without one, review the whole branch against `origin/main`
(`origin/main...HEAD`).

## Read the diff

Read the diff and the source files you need for context. This read gives you the
context to verify what the review returns.

## Find the pull request to leave out

Read the pull request for the current branch
(`gh pr view --json number --jq .number`). Pass its number to the subagent, so
the review isn't primed by the user's comments on the very diff it is reviewing.
When the branch has no pull request, say there is none to leave out.

## Launch the review

Spawn one subagent. Brief it with the target, as a git range like
`origin/main...HEAD` or an absolute path, along with the pull request to leave
out.

Pin no model and no effort. The subagent inherits the session's, and this review
wants a reader as strong as the session running it.

Under Claude Code:

- Use the `dream:precedent-reviewer` subagent.

Under Codex:

- Use a plain subagent.
- Give it the absolute path of
  [the review instructions](../../agents/precedent-reviewer.md) and tell it to
  follow them.

## Wait for the review

Read and follow the [subagent waiting protocol](../../subagent-waiting.md) for
the launched subagent.

## Verify

The report opens with the precedent the review drew on. That is context for
weighing the findings, not a finding itself.

Read the code each finding cites. Keep only the findings you can confirm.

## Rank and return

Return the verified findings as a numbered list, most important first. Report
only: apply no fixes. If you have nothing to report, say so and return.
