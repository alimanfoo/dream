---
name: requirements-analysis
description:
  Analyse the requirements behind a task and return a draft. It states who the
  task serves, what it must do, what it is deliberately not for, and the open
  questions it raises. Point it at an issue, a file or symbol, or a description.
argument-hint: "<issue | file or symbol | text>"
---

# Requirements analysis

Produce a Requirements Analysis: your explicit reading of what the system must
do behind the input, for whom, and what it is deliberately not for. The result
is a draft, ending with the open questions for the user to resolve.

Read the [writing style guide](../../writing-style.md) before you write. It is
the standard for the analysis and every message you write.

Follow the steps in order.

## Arguments

Read the argument the user gives. It names the input to analyse: an issue
reference, a file or symbol, or a free-text description of the task. Read
whatever it points to. That is your input. When no argument is given, derive the
input from your context. If you cannot identify it, ask the user.

## Orient to the repo

Establish what the repo is for before reading the input, so you weigh the task
against what the repo delivers. Read the repo's own docs (`AGENTS.md`, `README`,
`CLAUDE.md`) and its structure, and name:

- **What the repo is for**: the vision or goal of the project building it.
- **Its product**: what a consumer ultimately gets, whether code, data, content,
  or something else.

State the repo purpose and product in one or two sentences. Mark each part
**stated** (the docs say it) or **assumed** (your inference), so a reader can
see which is which.

## Read the cited material

Read everything the input cites: issue bodies and their comments, prior issues
they reference, linked PRs, named files or symbols. Comments often reframe an
issue or carry a decision the body doesn't show, so an issue read without them
can miss what it has become.

For each cited issue, check whether it has sub-issues:

```bash
gh api repos/{owner}/{repo}/issues/<N>/sub_issues
```

A sub-issue carries part of the same requirement. Read it too.

## Read the code for the requirements it already satisfies

Read the relevant code, callers, tests, and docs for the named surfaces, holding
one question in mind: _who uses these surfaces, and what do they do with them?_
This grounds the analysis in the requirements the code already satisfies, taken
from the code rather than the input's prose alone.

## Consult the record

Consult the record for each surface the input names:

- **Recurrence.** Search the issue tracker
  (`gh issue list --state all --search '<surface>'`). Other issues on the
  surface, open or closed, may show the task has come up before. Read the ones
  that relate.
- **Prior PRs.** `git blame` or `git log` the relevant lines to find the PRs
  that last shaped them, then read each PR's description
  (`gh pr view <N> --json body`). It may record the consumers, use cases, and
  non-goals for that surface. Carry that into the analysis.

## Check the input against the current code

Compare the input against what the reads showed. The input may cite an issue
filed a while ago, or name code directly, and the code moves in between. A
symbol it names may be renamed, a file may have moved, or part of the ask may
already be done. Reach for git history only to fill a real gap the reads left,
such as a named surface that is no longer there. Trace where it went.

Fold each discrepancy into the draft you compose next, so no separate record is
needed:

- **A drifted detail**, such as a renamed symbol or a moved file. Correct it in
  the draft, and note what the input said. For example, that the input called
  this `fooBar`, renamed to `foo_bar` in #123.
- **A superseded ask**, part of the work already done. Cover only the remaining
  work, and note what was already done and where. For example, that the input
  also asked for X, done in #123.
- **A reframed ask**, where later work changed what the input means and the done
  part can't be cleanly separated. Carry it as an open question.

If nothing has drifted, say so in one sentence and continue.

## Name the Session Type

Pin the type before composing, since it sets the shape of the analysis:

- **Enhancement.** New feature or functionality that doesn't currently exist, a
  change in behaviour.
- **Maintenance.** Coherence, naming, structure. Behaviour already correct.
- **Bug fix.** Incorrect behaviour to repair.

State it in one sentence with the reasoning ("Session Type: enhancement, adds a
new CLI subcommand").

## Compose the draft

Compose the draft: your explicit reading of the requirements behind the input. A
scope or design steer in the input is not a requirement. Leave it out.

Choose the shape from the Session Type.

For an **enhancement**:

- **Consumers**: who uses what's being built, whether a person, an agent, or an
  external system that interacts with the changed surface. Name each concretely
  ("an agent invoking this in scripts", not "users"). Code inside the repo is
  never a consumer.
- **Use cases**: what each consumer does and what they get, written as that
  action-outcome pair. "Passes a region string and gets back the bounding
  coordinates" is a use case. "Uses the API" is not.
- **Constraints**: qualities the work must hold, such as performance,
  compatibility, or security, when the input or the read names any.

For **maintenance**:

- **Improvement goals**: what "better" means here, each a checkable property of
  the code, such as "the valid-cases enumeration has one home". A goal you can't
  state checkably is an open question.
- **Preserved behaviour**: the contract that must not change, and who relies on
  it.

For a **bug fix**:

- **Expected behaviour**: what should happen, and where the expectation comes
  from, such as a docstring, prior behaviour, or only the report.
- **Observed behaviour**: what the report says happens.
- **Affected consumers**: who hits the defect and what it costs them.

Every shape also carries, when they apply:

- **Candidates**: items of the shape's own kind that the read suggests but the
  input never named, such as a candidate use case or a candidate improvement
  goal. Each cites what in the read suggests it, and a candidate use case names
  the consumer it would serve. These are for the reader to consider, not
  commitments.
- **System non-goals**: what the product is deliberately not built for, given
  what it is for, such as a consumer it will never serve or a behaviour it will
  never take on. This records intent, not scope. Most tasks have none. Leave the
  section out rather than fill it with merely out-of-scope work.
- **Open questions**: calls you can't make from the cited material, where the
  call matters for what comes next. Frame each concretely and list the answers
  you can see, with your recommendation. The test: write the `assumed` value
  you'd record. If you can write one without guessing, mark it assumed instead.
  If you can't, it's a genuine open question.

Mark every item **stated** (named in the cited material) or **assumed** (your
inference).

Keep maintenance and bug-fix shapes short, a sentence or two per section. For an
enhancement, the consumers and use cases are the work. Give them real detail.

## Review the draft

Get an adversarial read before you finish. Write the draft to a temporary file
outside the repo. Then launch these review subagents in parallel, via the Agent
tool, one per lens:

- `dream:review-requirements-consumer-value`
- `dream:review-requirements-project-purpose`
- `dream:review-requirements-coherence`

Brief each with the file's absolute path. A subagent can't resolve a path
relative to its own prompt file. Don't retype the draft into the prompt. Combine
their findings into one list, dropping duplicates.

Judge each finding on its merits, and verify it by comparing with your own read.
Address the findings you accept by editing the temporary file.

## Copy-edit the draft

Run the `dream:copy-edit` skill over the draft file, giving its absolute path.
The requirements analysis is what the reader studies most closely, so its
readability matters most.

## The result

Return the completed draft from the file. It ends with its open questions, which
remain to be answered before the work is built.
