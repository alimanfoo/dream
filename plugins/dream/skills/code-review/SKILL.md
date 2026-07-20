---
name: code-review
description:
  Review changed code through review lenses chosen to fit the diff, and return
  the combined findings.
argument-hint: "[target]"
---

# Code review

Review changed code through review lenses chosen to fit the diff, and return the
combined findings. Report findings only, do not apply fixes.

## Arguments

Read the argument the user gives. It names what to review: a git range like
`main...HEAD`, or a path. Without one, review the whole branch against `main`
(`main...HEAD`).

## Cold read

Read the diff and the source files you need for context. Review from the diff
itself, not from any surrounding description. Read the change in these
directions:

- **Inward:** the whole function each change sits in, not just the changed
  lines.
- **Backward:** the removed or replaced lines, and whether their guarantees are
  still handled.
- **Outward:** the callers and callees of changed symbols.
- **Lateral:** parallel sites, sibling files or parallel functions, that mirror
  the change.

These say where to look, not what to find. Judge what matters yourself.

Draft your findings from that read: correctness, coherence, and anything a
careful reviewer would flag. A spot where you had to load context or guess to
follow the code is itself a finding, even when the code is correct. Name the
spot and the concrete cost to the next reader.

## Widen with review lenses

Pick up to five review lenses that fit this diff, depending on its scale and
nature. A lens is one narrow question chosen for what the diff actually does,
not a generic "review this." Match the lens to the change. For example:
concurrent code invites a races-and-ordering lens, a parser invites a
malformed-input lens, a refactor invites a reuse-and-duplication lens.

Choose from these or invent your own. They are examples, not a checklist:

- concurrency and ordering: races, deadlocks, lost updates on the changed paths
- failure paths: errors, timeouts, partial writes, what is left half-done
- input validation and security: untrusted input, injection, missing checks
- reuse and simplification: code that re-implements what the codebase already
  has, or that a simpler form would replace
- efficiency: redundant work, repeated I/O, blocking added to a hot path
- altitude: whether the change sits at the right depth, or is a quick fix
  layered on shared infrastructure
- reader's context: in new or changed prose, what the reader needs but is
  missing, and what is there but they do not need

Spawn the `dream:code-review-lens` subagent once per lens, via the Agent tool,
all in a single message so they run in parallel. Give each the target, as a git
range like `main...HEAD` or an absolute path, and the one lens it applies. A
subagent can't resolve a path relative to its own prompt file. The subagent is
read-only by tool design: it reads and reports.

Skip the lenses for a diff small enough that your cold read already exhausts it.
Three subagents on a one-line fix is wasted motion.

## Combine and return

Combine the lens findings with your own. Judge each on its merits, not on the
fact a subagent raised it. Drop duplicates that point at the same line or
mechanism. Return the combined findings as turn output, in the format below.
Report only: apply no fixes.

```text
**Recommendation:** <one-line verdict — e.g. "looks good, a few
small things"; "blocking concerns below"; "approve subject to nits">

## Blocking
1. ... (concrete finding with file/line citation)

## Non-blocking
1. ...

## Nits
1. ...

## Out of scope but noticed
1. ... (pre-existing items, not part of what the diff changed)
```

Skip any section with no entries. If you have nothing to report, say so under
**Recommendation** and return.

Each finding follows these rules:

- **Name the concrete consequence.** Give each finding a specific consequence,
  not a vague worry. For example: a wrong output, a crash, a reader misled, a
  sibling left inconsistent. If you cannot say what goes wrong, it is not a
  finding.
- **Don't duplicate the diff.** State what's wrong and why, with a citation.
  Don't quote the change back.
- **State only findings.** Don't narrate what the code does or confirm what
  works.
- **Keep it tight.** One finding per numbered item, two or three sentences each.
