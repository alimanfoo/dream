---
name: review-plan
description: Review a draft plan and return the combined findings.
argument-hint: "<artifact>"
---

# Review plan

Review a draft plan across different lenses and return the combined findings.

## Arguments

Read the argument the user gives. It names the artifact to review: the draft
plan, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-plan-completeness`
- `dream:review-plan-tidy-first`

Brief each with the artifact's absolute path. A subagent can't resolve a path
relative to its own prompt file. Don't retype the content into the prompt.

Combine their findings into one list, dropping duplicates that point at the same
task.
