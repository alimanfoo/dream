# Phase 3: Scope

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is the accepted Session Scope: what the team commits to
doing in the current session. You draft the Scope Options, get one round of
review from Junio and Ralph, revise, and share with the user for acceptance.

## Step 3.1: Compose the Draft Scope Options

Compose the Draft Scope Options to the shape below. This is the artifact
reviewers will see next. Do not yet send it to the user. Three named options,
each with its presence condition:

- **Coherent Scope** (always): the work needed to meet the accepted Requirements
  Analysis, plus the additions the accepted Code Analysis showed are needed to
  leave the behaviour and the surrounding code in a coherent state. Cite the
  Code Analysis finding behind each addition so the user can trace each one back
  to the structural read they already accepted.
- **Minimal Scope** (when narrower than Coherent): strictly what the
  requirements call for, with the coherence gaps named. It gives the user a way
  to decline the coherence work explicitly (time pressure, scope discipline, the
  rest handled separately).
- **Maximal Scope** (when anticipated further work is real): beyond the Coherent
  Scope, rolls in work that will naturally lead on from the current concern. It
  anticipates what comes next, not just what the investigation surfaced about
  now. The widest sensible anticipation, not speculation.

Test the Coherent Scope before sharing: would finishing it leave the work short
of coherence? What coherence means depends on the Session Type:

- _Enhancement:_ the feature meets the existing code cleanly across the
  integration surface the Code Analysis named. Every convention it touches is
  upheld. Every adjacent behaviour that read flagged is handled. No caller is
  left to special-case it.
- _Maintenance:_ every instance of the inconsistency is fixed, not just the
  surface the input named.
- _Bug fix:_ the mechanism behind the defect is fixed, not the symptom site
  alone.

If the Coherent Scope would leave any of these undone, it is too narrow. Widen
it. When the Code Analysis traced a recurring surface to one fact written in two
places, single-sourcing it is the root-cause fix. That is Coherent work, not a
Maximal add-on (see [One fact, one home](../protocol.md#one-fact-one-home)). A
script or test that re-syncs the two copies is not the fix. It keeps both
copies, so the drift returns the next time the code changes. When the recurring
surface is one rule many sites must each follow, with no single home to
single-source, a check that enforces the rule is the root-cause fix instead.
That is Coherent work when the rule is real and the drift is observed, not a
Maximal add-on (see [Cross-site rules](../protocol.md#cross-site-rules)).

Ask the removal question too. Could dropping or narrowing something resolve the
concern, or leave the code simpler to maintain instead of adding? Examples: a
feature, a branch, a layer, a hand-maintained count. Agents default to adding
and to keeping what's there. The classic case is a count in prose that has to
change whenever the things it counts do. Remove the count.

State each scope item as the property or outcome the work must achieve, not how
it achieves it. Choosing the how is Design's call, where the reviewers weigh the
alternatives. The how includes the tool or library, the algorithm or structure,
the API or command shape, and a bug's fix shape.

## Step 3.2: Share the Draft Scope Options with Junio and Ralph for review

Write the Draft Scope Options to a temporary file outside this repo, via Bash.
Send both Junio and Ralph the file's absolute path: two `SendMessage` calls in
the same turn. Sign off `From Grace. RSVP via SendMessage.`

Junio reads from the maintainer's view. Ralph reads from the engineering-pattern
view. Send the same path to each. Their role files steer the lens. Each replies
with a numbered list of findings (or "no substantive findings"). Junio and Ralph
are advisory at Scope, not gating. One round only. Don't loop back to either
reviewer after revising. The point is fresh attention from two teammates, caught
at the cheapest point to fix.

## Step 3.3: Apply the reviews

Decide each finding, from either reviewer, on its merits, and record a one-line
reason for the call. You own the Scope Options. A teammate raising a finding is
not itself a reason to fold it in. Each finding takes one of these paths:

- **Fold in**: accept into the revised Scope Options (revise an existing option
  or add a missed candidate).
- **Reject**: you disagree with the finding. If the rejection is notable, carry
  the reason into the Scope Options message in
  [Step 3.4](#step-34-share-the-revised-scope-options-with-the-user).

## Step 3.4: Share the revised Scope Options with the user

Send the revised Scope Options. Add a brief note on **what changed from the
Draft after the reviews**: folded-in findings, notable rejections with the
reason. The user learns what the reviews changed without seeing them directly.

Frame the choice plainly. Coherent is the recommendation: the default if the
user just accepts. The user picks Minimal or Maximal to override. When only the
Coherent Scope applies, the message carries that alone and asks the user to
accept.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Session Scope to
  proceed to Phase 4: Design."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Session Scope as proposed (autopilot).
  Proceeding to Phase 4: Design."_

## Step 3.5: Seek user acceptance of the Session Scope

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 3.6](#step-36-hand-the-accepted-session-scope-to-junio-and-ralph). If the
user pushes back, revise and return to
[Step 3.4](#step-34-share-the-revised-scope-options-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

Even after acceptance, the Session Scope is not final. It can be revised at any
point through a Challenge (see [Challenge](../../../agents/Grace.md#challenge)).

## Step 3.6: Hand the accepted Session Scope to Junio and Ralph

Write the accepted Session Scope, the option the user picked plus any changes
from the acceptance discussion, to a temporary file outside this repo, via Bash.
Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP. No
reply is needed. They haven't seen the outcome since their Draft Scope Options
review in
[Step 3.2](#step-32-share-the-draft-scope-options-with-junio-and-ralph-for-review).
The accepted Session Scope feeds the analogies and sketches you generate in
Phase 4 and the Design review that follows.

## Step 3.7: Post the accepted Session Scope to the PR

Post the accepted Session Scope to the PR from the file written in
[Step 3.6](#step-36-hand-the-accepted-session-scope-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

The phase ends at user acceptance of the Session Scope.
