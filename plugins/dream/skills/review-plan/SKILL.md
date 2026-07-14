---
name: review-plan
description: Review a Draft Plan and return the combined findings.
argument-hint: "<artifact>"
---

# Review plan

Review a Draft Plan across its lenses and return the combined findings. It
returns findings; it doesn't change the artifact.

## Arguments

Read the argument the user gives. It names the artifact to review: the Draft
Plan, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-plan-completeness`
- `dream:review-plan-tidy-first`

Brief each with the artifact's absolute path. Give the path in the prompt, not
the content retyped. A subagent can't resolve a path relative to its own prompt
file.

Combine their findings into one list, dropping duplicates that point at the same
task.
