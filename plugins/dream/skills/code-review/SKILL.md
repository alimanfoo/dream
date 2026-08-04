---
name: code-review
description: Review changed code through review lenses chosen to fit the diff.
argument-hint: "[target] [inline]"
---

# Code review

Review changed code through review lenses chosen to fit the diff.

## Arguments

Read the arguments the user gives. `target` names what to review: a git range,
or a path. Without it, review the whole branch against `origin/main`
(`origin/main...HEAD`). If `inline` is given, run the lenses yourself without
spawning subagents.

## Read the diff

Read the diff and the source files you need for context. This read picks the
lenses, and it gives you the context to verify what they return.

## Launch the lenses

Pick up to nine review lenses that fit this diff, depending on its scale and
nature. A lens is one narrow question chosen for what the diff actually does,
not a generic "review this." For example: concurrent code invites a
races-and-ordering lens, a parser invites a malformed-input lens, a refactor
invites a reuse-and-duplication lens.

Choose from these or invent your own. They are examples, not a checklist:

- correctness bugs: inverted/wrong condition, off-by-one, null/undefined deref
  where adjacent lines show the value can be absent, removed guard, falsy-zero
  check, missing await, wrong-variable copy-paste, error swallowed in a catch
  that should propagate
- concurrency and ordering: races, deadlocks, lost updates on the changed paths
- failure paths: errors, timeouts, partial writes, what is left half-done
- input validation and security: untrusted input, injection, missing checks
- efficiency: redundant work, repeated I/O, blocking added to a hot path
- reuse and simplification: code that re-implements what the codebase, a
  library, or a language feature already provides, or that a simpler form would
  replace
- altitude: whether the change sits at the right depth, or is a quick fix
  layered on shared infrastructure
- reader's context: in new or changed prose, what the reader needs but is
  missing, and what is there but they do not need
- alignment: compliance with agent instructions (AGENTS.md or CLAUDE.md)

Spawn the `dream:code-review-lens` subagent once per lens, via the Agent tool,
all in a single message so they run in parallel. Give each the target, as a git
range like `origin/main...HEAD` or an absolute path, and the one lens it
applies. A subagent can't resolve a path relative to its own prompt file.

The subagent is read-only by tool design: it reads and reports.

In inline mode, run the lenses yourself instead of spawning subagents. Read
[the lens subagent's instructions](../../agents/code-review-lens.md) first and
work to them, since you are the one applying each lens.

Once the subagents are running, go idle: end your turn and let their findings
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Combine and verify

Wait for every subagent to finish before you act on any finding. When one
subagent's findings land while others are still running, go idle again.

Then combine their findings into one list, dropping duplicates that point at the
same line or mechanism.

Read the code each finding cites. Keep only the findings you can confirm.

## Rank and return

Return the verified findings as turn output: a numbered list, most important
first. Report only: apply no fixes. If you have nothing to report, say so and
return.
