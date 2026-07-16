---
name: code-analysis
description:
  Read and analyse code to understand how it works and how it's organised.
argument-hint: "<requirements | issue | file | symbol | text>"
---

# Code analysis

Produce a Code Analysis: a verifiable read of what the current code does and
where, with file:line or symbol citations throughout. It stays factual, not a
proposal.

Read the [writing style guide](../../writing-style.md) before you write. It is
the standard for the analysis and every message you write.

Follow the steps in order.

## Arguments

The argument gives the requirements or other focus for the code analysis. When
no argument is given, derive the focus from your context. If you cannot identify
a focus, ask the user.

## Read how the code works

Read the documentation governing the paths the work will change: the nearest
agent-instructions file (such as `AGENTS.md` or `CLAUDE.md`) to those paths, and
any system or technical documentation for the subsystem. They describe how the
code is meant to work and the conventions it keeps. Read them before tracing the
code, and cite them in the read.

Read the relevant code with one question in mind: _how does this work?_ Capture
how it is built and what it actually does. Trace the mechanism, the layers, the
callers and siblings, the patterns.

Describe the architecture the work reaches:

- which layers or modules the surfaces sit in
- the boundaries between them
- the separation of concerns the code already keeps
- the conventions the surfaces follow, such as a shared error shape, a naming
  pattern, or a structural rule

For each, say how it holds: types, checks, documentation, or unstated
convention. This is what later work builds on. State it factually. Name the
boundary that exists, don't propose one. Keep it to the architecture the
target's surfaces sit in, not a tour of the whole codebase.

Test the input's factual claims as you go, whoever made them. A bug fix names
expected and observed behaviour as a claim to verify, not a settled fact.
Confirm the code actually misbehaves rather than taking the claim at its word.
The reported behaviour may be a misunderstanding of what the code is built to
do. Record what the read shows: the defect located, or the code behaving as
designed. The latter means no bug to fix. Surface it plainly in the analysis for
the reader to decide.

Read for semantics, not just names, prose, or other surface details. A surface
can carry the same name but mean different things in different callers. For
example, a parameter with fallback semantics in one caller, no-anchor semantics
in another, required in a third. Name any such split explicitly.

If the focus is a bug fix, trace to the root cause, back from where the error
surfaces to the mechanism that produces it, not the symptom site alone. An
enhancement reads the integration surface: where the new feature would land,
what it changes, what adjacent behaviour it might affect. Maintenance reads the
full extent of the surface the work changes, with the specific instances it must
reach.

## Identify and investigate code smells

With that in hand, turn to the code smells: where that structure will resist the
work. Investigate each code smell as you notice it. A code smell is a sign the
code may resist change, not a proven defect. Examples: duplication, a long
function, tight coupling, one concern scattered across many sites, and the rest
of the code-smell catalogue. Describe the smell and where it lives. Whether it
matters and how to fix it is a call for whoever scopes and designs the work
next, not this read.

Some code smells are specific and common in codebases with agent-generated code:

- Complexity the need didn't earn. Generated code tends to add rather than
  integrate, overfit to the case in hand, and over-build. Examples: a new path
  bolted alongside one that could have extended, a special case per instance
  where one rule would serve, an abstraction or parameter no caller exercises.
  Trace each piece of structure to the need it serves and name the one that
  serves none.
- Defensive code at a layer that isn't the source of the constraint it defends
  against. Trace each constraint back to the function that imposes it.
- A comment that justifies non-obvious code by citing another function, layer,
  or invariant is a tell, not an explanation that settles the matter. Read the
  underlying code with extra scrutiny and record what it shows, not the
  comment's rationale.
- A fact duplicated across sites, so the copies drift as the code changes and
  each drift reads as a fresh, separate bug. Where prior issues or this read
  show fixes landing on the same surface, suspect this drift before a run of
  unrelated defects.
- A rule that many sites must each follow, with no single home and nothing
  enforcing it. For example, every endpoint building its own error response, or
  every public function carrying its own docstring. Cite the sites seen breaking
  it.

## Compose the Code Analysis

Compose the Code Analysis from both sections above, written up with file:line or
symbol citations throughout. Write it to a temporary file outside the repo. The
purpose is visible grounding for the work that follows.

The Code Analysis is a read, not a transcription. Tell the reader something they
couldn't get line by line. For example, for a reported bug, the transcription is
the line where the error surfaces. The analysis is the mechanism that produces
it, often layers away.

It stays factual, not a proposal. Name what is: how the code works, how it's
organised, and its code smells. Don't recommend what to change. Whether a smell
is worth fixing, and how, is a call for whoever scopes and designs the work
next.

## Copy-edit the draft

Run the `dream:copy-edit` skill over the draft file, giving its absolute path.

## The result

Return the completed Code Analysis from the file.
