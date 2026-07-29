---
name: stranger
description:
  Re-derive a module, pull request, or design from its problem alone, blind to
  the current solution, and report how the re-derivation differs.
argument-hint: "<module path | pull request | design doc | text>"
---

# Stranger

Re-derive the solution from its problem alone, and compare. A stranger, a fresh
agent that has never seen the solution, designs it again from a brief you
compose. The comparison shows which concepts the problem needs, and which ones
only history explains.

Load the `/dream:plain-english` skill before you write.

Follow the steps in order.

## Arguments

The argument names the target: a module or package path, a pull request, or a
design document. Without an argument, derive the target from your context. If
you cannot identify a target, ask the user.

## Name the solution and the problem

Write down, as turn output, what the solution is and what the problem is. The
solution is the thing under judgment. The problem is what the solution must
achieve, and the contract the world holds it to.

- **A module or package.** The solution is the code inside it. The problem is
  the behaviour its tests and callers rely on.
- **A pull request.** The solution is the diff. The problem is in the linked
  issue and in the code as it stands before the change. Resolve the base branch,
  read the issue, and read pre-change code with `git show <base>:<path>`. Tests
  the diff adds are part of the solution, not the problem. A pull request
  description mixes problem and solution: take its problem statement and leave
  its solution talk.
- **A design document.** The solution is the proposed design. The problem is the
  requirements and the motivating examples. A design document mixes the two:
  take the requirements and the examples, leave the proposal.

A name from the solution belongs to the problem only when you cannot change it:
a wire format, a command-line interface, an API that callers outside this repo
depend on. Every other name is part of the solution, however public it looks.

## Compose the brief

Compose the brief the stranger will design from. Don't read the solution yet.
What you have read leaks into what you write. If you read the solution first,
its concepts end up in the brief, even in your own words. At this step read only
problem material: the tests, the call sites, the issue, the requirements, the
docs.

If the solution is already in your context, because you read it earlier in this
session or the target came from work you just did, say so in turn output before
you compose. Then build every scenario by rereading the problem material, and
cite for each scenario where it came from. A scenario you cannot cite is your
memory of the solution, not the problem: drop it.

Write the brief as turn output. It carries:

- **Scenarios.** Each behaviour as a concrete story: this input, this outcome.
  Take them from the tests, the call sites, the issue, and the docs. Include the
  hardest cases they cover, with real values. Vague scenarios get you a generic
  design that compares against nothing.
- **Constraints.** What the design must live with: the fixed interfaces from the
  problem, the platform, anything the solution cannot choose.

If the problem yields more scenarios than a stranger could walk, narrow the
target to one coherent part, and say in the report which part you compared.

If you cannot ground the brief in concrete scenarios, stop and tell the user
what is missing. Ask them for scenarios rather than running on a vague brief.

## Scrub the brief

Reread the brief you just wrote. Wherever you notice a name the solution
invented (a class name, a module name, a layer name, the vocabulary of the
current decomposition), replace it with the words of the problem domain. The
fixed interfaces named in the constraints stay as they are. Write the scrubbed
brief out in full, as turn output. A reader of the brief should learn what the
solution must do, and nothing about how the current one is organised.

## Spawn the stranger

Spawn the `dream:stranger-designer` subagent via the Agent tool, with the full
scrubbed brief inline in its prompt. The subagent has no file tools. It cannot
read the repo, so a file path won't reach it. Its design is only evidence if it
never saw the solution.

The stranger may report a gap in the brief that left a scenario out of its
design. Repair the brief from problem material only, scrub it again, and spawn a
fresh `dream:stranger-designer` subagent. Do this at most once. If the second
stranger still leaves a scenario out, stop and report the gap to the user
instead of comparing.

## Read the solution

Now read the solution in full. List its concepts: the named parts a maintainer
must hold in mind to work on it. For a module, its classes, layers, and
mechanisms. For a pull request, what the diff adds or reshapes. For a design
document, the parts the proposal introduces.

## Compare and report

Map the stranger's concepts onto the solution's, and report the comparison as
turn output, kept short:

- The solution's concepts, named.
- The stranger's concepts, named.
- What the stranger did without, and how its design covers the same scenarios
  anyway.
- What the solution handles that the stranger missed. Say whether each is a real
  constraint the brief failed to carry, or work the problem never asked for.
- One or more pointed questions, each naming a solution concept whose work the
  stranger's design does with less.

Report only: apply no fixes. The stranger's simpler shape can be wrong for
reasons the brief never carried. Whether to act on the comparison is the user's
call.
