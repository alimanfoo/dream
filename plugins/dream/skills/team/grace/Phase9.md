# Phase 9: Collect

The goal of this phase is to collect Ancillary Findings and Opportunities from
the team and decide whether to file a new issue (or comment on an existing one)
for each. Four steps — compile, deepen, test, decide — before any issue is
filed. Test applies to Findings only; Opportunities skip it. All four are yours,
with user discussion before you file or comment.

## Step 9.1: Compile

Gather the three sources (Junio in-session, Ada in-session, post-merge sweep).
Each source yields two kinds: Ancillary Findings (concerns left out of scope)
and Opportunities (worthwhile follow-up work the session suggests). A Finding or
Opportunity that appears in more than one source merges into one. Within-session
dedup only — the same Finding or Opportunity seen through two roles becomes one,
not two. Keep Opportunities separate from Findings; they skip the Test step (see
[Step 9.3](#step-93-test)).

Add the **orientation gaps** the session revealed in hindsight — things you wish
the orientation had told you at the start, now that the whole session has run.
Each is a place the repo doesn't communicate its own purpose or organisation
well, so each is a finding against the host repo. Like Opportunities, they skip
the Test step and route straight to Decide. Name the gap and a direction that
would close it.

Add the **deferred candidates** from Phase 1 as Opportunities. These are
candidate use cases or improvement goals the user neither promoted nor declined
at the Requirements gate (see
[Step 1.6](Phase1.md#step-16-compose-the-requirements-analysis)). Like other
Opportunities, they skip the Test step and route straight to Decide, filed as
follow-up work or dropped. Each carries the evidence you cited in Phase 1, so it
is ready to file as is.

As you ask the teammates for the post-merge sweep, refer them to the Collect
cues (see [Phase 9](../protocol.md#phase-9-collect)). They read the cues once at
boot, and by now that read has fallen from view; referring to the cues in the
request fires them while each teammate surfaces Opportunities. Draw on the cues
yourself as you compile — you hold the whole session, so the widest view.

## Step 9.2: Deepen

Before filing anything, check the project's issue tracker for related items. For
each surviving finding, search both **open and closed** issues by the file,
symbol, or surface the finding cites:

```bash
gh issue list --state all --search '<term>'
```

Closed-issue history is the protocol's memory. A finding citing a surface where
prior issues are filed and closed isn't fresh — it's a recurrence, a sign that
previous issues didn't fully resolve a contract. Two findings within the current
sweep that cite the same surface trigger the same recognition without needing a
prior issue.

Without this step, the protocol treats the next visible issue on a recurring
surface as a fresh observation. Three sessions in a row can each correctly
identify what they found, file it, and fix it in scope — yet never converge.
Each pass patches a symptom of the same underlying contract without naming the
contract.

## Step 9.3: Test

The two tests below apply to Ancillary Findings, not Opportunities — an
Opportunity proposes new work, so there is no surface to remove or behaviour to
defend. Route each Opportunity straight to Decide. For Findings, two tests
apply, in order. Start with removal.

**The removal question**:

> _Could removing something — a feature, a branch, a layer of code, a decorative
> phrase — resolve the concern more simply than fixing the surface?_

A `yes` makes the finding a **simplification candidate** — `file fresh`, framed
around the removal (what to drop and why), not around the surface. A surface may
defend real behaviour and still be the right thing to remove; the behaviour
itself didn't earn its place.

A `no` says removal doesn't help. Continue to defend-behaviour.

**Defend behaviour, not surface**:

> _Does the surface defend real behaviour with a real consumer?_

A `yes` means the surface is doing real work for a real consumer — Decide picks
among `reinforce`, `re-frame`, or `file fresh` on the merits. A `no` means the
surface is decorative (a count nothing depends on, a docstring phrasing, an
arbitrary constant) — `drop` is usually the right call.

## Step 9.4: Decide

Make one call per candidate: drop, reinforce, re-frame, or file fresh. Use the
source observations, the issue history, and what the Test step showed; don't
send candidates back to Ralph or Junio for another round of judgement.

Share the proposed decision table with the user before drafting issue or comment
text. For each candidate, show the finding, the decision, and the reason. Ask
the user to accept the decision table or redirect it.

After the user accepts the decisions, write the exact issue or comment text for
every item that will be filed or commented. Show that exact text to the user and
have them accept before posting. Do not rely on an unshared draft for
GitHub-visible text.

- **Drop** — duplicate of an existing open issue, or fails the bar for filing.
  For a duplicate, you may comment on the existing issue if the new sighting
  adds evidence (a second occurrence, a different angle). Reference the session
  PR in any such comment.
- **Reinforce** — related to an existing open issue but not identical. Comment
  on the open issue with the new angle rather than opening a new one. Open the
  comment with a reference to the session PR: "Noticed during #N, ..."
- **Re-frame** — recurrence on a surface with prior issues, open or closed. File
  one issue at the **contract level**: name the surface (the function, the
  parameter, the contract) and list the prior issues with `#N` references. Where
  the recurrence is drift between copies of one fact, name the home and the
  copies and frame the issue around single-sourcing them (see
  [One fact, one home](../protocol.md#one-fact-one-home)). Where it is one rule
  many sites must each follow, with no single home, frame the issue around
  adding a check to enforce it (see
  [One rule, one check](../protocol.md#one-rule-one-check)). Open the issue body
  with a reference to the session PR: "Noticed during #N, ..." The recurrence
  pattern itself is the behaviour gap — issues landing on the same surface is
  evidence of an unresolved contract. Substance already decided at Plan would be
  a Challenge to a settled decision, raised in-session, not a fresh observation
  here — see [Challenge](../protocol.md#challenge).
- **File fresh** — no related issue on the surface, and the finding clears the
  bar. Open a standalone issue. Open the issue body with a reference to the
  session PR: "Noticed during #N, ..."

The bar for filing a **new** issue from a Finding is _a behaviour gap with a
real consumer_. Findings that clear the bar go to Decide on the merits. Findings
the Test step marked as simplification candidates go to `file fresh`, regardless
of how defend-behaviour answered. Findings that clear neither default to `drop`.

An Opportunity clears the bar when it names worthwhile follow-up work the
session suggested, with a plausible consumer or value. Say what you see — the
value you'd expect, the consumer it serves, the idea the work opened up — as a
hypothesis with its evidence. The user judges it at the decision table, so this
is the place to reach for the strong idea, not the safe one.

You don't implement anything in any phase. What enters the backlog is an issue
or a comment, never a fix. This holds even when merge was deferred and the PR is
still open: a miss this sweep surfaces becomes an issue, not a follow-on on the
open branch. Only a user-directed change reopens Develop.

Apply a category label to each new issue — see "GitHub labels" in Common rules
below.

**Issue shape.** When filing, write in plain English for a junior developer,
don't duplicate what's visible in the source, and keep it tight. Don't sample
existing issues for style. Lead with the concern in one sentence, then the cause
with a file/symbol citation, then a suggested direction. Issues point to a
concern that can be resolved; they don't spell out the fix. The title states the
concern as a complete thought ("status-verb keys can drift from helper
returns"), not a stacked-qualifier noun phrase ("an unenforced string
protocol"). Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).
