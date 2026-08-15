---
name: plan
description:
  Produce an implementation plan, a task list that delivers a design or a
  well-specified task. Use only when explicitly invoked.
argument-hint:
  "<design and code analysis | task, code read and session type | text>"
---

# Plan

A plan is the task list that delivers the given focus. Each task is one idea and
one commit.

Each task states a criterion that tells the implementer which work belongs in
the task. The implementer applies the criterion when starting the task.

Write every turn output and artefact in this skill using `dream:plain-english`.

Follow the steps in order.

## Arguments

The argument gives the focus for the plan in one of these forms:

- a design and code analysis
- a well-specified task, verified code read, and session type

Without an argument, derive the focus from your context. If you cannot identify
a focus, ask the user.

## Compose the draft plan

Compose the draft plan.

Derive tasks from the design and code analysis when they are available. For a
task-led focus, use the well-specified task to set the intended result. Use the
verified code read to choose work that fits the current code. Use the session
type to preserve or change behaviour as the task requires. Don't invent a
separate design phase.

Use the design or task's stated direction instead of translating raw session
input directly into tasks. That direction may have already reshaped the original
ask.

Each task should be one idea and one commit.

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

## Check each task for a tidying precursor

Read the draft back from the file. Take each task in turn. Name the code it
lands in, and say whether that shape resists the change. See
[Tidy first](../../coherent-coding.md#tidy-first) for what tidying means, why it
pays, and what it looks like.

A shape that resists earns a precursor task only when all of these hold:

- **Tied to a named task.** Say which planned task it supports. A free-floating
  cleanup doesn't qualify.
- **Behaviour-preserving.** Pure restructure: extract, inline, rename, move,
  split. Nothing a caller relies on changes.
- **Clearly easier or safer.** Without it, the named task would be more
  error-prone, more complex, or reach more places. A cleanup that only makes the
  code look nicer doesn't pass.

Then revise the file, adding each precursor that qualifies as its own task ahead
of the task it supports. Don't invent a cleanup to have something to report.

## Check each task is one idea

Read the draft back from the file. Test each task by its one-line headline. If
the headline needs an "and", the task is two ideas, so split it. A broad
headline can hide two ideas behind one phrase, so weigh the work behind it too:
more than one commit's worth means more than one idea. If a task leaves a change
half-done, it is less than one idea, so merge it into the task that completes
it.

One idea per task keeps each commit clean and its review focused on a single
change. A tidying precursor is a whole change, so leave it as its own task.

Name in turn output each task that isn't one idea. Then revise the file,
splitting or merging each one. When every task is one idea, say so plainly.

## Check each task can be committed

Read the draft back from the file. Read the tasks in order, and ask of each:
does it depend on work a later task does? The implementer commits one task at a
time, and the tests and checks must pass at each commit. A task that depends on
later work leaves a check failing, so there is nothing to commit. Shapes to
watch for:

- a task that changes a caller before the task that changes the callee
- a task that removes a symbol a later task still uses

Name in turn output each task that depends on later work. When none does, say so
plainly.

Then revise the file. Reorder the tasks so no task depends on work a later task
does. When two tasks depend on each other, reordering can't help. Merge them,
and rewrite the headline so it still names one idea. When no headline fits, the
split ran along the wrong line, so split the pair a different way.

## The result

Return the completed plan from the file.
