---
name: coherence-review
description:
  Review changed code across coherence lenses and return the combined findings.
argument-hint: "[target]"
---

# Coherence review

Review changed code across coherence lenses and return the combined findings.

## Arguments

Read the argument the user gives. It names what to review: a git range like
`main...HEAD`, or a path. Without one, review the whole branch against `main`
(`main...HEAD`).

## Review

Read the [coherent coding guide](../../coherent-coding.md). It is the home of
the disciplines this review checks. The lens subagents can't read it themselves,
so paste each lens the guide text it needs.

Launch the generic `dream:code-review-lens` subagent via the Agent tool, once
per lens below, all in one message so they run in parallel. Brief each with the
target and its guide section or sections, pasting the heading and the text
beneath it into the briefing.

- **Root cause.** The Resolve the root cause section.
- **Same edit.** The Same edit, every instance section.
- **One home.** The One fact, one home section.
- **One model.** The One concept, one model section.
- **Separation.** The Separation and boundaries section.
- **Carried in shape.** The Code-shape ladder, Wrong-layer defensive code, and
  Cross-site rules sections.
- **Compensation and scaffolding.** The Strip the compensation and Defend
  behaviour sections.
- **Naming.** The Names that tell the truth section.

Pass the target as a git range, or as an absolute path. A subagent can't resolve
a path relative to its own prompt file.

Combine their findings into one list, dropping duplicates. Mark each as a defect
or an opportunity, so the caller can tell them apart. A defect is where the code
fails to fit and needs fixing now. An opportunity is where the code fits, but a
generalisation would leave it simpler, easier to maintain, or able to shed code.
