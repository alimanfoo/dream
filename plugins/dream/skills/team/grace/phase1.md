# Phase 1: Requirements

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The user opens with session input: an idea for a new feature, an issue or issues
to address, a piece of code to tidy up, constraints, rough shape. When the boot
sequence derived one or more issues from the worktree branch name, those issues
are the session input. Phase 1 captures the system's requirements behind it. It
makes any assumptions explicit so the user can correct them. It checks the
session input against the current code, so stale details don't ride downstream.
It gets one round of adversarial review before anyone else sees the Draft
Requirements Analysis. And it elicits answers to the open questions the cited
material can't settle. It ends at an accepted Requirements Analysis: what the
system must do, for whom, and what it is deliberately not for. Follow the steps
below in sequence.

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
main-checkout session, reproduce the user's text verbatim. Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts) and append
the Claude Code footer from
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items).

## Step 1.2: Produce the Draft Requirements Analysis

Run the `dream:requirements-analysis` skill, giving it the session input.

The skill returns the Draft Requirements Analysis. By Session Type, it names one
of:

- the consumers and their use cases
- the improvement goals and the preserved behaviour
- the expected behaviour, the observed behaviour, and the affected consumers

It also carries any constraints, candidates, system non-goals, and open
questions, with each item marked stated or assumed. The skill folds any input
drift into corrections and notes, recording the drift in the Draft itself rather
than a separate comment. The skill also states the Session Type and the repo
orientation in turn output.

Hold the returned Draft, the Session Type, and the repo orientation as your
working artifacts for the steps below. Don't share the Draft with the user yet.

## Step 1.3: Elicit answers to open questions

Skip this step when there are no open questions.

When there are open questions, write them to a temporary file outside the repo.
Use the heading `Open questions`. List each question with the possible answers
you can see, in public register. Keep role names and protocol-process vocabulary
out. Follow
[GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts) and append
the Claude Code footer from
[Marking agent-authored GitHub items](../../../agents/Grace.md#marking-agent-authored-github-items).
Post the file to the PR as a comment.

Send the user the same questions and answers as a numbered list. Invite a
freeform answer too. End the message by asking the user to answer the questions
so Grace can complete the Requirements Analysis.

Wait for the user's reply. Fold their answers into the Requirements Analysis as
stated items, dropping the matching open questions. If the reply leaves any
question unanswered, re-ask the unanswered ones before continuing. You marked
them as needing the user, so a missing answer means the artifact isn't complete
yet.

## Step 1.4: Share the Requirements Analysis

Send the completed Requirements Analysis to the user. When there are candidates,
ask the user to name any they want included, by number. Note that any they don't
name are carried forward as Opportunities to
[Collect](../../../agents/Grace.md#phase-8-collect). Tell them they can ask to
drop any outright.

End the message with one of these two, depending on autopilot:

- Not under autopilot: ask the user to accept. _"Accept the Requirements
  Analysis to proceed to Phase 2: Code Analysis."_
- Under autopilot: skip the question. State what you're doing instead, and
  continue in the same turn. _"Taking the Requirements Analysis as proposed
  (autopilot). Proceeding to Phase 2: Code Analysis."_

## Step 1.5: Seek user acceptance of the Requirements Analysis

Wait for the user's reply. Under autopilot, take this gate's default and
continue without waiting (see [Autopilot](../../../agents/Grace.md#autopilot)).

If accepted, promote any candidate the user opted into. Remove any that the user
explicitly dropped. Defer the rest to
[Collect](../../../agents/Grace.md#phase-8-collect). Apply the Session Type's
category label to the PR via `gh pr edit --add-label <name>` (see
[GitHub labels](../../../agents/Grace.md#github-labels)). Then continue to
[Step 1.6](#step-16-hand-the-accepted-requirements-analysis-to-junio-and-ralph).

If the user pushes back, revise and return to
[Step 1.4](#step-14-share-the-requirements-analysis). Repeat until accepted.

This is one of the protocol's user acceptance gates (see
[Acceptance gates](../protocol.md#acceptance-gates)).

## Step 1.6: Hand the accepted Requirements Analysis to Junio and Ralph

Write the following, in the versions the user accepted plus any changes from the
acceptance discussion, to a temporary file outside this repo, via Bash:

- the accepted Requirements Analysis
- the Session Type
- the repo orientation from
  [Step 1.2](#step-12-produce-the-draft-requirements-analysis)

Send Junio and Ralph the file's absolute path: two `SendMessage` calls in the
same turn, for information only. Sign off `From Grace.` and skip the RSVP.

## Step 1.7: Post the accepted Requirements Analysis to the PR

Post the accepted Requirements Analysis to the PR from the file written in
[Step 1.6](#step-16-hand-the-accepted-requirements-analysis-to-junio-and-ralph).
Follow
[Posting an accepted artifact to the PR](../../../agents/Grace.md#posting-an-accepted-artifact-to-the-pr).
Use the heading `Requirements`.

The phase ends at user acceptance of the Requirements Analysis.
