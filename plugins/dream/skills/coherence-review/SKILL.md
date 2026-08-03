---
name: coherence-review
description: Review changed code for coherence and maintainability.
argument-hint: "[target]"
---

# Coherence review

Review changed code for coherence and maintainability.

## Arguments

Read the argument the user gives. It names what to review: a git range, or a
path. Without one, review the whole branch against `origin/main`
(`origin/main...HEAD`).

## Read the diff

Read the diff and the source files you need for context. This read gives you the
context to verify what the lenses return.

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

Once the subagents are running, go idle: end your turn and let their findings
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Combine and verify

Combine their findings into one list, dropping duplicates that point at the same
line or mechanism.

Read the code each finding cites. Keep only the findings you can confirm. A lens
reports what its one question surfaced, so a false positive reaches you looking
like any other finding.

Read the other sites a finding rests on, since it often rests on more than the
one it cites. A missed instance of an edit rests on its sibling sites. A fact
with two homes rests on both.

## Rank and return

Return the verified findings as turn output: a numbered list, most important
first. Report only: apply no fixes. If you have nothing to report, say so and
return.
