# Phase 3: Scope

The goal of this phase is the accepted Session Scope — what the team commits to
doing in the current session. You draft the Scope Options, get one round of
review from Junio and Ralph, revise, and share with the user for acceptance.

## Step 3.1: Compose the Draft Scope Options

Compose the Draft Scope Options to the shape below. This is the artifact
reviewers will see next; do not yet send to the user. Three named options, each
with its presence condition:

- **Coherent Scope** (always) — the work needed to meet the accepted
  Requirements Analysis, plus the additions the accepted Code Analysis showed
  are needed to leave the behaviour and the surrounding code in a coherent
  state. Cite the Code Analysis finding behind each addition so the user can
  trace each one back to the structural read they already accepted.
- **Minimal Scope** (when narrower than Coherent) — strictly what the
  requirements call for, with the coherence gaps named. Gives the user a way to
  decline the coherence work explicitly (time pressure, scope discipline, will
  handle the rest separately).
- **Maximal Scope** (when anticipated further work is real) — beyond the
  Coherent Scope, rolls in work that will naturally lead on from the current
  concern. Forward-looking: anticipates what comes next, not just what the
  investigation surfaced about now. Not everything imaginable — the widest
  sensible anticipation, not speculation.

Test the Coherent Scope before sharing: would finishing it leave the work short
of coherence? What coherence means depends on the Session Type:

- _Enhancement:_ the feature meets the existing code cleanly across the
  integration surface the Code Analysis named — every convention it touches
  upheld, every adjacent behaviour that read flagged handled, no caller left to
  special-case it. It fits, it doesn't just work.
- _Maintenance:_ every instance of the inconsistency is fixed, not just the
  surface the input named.
- _Bug fix:_ the mechanism behind the defect is fixed, not the symptom site
  alone.

If the Coherent Scope would leave any of these undone, it is too narrow — widen
it. When the Code Analysis traced a recurring surface to one fact written in two
places, single-sourcing it is the root-cause fix — Coherent work, not a Maximal
add-on (see [One fact, one home](../protocol.md#one-fact-one-home)). A script or
test that re-syncs the two copies is not the fix — it keeps both copies, so the
drift returns the next time the code changes. When the recurring surface is one
rule many sites must each follow, with no single home to single-source, a check
that enforces the rule is the root-cause fix instead — Coherent work when the
rule is real and the drift is observed, not a Maximal add-on (see
[One rule, one check](../protocol.md#one-rule-one-check)).

Ask the removal question too: could dropping or narrowing something — a feature,
a branch, a layer, a hand-maintained count — resolve the concern or leave the
code simpler to maintain, instead of adding? Agents default to adding and to
keeping what's there. The classic case is a count in prose that has to change
whenever the things it counts do — remove the count.

State each scope item as the property or outcome the work must achieve, not how
it achieves it. Choosing the how — a tool or library, an algorithm or structure,
an API or command shape, a bug's fix shape — is Design's call, where the
reviewers weigh the alternatives.

## Step 3.2: Share the Draft Scope Options with Junio and Ralph for review

Send the Draft Scope Options to both Junio and Ralph in parallel — two
`SendMessage` calls in the same turn. They already hold the Session Type and
accepted Requirements Analysis from the Phase 1 handoff and the accepted Code
Analysis from the Phase 2 handoff, so the body for each carries the Draft Scope
Options. Sign off `From Grace. RSVP via SendMessage.`

Junio reads from the maintainer's view — first, whether the Coherent Scope is
truly coherent: does it miss any work needed to reach coherence? Then whether
each addition there earns its place by code or recurrence evidence, and whether
the Maximal Scope is real anticipation.

Ralph reads from the engineering-pattern view — whether the Coherent Scope is
right-sized for the accepted Requirements Analysis, whether the Maximal Scope
avoids hypothetical future-proofing.

Send the same body to each; their role files steer the lens. Each replies with a
numbered list of findings (or "no substantive findings"). Junio and Ralph are
advisory at Scope, not gating. One round only — don't loop back to either
reviewer after revising. The point is fresh attention from two teammates, caught
at the cheapest point to fix.

## Step 3.3: Apply the reviews

Decide each finding — from either reviewer — on its merits, and record a
one-line reason for the call. You own the Scope Options; a teammate raising a
finding is not itself a reason to fold it in. Each finding takes one of these
paths:

- **Fold in** — accept into the revised Scope Options (revise an existing option
  or add a missed candidate).
- **Reject** — you disagree with the finding. If the rejection is notable, carry
  the reason into the Scope Options message in
  [Step 3.4](#step-34-share-the-revised-scope-options-with-the-user).

## Step 3.4: Share the revised Scope Options with the user

Send the revised Scope Options. Add a brief note on **what changed from the
Draft after the reviews** — folded-in findings, notable rejections with the
reason. The user learns what the reviews changed without seeing them directly.

Frame the choice plainly. Coherent is the recommendation — the default if the
user just accepts; the user picks Minimal or Maximal to override. When only the
Coherent Scope applies, the message carries that alone and asks the user to
accept.

End the message by explicitly asking the user to accept, naming the artifact and
the next phase: _"Accept the Session Scope to proceed to Phase 4: Design."_

## Step 3.5: Seek user acceptance of the Session Scope

Wait for the user's reply — or, under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, the phase ends, continue to Phase 4: Design. If the user pushes
back, revise and return to
[Step 3.4](#step-34-share-the-revised-scope-options-with-the-user); repeat until
accepted.

This is one of the protocol's user acceptance gates — see
[Acceptance gates](../protocol.md#acceptance-gates).

Even after acceptance, the Session Scope is not set in stone. It can be revised
at any point through a Challenge (see
[Challenge](../../../agents/Grace.md#challenge)).

## Step 3.6: Post the accepted Session Scope to the PR

Post the accepted Session Scope to the PR as a comment — see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr).

The phase ends at user acceptance of the Session Scope.
