---
name: validate-issues
description:
  Validate the open issues carrying a label, and recommend implementing or
  closing each one. Use only when the user explicitly runs
  /dream:validate-issues.
argument-hint: "[label]"
---

# Validate issues

Validate the open issues carrying a label. Each one gets a comment recommending
that the user implement it or close it, and then loses the label.

## Arguments

Read the argument the user gives. It names the label to look for. Without one,
use "validate". The repository is the one in the current working directory.

## Resolve the label

Find the repository's label:

```bash
gh label list --search "<label>"
```

Use the full name of the one match whose name holds the text you searched for.
The search matches a label's description as well as its name, and a repository's
label often carries an emoji. So "validate" and "validate 🔍" are one label to
the search and two labels to `gh issue list`.

Stop and tell the user when the search finds no such label, or more than one.
`gh issue list` returns nothing for a label that isn't there, which reads as
every issue being validated already.

## List the issues

List the open issues carrying the label you resolved:

```bash
gh issue list --label "<resolved label>" --limit 100
```

Write each issue's number and title in your turn output, so the user sees the
scale of the work before it starts. Stop and say so when nothing carries the
label.

Then read the repository's slug once, with `gh repo view --json nameWithOwner`.
Every subagent needs it.

## Launch the validators

Spawn the `dream:issue-validator` subagent once per issue, via the Agent tool,
all in one message so they run in parallel. Give each one the repository slug,
the absolute path of this checkout, and the one issue it validates. A subagent
can't resolve a path relative to its own prompt file. Its own instructions carry
the method, so brief it with nothing else.

Launch at most eight at a time. Work through a longer list in batches, since
each validator reads the whole project.

Once the subagents are running, go idle: end your turn and let their comments
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Read the comments together

Comments land one subagent at a time. So go idle again after each, until every
validator you launched is in, in every batch.

Each comment arrives confirmed. The validator checked its answers against what
it read, and says what it read. So don't check them again.

Then read the comments together. A validator sees only its own issue, so it
can't tell when two of the issues ask for the same change, or when two
recommendations pull the same design different ways. Say so in both comments
when you find such a pair. Write each paragraph you add on a single line, since
GitHub reflows it (see
[Text for GitHub](../../plain-english.md#text-for-github)).

## Copy-edit the comments

Write each comment to its own temporary file outside this repository, so the
working tree stays clean. Then run the `/dream:copy-edit` skill over those
files, naming them as the target. Without a target it reviews the branch's diff
instead.

## Post each comment and remove the label

Work through the issues one at a time. For each one:

- Add the heading `Validation` at the top of its file, and the Claude Code
  footer at the end:

  > 🤖 Generated with [Claude Code](https://claude.com/claude-code)

- Post the comment: `gh issue comment <issue> --body-file <path>`.
- Remove the label: `gh issue edit <issue> --remove-label "<resolved label>"`.

Post the comment before you remove the label. The label is the record that the
issue still needs validating, so a post that fails leaves the issue for the next
run.

Never close an issue, whatever its comment recommends. Closing is the user's
call.
