---
name: review-scope
description: Review Draft Scope Options and return the combined findings.
argument-hint: "<artifact>"
---

# Review scope

Review Draft Scope Options across their lenses and return the combined findings.
It returns findings; it doesn't change the artifact.

## Arguments

Read the argument the user gives. It names the artifact to review: the Draft
Scope Options, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-scope-coherent`
- `dream:review-scope-anticipation`
- `dream:review-scope-root-cause`
- `dream:review-scope-property`

Brief each with the Draft Scope Options under review, the Session Type, and the
accepted Requirements Analysis and Code Analysis, which the lenses need as
context. Give each artifact as an absolute path, not the content retyped. A
subagent can't resolve a path relative to its own prompt file.

Combine their findings into one list, dropping duplicates that point at the same
Scope Option part.
