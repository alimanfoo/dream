# Phase 3: Design

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

The goal of this phase is the design. Follow the steps below in sequence.

## Step 3.1: Produce the design options

Run the `/dream:design` skill, focused on the requirements analysis and code
analysis. Give it the session input too, so it sources any design steer the
input carries. The requirements analysis leaves that steer out, so this is its
only route into the design.

The skill returns the design options: the proposed design (its recommendation)
and any alternative designs, each with its trade-off named.

## Step 3.2: Share the design

Take the proposed design. It is the skill's recommendation, weighed against the
alternatives it names.

Write the following to a temporary file outside this repo, via Bash:

- the design you took
- every alternative design, under an "Alternatives considered" heading, so the
  record shows what was weighed and not chosen. When there was no alternative
  design, omit the heading.

Then:

- **Send it to Junio and Ralph.** Give them the file's absolute path: two
  `SendMessage` calls in the same turn, for information only.
- **Post it to the PR** from that same file, per
  [Writing to GitHub](../../../agents/Grace.md#writing-to-github).
