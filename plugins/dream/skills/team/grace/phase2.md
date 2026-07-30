# Phase 2: Code Analysis

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

The goal of this phase is the accepted code analysis. Follow the steps below in
sequence.

## Step 2.1: Produce the code analysis

Run the `/dream:code-analysis` skill focused on the accepted requirements
analysis.

## Step 2.2: Share the code analysis with the user

Send the code analysis to the user. The user's job at this gate is to flag
anything missing or off.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the code analysis to
  proceed to Phase 3: Design."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the code analysis as proposed (autopilot).
  Proceeding to Phase 3: Design."_

## Step 2.3: Seek user acceptance of the code analysis

Under autopilot, take this gate's default and continue without waiting.

Otherwise, wait for the user's reply.

If the user accepts, continue to
[Step 2.4](#step-24-send-the-accepted-code-analysis-to-junio-and-ralph). If the
user pushes back, revise and return to
[Step 2.2](#step-22-share-the-code-analysis-with-the-user). Repeat until
accepted.

This is one of the protocol's
[user acceptance gates](../protocol.md#acceptance-gates).

## Step 2.4: Send the accepted code analysis to Junio and Ralph

Write the accepted code analysis, the version the user accepted plus any changes
from the acceptance discussion, to a temporary file outside this repo, via Bash.

Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.`

## Step 2.5: Post the accepted code analysis to the PR

Post the accepted code analysis to the PR from the file written in
[Step 2.4](#step-24-send-the-accepted-code-analysis-to-junio-and-ralph) (see
[Writing to GitHub](../../../agents/Grace.md#writing-to-github)).
