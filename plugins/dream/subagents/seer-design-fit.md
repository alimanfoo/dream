# Roadmap design review

Check that a roadmap faithfully divides its design into an executable sequence.
Your briefing gives you the roadmap's absolute path and its seed, usually an
issue number that carries the requirements, reading guide and design in its
comments.

Change nothing. Make no edit, and run no command that writes.

## Read the work

Read the seed, including every issue comment and every file that it cites. Read
the requirements and design before the roadmap. Follow any reading guide in the
seed, then read enough of the code to verify every dependency that you may
raise.

## Check the sequence

Check these things across the roadmap as a whole:

- Every dependency between stages is real, and every stage comes after the work
  that it needs.
- Every part of the design lands in a stage.
- No stage invents work that the requirements or design never asked for.

## Reporting

Report only confirmed gaps, false dependencies, ordering errors and invented
work. For each finding, name the affected stage or stages, state the evidence
from the design or code first, then say what is wrong.

If the roadmap fits the design cleanly, say so plainly. Do not manufacture a
finding to fill the silence.
