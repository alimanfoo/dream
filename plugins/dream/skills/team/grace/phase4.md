# Phase 4: Plan

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

The goal of this phase is the accepted plan. Follow the steps below in sequence.

## Step 4.1: Produce the plan

Run the `/dream:plan` skill, focused on the accepted design and code analysis.

## Step 4.2: Share the plan with the user

Under autopilot, keep this step to one line, then continue in the same turn:
_"Taking the plan as proposed (autopilot). Proceeding to Phase 5: Develop."_

Otherwise, send the plan to the user. The plan is your draft. The user's job at
this gate is to flag anything missing or off. Ask the user to accept: _"Accept
the plan to proceed to Phase 5: Develop."_

## Step 4.3: Seek user acceptance of the plan

Under autopilot, take this gate's default and continue without waiting.

Otherwise, wait for the user's reply.

If the user accepts, continue to
[Step 4.4](#step-44-send-the-accepted-plan-to-junio-and-ralph). If the user
raises open questions or redirects, revise and return to
[Step 4.2](#step-42-share-the-plan-with-the-user). Repeat until accepted.

This is one of the protocol's
[user acceptance gates](../protocol.md#acceptance-gates).

## Step 4.4: Send the accepted plan to Junio and Ralph

Write the accepted plan to a temporary file outside this repo, via Bash. Send
Junio and Ralph the file's absolute path: two `SendMessage` calls in the same
turn, for information only.

## Step 4.5: Post the accepted plan to the PR

Post the accepted plan to the PR from the file written in
[Step 4.4](#step-44-send-the-accepted-plan-to-junio-and-ralph) (see
[Writing to GitHub](../../../agents/Grace.md#writing-to-github)).
