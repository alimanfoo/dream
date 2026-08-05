# Phase 1: Requirements

Write every turn output, message and artefact in this phase to the Plain English
guide.

The user opens with session input: an idea for a new feature, an issue or issues
to address, a piece of code to tidy up, constraints, rough shape. When the boot
sequence derived one or more issues from the worktree branch name, those issues
are the session input. Phase 1 captures the system's requirements behind it.
Follow the steps below in sequence.

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
Push the branch. All work runs against the session-start state of `main`. The
[merge phase](../../../agents/Grace.md#phase-7-merge) handles any drift on
origin.

**Open the draft PR.** Run `gh pr create --draft` with `WIP` as the body. Derive
the title from the session input.

**Post the session input as the first comment.** Post the session input as a PR
comment. Head it `Session input`. When the input is nothing but issue
references, give them as a bullet list, one bare `#N` per line. The linked issue
already carries its own body and comments. Repeating them here adds nothing.
Otherwise, reproduce the user's input verbatim. Post it per
[Writing to GitHub](../../../agents/Grace.md#writing-to-github).

**Start the watch.** Invoke the `dream:watcher <pr>` skill on the PR number. The
PR is how the user reaches you for the rest of the session (see
[The watch](../../../agents/Grace.md#the-watch)).

## Step 1.2: Produce the draft requirements analysis

Run the `dream:requirements-analysis` skill, giving it the session input. The
skill returns the draft requirements analysis, which names the session type.

## Step 1.3: Elicit answers to open questions

Skip this step when there are no open questions.

When there are open questions, write them to a temporary file outside the repo.
Use the heading `Open questions`. List each question with the possible answers
you can see. Close by asking the user to answer them, so the file stands on its
own for a reader who was not in the session. Post the file to the PR as a
comment, per [Writing to GitHub](../../../agents/Grace.md#writing-to-github).
Say in one line that you posted the questions and are waiting for the answer.

Then go idle (see
[Waiting for a reply](../../../agents/Grace.md#waiting-for-a-reply)). The watch
brings the user's answer back. Fold their answers into the requirements analysis
as stated items, dropping the matching open questions. If the reply leaves any
question unanswered, re-ask the unanswered ones before continuing. You marked
them as needing the user, so a missing answer means the artifact isn't complete
yet.

## Step 1.4: Share the requirements analysis and label the PR

Write the completed requirements analysis to a temporary file outside this repo,
via Bash. Then:

- **Send it to Junio and Ralph.** Give them the file's absolute path: two
  `SendMessage` calls in the same turn, for information only.
- **Post it to the PR** from that same file, per
  [Writing to GitHub](../../../agents/Grace.md#writing-to-github).
- **Label the PR.** Apply the session type's category label via
  `gh pr edit --add-label <name>` (see
  [GitHub labels](../../../agents/Grace.md#github-labels)). The requirements
  analysis names the session type, so this is the first point you know it.

Any candidates the analysis named stay out of the session's scope. Each carries
forward to the [collect phase](../../../agents/Grace.md#phase-8-collect) as an
opportunity, with the evidence the analysis cited.
