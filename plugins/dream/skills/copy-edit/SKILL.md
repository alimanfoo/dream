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
- Anything else names a target: a git range, a file, a section, or a passage to
  review. Without a target, review the whole branch against `origin/main`
  (`origin/main...HEAD`).

## Each round

1. Gather the prose to review. With a git range, run `git diff` over the range
   to find the prose it changed: Markdown, docstrings, comments, prompts. Skip
   any file the range changed without touching prose. Any other target is itself
   the prose. Read each passage in its current form, and widen it until every
   paragraph it holds is whole. The subagent judges only what you hand it, so a
   passage cut mid-paragraph is one it cannot judge. Review prose, not diff
   markup.
2. Review it with `general-purpose` subagents, spawned via the Agent tool on
   Sonnet at medium effort. Give each the absolute path of
   [the copy editor's instructions](../../subagents/copy-editor.md) and tell it
   to work to them. Give each the Plain English guide's absolute path too. A
   subagent can't resolve a path relative to its own prompt file. Locate each
   passage exactly: give its absolute path with the line range, or the text
   inline when it isn't in a file yet. A passage you name only by section costs
   the subagent a search. Name who reads the passage, so the subagent judges it
   for that reader rather than reading the surrounding code to work out who the
   reader is. For a small passage, give one subagent the whole of it. For a
   large passage, split it by file or section. Launch parallel subagents, one
   per part. The next thing you write to me carries their reports. So wait for
   the reports however your session waits, then continue — don't sleep, don't
   poll for progress, and don't write that you're waiting.
3. Wait again after each, however your session waits, until every subagent you
   launched is in, since findings land one subagent at a time. Then combine the
   findings into one list. Drop duplicates and resolve inconsistencies. Write
   the combined list in your turn output.
4. Resolve every finding on the combined list. You are the author. Make each
   edit yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
5. Report the number of findings resolved this round.
6. If you made no edits this round, or you have reached the cap, stop.
7. Otherwise, start the next round.
