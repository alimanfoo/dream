---
name: code-review
description:
  Review changed code through review lenses chosen to fit the diff. Use only
  when explicitly invoked.
argument-hint: "[target] [inline]"
---

# dream:code-review

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

Prepare one subagent per lens. Give every subagent the target, as a git range
like `origin/main...HEAD` or an absolute path, and the one lens it applies.

Under Claude Code:

- Use the `dream:code-review-lens` subagent. Its definition sets the model and
  effort.

Under Codex:

- Use a plain subagent.
- Set its `fork_turns` to `none`, which lets Codex override the parent session's
  effort. Set its `reasoning_effort` to `medium`.
- Give it the absolute path of
  [the lens instructions](../../agents/code-review-lens.md) and tell it to
  follow them, skipping the file's YAML frontmatter, which configures the agent
  under Claude Code.

Launch every prepared subagent at the same time so they run in parallel.

In inline mode, run the lenses yourself instead of spawning subagents. Read
[the lens instructions](../../agents/code-review-lens.md) first and work to
them, since you are the one applying each lens.

## Wait for the lenses

If you launched any subagents, read and follow the
[subagent waiting protocol](../../subagent-waiting.md) for them.

## Combine and verify

Combine their findings into one list. Drop duplicates and resolve
inconsistencies.

Read the code each finding cites. Keep only the findings you can confirm.

## Rank and output

Output the verified findings as a numbered list, most important first. If you have
nothing to report, say so.
