---
name: stranger
description:
  Re-derive a module, pull request, or design from its problem alone, blind to
  the current solution, and report how the re-derivation differs.
argument-hint: "<module path | pull request | design doc | text>"
---

# Stranger

Ask a fresh agent that has never seen the solution to design it again from the
problem alone, then compare the two. The comparison shows which concepts the
problem needs, and which ones only history explains.

Load the `/dream:plain-english` skill before you write.

Follow the steps in order.

## Arguments

The argument names the target: a module or package path, a pull request, or a
design document. Without an argument, derive the target from your context. If
you cannot identify a target, ask the user.

## Name the solution and its boundary

Write down, as turn output, what the solution is and what its boundary is. The
solution is the thing under judgment. The boundary is the problem it solves and
the contract the world holds it to.

- **A module or package.** The solution is the code inside it. The boundary is
  the behaviour its tests and callers rely on.
- **A pull request.** The solution is the diff. The boundary is the problem in
  the issue, and the code as it stands before the change. A pull request
  description mixes problem and solution. Take its problem statement and leave
  its solution talk.
- **A design document.** The solution is the proposed design. The boundary is
  the requirements it serves.

A name from the solution belongs to the boundary only when changing it is off
the table: a wire format, a command-line interface, an API that callers outside
this repo depend on. Every other name is part of the solution, however public it
looks. The current shape of the code never justifies itself.

## Compose the brief

Compose the brief the stranger will design from. Do this before you read the
solution. What you have read leaks into what you write, so an early look at the
solution smuggles its concepts into the brief through your own paraphrase. At
this step read only boundary material: the tests, the call sites, the issue, the
requirements.

The brief carries:

- **Scenarios.** Each behaviour as a concrete story: this input, this outcome.
  Take them from the tests and the issue. Include the hardest cases the tests
  cover, with real values. Vague scenarios get you a generic design that
  compares against nothing.
- **Constraints.** What the design must live with: the fixed interfaces from the
  boundary, the platform, anything the solution cannot choose.

If you cannot ground the brief in concrete scenarios, stop and tell the user
what is missing. Don't run the comparison on a vague brief.

## Scrub the brief

Rewrite the brief in the words of the problem domain. Remove every name the
solution invented: class names, module names, layer names, the vocabulary of the
current decomposition. A reader of the brief should learn what the solution must
do, and nothing about how the current one is organised. The fixed interfaces
named in the constraints stay as they are.

## Spawn the stranger

Spawn the `dream:stranger` subagent via the Agent tool, with the full brief
inline in its prompt. The subagent has no file tools, so it cannot read the
repo, and a file path won't reach it. That blindness is the point: its design is
only evidence if it never saw the solution.

The stranger returns the smallest design it can defend, with every scenario
walked through it. If it reports a gap in the brief that breaks the comparison,
repair the brief and spawn a fresh stranger, once.

## Read the solution

Now read the solution in full. List its concepts: the named parts a maintainer
must hold in mind to work on it. For a module, its classes, layers, and
mechanisms. For a pull request, what the diff adds or reshapes. For a design
document, the parts the proposal introduces.

## Compare and report

Map the stranger's concepts onto the solution's, and report the comparison as
turn output, kept to about one screen:

- The solution's concepts, named.
- The stranger's concepts, named.
- What the stranger did without, and how its design covers the same scenarios
  anyway.
- What the solution handles that the stranger missed. Say whether each is a real
  constraint the brief failed to carry, or work the problem never asked for.
- One or more pointed questions, each naming a solution concept whose work the
  stranger's design does with less.

Report only. Apply no fixes. The gap between the two designs is information, not
a verdict: the stranger's simpler shape can be wrong for reasons the brief never
carried. Whether to act on the comparison is the user's call.
