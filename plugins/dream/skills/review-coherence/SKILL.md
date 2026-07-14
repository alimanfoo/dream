---
name: review-coherence
description:
  Review changed code across coherence lenses and return the combined findings.
  Reviews the uncommitted changes by default. Name a git range or path to review
  that instead.
argument-hint: "[target]"
---

# Review coherence

Review changed code across coherence lenses and return the combined findings. It
does not apply fixes. Whoever runs it weighs the findings and acts on them.

## Arguments

Read the argument the user gives. It names what to review: a git range like
`main...HEAD`, or a path. Without one, review the uncommitted changes.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens,
briefing each to review the target:

- `dream:review-coherence-root-cause`
- `dream:review-coherence-same-edit`
- `dream:review-coherence-one-home`
- `dream:review-coherence-separation`
- `dream:review-coherence-in-shape`
- `dream:review-coherence-scaffolding`
- `dream:review-coherence-names`

Pass the target as a git range, or as an absolute path. A subagent can't resolve
a path relative to its own prompt file.

Combine their findings into one list, dropping duplicates that point at the same
line or mechanism. Mark which are defects, where the code fails to fit and needs
fixing now, and which are opportunities, where the code fits but a
generalisation would leave it simpler, so the caller can tell the two apart.
