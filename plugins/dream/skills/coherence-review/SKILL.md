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

Tell each lens to give every finding a proposal that resolves it by taking out
more code than it puts in, naming what goes and from where. A lens that can't
propose one drops the finding. Fixing incoherence by adding is what makes a
codebase harder to maintain the more carefully it is reviewed, so a finding with
no removal behind it costs more than it returns.

Once the subagents are running, go idle: end your turn and let their findings
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Combine and verify

Findings land one subagent at a time. So go idle again after each, until every
subagent you launched is in.

Then combine their findings into one list. Drop duplicates and resolve
inconsistencies.

Read the code each finding cites. Keep only the findings you can confirm.

Confirm each proposal against the code too. Check that what it removes is really
there, and that carrying it out leaves less code than before. Drop any finding
whose proposal fails either check. A lens proposes without being able to see
another lens's work, so two proposals can want the same code gone, and one can
rest on a removal another already counted.

## Rank and return

Return the verified findings as turn output: a numbered list, most important
first. Give each its proposal, since a finding without one doesn't survive this
review. Report only: apply no fixes. If you have nothing to report, say so and
return.
