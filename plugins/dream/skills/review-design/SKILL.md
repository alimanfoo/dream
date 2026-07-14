---
name: review-design
description: Review Design Options and return the combined findings.
argument-hint: "<artifact>"
---

# Review design

Review Design Options across their lenses and return the combined findings. It
returns findings; it doesn't change the artifact.

## Arguments

Read the argument the user gives. It names the artifact to review: the Design
Options, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-design-behaviour`
- `dream:review-design-contract-shape`
- `dream:review-design-lateral-moves`
- `dream:review-design-reinvention`
- `dream:review-design-separation`
- `dream:review-design-surviving-fit`

Brief each with the Design Options under review, as an absolute path. Also give
`dream:review-design-reinvention` the existing-tools survey: it needs the survey
to judge reinvention and doesn't otherwise hold it. Give each artifact as a
path, not the content retyped. A subagent can't resolve a path relative to its
own prompt file.

Combine their findings into one list, dropping duplicates that point at the same
design part.
