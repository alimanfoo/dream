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

A repository's label often carries more than the word you were given, such as a
trailing emoji, and `gh issue list --label` matches the full name only. Take the
match as the resolved label. Stop and tell the user if the search finds none.
Don't sweep with a guess.

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

## Report what you found

Report each issue in your turn output: its number, its recommendation, and the
check that stopped it when you recommend closing. Name separately any issue you
could not judge.
