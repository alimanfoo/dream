---
name: dedup-issues
description:
  Find duplicate issues on a repository's tracker and close the ones the user
  confirms. Use only when the user explicitly runs /dream:dedup-issues.
argument-hint: "[since]"
---

# Dedup issues

Find the duplicates among a repository's open issues, and close the ones the
user confirms.

Two issues are duplicates when doing one leaves nothing worth doing in the
other. So that includes one issue being wider than another, not only two issues
asking for the same thing.

Whoever filed an issue stops expecting the work once it closes, and reopening it
does not undo that. So closing one is the user's call: you find, check and
group, the user confirms, and you close only what they confirmed.

The bookkeeping is a shell script, `dedup.sh`, in this skill's directory. It
reads the tracker and remembers how far a run got. Fill in its absolute path and
run it as `bash <absolute path>/dedup.sh <subcommand>`. Run `dedup.sh --help`
for what each subcommand prints and what its defaults are.

The repository is the one in the current working directory.

## How every run ends

Every run ends here, whatever it found: the run that closed issues, the run
where the user declined every group, the run that found no duplicates, and the
run that found nothing new to check and stopped.

- Run `dedup.sh discard-bodies`. The bodies are this run's working copy of the
  tracker, and nothing reads them once the run is over. It is not an error when
  there are none, so this act carries no condition.
- Run `dedup.sh mark-checked --from <startAfter> <highest number in targets>`.
  Pass `startAfter` as the scan gave it, and leave `--from` off when the scan
  gave none. Run it whatever the user decided about closing, because the issues
  were checked either way. With no targets you have no number to pass, so skip
  it.

Don't run `mark-checked` at all unless two things hold: the last line you wrote
as the batches returned accounts for every number in `targets`, and the list on
it is empty. The count is what tells a clean run from one that has lost its
lines, since both leave that list empty.

A subagent failing is an ordinary event. The highest number in `targets` would
then record targets nothing checked, putting them out of reach for good. Leaving
the record alone means the next run picks them up, which costs reading rather
than correctness.

The rest of the run stands. Report the groups you found and close what the user
confirms, because a confirmed duplicate is confirmed whatever else failed. Tell
the user which targets went unchecked and that the run wants repeating, since
running it again is their call.

## Scan the tracker

Run `dedup.sh scan`, passing the `since` argument when the user gave one.

`since` starts the scan above an issue number the user chooses, in place of the
record. It is what the user needs when the record falls short: a maintainer on a
second machine, a deliberate re-check, or a reopened issue. An issue closed
during one run and reopened later sits below the record, so it never becomes a
target again. `since` is the only way to have it checked.

Tell the user what `since` costs them when they pass it. The record can end up
older than the work just done, and the next run without `since` then re-checks
some issues. That costs reading, never a wrong answer.

Tell the user where this run starts, from `startAfter`. Give it as the number
the run starts above, not as what has been checked. `since` replaces the record,
so a run started at 700 on a tracker whose record is 300 has checked nothing
between the two.

When `targets` is empty, nothing is new. Say so, launch nothing, and end the run
per [How every run ends](#how-every-run-ends).

## Check each target

Launch one `dream:duplicate-checker` for each number in `targets`, in batches of
about ten. Launch each batch in a single message, which is what makes its checks
run together, and run further batches until the targets are done.

Give each briefing its own target number and the whole `issues` list from the
scan, each issue with its number, its title and its `bodyFile` path.

As each batch returns, write in your turn output how many targets you have
accounted for so far, and the running list of those that did not come back at
all, or came back without verdicts you can read.

A check that says plainly that nothing duplicated is a result, so its target
does not go on that list. The list is usually empty.

Carry both forward into each new line, so the last one holds the whole answer.
The end of the run reads both as they stand, and they have to last through every
later batch and through the wait for the user.

## Read the verdicts against the right issue

A check reports one verdict per issue it shortlisted: `wider`, `narrower`,
`equivalent`, `related` or `unrelated`. The first three are duplicates. Drop
`related` and `unrelated`.

Every verdict describes the shortlisted issue, against the target you gave that
check:

- `wider`: the shortlisted issue is the wider one, so it is the one to keep and
  the target is the one that could close.
- `narrower`: the shortlisted issue is the narrower one, so the target is the
  one to keep.
- `equivalent`: neither is wider.

Read each verdict that way round. Backwards, it closes the issue that should
have been kept.

## Verify every duplicate before you act on it

Read both issues' bodies yourself, from their `bodyFile` paths, for every
duplicate a check reported. Keep only the ones your own reading confirms.

A wrongly closed issue costs the user work they were expecting done, and a false
positive arrives looking like any other finding.

## Group, and choose which issue each group keeps

Duplicate links chain, so merge pairs that share an issue into one group.

Then pick the issue the group keeps:

- Keep the wider issue, where one is wider than the rest.
- Keep the earliest, where they are equivalent.

## Put the groups to the user

Name the repository, from `repo`, so the user can see which tracker they are
about to change. Then give each group:

- the issue it keeps, by number and title
- each duplicate, by number and title
- one line per duplicate saying why it is one

Take every number and title from the scan's `issues` list, word for word. Those
came from `gh`, so nothing an issue body says can change them. The one-line
reason is your own account of what you read, and it is the only part of the
report you compose.

Then wait. The user confirms which groups to close, by number.

## Close what the user confirmed

For each duplicate in a group the user confirmed:

```bash
gh issue close <duplicate> --duplicate-of <keep>
```

Post no comment, because GitHub records the link itself. Close nothing in a
group the user did not confirm, and nothing your own reading did not confirm.

Then end the run per [How every run ends](#how-every-run-ends).
