# Phase 4: Plan

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is the accepted plan: the task list that delivers the
design. Follow the steps below in sequence.

## Step 4.1: Produce the plan

Run the `/dream:plan` skill, focused on the accepted design and code analysis.

The skill returns the plan: the task list that delivers the design, each task a
manageable single-commit unit selected by a criterion.

## Step 4.2: Share the plan with the user

Send the plan to the user. The plan is your draft. The user's job at this gate
is to flag anything missing or off. Accepting without flagging anything is the
default that lets the phase proceed.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the plan to proceed to
  Phase 5: Develop."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the plan as proposed (autopilot).
  Proceeding to Phase 5: Develop."_

## Step 4.3: Seek user acceptance of the plan

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 4.4](#step-44-hand-the-accepted-plan-to-junio-and-ralph). If the user
raises open questions or redirects, revise and return to
[Step 4.2](#step-42-share-the-plan-with-the-user). Repeat until accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 4.4: Hand the accepted plan to Junio and Ralph

Write the accepted plan to a temporary file outside this repo, via Bash. Send
Junio and Ralph the file's absolute path: two `SendMessage` calls in the same
turn, for information only. Sign off `From Grace.` and skip the RSVP. No reply
is needed. The accepted plan feeds Junio's per-task coherence audits and Ralph's
per-task implementations in Phase 5.

## Step 4.5: Post the accepted plan to the PR

Post the accepted plan to the PR from the file written in
[Step 4.4](#step-44-hand-the-accepted-plan-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

The phase ends at user acceptance of the plan.
