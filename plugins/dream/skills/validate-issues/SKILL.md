---
name: validate-issues
description:
  Investigate the issues carrying a label, and recommend implementing or closing
  each one.
argument-hint: "[label]"
---

# Validate issues

Investigate every open issue that carries a label, and recommend for each one
whether to implement it or close it.

Write every turn output and artefact in this skill using `/dream:plain-english`.

## Arguments

Read the argument the user gives. It names the label to sweep for. Without one,
sweep for `validate`.

## Find the labelled issues

Resolve the label against the repository:

```bash
gh label list --search "<label>"
```

Take the match as the resolved label. A repository's label often carries more
than the word you were given, such as a trailing emoji, and
`gh issue list --label` matches the full name only. Stop and tell the user if
the search finds no match. Don't sweep with a guess.

List the open issues carrying the resolved label:

```bash
gh issue list --label "<resolved label>" --state open --limit 100
```

Tell the user and stop if no issue carries it.

## Validate each issue

Spawn the `dream:issue-validator` subagent once per issue, via the Agent tool,
all in a single message so they run in parallel. Give each one the number of the
issue it investigates.

The subagent is read-only by tool design: it reads and reports.

Once the subagents are running, go idle: end your turn and let their findings
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Verify each recommendation

Read each issue, and read the code and issues that its recommendation cites.
Keep only the claims you can confirm. A subagent's answer carries no weight on
its own, and its recommendation drives a call to close real work.

Make the call yourself when dropping an unconfirmed claim changes the
recommendation. Set the recommendation aside when what is left cannot support
one, and treat that issue as one you could not judge.

## Draft a comment for each issue

Draft each issue's comment in its own file, in a temporary directory outside the
repository. Don't commit the drafts. They belong to this run, not to the
repository.

Head each comment `## Validation`. Give a line for each check the investigation
ran, with its answer and the evidence behind it. Close with the recommendation
in one sentence, naming the check that stopped it when you recommend closing.

Write for someone who was not in this session. The reader is whoever filed the
issue. Keep the whole comment short.

Write each paragraph on a single line, since GitHub reflows it (see
[Text for GitHub](../../plain-english.md#text-for-github)).

End each comment with the Claude Code footer, which marks it as agent-authored:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

## Copy-edit the drafts

Run the `/dream:copy-edit` skill over the draft files, giving it their absolute
paths.

Then post what the copy-edited files hold, word for word. Don't reword a comment
on its way to GitHub, or the copy-edit buys you nothing.

## Post each comment and clear the label

Post an issue's comment, then take the label off that issue:

```bash
gh issue comment <number> --body-file <draft file>
gh issue edit <number> --remove-label "<resolved label>"
```

Hold that order. The label is what marks the issue as still owed an
investigation. Clearing it before the comment posts drops the issue out of the
queue with nothing to show for it.

Leave the label alone for any issue you did not comment on: one you could not
judge, and one whose comment `gh` failed to post.

Recommend, and stop there. Don't close an issue, however clear the case for it.
Closing is the user's call.

## Report what you did

Report each issue in your turn output: its number, its recommendation, and
whether its comment posted and its label came off. Name separately any issue you
could not judge.
