# Phase 8: Collect

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal of this phase is to collect ancillary findings and opportunities from
the team. For each, decide whether to file a new issue or comment on an existing
one. Four steps (compile, deepen, test, decide) come before any issue is filed.
Test applies to findings only. Opportunities skip it. All four are yours, with
user discussion before you file or comment. A fifth step, summarize, closes the
phase by posting what the collect phase did back to the session PR.

## Step 8.1: Compile

Ask the teammates for the post-merge sweep, referring them to the collect cues
(see the [collect phase](../protocol.md#phase-8-collect)). They read the cues
once at boot, and by now that read has fallen from view. Referring to the cues
in the request fires them while each teammate surfaces opportunities.

Gather the sources (Ralph in-session, Junio in-session, Ada in-session, and the
post-merge sweep). Each source yields two kinds: ancillary findings (concerns
left out of scope) and opportunities (worthwhile follow-up work the session
suggests). Merge a finding or opportunity that appears in more than one source
into one. Do this only within a session, not across sessions. Keep opportunities
separate from findings. They skip the Test step. Draw on the cues yourself as
you compile. You hold the whole session, so you have the widest view.

Add the **deferred candidates** from Phase 1 as opportunities. These are
candidate use cases or improvement goals the user neither promoted nor declined
at the requirements gate (see
[Step 1.2](phase1.md#step-12-produce-the-draft-requirements-analysis)). Like
other opportunities, they skip the Test step and route straight to Decide, filed
as follow-up work or dropped. Each carries the evidence you cited in Phase 1, so
it is ready to file as is.

Add the **code smells** the code analysis named but the design didn't take up,
as ancillary findings. Unlike the Phase 1 candidates, these are findings, so
they go through the Test step. The removal question fits an over-built smell
especially well. Each carries the citation you made in the code analysis, so it
is ready to file as is.

## Step 8.2: Deepen

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

## Step 8.3: Test

The two tests below apply to ancillary findings, not opportunities. An
opportunity proposes new work, with no surface to remove or behaviour to defend.
Route each opportunity straight to Decide. For findings, apply them in order,
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

## Step 8.4: Decide

Make one call per candidate: drop, reinforce, re-frame, or file fresh. Use the
source observations, the issue history, and what the Test step showed. Don't
send candidates back to Ralph or Junio for another round of judgement.

The bar for filing a **new** issue from a finding is _a behaviour gap with a
real consumer_. Findings that clear the bar go to Decide on the merits. Findings
the Test step marked as simplification candidates go to `file fresh`, regardless
of how defend-behaviour answered. Findings that clear neither default to `drop`.

An opportunity clears the bar when it names worthwhile follow-up work the
session suggested, with a plausible consumer or value. Say what you see as a
hypothesis with its evidence: the value you'd expect, the consumer it serves,
the idea the work opened up. The user judges it, so this is the place to reach
for the strong idea, not the safe one.

- **Drop**: duplicate of an existing open issue, fails the bar for filing, or
  cut by the auto-collect cap. For a duplicate, you may comment on the existing
  issue if the new sighting adds evidence (a second occurrence, a different
  angle).
- **Reinforce**: related to an existing open issue but not identical. Comment on
  the open issue with the new angle rather than opening a new one.
- **Re-frame**: recurrence on a surface with prior issues, open or closed. File
  one issue at the **contract level**: name the surface (the function, the
  parameter, the contract) and list the prior issues with `#N` references. Where
  the recurrence is drift between copies of one fact, name the home and the
  copies. Frame the issue around single-sourcing them (see
  [One fact, one home](../protocol.md#one-fact-one-home)). Where it is one rule
  many sites must each follow, with no single home, frame the issue as a
  [cross-site rule](../protocol.md#cross-site-rules).
- **File fresh**: no related issue on the surface, and the finding clears the
  bar. Open a standalone issue.

Build the decision table. For each candidate, show the finding, the decision,
the concrete action it maps to with its target, and the reason. The decision
word alone doesn't tell the user what will happen:

- `re-frame` and `file fresh` open a new issue
- `reinforce` and a duplicate `drop` comment on an existing one
- a plain `drop` does nothing

Spell out the action and target per row
(`re-frame → new issue, references #155`, `reinforce → comment on #142`). Each
row is then self-contained, so the user doesn't have to ask what it does.

Under auto-collect, cap the table once it's built, before drafting anything.
With no user at the gate to redirect a candidate, an unattended sweep would
otherwise file every row the table already decided to open. Rank the rows you
decided were `file fresh` or `re-frame` within each category:

- **Bug:** how directly the behaviour gap hits a real consumer.
- **Maintenance:** how much drift or duplication the surface causes.
- **Enhancement:** how strong the expected value is.

Keep the top three bugs, the top two maintenance items, and the top one
enhancement. Re-decide the rest as `drop` in the table, with the reason
`capped by auto-collect`. This is the cap standing in for the user's redirect:
it happens once, on the table, then drafting and sharing continue as usual. Not
under auto-collect, skip it: the user's acceptance at the gate already bounds
volume.

Draft the exact issue or comment text for every row that isn't a plain `drop`,
before sharing anything with the user. Write the drafts to a temporary file
outside the repo.

Before sharing the drafts, run the `/dream:copy-edit` skill over that file.
Issue drafts run dense, and a second pass against the writing style guide
catches what writing them the first time misses.

Share the decision table together with the copy-edited drafts in one message.
End it with one of these two, depending on
[auto-collect](../../../agents/Grace.md#auto-collect):

- Not under auto-collect: ask the user to accept the table and drafts, or
  redirect.
- Under auto-collect: skip the question. State that you're taking the table and
  drafts as proposed, then file them in the same turn.

Do not rely on an unshared draft for GitHub-visible text.

You don't implement anything in any phase. What enters the backlog is an issue
or a comment, never a fix. This holds even when merge was deferred and the PR is
still open. A miss this sweep surfaces becomes an issue, not a follow-on on the
open branch. Only a user-directed change reopens the
[develop phase](../protocol.md#phase-5-develop).

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

## Step 8.5: Summarize

Once every item from the decision table is filed or commented, post one summary
comment on the session PR: a list of references to every new issue and every
comment the collect phase posted. Use `#N` for a new issue. Use the comment's
own URL for a posted comment, since a bare `#N` would point at the issue, not
the comment. Capture each comment's URL when you post it in Step 8.4, so it's
ready to use here. Skip a plain `drop`, since it produced nothing to link. Skip
the summary comment entirely if every candidate dropped.

Append the Claude Code footer (see
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items)).
Follow [GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).
