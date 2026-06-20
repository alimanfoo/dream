# Phase 2: Code Analysis

The goal of this phase is the accepted Code Analysis — a verifiable read of what
the current code does and where, with file:line or symbol citations. It is the
structural counterpart to Phase 1's consumer-focused read: same code, different
attention. Follow the steps below in sequence.

## Step 2.1: Read the code with a structural lens

Read the relevant code with one question in mind: _how does this work?_ Trace
mechanism, layers, callers, siblings, patterns, and candidate smells. This is
the structural lens — distinct from Phase 1's consumer lens. The two reads cover
the same code with different attention.

Test the session input's factual claims about the code, whoever made them. A bug
report asserts a defect; confirm the code actually misbehaves rather than taking
the report at its word, since the reported behaviour may be a misunderstanding
of what the code is built to do. The Code Analysis records what the read shows —
the defect located, or the code behaving as designed. The latter means there is
no bug to fix; surface it at the gate for the user to decide.

Read for semantics, not just names, prose, or other surface details. A surface
can carry the same name but mean different things in different callers. For
example: a parameter with fallback semantics in one caller, no-anchor semantics
in another, and required in a third. Note any such split — the Code Analysis
names it explicitly.

Name the architecture the work touches. Which layers or modules the surfaces sit
in, the boundaries between them, the separation of concerns the code already
keeps, and the conventions the surfaces follow — a shared error shape, a naming
pattern, a structural rule. Note which of these are enforced and which hold only
by convention, with nothing checking them. This is the structural baseline the
Design later builds on and Junio reads when judging whether the Design keeps
concerns separate (see his Design separation-of-concerns lens). State it
factually — name the boundary that exists, don't propose one; the read stays a
read. Keep it to the architecture the session's surfaces touch, not a tour of
the whole codebase.

Trace each constraint the surface defends against back to the function that
imposes it. Name any defensive code that sits at a different layer — see
[Wrong-layer defensive code](../protocol.md#wrong-layer-defensive-code).

Flag candidate smells as you read, and read each closer rather than waiting for
hard evidence. A candidate smell is a sign the code may resist change, not a
proven defect — high complexity, duplication, a long function, tight coupling,
one concern scattered across many sites, and the rest of the code-smell
catalogue. Complexity is the clearest case: correct, working code can still be
too tangled to change safely.

One such smell: a comment that justifies non-obvious code, read as a tell, not
description. A comment explaining why code exists by citing another function,
layer, or invariant is a tell, not an explanation that settles the matter — read
the underlying code with extra scrutiny and flag it in the analysis rather than
recording the comment's rationale as fact.

## Step 2.2: Compose the Code Analysis

Compose the Code Analysis — your structural read of the current code, with
file:line or symbol citations throughout. The purpose is visible grounding for
the work that follows: the user sees the code as you read it before seeing what
you propose to commit to or build on top of it. Depth scales with Session Type:

- _Enhancement:_ the integration surface — where the enhancement would land,
  what it touches, what adjacent behaviour it might affect, and whether the
  surface the work builds on is sound to extend. Where the closer read confirms
  a candidate smell in that surface as an obstacle to clean integration, record
  it with the citation.
- _Maintenance:_ the inconsistency pattern across the named surface, with
  specific instances.
- _Bug fix:_ the root cause — traced back from where the error surfaces to the
  mechanism that produces it, not the symptom site alone.

Show the recurrence pattern in enough detail for surfaces where Phase 1's
recurrence check found prior issues. Name wrong-layer defensive code,
same-name-different-contract splits, and the architecture the work touches —
boundaries, separation of concerns, conventions, and which hold only by
convention — from [Step 2.1](#step-21-read-the-code-with-a-structural-lens)
explicitly so a reader can see what the read surfaced.

Where Phase 1's recurrence check found prior issues on a surface — or where this
read shows the same fix shape landing in more than one place — say where the
underlying fact lives. A fact is one decision the code makes: a set of valid
cases, a formula, the shape of a response. When the same fact is written out in
two places, the copies drift apart as the code changes, and each drift looks
like a fresh, separate bug. So name the one place the fact belongs (or note it
has no single home yet) and the copies that derive or drift from it. A run of
fixes tightening on one surface is usually this drift, not a run of unrelated
defects (see [One fact, one home](../protocol.md#one-fact-one-home)).

Some recurring surfaces are not one fact copied to several places but one rule
that many hand-written sites must each follow, with no single home — every
endpoint building its own error response, every public function carrying its own
docstring. Record the rule and that nothing checks it, citing the sites seen
breaking it. Naming it is factual; whether to enforce it with a check is Scope's
call (see [One rule, one check](../protocol.md#one-rule-one-check)).

The Code Analysis is a read, not a transcription. Tell the reader something they
couldn't get line by line. Root cause analysis is the clearest case: for a
reported bug, the transcription is the line where the error surfaces; the
analysis is the mechanism that produces it, often layers away. The same read
finds what's tangled, what a surface means across its callers, and what recurs.
It stays factual, not proposal: name what is, don't recommend what to change —
those changes land in Scope and Design.

## Step 2.3: Share the Code Analysis with the user

Send the Code Analysis to the user. The Code Analysis is your structural read;
the user's job at this gate is to flag anything missing or off — accepting
without flagging anything is the default that lets the phase proceed.

End the message by explicitly asking the user to accept: _"Accept the Code
Analysis to proceed to Phase 3: Scope."_

## Step 2.4: Seek user acceptance of the Code Analysis

Wait for the user's reply — or, under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 2.5](#step-25-hand-the-accepted-code-analysis-to-junio-and-ralph). If the
user pushes back — a missed caller, a misread mechanism, a wider pattern they
want named — revise and return to
[Step 2.3](#step-23-share-the-code-analysis-with-the-user); repeat until
accepted.

This is one of the protocol's user acceptance gates — see
[Acceptance gates](../protocol.md#acceptance-gates).

## Step 2.5: Hand the accepted Code Analysis to Junio and Ralph

Send Junio and Ralph the accepted Code Analysis — the version the user accepted,
plus any changes from the acceptance discussion. Two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP; no
reply is expected. They hold it as context for the rest of the session.

## Step 2.6: Post the accepted Code Analysis to the PR

Post the accepted Code Analysis to the PR as a comment — see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr).

The phase ends at user acceptance of the Code Analysis.
