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

Write every turn output and artefact in this skill using `/dream:plain-english`.

Follow the steps in order.

## Arguments

The argument gives the focus for the plan: the accepted design and code analysis
the plan must serve. Without an argument, derive the focus from your context. If
you cannot identify a focus, ask the user.

## Compose the draft plan

Compose the draft plan, the task list that delivers the design.

Derive tasks from the design and the code analysis. Don't translate the session
input directly into tasks. The design has already reshaped it where needed.

Each task should be a manageable unit of work for the implementer, one commit
per task.

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

## Check the tidying comes first

Read the draft back from the file. Ask of each task: would it go more cleanly if
a small precursor cleanup made the change easy first? New code forced to fit
around a shape that no longer suits it comes out more complex (see
[Tidy first](../../coherent-coding.md#tidy-first)). Examples:

- extract a helper before adding a sibling case
- rename a confusing parameter before threading new arguments
- split a tangled function before adding a branch

A precursor qualifies only when all of these hold:

- **Tied to a named task.** Say which planned task it supports. A free-floating
  cleanup doesn't qualify.
- **Behaviour-preserving.** Pure restructure: extract, inline, rename, move,
  split. No contract change.
- **Clearly easier or safer.** Without it, the named task would be more
  error-prone, more complex, or reach more places. A cleanup that only makes the
  code look nicer doesn't pass.

Name in turn output each task that needs a precursor, and the precursor it
needs. Then revise the file, adding each precursor as its own task ahead of the
task it supports. When no task needs one, say so plainly. Don't invent a cleanup
to have something to report.

## Check each task is manageable

Read the draft back from the file. Test each task by its one-line headline. If
the headline needs an "and", the task is two ideas, so split it. One idea per
task keeps each commit clean and its review focused on a single change.

Name in turn output each task that holds more than one idea. Then revise the
file, splitting each one. When every task holds one idea, say so plainly.

## Check each task can be committed

Read the draft back from the file. Read each task as the implementer, and ask
whether the tests and checks pass once they have done that task and nothing
else. The implementer commits one task at a time. A task that leaves a check
failing has nothing it can commit. Shapes to watch for:

- a task that changes a caller before the task that changes the callee
- a task that removes a symbol later tasks still use
- a fragment of a change, too small to stand on its own

Merge each failing task into the task that completes it. Rewrite the merged
task's headline so it still names one change. If no such headline fits, the
merge was wrong, and the task boundary is the real problem.

Name in turn output each task that can't be committed on its own. Then revise
the file. When every task can, say so plainly.

## The result

Return the completed plan from the file: the task list that delivers the design.
