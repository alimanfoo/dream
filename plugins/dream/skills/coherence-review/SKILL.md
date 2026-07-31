---
name: coherence-review
description:
  Review changed code across coherence lenses and return the combined findings.
argument-hint: "[target]"
---

# Coherence review

Review changed code across coherence lenses and return the combined findings.

## Arguments

Read the argument the user gives. It names what to review: a git range, or a
path. Without one, review the whole branch against `origin/main`
(`origin/main...HEAD`).

## Launch the lenses

Read the [coherent coding guide](../../coherent-coding.md). It is the home of
the disciplines this review checks. The lens subagents can't read it themselves,
so paste each lens the guide text it needs.

Launch the generic `dream:code-review-lens` subagent via the Agent tool, once
per lens below, all in one message so they run in parallel. Brief each with the
target and its guide section or sections, pasting the heading and the text
beneath it into the briefing.

- **Root cause.** The
  [Resolve the root cause](../../coherent-coding.md#resolve-the-root-cause)
  section.
- **Same edit.** The
  [Same edit, every instance](../../coherent-coding.md#same-edit-every-instance)
  section.
- **One home.** The
  [One fact, one home](../../coherent-coding.md#one-fact-one-home) section.
- **One model.** The
  [One concept, one model](../../coherent-coding.md#one-concept-one-model)
  section.
- **Separation.** The
  [Separation and boundaries](../../coherent-coding.md#separation-and-boundaries)
  section.
- **Deep modules.** The [Deep modules](../../coherent-coding.md#deep-modules)
  section.
- **Defensive code.** The
  [Define errors out of existence](../../coherent-coding.md#define-errors-out-of-existence),
  [Code-shape ladder](../../coherent-coding.md#code-shape-ladder), and
  [Wrong-layer defensive code](../../coherent-coding.md#wrong-layer-defensive-code)
  sections.
- **Cross-site rules.** The
  [Cross-site rules](../../coherent-coding.md#cross-site-rules) section.
- **Compensation and scaffolding.** The
  [Strip the compensation](../../coherent-coding.md#strip-the-compensation) and
  [Defend behaviour, not surface](../../coherent-coding.md#defend-behaviour-not-surface)
  sections.
- **Naming.** The
  [Names that tell the truth](../../coherent-coding.md#names-that-tell-the-truth)
  section.

Pass the target as a git range, or as an absolute path. A subagent can't resolve
a path relative to its own prompt file.

## Combine, verify and return

Combine their findings into one list, dropping duplicates. Judge each on its
merits, not on the fact a subagent raised it.

Read the code each finding cites, and drop the findings that don't hold up. A
lens reports what its one question surfaced, so a false positive reaches you
looking like any other finding.

A finding often rests on more than the site it cites, so read those other sites
too. A missed instance of an edit rests on its sibling sites. A fact with two
homes rests on both.

Mark each surviving finding as a defect or an opportunity, so the caller can
tell them apart. A defect is where the code fails to fit and needs fixing now.
An opportunity is where the code fits, but a generalisation would leave it
simpler, easier to maintain, or able to shed code.

Return the surviving findings as turn output. Report only: apply no fixes. If
you have nothing to report, say so and return.
