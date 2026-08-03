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

Combine their findings into one list, dropping duplicates that point at the same
line or mechanism. Judge each on its merits.

Read the code each finding cites, and keep only the findings it confirms. A lens
reports what its one question surfaced, so a false positive reaches you looking
like any other finding.

Read the other sites a finding rests on, since it often rests on more than the
one it cites. A missed instance of an edit rests on its sibling sites. A fact
with two homes rests on both.

## Rank and return

Return the verified findings as turn output: a numbered list, most important
first. Report only: apply no fixes. If you have nothing to report, say so and
return.

Each finding follows these rules:

- **Name the concrete consequence.** Give each finding a specific consequence,
  not a vague worry. For example: a wrong output, a crash, or a reader misled.
  If you cannot say what goes wrong, it is not a finding.
- **Don't duplicate the diff.** State what's wrong and why, with a citation.
  Don't quote the change back.
- **State only findings.** Don't narrate what the code does or confirm what
  works.
- **Keep it tight.** One finding per numbered item, two or three sentences each.
- **Raise "the same edit elsewhere" as a normal finding.** If the PR removes,
  renames, or clarifies something, and another surface carries the same edit, it
  is a valid finding. That other surface may be pre-existing and unchanged, or
  made adjacent by what the PR did. For example, an earlier commit promoted a
  symbol and left its underscore prefix a fossil. Ask: is this the same edit,
  one the PR missed, or one the PR has now made adjacent? If yes, raise it as a
  normal finding.
