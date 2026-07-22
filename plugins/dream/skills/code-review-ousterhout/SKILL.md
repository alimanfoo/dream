---
name: code-review-ousterhout
description:
  Review changed code through lenses from Ousterhout's "A Philosophy of Software
  Design", and return the combined findings.
argument-hint: "[target]"
---

# Ousterhout review

Review changed code through lenses from Ousterhout's "A Philosophy of Software
Design", and return the combined findings.

## Arguments

Read the argument the user gives. It names what to review: a git range like
`main...HEAD`, or a path. Without one, review the whole branch against `main`
(`main...HEAD`).

## The lenses

Each lens is one narrow question about the change's design, answerable from the
diff alone.

### Module depth

Does this unit's interface pay for itself? Weigh what it hides against what a
caller must learn to use it. A shallow module, whose interface costs about as
much as it saves, is the failure to look for. Signs:

- a wrapper or method that hides almost nothing behind its signature.
- a pass-through layer that forwards its arguments to the next layer without
  adding abstraction.
- two adjacent layers that look almost identical, so one is not earning its
  keep.
- complexity pushed onto callers through configuration, special-case parameters,
  or exposed edge cases, that the implementation could absorb instead. Callers
  outnumber implementers, so the implementation is the cheaper place for it.

### Temporal decomposition

Is the code split by the order its operations run in, rather than by what each
part hides? When execution order drives the structure, it becomes a dependency
between units that should not have one. Look for steps carved into separate
units only because one runs after another, where a single unit hiding the whole
job would serve better.

### Define errors out of existence

Does the change add special-case error handling for a case the interface could
be redesigned to rule out? Ask whether the interface's semantics could be
defined so the error never arises, instead of detecting and reporting it.
Ousterhout's example is a substring operation that clamps out-of-range indices
to the string's bounds, so it cannot raise an out-of-range error at all.

## Review

Launch the generic `dream:code-review-lens` subagent, via the Agent tool, once
per lens above. Send them all in a single message so they run in parallel. Brief
each with the target and one lens: its heading and the text beneath it. Pass the
target as a git range like `main...HEAD`, or as an absolute path. A subagent
can't resolve a path relative to its own prompt file.

Combine their findings into one list, dropping duplicates. Mark each as a defect
or an opportunity, so the caller can tell them apart. A shallow module is rarely
a defect. More often it is an opportunity to simplify, hiding more behind less.
