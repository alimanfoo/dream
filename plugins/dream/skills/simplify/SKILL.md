---
name: simplify
description:
  Review changed code for reuse, simplification, efficiency, and altitude, then
  apply the fixes. Reviews the uncommitted changes by default. Name a git range
  or path to review that instead.
argument-hint: "[target]"
---

# Simplify

Review changed code for reuse, simplification, efficiency, and altitude, then
apply the fixes, so the code reads more clearly. It improves how the code reads;
it does not hunt for correctness bugs.

## Arguments

Read the argument the user gives. It names what to review: a git range like
`main...HEAD`, or a path. Without one, review the uncommitted changes.

## Review and apply

Launch these review subagents in parallel, via the Agent tool, one per lens,
briefing each to review the target:

- `dream:simplify-reuse`
- `dream:simplify-simplification`
- `dream:simplify-efficiency`
- `dream:simplify-altitude`

Combine their findings. Judge each on its merits. Apply the fixes that hold, and
skip any that would change behaviour.
