---
name: dedup-issues
description:
  Scan a repository's issues for duplicates, including one issue whose scope
  contains another's, and report the pairs that could close as duplicates.
argument-hint: "[--full]"
---

# Dedup issues

Scan a repository's issue tracker for duplicates, and print the pairs that could
close as a duplicate of another. This covers the case where one issue's scope
contains another's, so the narrower one could close as a duplicate of the wider.
The skill reports the pairs. It never closes an issue. You read the report and
decide.

Run this from a repository's working directory. It reads that repository's
issues through the `gh` CLI.

The skill reads each issue once. A first run checks every open issue against all
earlier issues. A later run checks only the issues added since. So it does not
re-read a large tracker every time.

## Arguments

Read the argument the user gives. With `--full`, the run rechecks every open
issue against all earlier ones. Without it, the run is incremental: it checks
only the open issues added since the last run.

## Scan the tracker

Run `dedup.sh` in this skill's directory, giving the Bash tool its absolute
path. Pass `--full` through when the user gave it. Read the JSON it prints. Do
not read the issue body files yourself. The subagents read those, so your own
context stays small even on a large tracker.

If `dedup.sh` exits with an error, it prints why. Report that and stop.

The JSON holds:

- `repo`, the repository the run reads.
- `watermark`, the highest issue number the last run checked, or zero on a first
  run.
- `highWater`, the highest issue number this scan saw. The advance step needs
  it.
- `issues`, every issue open and closed, sorted by number. Each carries its
  `number`, `title`, `state`, and `bodyFile`, the path to a file holding its
  body.

## Screen each target by title

A target is any open issue whose number is above the watermark. Treat every such
issue as a target to check.

For each target, look at every earlier issue: any issue with a lower number, in
any state. Pick those whose titles look like they might cover the same thing as
the target. This is a coarse screen on titles alone. Be generous and include a
title that plausibly overlaps. The subagent's read of the title and body is what
decides. A spare match costs little. A missed match never reaches a subagent. A
target with no title-similar earlier issue needs no further reading.

## Confirm each target with a subagent

For each target that has one or more possible matches, launch one
`dream:dedup-issue-check` subagent through the Agent tool. Launch them in
parallel, the way the review skills do. On an incremental run this is a handful.
On a full run over a large tracker it can be many, which is why the title screen
keeps the count down.

Brief each subagent with:

- the target: its issue number, its title, and its `bodyFile` path.
- each match: its issue number, its title, and its `bodyFile` path.

Take the number, title, and path from the scan JSON. The subagent needs the
number to say which issue to close. It does not read the number from the path.

The subagent judges from the title and the body. It returns the duplicate
relationships it finds. For each match, it reports whether the target could
close as a duplicate, which issue to close, and a one-line reason.

## Print the report

Gather the relationships every subagent returned into one Markdown report, and
print it. Give each relationship one line: the issue to close, the issue it
closes against, and the reason the subagent gave. Refer to each issue as
`#<number>`, the form GitHub turns into a link.

Print a line saying the run found none, when there were no targets or no
subagent found a duplicate.

## Advance the watermark

Advance only after you have printed the report. So a run stopped midway repeats
next time, rather than skipping the issues it had not yet reported.

Extract the value with `jq -r '.highWater // empty'`, so a null `highWater`
becomes an empty string. Run `dedup.sh --advance <value>` with it. On an empty
tracker the value is empty. So `--advance` gets no value, and the watermark
stays unchanged.
