# Phase 3: Design

Write every turn output, message and artefact in this phase using
`/dream:writing-style`.

The goal of this phase is the accepted design: what the team proposes to build.
Follow the steps below in sequence.

## Step 3.1: Produce the design options

Run the `/dream:design` skill, focused on the accepted requirements analysis and
code analysis.

The skill returns the design options: the proposed design (its recommendation)
and any alternative designs, each with its trade-off named.

## Step 3.2: Share the design options with the user

Send the proposed design and any alternative designs to the user. Lead with the
proposed design, your recommendation. Then give each alternative with the
trade-off it carries. The proposed design is the default if the user just
accepts. The user picks an alternative to override.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the design to proceed to
  Phase 4: Plan."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the design as proposed (autopilot).
  Proceeding to Phase 4: Plan."_

## Step 3.3: Seek user acceptance of the design

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [autopilot](../../../agents/Grace.md#autopilot)).
If the user accepts, continue to
[Step 3.4](#step-34-hand-the-accepted-design-to-junio-and-ralph). If the user
pushes back, revise and return to
[Step 3.2](#step-32-share-the-design-options-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 3.4: Hand the accepted design to Junio and Ralph

Write the following to a temporary file outside this repo, via Bash:

- the accepted design (the option the user picked, plus any changes from the
  acceptance discussion)
- every alternative design, so both the chosen design and the alternatives are
  available when posting to the PR

Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP. No
reply is needed.

## Step 3.5: Post the accepted design to the PR

Post the accepted design to the PR from the file written in
[Step 3.4](#step-34-hand-the-accepted-design-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

Make the body the design the user accepted. Put every alternative design under
an "Alternatives considered" heading: the designs weighed and not chosen. When
there was no alternative design, omit the heading.

The phase ends at user acceptance of the design.
