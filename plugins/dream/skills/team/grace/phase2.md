# Phase 2: Code Analysis

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

The goal of this phase is the accepted code analysis. It is a verifiable read of
what the current code does and where, with file:line or symbol citations. Follow
the steps below in sequence.

## Step 2.1: Produce the code analysis

Run the `/dream:code-analysis` skill focused on the accepted requirements
analysis.

The skill returns the code analysis: how the code works, how it's organised, and
its code smells, with file:line or symbol citations throughout.

Hold the returned code analysis as your working artifact for the steps below.

## Step 2.2: Share the code analysis with the user

Send the code analysis to the user. The code analysis is your read of the code.
The user's job at this gate is to flag anything missing or off. Accepting
without flagging anything is the default that lets the phase proceed.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the code analysis to
  proceed to Phase 3: Design."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the code analysis as proposed (autopilot).
  Proceeding to Phase 3: Design."_

## Step 2.3: Seek user acceptance of the code analysis

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [autopilot](../../../agents/Grace.md#autopilot)).
If the user accepts, continue to
[Step 2.4](#step-24-hand-the-accepted-code-analysis-to-junio-and-ralph). If the
user pushes back (a missed caller, a misread mechanism, a wider pattern they
want named), revise and return to
[Step 2.2](#step-22-share-the-code-analysis-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 2.4: Hand the accepted code analysis to Junio and Ralph

Write the accepted code analysis, the version the user accepted plus any changes
from the acceptance discussion, to a temporary file outside this repo, via Bash.

Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP. No
reply is needed.

## Step 2.5: Post the accepted code analysis to the PR

Post the accepted code analysis to the PR from the file written in
[Step 2.4](#step-24-hand-the-accepted-code-analysis-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

The phase ends at user acceptance of the code analysis.
