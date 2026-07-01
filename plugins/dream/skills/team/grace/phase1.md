# Phase 1: Requirements

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The user opens with session input: an idea for a new feature, an issue or issues
to address, a piece of code to tidy up, constraints, rough shape. When the boot
sequence derived one or more issues from the worktree branch name, those issues
are the session input. Phase 1 captures the system's requirements behind it. It
makes any assumptions explicit so the user can correct them. And it elicits
answers to anything Grace can't call from the cited material. It ends at an
accepted Requirements Analysis: what the system must do, for whom, and what it
is deliberately not for. Follow the steps below in sequence.

## Step 1.1: Open the session PR

Open the session branch and PR before the analysis begins.

**Set the session branch.** Name it after the session input. For example,
`GH123` for an issue, a short slug like `add-foo` for an unscoped task. If the
session started on `main`, create the branch and switch to it. If the session
started in a worktree, the branch already exists.

**Create the bootstrap commit and push.** Create an empty bootstrap commit
(`git commit --allow-empty`) so the draft PR has a commit to anchor to. Give it
a short subject (the issue ref or slug) and the `Co-Authored-By` trailer only
(see
[Branch and commit operations](../../../agents/Grace.md#branch-and-commit-operations)).
Push the branch. All work runs against the session-start state of `main`. Merge
handles any drift on origin.

**Open the draft PR.** Run `gh pr create --draft` with `WIP` as the body. Derive
the title from the session input. Mark the title and body per
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items).
Follow [GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).

**Post the session input as the first comment.** Post the session input as a PR
comment (`gh pr comment <N> --body "..."`). Head it `Session input`. For a
worktree session with derived issues, list each issue number and title. For a
main-checkout session, reproduce the user's text verbatim. Append the Claude
Code footer from
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items).

## Step 1.2: Orient to the repo

Establish what the repo is for as a whole, before reading the session input.
Orienting first brings a whole-repo frame to the task, so you weigh the work
against what the repo delivers.

Name four things:

- **What the repo is for**: the vision, goal, or objective of the project
  building it.
- **Its product**: the deliverable, what a consumer ultimately gets. For an
  application or software library this is the code, but it could also be data,
  content, configuration, or something else.
- **The product's architecture**: how that product is organised into its major
  components.
- **The supporting infrastructure**: the tests, checks, build steps, and tooling
  built around the product to produce, verify, and maintain it.

Source each part from the repo's own docs (`AGENTS.md`, `README`, `CLAUDE.md`,
package manifests) where they state it, or read it from the structure where they
don't. Mark each part **stated** or **assumed**, so the user can see which parts
come from the repo's own account and which are your inference.

Share the orientation with the user in a few sentences, so they can correct a
mis-orientation before it shapes everything downstream. This is not a gate.
Proceed once you've shared.

## Step 1.3: Read the cited material

Read everything the user cites in their session input: issue bodies and their
comments, prior issues they reference, linked PRs, named files or symbols.
Comments often reframe the issue or carry a decision the body doesn't show. An
issue read without its comments can miss what the issue has become. This is the
substantive baseline for the steps that follow. Without it, the recurrence check
and code read run on guesses about what the user means.

## Step 1.4: Read the code with a consumer lens

Read the relevant code, callers, tests, and docs for the named surfaces. Hold
one question in mind: _who uses these surfaces and what do they do with them?_
This is the consumer lens. It makes the Requirements Analysis substantive, with
who and what the work serves checked against the code rather than inferred from
prose alone.

## Step 1.5: Consult the record

Consult the record for the surfaces the user has named: a function, a class, a
module, or a parameter. A session may name several. Consult two ways: search the
issue tracker for recurrence, and read the PRs that last shaped each surface.

**Recurrence.** Search the issue tracker for each surface:

```bash
gh issue list --state all --search '<surface>'
```

If the search returns other issues on any of these surfaces (open or closed), or
if the issue body cites prior closed issues, note what the prior context shows.
Judge which prior issues actually relate to the current concern and read those
too.

**Prior PRs.** For each surface, `git blame` the relevant lines (or `git log` to
follow their history) to find the PRs that last shaped them, then read each PR's
description for the requirements record it carries:

```bash
gh pr view <N> --json body
```

The link from line to PR is structural. Git maintains it for free, so you reach
the exact prior decisions without guessing search terms. Prior PRs may tell you
more about the consumers, use cases, and non-goals for that surface. Carry that
information into the Requirements Analysis.

## Step 1.6: Name the Session Type

Pin the Session Type before composing the Requirements Analysis. It selects the
shape of the Requirements Analysis and what later phases focus on. Three types:

- **Enhancement.** New feature or capability that doesn't currently exist.
- **Maintenance.** Coherence, naming, structure. Behaviour already correct.
- **Bug fix.** Incorrect behaviour to repair.

State the Session Type in one short sentence with the reasoning ("Session Type:
enhancement, adds a new CLI subcommand") and continue to
[Step 1.7](#step-17-compose-the-requirements-analysis).

## Step 1.7: Compose the Requirements Analysis

Compose the Requirements Analysis: your explicit reading of the system's
requirements behind the session input. Without this step, hidden inferences
about who is served and what counts as done ride through to Design. There they
shape machinery no real consumer needs.

Choose the shape based on the Session Type.

For an **enhancement**:

- **Consumers**: who uses what's being built, whether a person, an agent, or an
  external system that interacts with the changed surface. Name each concretely
  ("an agent invoking this in scripts", not "users"). Code inside the repo is
  never a consumer. Caller relationships are Phase 2 content.
- **Use cases**: what each consumer does with it and what they get, written as
  that action-outcome pair. "Passes a region string and gets back the bounding
  coordinates" is a use case. "Uses the API" is not. A use case you can't write
  as a pair isn't concrete enough to build from.
- **Constraints**: qualities the work must hold (performance, compatibility, API
  stability, security), when the input or the read names any.

For **maintenance**:

- **Improvement goals**: what "better" means here, each stated as a checkable
  property of the code, such as "the valid-cases enumeration has one home" or
  "no caller mentions the old name". A goal you can't state checkably is an open
  question, not a goal.
- **Preserved behaviour**: the contract that must not change, and the consumers
  who rely on it.

For a **bug fix**:

- **Expected behaviour**: what should happen, citing where the expectation comes
  from, such as a docstring, a signature, prior behaviour, or only the report
  itself. The source matters because Phase 2 tests the claim. An expectation
  backed only by the report is the first thing to check.
- **Observed behaviour**: what the report says happens, recorded as a claim for
  Phase 2 to verify.
- **Affected consumers**: who hits the defect and what it costs them. One or two
  sentences.

Every shape also carries:

- **Candidates**: items of the shape's own kind that the read suggests but the
  input never named, such as candidate use cases for an enhancement or candidate
  improvement goals for maintenance. To notice them, draw on similar or
  analogous situations you know of. A candidate qualifies only when you can
  point to what in the read suggests it. Each cites that evidence, and a
  candidate use case also names the consumer it would serve. The user opts in to
  any they want at the gate, and
  [Step 1.10](#step-110-seek-user-acceptance-of-the-requirements-analysis)
  decides each one from there.
- **System non-goals** (when any are stated or strongly implied): what the
  product is deliberately not built for, given what it is for, such as a
  consumer it will never serve or a behaviour it will never take on. This
  records intent, not scope: the product is never meant to do this, not that
  this session skips it. Most sessions have none. Leave the section out rather
  than fill it with work that is merely out of scope or deferred, which is
  Scope's call.
- **Open questions**: calls you can't make from the cited material, where the
  call matters for what comes next. Frame each as a concrete question. List the
  possible answers you can see and invite a freeform answer too. The test: write
  the `assumed` value you'd record. If you can write one without guessing, mark
  it assumed instead. If you can't, it's a genuine open question.

Mark every item in every shape as **stated** (named in the cited material) or
**assumed** (your inference).

Keep maintenance and bug-fix shapes short. One or two sentences per section is
usually enough. For an enhancement, the consumer and use-case sections are the
work. Give them real detail.

Test the new intent the session input carries against the existing intent. The
orientation names what the repo delivers, and the consumer-lens read shows what
its surfaces already serve. Ask whether the proposed work serves that product,
and whether its value is evidenced by the existing goals or only asserted by the
input. Where it doesn't cohere or the value isn't evidenced, surface that as an
open question. Don't carry the intent through unexamined. The user decides at
the gate.

The marking shows where each item came from, the session input or your own
inference, not whether it's true. The user can edit either kind. They can drop
an assumed item freely, since it's your inference, not the input's claim. They
can drop a stated item too, when the consumer-lens read or the intent test shows
the input got it wrong.

## Step 1.8: Elicit answers to open questions

Skip this step when there are no open questions.

When there are open questions, post them to the PR as a comment before sending
them to the user. Use the heading `Open questions`. List each question with the
possible answers you can see, in public register. Keep role names and
protocol-process vocabulary out. Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts) and append
the Claude Code footer from
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items).

Then send the open questions to the user as a numbered list. For each, give the
possible answers you can see. Invite a freeform answer too. End the message by
asking the user to answer the questions so Grace can complete the Requirements
Analysis.

Wait for the user's reply. Fold their answers into the Requirements Analysis as
stated items, dropping the matching open questions. If the reply leaves any
question unanswered, re-ask the unanswered ones before continuing. You marked
them as needing the user, so a missing answer means the artifact isn't complete
yet.

## Step 1.9: Share the Requirements Analysis

Send the completed Requirements Analysis to the user. When there are candidates,
ask the user to name any they want included, by number. Note that any they don't
name are carried forward as Opportunities to Collect (see
[Phase 9](../../../agents/Grace.md#phase-9-collect)). Tell them they can ask to
drop any outright.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Requirements
  Analysis to proceed to Phase 2: Code Analysis."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Requirements Analysis as proposed
  (autopilot). Proceeding to Phase 2: Code Analysis."_

## Step 1.10: Seek user acceptance of the Requirements Analysis

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).
Promote any candidate the user opted into. A candidate use case becomes a use
case, a candidate improvement goal an improvement goal. Remove any the user
explicitly dropped. Defer the rest to Collect (see
[Phase 9](../../../agents/Grace.md#phase-9-collect)).

If accepted, apply the Session Type's category label to the PR via
`gh pr edit --add-label <name>` (see
[GitHub labels](../../../agents/Grace.md#github-labels)). Then continue to
[Step 1.11](#step-111-hand-the-accepted-requirements-analysis-to-junio-and-ralph).

If the user pushes back, revise and return to
[Step 1.9](#step-19-share-the-requirements-analysis). Repeat until accepted. If
the pushback challenges the Session Type itself, return to
[Step 1.6](#step-16-name-the-session-type) and recompose from there.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 1.11: Hand the accepted Requirements Analysis to Junio and Ralph

Send Junio and Ralph the following, in the versions the user accepted plus any
changes from the acceptance discussion:

- the accepted Requirements Analysis
- the Session Type
- the repo orientation from [Step 1.2](#step-12-orient-to-the-repo)

Send them as two `SendMessage` calls in the same turn, for information only.
Sign off `From Grace.` and skip the RSVP.

## Step 1.12: Post the accepted Requirements Analysis to the PR

Post the accepted Requirements Analysis as a PR comment. Follow
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr).
Use the heading `Requirements`.

The phase ends at user acceptance of the Requirements Analysis.
