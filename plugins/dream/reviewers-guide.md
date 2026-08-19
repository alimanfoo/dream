# Reviewer's guide

Fit a short `## Reviewer's guide` into the repository's PR template. Put it near
the start, after the issue references and summary when the template allows. Use
these sections:

- `### Read first`: name the smallest set of files or parts the reviewer should
  read. Put them in order, and say what each one contains. Include generated
  output when it needs review.
- `### Check carefully`: name any behaviour or design choices that need closer
  review than the rest. Point to evidence the reviewer can inspect, such as a
  code path, a command they can run, or a PR comment. Say
  `Nothing beyond the diff` when no part needs closer review.
- `### Safe to skip`: name only changes where review would add no value, and say
  why. A generated or mechanical change is not safe to skip by default. Say
  `Nothing` when the reviewer should read the whole diff.

## Keep it current

Reread the description after any later commit. Update the summary and reviewer's
guide when the diff changes what they say.
