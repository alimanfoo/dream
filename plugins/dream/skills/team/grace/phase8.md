# Phase 8: Collect

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

The goal of this phase is to collect ancillary findings and opportunities from
the team. Every issue you file here is about the host repo, the codebase the
session worked on. Follow the steps below in sequence.

## Step 8.1: Compile

Ask the teammates for the post-merge sweep. State the cues in the request
itself, so each teammate has them in view while searching. Each reaches
knowledge the immediate task leaves dormant:

- **Analogy:** what does this session remind you of? Where have you seen this
  pattern before, and what worked or failed there?
- **Expert lens:** what would a specialist flag that a generalist pass skips: a
  security engineer, an SRE, someone who has maintained this kind of system for
  years?
- **Premortem:** a year on, what will we wish we'd done sooner? What is most
  likely to bite?
- **Best-in-class:** how do the strongest projects in this space handle what the
  session just worked on?
- **Negative space:** what is conspicuously absent? What did the session not do
  that a careful reviewer would expect?

An opportunity must still be suggested by the work just done, not a
free-standing wishlist.

Gather the sources (Ralph in-session, Junio in-session, Ada in-session, and the
post-merge sweep). Each source yields ancillary findings (concerns left out of
scope) and opportunities (worthwhile follow-up work the session suggests). Merge
a finding or opportunity that appears in more than one source into one. Keep
opportunities separate from findings. They skip the [test step](#step-83-test).
Draw on the cues yourself as you compile. You hold the whole session, so you
have the widest view.

Add the **deferred candidates** from Phase 1 as opportunities. These are
candidate use cases or improvement goals the requirements analysis named and the
session did not take up (see
[Step 1.4](phase1.md#step-14-share-the-requirements-analysis-and-label-the-pr)).
Like other opportunities, they skip the [test step](#step-83-test) and route
straight to the [decide step](#step-84-decide), filed as follow-up work or
dropped. Each carries the evidence you cited in Phase 1, so it is ready to file
as is.

Add the **code smells** the code analysis named but the design didn't take up,
as ancillary findings. Unlike the Phase 1 candidates, these are findings, so
they go through the [test step](#step-83-test). The removal question fits an
over-built smell especially well. Each carries the citation you made in the code
analysis, so it is ready to file as is.

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

## Step 8.3: Test

The tests below apply to ancillary findings, not opportunities. An opportunity
proposes new work, with no surface to remove or behaviour to defend. Route each
opportunity straight to the [decide step](#step-84-decide). For findings, apply
them in order, starting with removal.

**[The removal question](../../../coherent-coding.md#the-burden-of-proof-is-on-the-addition)**:

> _Could removing something (a feature, a branch, a layer of code, a decorative
> phrase) resolve the concern more simply than fixing the surface?_

A `yes` makes the finding a **simplification candidate**: `file fresh`, framed
around the removal (what to drop and why), not around the surface. A surface may
defend real behaviour and still be the right thing to remove. The behaviour
itself didn't earn its place.

A `no` says removal doesn't help. Continue to defend-behaviour.

**[Defend behaviour, not surface](../../../coherent-coding.md#defend-behaviour-not-surface)**:

> _Does the surface defend real behaviour with a real consumer?_

A `yes` means the surface is doing real work for a real consumer. A `no` means
the surface is decorative (a count nothing depends on, a docstring phrasing, an
arbitrary constant).

## Step 8.4: Decide

Make one call per candidate: drop, reinforce, re-frame, or file fresh. Use the
source observations, the issue history, what the [test step](#step-83-test)
showed, and `/dream:coherent-coding` principles. Don't send candidates back to
Ralph or Junio for another round of judgement.

The bar for filing a **new** issue from a finding is _a behaviour gap with a
real consumer_. Findings that clear the bar are decided on the merits. Findings
the [test step](#step-83-test) marked as simplification candidates go to
`file fresh`, regardless of how defend-behaviour answered. Findings that clear
neither default to `drop`.

An opportunity clears the bar when it names worthwhile follow-up work the
session suggested, with a plausible consumer or value. Say what you see as a
hypothesis with its evidence: the value you'd expect, the consumer it serves,
the idea the work opened up. The user judges it, so this is the place to reach
for the strong idea, not the safe one.

- **Drop**: duplicate of an existing open issue, fails the bar for filing, or
  cut by the cap. For a duplicate, you may comment on the existing issue if the
  new sighting adds evidence (a second occurrence, a different angle).
- **Reinforce**: related to an existing open issue but not identical. Comment on
  the open issue with the new angle rather than opening a new one.
- **Re-frame**: recurrence on a surface with prior issues, open or closed. File
  one issue at the **contract level**: name the surface (the function, the
  parameter, the contract) and list the prior issues with `#N` references. Where
  the recurrence is drift between copies of one fact, name the home and the
  copies. Frame the issue around single-sourcing them (see
  [One fact, one home](../../../coherent-coding.md#one-fact-one-home)). Where it
  is one rule many sites must each follow, with no single home, frame the issue
  as a [cross-site rule](../../../coherent-coding.md#cross-site-rules).
- **File fresh**: no related issue on the surface, and the finding clears the
  bar. Open a standalone issue.

Build the decision table in your turn output. For each candidate, show the
finding, the decision, the concrete action it maps to with its target, and the
reason. The decision word alone doesn't say what will happen:

- `re-frame` and `file fresh` open a new issue
- `reinforce` and a duplicate `drop` comment on an existing one
- a plain `drop` does nothing

Spell out the action and target per row
(`re-frame → new issue, references #155`, `reinforce → comment on #142`). Each
row is then self-contained, so you work from the table alone.

Cap the table once it's built, before drafting anything. Nobody redirects a
candidate, so an uncapped sweep would file every row the table decided to open.
Rank the rows you decided were `file fresh` or `re-frame` within each category:

- **Bug:** how directly the behaviour gap hits a real consumer.
- **Maintenance:** how much drift or duplication the surface causes.
- **Enhancement:** how strong the expected value is.

Keep the top three bugs, the top two maintenance items, and the top one
enhancement. Re-decide the rest as `drop` in the table, with the reason
`capped`. Cap once, on the table, then carry on.

Draft the exact issue or comment text for every row that isn't a plain `drop`.
Write the drafts to a temporary file outside the repo.

Then run the `/dream:copy-edit` skill over that file. A second pass against the
Plain English guide catches what writing the drafts the first time missed.

File the drafts. Never file text the copy-edited file doesn't hold.

You don't implement anything in any phase. What enters the backlog is an issue
or a comment, never a fix. This holds even when merge was deferred and the PR is
still open. A miss this sweep surfaces becomes an issue, not a follow-on on the
open branch.

Apply a category label to each new issue. See "GitHub labels" in Common rules.

**Issue shape.** When filing, write for a junior developer, using
`/dream:plain-english`. Don't duplicate what's visible in the source. Keep it
tight. Don't sample existing issues for style. Order the issue body:

- the concern, in one sentence
- the cause, with a file/symbol citation

Issues point to a concern that can be resolved. They don't spell out the fix. A
stated direction would narrow the design space before work starts. The title
states the concern as a complete thought ("status-verb keys can drift from
helper returns"), not a stacked-qualifier noun phrase ("an unenforced string
protocol"). File it per
[Writing to GitHub](../../../agents/Grace.md#writing-to-github).

## Step 8.5: Summarize

Once every item from the decision table is filed or commented, post one summary
comment on the session PR: a list of references to every new issue and every
comment the collect phase posted. Use `#N` for a new issue. Use the comment's
own URL for a posted comment, since a bare `#N` would point at the issue, not
the comment. Capture each comment's URL when you post it in Step 8.4, so it's
ready to use here. Skip a plain `drop`, since it produced nothing to link. Skip
the summary comment entirely if every candidate dropped.

Post it per [Writing to GitHub](../../../agents/Grace.md#writing-to-github).

The session's work ends there. Tell the user so in one line, and that they can
wind the team down from the main session (`/exit`).
