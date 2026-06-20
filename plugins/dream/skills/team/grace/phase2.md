# Phase 2: Code Analysis

The goal of this phase is the accepted Code Analysis — a verifiable read of what
the current code does and where, with file:line or symbol citations. It is the
structural counterpart to Phase 1's consumer-focused read: same code, different
attention. Follow the steps below in sequence.

## Step 2.1: Read the structural baseline

Read the relevant code with one question in mind: _how does this work?_ The
baseline is how the code is built and what it actually does. Trace the
mechanism, the layers, the callers and siblings, the patterns. Name the
architecture the work touches: which layers or modules the surfaces sit in, the
boundaries between them, the separation of concerns the code already keeps, and
the conventions the surfaces follow — a shared error shape, a naming pattern, a
structural rule — and which of these are enforced and which hold only by
convention, with nothing checking them. This is the structural baseline the
Design later builds on. State it factually — name the boundary that exists,
don't propose one. Keep it to the architecture the session's surfaces touch, not
a tour of the whole codebase.

Test the session input's factual claims as you go, whoever made them. A bug
report asserts a defect; confirm the code actually misbehaves rather than taking
the report at its word, since the reported behaviour may be a misunderstanding
of what the code is built to do. Record what the read shows — the defect
located, or the code behaving as designed. The latter means there is no bug to
fix; surface it at the gate for the user to decide.

Read for semantics, not just names, prose, or other surface details. A surface
can carry the same name but mean different things in different callers — a
parameter with fallback semantics in one caller, no-anchor semantics in another,
required in a third. Name any such split explicitly.

How far the baseline reaches scales with the Session Type: a bug fix traces to
the root cause, back from where the error surfaces to the mechanism that
produces it, not the symptom site alone; an enhancement reads the integration
surface — where the work would land, what it touches, what adjacent behaviour it
might affect; maintenance reads the full extent of the surface the work touches,
with the specific instances it must reach.

## Step 2.2: Identify and investigate code smells

With the baseline in hand, turn to the code smells — where that structure will
resist the work. Investigate each code smell as you notice it. A code smell is a
sign the code may resist change, not a proven defect — high complexity,
duplication, a long function, tight coupling, one concern scattered across many
sites, and the rest of the code-smell catalogue. Don't ignore complexity:
correct, working code can still be too tangled to change safely. Describe the
smell and where it lives; whether it matters and how to fix it is Scope's and
Design's call, not the read's.

Some code smells are specific and recurring:

- Defensive code at a layer that isn't the source of the constraint it defends
  against. Trace each constraint back to the function that imposes it — see
  [Wrong-layer defensive code](../protocol.md#wrong-layer-defensive-code).
- A comment that justifies non-obvious code, read as a tell, not description. A
  comment explaining why code exists by citing another function, layer, or
  invariant is a tell, not an explanation that settles the matter — read the
  underlying code with extra scrutiny and record what it shows, not the
  comment's rationale.
- A fact duplicated across sites, so the copies drift as the code changes and
  each drift reads as a fresh, separate bug. Where Phase 1's recurrence check or
  this read shows fixes landing on the same surface, suspect this drift before a
  run of unrelated defects — the recurrence is the evidence.
- A rule that many sites must each follow, with no single home and nothing
  enforcing it — every endpoint building its own error response, every public
  function carrying its own docstring — cited at the sites seen breaking it.

## Step 2.3: Compose the Code Analysis

Compose the Code Analysis — the structural read above, the baseline and the code
smells, written up with file:line or symbol citations throughout. The purpose is
visible grounding for the work that follows: the user sees the code as you read
it before seeing what you propose to commit to or build on top of it.

The Code Analysis is a read, not a transcription. Tell the reader something they
couldn't get line by line. Root cause is the clearest case: for a reported bug,
the transcription is the line where the error surfaces; the analysis is the
mechanism that produces it, often layers away.

It stays factual, not proposal: name what is — the baseline and the code smells
— don't recommend what to change. Whether a smell is worth fixing, and how,
lands in Scope and Design.

## Step 2.4: Share the Code Analysis with the user

Send the Code Analysis to the user. The Code Analysis is your structural read;
the user's job at this gate is to flag anything missing or off — accepting
without flagging anything is the default that lets the phase proceed.

End the message by explicitly asking the user to accept: _"Accept the Code
Analysis to proceed to Phase 3: Scope."_

## Step 2.5: Seek user acceptance of the Code Analysis

Wait for the user's reply — or, under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 2.6](#step-26-hand-the-accepted-code-analysis-to-junio-and-ralph). If the
user pushes back — a missed caller, a misread mechanism, a wider pattern they
want named — revise and return to
[Step 2.4](#step-24-share-the-code-analysis-with-the-user); repeat until
accepted.

This is one of the protocol's user acceptance gates — see
[Acceptance gates](../protocol.md#acceptance-gates).

## Step 2.6: Hand the accepted Code Analysis to Junio and Ralph

Send Junio and Ralph the accepted Code Analysis — the version the user accepted,
plus any changes from the acceptance discussion. Two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP; no
reply is expected. They hold it as context for the rest of the session.

## Step 2.7: Post the accepted Code Analysis to the PR

Post the accepted Code Analysis to the PR as a comment — see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr).

The phase ends at user acceptance of the Code Analysis.
