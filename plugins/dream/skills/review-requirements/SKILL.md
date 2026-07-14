---
name: review-requirements
description:
  Review a Draft Requirements Analysis and return the combined findings.
argument-hint: "<artifact>"
---

# Review requirements

Review a Draft Requirements Analysis across its lenses and return the combined
findings. It returns findings; it doesn't change the artifact.

## Arguments

Read the argument the user gives. It names the artifact to review: the Draft
Requirements Analysis, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-requirements-consumer-value`
- `dream:review-requirements-project-purpose`
- `dream:review-requirements-coherence`

Brief each with the artifact's absolute path. Give the path in the prompt, not
the content retyped. A subagent can't resolve a path relative to its own prompt
file.

Combine their findings into one list, dropping duplicates that point at the same
claim.
