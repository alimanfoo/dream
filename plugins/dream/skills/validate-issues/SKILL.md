---
name: validate-issues
description:
  Judge the issues carrying a label, and recommend on each whether to implement
  it or close it. Use only when the user explicitly runs /dream:validate-issues.
argument-hint: "[label]"
---

# Validate issues

Judge every issue carrying a label, and post a recommendation on each: implement
it, or close it. This works through a backlog of issues nobody has judged yet.

You recommend. You never close an issue. Dropping a piece of work is the user's
call.

Write every comment in this skill using `/dream:plain-english`.

Follow the steps in order.

## Arguments

Read the argument the user gives. It names the label to work through. Without
one, use "validate".

## Resolve the label

Run `gh label list --search "<name>"`. Take the label whose name is the one you
were given, or that name with an emoji added. Repos often decorate a label that
way. The issue filter matches the whole name. So the bare name matches no issue,
and `gh` returns an empty list rather than an error. The search also matches a
label's description, so expect rows that no name match picks up. Stop and tell
the user when no name matches, or more than one does. Use the resolved name from
here on.

## List the issues

List the open issues carrying the resolved label:

```bash
gh issue list --label "<label>" --state open --limit 100 --json number,title
```

Pass the limit. Without it `gh` returns the first 30 and drops the rest without
saying so.

Name the issues you found in your turn output, so the user sees the batch before
you post to it. Stop and say so when there are none.

## Validate each issue

Launch the `dream:issue-validator` subagent, once per issue, all in one message
so they run in parallel. Give each the issue number and the absolute path to the
repository. A subagent can't resolve a path relative to its own prompt file.

## Check the evidence

Read the code, issues, and history each recommendation cites, and confirm the
evidence holds. A subagent reports what its own read surfaced, so a
recommendation built on a misread reaches you looking like any other one. This
matters most for a close, which drops work the user thought was wanted.

Where the evidence doesn't hold, the recommendation has nothing under it. Launch
a fresh `dream:issue-validator` subagent on that issue, and tell it what your
check found. The questions behind a recommendation live in that subagent, so
deciding the issue here would judge it by something else. Check the fresh
recommendation the same way. When that one doesn't hold either, leave the issue
alone: post nothing, keep its label, and name it in your report. A subagent that
returned nothing gives you nothing to check, so leave that issue alone too.

## Draft the comments

Draft one comment per issue: the recommendation, and the reasoning behind it.
Keep each to a few sentences. Cite what the reasoning rests on, so the user can
check it. End each with the Claude Code footer:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

Write each draft to its own temporary file outside the repo, then run the
`/dream:copy-edit` skill over those files, naming each path. The user reads
these comments on the issue, so they need to be as readable as the rest of the
project's prose.

## Post the recommendations

For each issue, post its comment, then remove the label:

```bash
gh issue comment <n> --body-file <path>
gh issue edit <n> --remove-label "<label>"
```

Post before you remove the label, and remove it only when the comment landed.
The label is what marks an issue as still to judge. An issue that loses its
label with nothing posted drops out of the next run.

Finally, report what happened to each issue: the recommendation, and whether the
comment and the label removal both landed. A removal that failed leaves the
issue labelled, and the next run posts a second comment on it.
