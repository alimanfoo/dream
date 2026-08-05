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
2. Split the prose into parts, one per subagent. Give one subagent the whole of
   a small passage. Split a large one by file or section.

   Review each part with the `dream:copy-editor` subagent. Where your session
   has no subagent of that name, use a plain subagent and give it the absolute
   path to [the copy editor's instructions](../../agents/copy-editor.md) to read
   and work to. Launch them all in parallel, one per part.

   Give each subagent the Plain English guide's absolute path in its prompt. A
   subagent can't resolve a path relative to its own prompt file. Locate its
   part exactly: give the absolute path with the line range, or the text inline
   when it isn't in a file yet. A passage you name only by section costs the
   subagent a read of the whole file to find. Name who reads the passage, so the
   subagent judges it for that reader rather than reading the surrounding code
   to work out who the reader is.

   Once the subagents are running, wait for their findings. End your turn if
   that is how your session waits. They arrive on their own when each subagent
   finishes. Don't sleep. Don't poll for progress. Don't write that you are
   waiting.

3. Findings land one subagent at a time, so keep waiting after each until every
   subagent you launched is in. Then combine the findings into one list. Drop
   duplicates and resolve inconsistencies. Write the combined list in your turn
   output.
4. Resolve every finding on the combined list. You are the author. Make each
   edit yourself and keep the meaning. When a fix would drop a reason, keep the
   reason and meet the rule another way.
5. Report the number of findings resolved this round.
6. If you made no edits this round, or you have reached the cap, stop.
7. Otherwise, start the next round.
