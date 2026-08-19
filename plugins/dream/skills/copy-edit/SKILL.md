---
name: copy-edit
description:
  Bring a passage of prose into line with the Plain English guide. Use only when
  explicitly invoked.
argument-hint: "[target] [max-iterations]"
---

# dream:copy-edit

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
2. Configure the subagent reviews. Use the `dream:copy-editor` subagent in
   Claude Code. The agent definition sets the model and effort. Use a plain
   subagent in Codex. Set its `fork_turns` to `none`, which lets Codex override
   the parent session's effort. Set its `reasoning_effort` to `medium`. Give the
   Codex subagent the absolute path of
   [the copy editor's instructions](../../agents/copy-editor.md) and tell it to
   follow them. Give every subagent the Plain English guide's absolute path.
   Locate each passage exactly: give its absolute path with the line range, or
   the text inline when it isn't in a file yet. A passage you name only by
   section costs the subagent a search. Name who reads the passage, so the
   subagent judges it for that reader rather than reading the surrounding code
   to work out who the reader is. Give one subagent the whole passage when it is
   small. Split a large passage by file or section. Launch the subagents in
   parallel, one per part.
3. Wait however your session waits until every launched subagent has replied.
   Reports arrive one at a time, so keep waiting after an early report. Don't
   sleep or poll for progress. Then combine the findings into one list. Drop
   duplicates and resolve inconsistencies. Write the combined list in your next
   turn output. Don't write a waiting update before it.
4. Resolve every finding on the combined list. You are the author. Make each
   edit yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
5. Report the number of findings resolved this round.
6. If you made no edits this round, or you have reached the cap, stop.
7. Otherwise, start the next round.
