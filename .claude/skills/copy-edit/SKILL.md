---
name: copy-edit
description:
  Align a passage of repo prose with WRITING.md. Reviews the prose with a fresh
  reader and fixes what the review raises, looping until it passes or hits the
  cap. By default it reviews the prose you changed. Name a file or section to
  review that instead.
argument-hint: "[target] [max-iterations]"
---

# Copy-edit

Bring a passage of repo prose into line with WRITING.md. Work in rounds.

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
3. When no finding from any subagent is marked `CHANGES NEEDED`, stop. Report
   success and the number of rounds it took.
4. Otherwise, resolve every finding marked `CHANGES NEEDED`. You are the author.
   Make each edit yourself and keep the meaning. When a fix would drop a reason,
   keep the reason and meet the rule another way.
5. Start the next round, up to the cap.

## When you reach the cap

Stop and report the open issues to the user. They can run the skill again to
continue.
