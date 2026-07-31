---
name: copy-edit
description: Bring a passage of prose into line with the Plain English guide.
argument-hint: "[target] [max-iterations]"
---

# Copy-edit

Bring a passage of prose into line with the Plain English guide. Work in rounds.

## First, read the Plain English guide

Read the [Plain English guide](../../plain-english.md) before you start. It is
the standard you rewrite the prose toward.

## Arguments

Read the arguments the user gives.

- A number sets the cap on rounds. Without it, use one.
- Anything else names a target: a git range like `main...HEAD`, a file, a
  section, or a passage to review. Without a target, review the whole branch
  against `main` (`main...HEAD`).

## Each round

1. Gather the prose to review. With a file, a section, or a passage, that is the
   prose. With a git range, run `git diff` over the range to find the prose it
   changed. Read each passage in its current form, with enough surrounding text
   to judge a paragraph whole. Review prose, not diff markup.
2. Review it with the `dream:copy-editor` subagent. Give each subagent the Plain
   English guide's absolute path in its prompt. A subagent can't resolve a path
   relative to its own prompt file. For a small passage, give one subagent the
   whole of it. For a large passage, split it by file or section. Launch
   parallel `dream:copy-editor` subagents, one per part.
3. Resolve every finding the review returns. You are the author. Make each edit
   yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
4. Report the number of findings addressed this round.
5. If the review returned no findings, or you have reached the cap, stop.
6. Otherwise, start the next round.
