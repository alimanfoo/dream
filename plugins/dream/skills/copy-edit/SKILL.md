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
2. Review it with the `dream:copy-editor` subagent. Give each subagent the Plain
   English guide's absolute path in its prompt. A subagent can't resolve a path
   relative to its own prompt file. Locate each passage exactly: give its
   absolute path with the line range, or the text inline when it isn't in a file
   yet. The subagent has no search tool, so a passage you name only by section
   costs it a read of the whole file. Name who reads the passage, so the
   subagent judges it for that reader rather than reading the surrounding code
   to work out who the reader is. For a small passage, give one subagent the
   whole of it. For a large passage, split it by file or section. Launch
   parallel `dream:copy-editor` subagents, one per part. Once the subagents are
   running, go idle: end your turn and let their findings land. They arrive on
   their own when each subagent finishes. Don't sleep. Don't poll for progress.
   Don't write that you are waiting.
3. Wait for every subagent to finish before you act on any finding. When one
   subagent's findings land while others are still running, go idle again. Then
   combine the findings into one list. Each subagent judged its own passage
   alone, so you are the only reader who sees them all. Drop duplicates that
   point at the same span. When two findings pull one span different ways, keep
   one and drop the other. When a fix would word one passage differently from
   another that says the same thing, word both the same way.
4. Resolve every finding on the combined list. You are the author. Make each
   edit yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
5. Report the number of findings resolved this round. Name each finding you
   dropped when you combined them, and give the reason in one sentence.
6. If you made no edits this round, or you have reached the cap, stop.
7. Otherwise, start the next round.
