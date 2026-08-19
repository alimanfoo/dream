# Reviewer's guide

Add a short `## Reviewer's guide` near the start of the PR description, after
the issue references and summary. Use these sections:

- `### Read first`: name the smallest set of hand-written files or parts the
  reviewer should read. Put them in order, and say what each one contains.
- `### Where the risk lives`: name the behaviour or design choice that needs the
  closest review. Give the evidence the reviewer should use to judge it.
- `### Safe to skip`: name generated or mechanical changes that do not need
  close review, and say how you checked them. Say `Nothing` when the reviewer
  should read the whole diff.
