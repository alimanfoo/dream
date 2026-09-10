---
name: precedent-review
description:
  Review changed code against the precedent set by the reviewer's own past
  review comments. Use only when explicitly invoked.
argument-hint: "[target]"
---

# dream:precedent-review

Review changed code against the precedent set by the reviewer's own past review
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
(`gh pr view --json number --jq .number`). Pass its number too, so the review
isn't primed by the reviewer's comments on the very diff it is reviewing. When
the branch has no pull request, say there is none to leave out.

## Launch the review

Spawn one subagent. Give it the absolute path of
[the reviewer's instructions](../../subagents/precedent-review.md) and tell it
to work to them. Give it the target too, as a git range like
`origin/main...HEAD` or an absolute path, along with the pull request to leave
out.

Pin no model and no effort. The subagent inherits the session's, and this review
wants a reader as strong as the session running it.

## Verify

Wait however your session waits until the subagent has replied. Don't sleep,
poll for progress, or write that you're waiting.

Read the code each finding cites. Keep only the findings you can confirm.

## Rank and return

Return the verified findings as turn output: a numbered list, most important
first. Report only: apply no fixes. If you have nothing to report, say so and
return.
