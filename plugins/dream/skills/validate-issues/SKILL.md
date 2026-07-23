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
gh issue list --state open --label "<label>" --limit 500 --json number,title
```

The `--limit 500` overrides the default of 30, so a large backlog isn't silently
truncated.

When none carry it, tell the user so and stop.

## Evaluate each issue

Launch one `dream:issue-validator` subagent per issue, via the Agent tool. Give
each the issue number. It reads the issue itself and returns the comment to
post.

Launch them in parallel, several in one message so they run at once. Cap each
batch at about ten. A label can sit on a large backlog, and firing one subagent
per issue all at once would strain the API and thin each subagent's output.

## Post and mark each issue

Once a batch returns, handle each issue in it. Skip any whose subagent returned
without a usable comment. Leave that issue's label in place and tell the user,
so nothing half-formed is posted. For each of the rest:

1. Write the comment to a temporary file.
2. Copy-edit it. Run the `/dream:copy-edit` skill over the file, giving its
   absolute path.
3. End the file with the Claude Code footer, so a reader can tell the comment is
   agent-authored:

   > 🤖 Generated with [Claude Code](https://claude.com/claude-code)

4. Post the comment and remove the label. Post from the file, so the prose needs
   no shell quoting. Chain the two commands so the label comes off only when the
   post succeeds, leaving it in place otherwise, so the issue is picked up again
   next time:

   ```bash
   gh issue comment <N> --body-file <path> && gh issue edit <N> --remove-label "<label>"
   ```

Removing the label marks the issue validated, whichever way the recommendation
went.
