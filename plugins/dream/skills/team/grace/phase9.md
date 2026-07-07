# Phase 9: Collect

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is to collect Ancillary Findings and Opportunities from
the team. For each, decide whether to file a new issue or comment on an existing
one. Four steps (compile, deepen, test, decide) come before any issue is filed.
Test applies to Findings only. Opportunities skip it. All four are yours, with
user discussion before you file or comment. A fifth step, summarize, closes the
phase by posting what Collect did back to the session PR.

## Step 9.1: Compile

Gather the sources (Ralph in-session, Junio in-session, Ada in-session,
post-merge sweep). Each source yields two kinds: Ancillary Findings (concerns
left out of scope) and Opportunities (worthwhile follow-up work the session
suggests). Merge a Finding or Opportunity that appears in more than one source
into one. Do this only within a session, not across sessions. Keep Opportunities
separate from Findings. They skip the Test step (see [Step 9.3](#step-93-test)).

Add the **deferred candidates** from Phase 1 as Opportunities. These are
candidate use cases or improvement goals the user neither promoted nor declined
at the Requirements gate (see
[Step 1.8](phase1.md#step-18-compose-the-draft-requirements-analysis)). Like
other Opportunities, they skip the Test step and route straight to Decide, filed
as follow-up work or dropped. Each carries the evidence you cited in Phase 1, so
it is ready to file as is.

Add the **code smells** the Code Analysis named but the Session Scope didn't
take up, as Ancillary Findings. Unlike the Phase 1 candidates, these are
Findings, so they go through the Test step. The removal question fits an
over-built smell especially well. Each carries the citation you made in the Code
Analysis, so it is ready to file as is.

As you ask the teammates for the post-merge sweep, refer them to the Collect
cues (see [Phase 9](../protocol.md#phase-9-collect)). They read the cues once at
boot, and by now that read has fallen from view. Referring to the cues in the
request fires them while each teammate surfaces Opportunities. Draw on the cues
yourself as you compile. You hold the whole session, so you have the widest
view.

## Step 9.2: Deepen

Before filing anything, check the project's issue tracker for related items. For
each surviving finding, search both **open and closed** issues by the file,
symbol, or surface the finding cites:

```bash
gh issue list --state all --search '<term>'
```

Closed-issue history is the protocol's memory. A finding citing a surface where
prior issues are filed and closed isn't fresh. It's a recurrence, a sign that
previous issues didn't fully resolve a contract. Two findings within the current
sweep that cite the same surface trigger the same recognition without needing a
prior issue.

Without this step, the protocol treats the next visible issue on a recurring
surface as a fresh observation. Three sessions in a row can each correctly
identify what they found, file it, and fix it in scope, yet never converge. Each
pass patches a symptom of the same underlying contract without naming the
contract.

## Step 9.3: Test

The two tests below apply to Ancillary Findings, not Opportunities. An
Opportunity proposes new work, with no surface to remove or behaviour to defend.
Route each Opportunity straight to Decide. For Findings, apply them in order,
starting with removal.

**The removal question**:

> _Could removing something (a feature, a branch, a layer of code, a decorative
> phrase) resolve the concern more simply than fixing the surface?_

A `yes` makes the finding a **simplification candidate**: `file fresh`, framed
around the removal (what to drop and why), not around the surface. A surface may
defend real behaviour and still be the right thing to remove. The behaviour
itself didn't earn its place.

A `no` says removal doesn't help. Continue to defend-behaviour.

**Defend behaviour, not surface**:

> _Does the surface defend real behaviour with a real consumer?_

A `yes` means the surface is doing real work for a real consumer. Decide picks
among `reinforce`, `re-frame`, or `file fresh` on the merits. A `no` means the
surface is decorative (a count nothing depends on, a docstring phrasing, an
arbitrary constant). `drop` is usually the right call.

## Step 9.4: Decide

Make one call per candidate: drop, reinforce, re-frame, or file fresh. Use the
source observations, the issue history, and what the Test step showed. Don't
send candidates back to Ralph or Junio for another round of judgement.

Build the decision table. For each candidate, show the finding, the decision,
the concrete action it maps to with its target, and the reason. The decision
word alone doesn't tell the user what will happen:

- `re-frame` and `file fresh` open a new issue
- `reinforce` and a duplicate `drop` comment on an existing one
- a plain `drop` does nothing

Spell out the action and target per row
(`re-frame → new issue, references #155`, `reinforce → comment on #142`). Each
row is then self-contained, so the user doesn't have to ask what it does.

Draft the exact issue or comment text for every row that isn't a plain `drop`,
before sharing anything with the user. Write the drafts to a temporary file
outside the repo.

Copy-edit the drafts before sharing them. Issue drafts run dense, and a second
pass against the writing style guide catches what writing them the first time
misses. Spawn the `dream:copy-editor` subagent (see
[the copy editor](../../../agents/copy-editor.md)) on that file for one round,
giving the subagent the writing style guide's absolute path. Resolve every
finding yourself. You are the author. Keep the meaning.

Share the decision table together with the copy-edited drafts in one message.
End it with one of these two, depending on
[Auto-collect](../../../agents/Grace.md#auto-collect):

- Not under auto-collect: ask the user to accept the table and drafts, or
  redirect.
- Under auto-collect: skip the question. State that you're taking the table and
  drafts as proposed, then file them in the same turn.

Do not rely on an unshared draft for GitHub-visible text.

- **Drop**: duplicate of an existing open issue, or fails the bar for filing.
  For a duplicate, you may comment on the existing issue if the new sighting
  adds evidence (a second occurrence, a different angle).
- **Reinforce**: related to an existing open issue but not identical. Comment on
  the open issue with the new angle rather than opening a new one.
- **Re-frame**: recurrence on a surface with prior issues, open or closed. File
  one issue at the **contract level**: name the surface (the function, the
  parameter, the contract) and list the prior issues with `#N` references. Where
  the recurrence is drift between copies of one fact, name the home and the
  copies. Frame the issue around single-sourcing them (see
  [One fact, one home](../protocol.md#one-fact-one-home)). Where it is one rule
  many sites must each follow, with no single home, frame the issue around
  adding a check to enforce it (see
  [One rule, one check](../protocol.md#one-rule-one-check)). The recurrence
  pattern itself is the behaviour gap. Issues landing on the same surface are
  evidence of an unresolved contract. Substance already decided at Plan would be
  a Challenge to a settled decision, raised in-session, not a fresh observation
  here (see [Challenge](../protocol.md#challenge)).
- **File fresh**: no related issue on the surface, and the finding clears the
  bar. Open a standalone issue.

The bar for filing a **new** issue from a Finding is _a behaviour gap with a
real consumer_. Findings that clear the bar go to Decide on the merits. Findings
the Test step marked as simplification candidates go to `file fresh`, regardless
of how defend-behaviour answered. Findings that clear neither default to `drop`.

An Opportunity clears the bar when it names worthwhile follow-up work the
session suggested, with a plausible consumer or value. Say what you see as a
hypothesis with its evidence: the value you'd expect, the consumer it serves,
the idea the work opened up. The user judges it at the decision table, so this
is the place to reach for the strong idea, not the safe one.

You don't implement anything in any phase. What enters the backlog is an issue
or a comment, never a fix. This holds even when merge was deferred and the PR is
still open. A miss this sweep surfaces becomes an issue, not a follow-on on the
open branch. Only a user-directed change reopens Develop.

Apply a category label to each new issue. See "GitHub labels" in Common rules.

**Issue shape.** When filing, write in plain English for a junior developer.
Don't duplicate what's visible in the source. Keep it tight. Don't sample
existing issues for style. Order the issue body in two parts:

- the concern, in one sentence
- the cause, with a file/symbol citation

Issues point to a concern that can be resolved. They don't spell out the fix. A
stated direction would narrow the design space before work starts. The title
states the concern as a complete thought ("status-verb keys can drift from
helper returns"), not a stacked-qualifier noun phrase ("an unenforced string
protocol"). Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).

## Step 9.5: Summarize

Once every item from the decision table is filed or commented, post one summary
comment on the session PR: a list of references to every new issue and every
comment Collect posted. Use `#N` for a new issue. Use the comment's own URL for
a posted comment, since a bare `#N` would point at the issue, not the comment.
Capture each comment's URL when you post it in Step 9.4, so it's ready to use
here. Skip a plain `drop`, since it produced nothing to link. Skip the summary
comment entirely if every candidate dropped.

Append the Claude Code footer (see
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items)).
Follow [GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).
