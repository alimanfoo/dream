---
name: plan
description:
  Produces an implementation plan, a list of implementation steps that delivers
  the given focus. Use only when explicitly invoked.
argument-hint: "<focus | text>"
---

# dream:plan

An implementation plan is the ordered list of implementation steps that delivers
the given focus. Each step is one idea and one commit.

Each step states a criterion that tells the implementer which work belongs in
the step. The implementer applies the criterion when starting the step.

Work through the sections below in order.

## Arguments

The argument gives the focus for the plan. Identify the intended result, how the
current code works and is organised, and whether behaviour must be preserved or
changed from that focus. Without an argument, derive the focus from your
context. If you cannot identify a focus, ask the user.

## Compose the draft plan

Compose the draft plan.

Derive steps from the focus. Use the intended result to decide what must change.
Use how the current code works and is organised to decide where the work
belongs. Use the behaviour requirement to keep each step within scope.

Use the intended result instead of translating the original ask directly into
steps. The intended result may have already reshaped the ask.

Each step should be one idea and one commit.

Build each step in this order:

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

Prefer one step with a bounded criterion to a run of special-case steps that
each name a single site. The criterion collapses them into one clean change.

Write the draft plan to a temporary file outside the repo.

## Check each step for a tidying precursor

Read the draft back from the file. Take each step in turn. Name the code it
lands in, and say whether that shape resists the change. See
[Tidy first](../../coherent-coding.md#tidy-first) for what tidying means, why it
pays, and what it looks like.

A shape that resists earns a precursor step only when all of these hold:

- **Tied to a named step.** Say which step it supports. A free-floating cleanup
  doesn't qualify.
- **Behaviour-preserving.** Pure restructure: extract, inline, rename, move,
  split. Nothing a caller relies on changes.
- **Clearly easier or safer.** Without it, the named step would be more
  error-prone, more complex, or reach more places. A cleanup that only makes the
  code look nicer doesn't pass.

Then revise the file, adding each precursor that qualifies as its own step ahead
of the step it supports. Don't invent a cleanup to have something to report.

## Check each step is one idea

Read the draft back from the file. Test each step by its one-line headline. If
the headline needs an "and", the step is two ideas, so split it. A broad
headline can hide two ideas behind one phrase, so weigh the work behind it too:
more than one commit's worth means more than one idea. If a step leaves a change
half-done, it is less than one idea, so merge it into the step that completes
it.

One idea per step keeps each commit clean and its review focused on a single
change. A tidying precursor is a whole change, so leave it as its own step.

Name in turn output each step that isn't one idea. Then revise the file,
splitting or merging each one. When every step is one idea, say so plainly.

## Check each step can be committed

Read the draft back from the file. Read the steps in order, and ask of each:
does it depend on work a later step does? The implementer commits one step at a
time, and the tests and checks must pass at each commit. A step that depends on
later work leaves a check failing, so there is nothing to commit. Shapes to
watch for:

- a step that changes a caller before the step that changes the callee
- a step that removes a symbol a later step still uses

Name in turn output each step that depends on later work. When none does, say so
plainly.

Then revise the file. Reorder the steps so no step depends on work a later step
does. When two steps depend on each other, reordering can't help. Merge them,
and rewrite the headline so it still names one idea. When no headline fits, the
split ran along the wrong line, so split the pair a different way.

## The result

Return the completed plan from the file.
