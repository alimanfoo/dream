---
name: design
description:
  Produce design options for a task, a recommended design plus any credible
  alternatives.
argument-hint: "<requirements and code analysis | text>"
---

# Design

Produce design options: the proposed design, your recommendation for what the
code will look like when the work is done, and any credible alternative designs.

Write every turn output and artefact in this skill using `/dream:plain-english`.

Load the `/dream:coherent-coding` skill. It provides guiding principles for the
design you propose.

Follow the steps in order.

## Arguments

The argument gives the focus for the design: the accepted requirements and code
analysis the design must serve. Without an argument, derive the focus from your
context. If you cannot identify a focus, ask the user.

## Generate analogies

Generate a spread of analogies for the work before sketching, so the sketches
draw on ideas and patterns carried in from elsewhere rather than invented cold.
An analogy is something this work resembles (a feature, a bug, a structure, a
technique), paired with what happened there. Near analogies come from the same
problem domain. Far ones come from a different domain entirely. Several
analogies, near and far, give the sketch step more to draw on.

Write the analogies as turn output, a numbered list, near and far.

## Survey existing tools

Survey the existing tools that could meet the need, so the sketches reach for an
existing building block before inventing one. Name every entry that could
address the need, in part or in full, external or internal.

- **External**: a library, a standard algorithm or technique, or a language or
  platform feature. Common examples: an argument parser, date arithmetic, a
  state machine, topological sort, retry-with-backoff, or an LRU cache.
- **Internal**: a helper, module, or pattern already in this tree that does the
  same job.

Search the web when the problem domain likely has tooling you don't already
know. Check an entry on the web too before ruling it out or downgrading it from
memory alone. Your knowledge of it may be a year or so out of date.

Tag each entry: **fully addresses** or **partially addresses** the need, naming
the gap when it's partial. Say why any entry you don't recommend falls short. If
nothing applies, say so.

Write the survey as turn output, a numbered list. It feeds your sketches next.

## Generate design sketches

Sketch a spread of design approaches, drawing on your analogies and survey where
they help. A sketch is brief: a few lines naming one way to approach the work
and the shape it would take. Not a fully worked design.

Write the sketches as turn output, a numbered list.

## Draft the design options

Consolidate the sketches into the design options: the proposed design (your
recommendation) and any credible alternative designs.

### The proposed design

Describe what the code will look like when the work is done, the approach
proposed, and the key design calls that follow from the code analysis. Depth
scales with session type:

- _Enhancement:_ the **happy-path contract** (what valid inputs produce what
  outputs, where it slots in, how callers interact with it). Then the **input
  contract** (what input space is supported, and what happens on inputs outside
  it: error, fallback, or rejection). For example, for integer parsing,
  non-numeric input might raise, return None, or return 0. Also the key
  integration calls.
- _Maintenance:_ the target shape, the surface when the work is done: which
  name, which structure, which abstraction wins, and the migration path.
- _Bug fix:_ the fix approach. For straightforward bugs, one or two sentences.
  When more than one fix shape is plausible (defensive check, structural fix,
  removal), name the alternatives and why this one.

The input may steer the design: a library, framework, or approach to use. Source
that steer and weigh it with the sketches, on its merits. It is the user's steer
on the how, not a fixed requirement. Take it in the proposed design unless you
have reason to set it aside. The user decides whether to set it aside. Recommend
the alternative and flag the steer prominently in the result. Don't override it
silently.

Prefer re-use of an existing library over custom code, but weigh the trade-offs.

Serve only the consumers the requirements name. A consumer you invent widens the
design with no one to serve.

Reshape the proposed design around the real structural fix, even when the input
asked for a docstring or comment change. The design follows the code, not the
input's literal wording.

### The alternative designs

Keep each strong sketch you did not pick as an alternative design. It qualifies
when it still delivers the full requirements and reaches the same coherent
resolution, but its difference costs something. Name the trade-off: a new
dependency, more coupling, less flexibility.

A sketch that delivers less than the requirements, or stops short of the
coherent resolution, is not an alternative. It is a change to the requirements.
Flag it prominently in the result if it has merit, rather than folding it in.

Write the design options to a temporary file outside the repo.

## Revise the design against the coherent coding guide

Take the [coherent coding guide](../../coherent-coding.md) one section at a
time, and consider whether the draft design could be improved. Do this for the
proposed design and for each alternative design. A gap you leave here becomes a
gap in the code.

Revise the file to implement each improvement you found.

Then write in your turn output which sections changed in the design. Say so if
none did.

## The result

Return the completed design options from the file: the proposed design and any
alternative designs with their trade-offs.
