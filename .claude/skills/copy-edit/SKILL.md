---
name: copy-edit
description:
  Align the prose you changed with WRITING.md. Reviews your changed text with a
  fresh reader and fixes what the review raises, looping until it passes or hits
  the iteration cap. Run it after you write or edit repo prose.
argument-hint: "[max-iterations]"
---

# Copy-edit

Bring the prose you changed into line with WRITING.md. Run a loop. Each round
reviews the changed prose with a fresh reader, then fixes what the review
raises. The loop ends when the review is clean or you reach the iteration cap.

## The iteration cap

The first argument sets the largest number of rounds. Use three when the caller
gives no number.

## Each round

1. Gather the prose you changed. Use `git diff` to find the changed Markdown.
   Read each changed passage in its current form, with enough surrounding text
   to judge a paragraph whole. Review prose, not diff markup.
2. Review it with the `writing-judge` subagent. For a small change, give one
   subagent the whole of it. For a large change, split it by file or section and
   launch parallel `writing-judge` subagents, one per part.
3. When every subagent returns `VERDICT: PASS`, stop. Report success and the
   number of rounds it took.
4. Otherwise, resolve every issue the review raised. You are the author. Make
   each edit yourself and keep the meaning. When a fix would drop a reason, keep
   the reason and meet the rule another way.
5. Start the next round, up to the cap.

## When you reach the cap

Stop and report the open issues to the user. They can run the skill again to
continue.

## Scope

Review only the prose the session changed.
