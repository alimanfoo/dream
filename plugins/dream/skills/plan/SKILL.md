---
name: plan
description:
  Produce a plan for a task, the task list that delivers the design, each task a
  clean single-commit unit selected by a criterion.
argument-hint: "<design and code analysis | text>"
---

# Plan

Produce a plan: the task list that delivers the design. Each task is a
manageable single-commit unit. A criterion selects its work, and the implementer
applies that criterion fresh.

Load the `/dream:writing-style` skill before you write.

Follow the steps in order.

## Arguments

The argument gives the focus for the plan: the accepted design and code analysis
the plan must serve. Without an argument, derive the focus from your context. If
you cannot identify a focus, ask the user.

## Compose the draft plan

Compose the draft plan, the task list that delivers the design.

Derive tasks from the design and the code analysis. The tasks are the work that
delivers the design. Don't translate the session input directly into tasks. The
design has already reshaped it where needed.

Each task should be a manageable unit of work for the implementer, one commit
per task. Test each task by its one-line headline. If the headline needs an
"and," the task is two ideas, so split it. One idea per task keeps each commit
clean and its review focused on a single change. Split tasks that grow beyond
manageable. Fold fragments into a related task.

Build each brief in this order:

- Lead with the goal.
- Name the **criterion** that selects the work.
- Offer concrete examples as scaffold.

The criterion is what makes a site count. Examples illustrate. They don't bound.
The implementer applies the criterion fresh and finds the instances themselves.

Write the criterion so its wording sets its own scope. "Every occurrence of
`foo`" spans wherever the literal appears, tree-wide unless the criterion's
wording bounds it. "Every docstring of kind X in the parser module" bounds
itself to the kind within the parser module. "Rename `foo` to `bar` at
`module.py:42`" has a single application. State it directly, no examples needed.
For kind-based criteria, show two or three examples to anchor the kind.

Prefer one task with a bounded criterion to a run of special-case tasks that
each name a single site. The criterion collapses them into one clean change.

Write the draft plan to a temporary file outside the repo.

## Review the draft

Get an adversarial read before you finish. Launch these review subagents in
parallel, via the Agent tool, one per lens:

- `dream:review-plan-completeness`
- `dream:review-plan-tidy-first`
- `dream:review-plan-implementability`

Brief each with the temporary file's absolute path. A subagent can't resolve a
path relative to its own prompt file. Don't retype the draft into the prompt.
Combine their findings into one list, dropping duplicates.

Judge each finding on its merits, and verify it against your own read. Address
the findings you accept by editing the temporary file:

- A completeness finding adds the missed task.
- A tidy-first finding folds in a behaviour-preserving precursor task before the
  task it supports.
- An implementability finding splits a bundled task, or rewrites a brief to
  surface the criterion it buried.

## Copy-edit the draft

Run the `/dream:copy-edit` skill over the draft file, giving its absolute path.

## The result

Return the completed plan from the file: the task list that delivers the design.
