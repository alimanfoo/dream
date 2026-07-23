---
name: validate-issues
description:
  Investigate and validate labelled issues. List the issues carrying a label,
  evaluate each for whether it is worth implementing, post a brief
  recommendation, and remove the label.
argument-hint: "[label]"
---

# Validate issues

Investigate the issues carrying a label and recommend, for each, whether to
implement or close it. You list the labelled issues, evaluate each with a
subagent, post the recommendation as a comment, and remove the label to mark the
issue validated.

The recommendation is advisory. Don't close any issue and don't add any other
label. The decision to implement or close stays with the user.

## Arguments

Read the argument the user gives. It names the label to process. Without one,
use "validate".

Quote the label in every command, since it can hold spaces or an emoji. This
repo's label is "validate 🔍", for example. The user passes it as the argument.

## List the labelled issues

List the open issues carrying the label:

```bash
gh issue list --state open --label "<label>" --json number,title
```

When none carry it, tell the user so and stop.

## Evaluate each issue

Launch one `dream:validate-issue` subagent per issue, via the Agent tool, all in
a single message so they run in parallel. Give each the issue number. Each reads
the issue itself and returns a recommendation and a drafted comment.

## Post and mark each issue

Once the subagents return, handle each issue in turn:

1. Copy-edit the drafted comment. Run the `/dream:copy-edit` skill over it,
   passing the comment as the passage to review, since it is not a file.
2. End the comment with the Claude Code footer, so a reader can tell it is
   agent-authored:

   > 🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Then post it: `gh issue comment <N> --body "<comment>"`.

3. Remove the label, but only after the post succeeds:
   `gh issue edit <N> --remove-label "<label>"`. A failed post then leaves the
   label in place, so the issue is picked up again next time.

Removing the label marks the issue validated, whichever way the recommendation
went.
