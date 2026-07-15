# Phase 2: Code Analysis

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is the accepted Code Analysis. It is a verifiable read of
what the current code does and where, with file:line or symbol citations. Follow
the steps below in sequence.

## Step 2.1: Produce the Code Analysis

Run the `dream:code-analysis` skill, giving it the file from
[Step 1.6](phase1.md#step-16-hand-the-accepted-requirements-analysis-to-junio-and-ralph):
the accepted Requirements Analysis and the Session Type. The skill carries the
analysis end to end. It reads the structural baseline, the documentation and
code governing the paths the work will change, then investigates the code smells
that baseline reveals. It composes the Code Analysis from both and copy-edits
it, so what it returns is already readable. Take the skill through to its
returned Code Analysis without your own review or copy-edit on top.

The skill returns the Code Analysis: the structural baseline and the code
smells, with file:line or symbol citations throughout, factual rather than a
proposal.

Hold the returned Code Analysis as your working artifact for the steps below.

## Step 2.2: Share the Code Analysis with the user

Send the Code Analysis to the user. The Code Analysis is your structural read.
The user's job at this gate is to flag anything missing or off. Accepting
without flagging anything is the default that lets the phase proceed.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Code Analysis to
  proceed to Phase 3: Scope."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Code Analysis as proposed (autopilot).
  Proceeding to Phase 3: Scope."_

## Step 2.3: Seek user acceptance of the Code Analysis

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
If accepted, continue to
[Step 2.4](#step-24-hand-the-accepted-code-analysis-to-junio-and-ralph). If the
user pushes back (a missed caller, a misread mechanism, a wider pattern they
want named), revise and return to
[Step 2.2](#step-22-share-the-code-analysis-with-the-user). Repeat until
accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 2.4: Hand the accepted Code Analysis to Junio and Ralph

Write the accepted Code Analysis, the version the user accepted plus any changes
from the acceptance discussion, to a temporary file outside this repo, via Bash.
Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP. No
reply is needed. They hold it as context for the rest of the session.

## Step 2.5: Post the accepted Code Analysis to the PR

Post the accepted Code Analysis to the PR from the file written in
[Step 2.4](#step-24-hand-the-accepted-code-analysis-to-junio-and-ralph) (see
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr)).

The phase ends at user acceptance of the Code Analysis.
