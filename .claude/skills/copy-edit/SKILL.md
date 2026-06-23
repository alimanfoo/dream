---
name: copy-edit
description:
  Align a passage of repo prose with the writing guide (writing-style.md).
  Reviews the prose with a fresh reader and fixes what the review raises,
  looping until it passes or hits the cap. By default it reviews the prose you
  changed. Name a file or section to review that instead.
argument-hint: "[target] [max-iterations]"
---

# Copy-edit

Bring a passage of repo prose into line with the writing guide
(`writing-style.md`). Work in rounds.

## Arguments

Read the arguments the user gives.

- A number sets the cap on rounds. Without it, use three.
- Anything else names a target: a file, a section, or a passage to review.

## Each round

1. Gather the prose to review. With a target, read it. Without one, use
   `git diff` to find the prose the session changed. Read each passage in its
   current form, with enough surrounding text to judge a paragraph whole. Review
   prose, not diff markup.
2. Review it with the `copy-editor` subagent. For a small passage, give one
   subagent the whole of it. For a large passage, split it by file or section
   and launch parallel `copy-editor` subagents, one per part.
3. Resolve every finding the review returns. You are the author. Make each edit
   yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
4. Report the number of findings addressed this round.
5. If the review returned no findings, or you have reached the cap, stop.
6. Otherwise, start the next round.
