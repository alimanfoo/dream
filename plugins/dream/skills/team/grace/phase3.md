# Phase 3: Design

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is the accepted Design: what the team proposes to build.
Follow the steps below in sequence.

## Step 3.1: Produce the Design Options

Run the `dream:design` skill, focused on the accepted Requirements Analysis and
Code Analysis.

The skill returns the Design Options: the Proposed Design (its recommendation)
and any Alternative Designs, each with its trade-off named.

## Step 3.2: Share the Design Options with the user

Send the Proposed Design and any Alternative Designs to the user. Lead with the
Proposed Design, your recommendation. Then give each Alternative with the
trade-off it carries. The Proposed Design is the default if the user just
accepts. The user picks an Alternative to override.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Design to proceed to
  Phase 4: Plan."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Design as proposed (autopilot).
  Proceeding to Phase 4: Plan."_

## Step 3.3: Seek user acceptance of the Design

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 3.4](#step-34-hand-the-accepted-design-to-junio-and-ralph). If the user
pushes back, revise and return to
[Step 3.2](#step-32-share-the-design-options-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 3.4: Hand the accepted Design to Junio and Ralph

Write the following to a temporary file outside this repo, via Bash:

- the accepted Design (the option the user picked, plus any changes from the
  acceptance discussion)
- every other design from the spread, so both the chosen design and the
  alternatives are available when posting to the PR

Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP. No
reply is needed. The accepted Design feeds the Plan review that follows.

## Step 3.5: Post the accepted Design to the PR

Post the accepted Design to the PR from the file written in
[Step 3.4](#step-34-hand-the-accepted-design-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

Make the body the design the user accepted. Put every other design from the
spread under an "Alternatives considered" heading: the designs weighed and not
chosen. The heading shows a reader which one the session decided on. A bare
"Alternative Designs" heading reads as options still open. When the spread held
no other design, omit the heading.

The phase ends at user acceptance of the Design.
