---
name: review-design
description: Review design options and return the combined findings.
argument-hint: "<artifact>"
---

# Review design

Review design options across different lenses and return the combined findings.

## Arguments

Read the argument the user gives. It names the artifact to review: the design
options, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-design-behaviour`
- `dream:review-design-contract-shape`
- `dream:review-design-lateral-moves`
- `dream:review-design-reinvention`
- `dream:review-design-separation`
- `dream:review-design-surviving-fit`

Brief each with the design options under review. Also give
`dream:review-design-reinvention` the existing-tools survey: it needs the survey
to judge reinvention and doesn't otherwise hold it. Pass each as an absolute
path. A subagent can't resolve a path relative to its own prompt file. Don't
retype the content into the prompt.

Combine their findings into one list, dropping duplicates that point at the same
design part.
