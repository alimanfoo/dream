# Phase 4: Design

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is the accepted Design: what the team proposes to build.

## Step 4.1: Generate analogies and survey existing tools

Generate a spread of analogies for the work before sketching, so the sketches
draw on ideas and patterns carried in from elsewhere rather than invented cold.
An analogy is something this work resembles (a feature, a bug, a structure, a
technique), paired with what happened there. Near analogies come from the same
problem domain. Far ones come from a different domain entirely. Several
analogies, near and far, give the sketch step more to draw on. Don't filter for
relevance here. Quantity and spread are the goal.

Write your own analogies as a discrete act, as turn output in a numbered list,
near and far. Then send a message to Junio and Ralph: two `SendMessage` calls in
the same turn. Ask Ralph to write a numbered list of near and far analogies as
turn output. Ask Junio to survey existing tools instead, internal and external,
tagged by how fully each addresses the need. No reply is needed from either.
Each agent's analogies or survey feeds its own sketches, not a shared artifact
you collect. Sign off `From Grace.` and skip the RSVP. Ada stays out: she holds
her fresh read for Phase 7.

Don't wait for the teammates. They will not reply. Move straight to
[Step 4.2](#step-42-generate-design-sketches).

## Step 4.2: Generate design sketches

Sketch a spread of design approaches, before any single design is chosen,
drawing on your analogies where they help. A sketch is brief: a few lines naming
one way to approach the work and the shape it would take. Not a fully worked
design. Several rough sketches across different approaches are worth more here
than one polished one.

Write your own sketches as turn output, a numbered list. Then send a message to
Junio and Ralph: two `SendMessage` calls in the same turn. Pose the problem and
the outcome to reach. Do not name candidate approaches or the solution axis the
originating issue named. Naming an axis collapses the spread onto it. Ask each
to write a numbered list of design sketches and to send the list back. Sign off
`From Grace. RSVP via SendMessage.`

Wait for both replies. Hold the three sketch sets (yours, Junio's, Ralph's) as
context for the consolidation in [Step 4.3](#step-43-draft-the-design-options).

## Step 4.3: Draft the Design Options

Consolidate the pooled sketches into the Design Options in one act. The Design
Options are the Proposed Design (your recommendation) and any credible
Alternative Designs. This is the artifact reviewers will see next. Do not yet
send it to the user. Choose the recommendation and the alternatives together,
from the pool.

**The Proposed Design.** Name what the code will look like when the work is
done, the approach proposed, and the key design calls that follow from the Code
Analysis. Depth scales with Session Type:

- _Enhancement:_ the **happy-path contract** (what valid inputs produce what
  outputs, where it slots in, how callers interact with it) and the **input
  contract** (what input space is supported, and what happens on inputs outside
  it: error, fallback, or rejection). For example, for integer parsing,
  non-numeric input might raise, return None, or return 0. Also the key
  integration calls.
- _Maintenance:_ the target shape, the surface when the work is done: which
  name, which structure, which abstraction wins, and the migration path.
- _Bug fix:_ the fix approach. When more than one fix shape is plausible
  (defensive check, structural fix, removal), name the alternatives and why this
  one. For straightforward bugs this is one or two sentences.

Check the Proposed Design against common overcomplication defaults:

- consumers the accepted Requirements Analysis doesn't name
- surfaces held "for the future" or "for downstream" with no current consumer
- failure modes from over-flexible interfaces
- abstraction held "for symmetry" with only one real branch

Remove any code the change leaves purposeless. When a function the Design
modifies has no remaining purpose after the change, the same Design removes it.

Reshape the Proposed Design around the real structural fix, even when the user
asked for a docstring or comment change. Example: "expand the docstring to
express a contract". But the signature doesn't enforce it, so the docstring has
to. The Plan follows the Design, not the session input.

Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)** to
any docstring, comment, or section-header carrying a contract, invariant,
precondition, or convention. Run it on your own output as well as the user's.
You might default to a section-header comment to mark a public-helper grouping,
or a docstring sentence to mark cross-module use. A module split, rename, or
relocation would carry the meaning more reliably.

**The Alternative Designs.** Keep each strong sketch you did not pick (yours or
a teammate's) as an Alternative Design. It qualifies when it still delivers the
full Session Scope but buys its difference at a cost. Name the trade-off: a new
dependency, more coupling, less flexibility. Reaching for an existing library in
place of custom code is a common one. Surface it when a sketch points at one. A
sketch that delivers less than the Session Scope is not an Alternative. It is a
scope change. Raise it as a Challenge if it has merit.

Report the consolidation honestly, including an empty result, and carry it into
the Design Options you share next:

- which sketches folded into the Proposed Design
- which became Alternatives, with their trade-offs
- which you set aside and why

## Step 4.4: Share the Design Options with Junio and Ralph for review

Send the Design Options to both Junio and Ralph in parallel: two `SendMessage`
calls in the same turn. Sign off `From Grace. RSVP via SendMessage.`

Send the same body to each reviewer. Their role files steer the lens. Junio
reads from the maintainer's view (defend behaviour, code-shape, surviving-fit)
and proposes candidate lateral moves. Ralph reads from the engineering-pattern
view: naming, scope and abstraction, plain code. Each replies with a numbered
list of findings (or "no substantive findings"), optionally with a Challenge.
Junio and Ralph are advisory at Design, not gating. Run one round only. Don't
loop back after revising.

## Step 4.5: Apply the reviews

Decide each finding, from either reviewer, on its merits, and record a one-line
reason for the call. You own the Design. A teammate raising a finding is not
itself a reason to fold it in. Each finding takes one of these paths:

- **Fold in**: accept into the revised Proposed Design.
- **Reject**: you disagree with the finding. If the rejection is notable, carry
  the reason into the Design message in
  [Step 4.6](#step-46-share-the-revised-design-options-with-the-user).
- **Hold as Ancillary Finding**: the finding is real but out of the Session
  Scope. Hold for post-merge triage.
- **Raise a Challenge**: the finding shows an accepted artifact no longer holds.
  Either the Session Scope is the wrong shape, or an earlier artifact got
  something wrong. Take it to the user, who accepts (revise) or rejects (with
  direction).

Junio's review may also propose candidate lateral moves, each tagged. A
candidate tagged strictly-better folds into the Proposed Design. It improves the
recommendation at no real cost. A candidate tagged with a trade-off joins the
Alternative Designs from [Step 4.3](#step-43-draft-the-design-options), with its
trade-off named. A candidate that would deliver less than the Session Scope is
not a lateral move. Raise it as a Challenge if it has merits worth considering.

Apply the
**[code-shape-first check](../../../agents/Grace.md#code-shape-first-check)**
before deciding any finding that proposes a docstring, comment, or
section-header to express a contract, invariant, precondition, or convention. If
Ralph's review already proposes a structural alternative, the check largely
reduces to accepting it.

When the reply raises a Challenge, assess it before acting: does an accepted
artifact really no longer hold?

## Step 4.6: Share the revised Design Options with the user

Send the revised Proposed Design and any Alternative Designs. Lead with the
Proposed Design, your recommendation. Then give each Alternative with the
trade-off it carries. Add a brief note on **what changed after the reviews**:

- what folded into the Proposed Design
- notable rejections, with the reason
- what the sketches yielded as Alternatives, including an empty result

The Proposed Design is the default if the user just accepts. The user picks an
Alternative to override.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Design to proceed to
  Phase 5: Plan."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Design as proposed (autopilot).
  Proceeding to Phase 5: Plan."_

## Step 4.7: Seek user acceptance of the Design

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 4.8](#step-48-hand-the-accepted-design-to-junio-and-ralph). If the user
pushes back, revise and return to
[Step 4.6](#step-46-share-the-revised-design-options-with-the-user). Repeat
until accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 4.8: Hand the accepted Design to Junio and Ralph

Send Junio and Ralph the accepted Design: the option the user picked, plus any
changes from the acceptance discussion. Two `SendMessage` calls in the same
turn, for information only. Sign off `From Grace.` and skip the RSVP. No reply
is needed. They haven't seen the outcome since their Design review in
[Step 4.4](#step-44-share-the-design-options-with-junio-and-ralph-for-review).
The accepted Design feeds the Plan review that follows.

## Step 4.9: Post the accepted Design to the PR

Post the accepted Design to the PR as a comment (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

Make the body the design the user accepted. Put every other design from the
spread under an "Alternatives considered" heading: the designs weighed and not
chosen. The heading shows a reader which one the session decided on. A bare
"Alternative Designs" heading reads as options still open. When the spread held
no other design, omit the heading.

The phase ends at user acceptance of the Design.
