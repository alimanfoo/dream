# Phase 4: Design

The goal of this phase is the accepted Design — what the team proposes to build.

## Step 4.1: Share the accepted Session Scope with Junio and Ralph for information

Send Junio and Ralph the accepted Session Scope — the option the user picked,
plus any changes from the acceptance discussion. Two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP; no
reply is expected. They haven't seen the outcome since their Draft Scope Options
review in
[Step 3.2](Phase3.md#step-32-share-the-draft-scope-options-with-junio-and-ralph-for-review).
The accepted Session Scope feeds the analogies and sketches you generate and the
Design review that follows.

## Step 4.2: Generate analogies

Generate a spread of analogies for the work before sketching, so the sketches
draw on ideas and patterns carried in from elsewhere rather than invented cold.
An analogy is something this work resembles — a feature, a bug, a structure, a
technique — paired with what happened there. Near analogies come from the same
problem domain; far ones from a different domain entirely. Variety is the point:
several analogies, near and far, give the sketch step more to draw on. Don't
filter for relevance here; quantity and spread are the goal.

Write your own analogies as turn output — a numbered list, near and far — as a
discrete act. Then send a message to Junio and Ralph: two `SendMessage` calls in
the same turn, each asking them to write a numbered list of near and far
analogies as turn output. No reply is needed — each agent's analogies feed its
own sketches, not a shared artifact you collect. Sign off `From Grace.` and skip
the RSVP. Ada stays out: she holds her fresh read for Phase 7.

Don't wait for the teammates, they are not expected to reply — move straight to
[Step 4.3](#step-43-generate-design-sketches).

## Step 4.3: Generate design sketches

Sketch a spread of design approaches, before any single design is chosen,
drawing on your analogies where they help. A sketch is brief — a few lines
naming one way to approach the work and the shape it would take, not a fully
worked design. Several rough sketches across different approaches are worth more
here than one polished one.

Write your own sketches as turn output — a numbered list. Then send a message to
Junio and Ralph: two `SendMessage` calls in the same turn, each asking them to
write a numbered list of design sketches and to send the list back. Sign off
`From Grace. RSVP via SendMessage.`

Wait for both replies. Hold the three sketch sets — yours, Junio's, Ralph's — as
context for the consolidation in [Step 4.4](#step-44-draft-the-design-options).

## Step 4.4: Draft the Design Options

Consolidate the pooled sketches into the Design Options — the Proposed Design
(your recommendation) and any credible Alternative Designs — in one act. This is
the artifact reviewers will see next; do not yet send to the user. Choose the
recommendation and the alternatives together, from the pool.

**The Proposed Design.** Name what the code will look like when the work is
done, the approach proposed, and the key design calls that follow from the Code
Analysis. Depth scales with Session Type:

- _Bug fix:_ the fix approach. When more than one fix shape is plausible
  (defensive check, structural fix, removal), name the alternatives and why this
  one. For straightforward bugs this is one or two sentences.
- _Enhancement:_ the new shape — the **happy-path contract** (what valid inputs
  produce what outputs, where it slots in, how callers interact with it) and the
  **input contract** (what input space is supported, and what happens on inputs
  outside it — error, fallback, rejection; e.g. for integer parsing, non-numeric
  input raises vs returns None vs returns 0). The key integration calls.
- _Maintenance:_ the target shape — what the surface looks like when done.
  Specifically: which name, which structure, which abstraction wins, and what
  the migration path looks like.

Check the Proposed Design against common overcomplication defaults: consumers
the accepted Requirements Analysis doesn't name, surfaces held "for the future"
or "for downstream" with no current consumer, failure modes from over-flexible
interfaces, and abstraction held "for symmetry" with only one real branch.
Remove any code the change leaves purposeless — when a function the Design
modifies has no remaining purpose after the change, the same Design removes it.

Reshape the Proposed Design around the real structural fix, even when the user
asked for a docstring or comment change. Example: "expand the docstring to
express a contract" — but the signature doesn't enforce it, so the docstring has
to. The Plan follows the Design, not the session input.

Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)** to
any docstring, comment, or section-header carrying a contract, invariant,
precondition, or convention. Run it on your own output as well as the user's.
You might default to a section-header comment to mark a public-helper grouping,
or a docstring sentence to mark cross-module use. A module split, rename, or
relocation would carry the meaning more reliably.

**The Alternative Designs.** Keep each strong sketch you did not pick — yours or
a teammate's — as an Alternative Design when it still delivers the full Session
Scope but buys its difference at a cost: name the trade-off — a new dependency,
more coupling, less flexibility. Reaching for an existing library in place of
custom code is a common one; surface it when a sketch points at one. A sketch
that delivers less than the Session Scope is not an Alternative; it is a scope
change — raise it as a Challenge if it has merit.

Report the consolidation honestly, including an empty result. Say which sketches
folded into the Proposed Design, which became Alternatives with their
trade-offs, and which you set aside and why.

## Step 4.5: Share the Design Options with Junio and Ralph for review

Send the Design Options to both Junio and Ralph in parallel — two `SendMessage`
calls in the same turn. Sign off `From Grace. RSVP via SendMessage.`

Send the same body to each reviewer; their role files steer the lens. Junio
reads from the maintainer's view — defend behaviour, code-shape, surviving-fit —
and proposes candidate lateral moves. Ralph reads from the engineering-pattern
view — naming, scope and abstraction, plain code. Each replies with a numbered
list of findings (or "no substantive findings"), optionally with a Challenge.
Junio and Ralph are advisory at Design, not gating. Run one round only; don't
loop back after revising.

## Step 4.6: Apply the reviews

Decide each finding — from either reviewer — on its merits, and record a
one-line reason for the call. You own the Design; a teammate raising a finding
is not itself a reason to fold it in. Each finding takes one of these paths:

- **Fold in** — accept into the revised Proposed Design.
- **Reject** — you disagree with the finding. If the rejection is notable, carry
  the reason into the Design message in
  [Step 4.7](#step-47-share-the-revised-design-options-with-the-user).
- **Hold as Ancillary Finding** — the finding is real but out of session scope;
  hold for post-merge triage.
- **Raise a Challenge** — the finding shows an accepted artifact no longer
  holds: the Session Scope is the wrong shape, or an earlier artifact got
  something wrong. Take it to the user, who accepts (revise) or rejects (with
  direction).

Junio's review may also propose candidate lateral moves, each tagged. A
candidate tagged strictly-better folds into the Proposed Design — it improves
the recommendation at no real cost. A candidate tagged with a trade-off joins
the Alternative Designs from [Step 4.4](#step-44-draft-the-design-options), with
its trade-off named. A candidate that would deliver less than the Session Scope
is not a lateral move; raise it as a Challenge if it has merits worth
considering.

Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding any finding that proposes a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention. If
Ralph's review already proposes a structural alternative, the check largely
reduces to accepting it.

When the reply raises a Challenge, assess it: does an accepted artifact really
no longer hold? If it does, take it to the user (accept or reject). A teammate
raising one is not itself the decision.

## Step 4.7: Share the revised Design Options with the user

Send the revised Proposed Design and any Alternative Designs. Lead with the
Proposed Design — your recommendation — then each Alternative with the trade-off
it carries. Add a brief note on **what changed after the reviews**: what folded
into the Proposed Design, notable rejections with the reason, and what the
sketches yielded as Alternatives (including an empty result).

The Proposed Design is the default if the user just accepts; the user picks an
Alternative to override.

End the message by explicitly asking the user to accept: _"Accept the Design to
proceed to Phase 5: Plan."_

## Step 4.8: Seek user acceptance of the Design

Wait for the user's reply — or, under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, the phase ends, continue to Phase 5: Plan. If the user pushes back,
revise and return to
[Step 4.7](#step-47-share-the-revised-design-options-with-the-user); repeat
until accepted.

This is one of the protocol's user acceptance gates — see
[Acceptance gates](../protocol.md#acceptance-gates).

## Step 4.9: Post the accepted Design to the PR

Post the accepted Design to the PR as a comment — see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)
below.

The phase ends at user acceptance of the Design.
