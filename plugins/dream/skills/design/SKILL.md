---
name: design
description:
  Produce the Design Options for a task, a recommended design plus any credible
  alternatives. Assumes the requirements, code analysis, and scope are in
  context. Runs a spread of analogies, an existing-tools survey, and design
  sketches, then reviews and refines the result.
argument-hint: "<requirements, code analysis, and scope | text>"
---

# Design

Produce the Design Options: the Proposed Design, your recommendation for what
the code will look like when the work is done, and any credible Alternative
Designs. The result is the option a reader can act on, with the trade-offs of
each alternative named.

Read the [writing style guide](../../writing-style.md) before you write. It is
the standard for the Design Options and every message you write.

Follow the steps in order.

## Arguments

The argument gives the focus for the design: the accepted requirements, code
analysis, and session scope the design must serve. Without an argument, derive
the focus from your context. If you cannot identify a focus, ask the user.

The design rests on prior reads, assumed already in context: what the work must
achieve (the requirements), how the current code works and is organised (the
code analysis), and the work committed to (the scope). Name the Session Type
from them, since it sets the depth of the design.

## Generate analogies

Generate a spread of analogies for the work before sketching, so the sketches
draw on ideas and patterns carried in from elsewhere rather than invented cold.
An analogy is something this work resembles (a feature, a bug, a structure, a
technique), paired with what happened there. Near analogies come from the same
problem domain. Far ones come from a different domain entirely. Several
analogies, near and far, give the sketch step more to draw on. Don't filter for
relevance here. Quantity and spread are the goal.

Write the analogies as turn output, a numbered list, near and far.

## Survey existing tools

Survey the existing tools that could meet the need, so the sketches reach for a
building block already to hand before inventing one. Name every entry that could
address the need, in part or in full. Both are knowledge you hold but rarely
volunteer:

- **External**: a library, a standard algorithm or technique, or a language or
  platform feature. Common examples: an argument parser, date arithmetic, a
  state machine, topological sort, retry-with-backoff, or an LRU cache.
- **Internal**: a helper, module, or pattern already in this tree that does the
  same job. Shallow reading hides these, so the same fact ends up with a second
  home.

Search the web when the problem domain likely has tooling you don't already
know. Check an entry on the web too before ruling it out or downgrading it from
memory alone. Your knowledge of it may be a year or so out of date.

Tag each entry: **fully addresses** or **partially addresses** the need, naming
the gap when it's partial. Say why any entry you don't recommend falls short. If
nothing applies, say so. An empty result is valid when the search was genuine.

Write the survey as turn output, a numbered list. It feeds your sketches next.

## Generate design sketches

Sketch a spread of design approaches, before any single design is chosen,
drawing on your analogies and survey where they help. A sketch is brief: a few
lines naming one way to approach the work and the shape it would take. Not a
fully worked design. Several rough sketches across different approaches are
worth more here than one polished one.

Write the sketches as turn output, a numbered list.

## Draft the Design Options

Consolidate the sketches into the Design Options: the Proposed Design (your
recommendation) and any credible Alternative Designs. Choose the recommendation
and the alternatives together, from the pool.

**The Proposed Design.** Name what the code will look like when the work is
done, the approach proposed, and the key design calls that follow from the code
analysis. Depth scales with Session Type:

- _Enhancement:_ the **happy-path contract** (what valid inputs produce what
  outputs, where it slots in, how callers interact with it). Then the **input
  contract** (what input space is supported, and what happens on inputs outside
  it: error, fallback, or rejection). For example, for integer parsing,
  non-numeric input might raise, return None, or return 0. Also the key
  integration calls.
- _Maintenance:_ the target shape, the surface when the work is done: which
  name, which structure, which abstraction wins, and the migration path.
- _Bug fix:_ the fix approach. When more than one fix shape is plausible
  (defensive check, structural fix, removal), name the alternatives and why this
  one. For straightforward bugs this is one or two sentences.

The input may steer the design: a library, framework, or approach to use. Source
that steer and weigh it with the sketches, on its merits. It is the user's steer
on the how, not a fixed requirement. Take it in the Proposed Design unless you
have reason to set it aside. Setting it aside is the user's call, so don't
override it silently: recommend the alternative and flag the steer prominently
in the result, for the user to decide.

Check the Proposed Design against common overcomplication defaults:

- consumers the requirements don't name
- surfaces held "for the future" or "for downstream" with no current consumer
- failure modes from over-flexible interfaces
- abstraction held "for symmetry" with only one real branch

Remove any code the change leaves purposeless. When a function the Design
modifies has no remaining purpose after the change, the same Design removes it.

Reshape the Proposed Design around the real structural fix, even when the input
asked for a docstring or comment change. Example: "expand the docstring to
express a contract". But the signature doesn't enforce it, so the docstring has
to. The design follows the code, not the input's literal wording.

Carry a contract, invariant, precondition, or convention in the shape of the
code, not in a docstring, comment, or section-header. A type or a module
boundary holds it more reliably than prose a reader can skip. Reach for prose
only when no shape carries the meaning.

**The Alternative Designs.** Keep each strong sketch you did not pick as an
Alternative Design. It qualifies when it still delivers the full session scope
but buys its difference at a cost. Name the trade-off: a new dependency, more
coupling, less flexibility. Reaching for an existing library in place of custom
code is a common trade-off. Surface it when a sketch points that way. A sketch
that delivers less than the session scope is not an Alternative. It is a scope
change. Flag it prominently in the result if it has merit, rather than folding
it in.

Write the Design Options to a temporary file outside the repo. Report the
consolidation honestly, including an empty result:

- which sketches folded into the Proposed Design
- which became Alternatives, with their trade-offs
- which you set aside and why

## Review the draft

Get an adversarial read before you finish. Launch these review subagents in
parallel, via the Agent tool, one per lens:

- `dream:review-design-behaviour`
- `dream:review-design-contract-shape`
- `dream:review-design-lateral-moves`
- `dream:review-design-reinvention`
- `dream:review-design-separation`
- `dream:review-design-surviving-fit`

Brief each with the temporary file's absolute path. A subagent can't resolve a
path relative to its own prompt file. Don't retype the draft into the prompt.
Also give `dream:review-design-reinvention` the existing-tools survey you wrote,
since that subagent doesn't hold your context. Combine their findings into one
list, dropping duplicates.

Judge each finding on its merits, and verify it against your own read. A
subagent raising a finding is not itself a reason to fold it in. Address the
findings you accept by editing the temporary file. A candidate lateral move that
is strictly better folds into the Proposed Design. One that buys its difference
at a cost joins the Alternative Designs, with its trade-off named.

A finding may reach beyond the Design. It may point at a scope change or an
earlier read that no longer holds, or it may be real but outside the current
scope. Don't swallow either. Name it in the result, kept separate from the
Design, so it is carried forward rather than lost.

## Copy-edit the draft

Run the `dream:copy-edit` skill over the draft file, giving its absolute path.
The Design Options are what the reader weighs to choose a direction, so their
readability matters.

## The result

Return the completed Design Options from the file: the Proposed Design, any
Alternative Designs with their trade-offs, and any finding that reached beyond
the Design, kept separate so it is carried forward.
