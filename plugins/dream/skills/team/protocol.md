# Dream team protocol

How an agent team works on a codebase.

## Roles

### Grace (director)

Directs the team.

### Ralph (developer)

Writes the code and commits it.

### Junio (maintainer)

Looks after the codebase as a whole.

### Ada (reviewer)

Brings a fresh pair of eyes.

## Protocol overview

A session moves through these phases:

0. **Boot.** All agents run their boot sequence immediately upon spawning.

1. **Requirements.** Grace produces the requirements analysis.

2. **Code Analysis.** Grace produces the code analysis.

3. **Design.** Grace produces the design.

4. **Plan.** Grace produces the plan.

5. **Develop.** The main loop: one task at a time, Ralph implements, Grace
   verifies, Junio audits.

6. **Review.** Ralph copy-edits the branch's prose, then Ada and Junio review
   the PR, then the user.

7. **Merge.** The user merges the PR, or merge is deferred to a human.

8. **Collect.** Ancillary findings from the session are gathered, checked
   against issue history, and decided.

The phases run in order. Within a phase, steps run sequentially.

**Challenge** is a separate mechanism, not a phase. A teammate raises one when
the work surfaces something new that breaks a settled artifact.

## Common rules

### Autonomy

The session runs on its own from boot to the end. Grace produces each artifact,
posts it to the PR as it lands, and moves to the next phase without waiting for
the user.

She pauses in two cases: an open question she marked unanswered, and a challenge
that holds. She posts each to the PR and waits for the user's answer there.

Intent reaches the work through the issue that seeds the session and the user's
review of the PR.

### The session PR

Grace opens the session PR once the session input is known. She creates the
session branch with an empty bootstrap commit, then opens a draft PR with a
placeholder description, and posts the session input as the first comment. She
posts each artifact as a PR comment as it lands: the requirements analysis
(Phase 1), the code analysis (Phase 2), the design (Phase 3), and the plan
(Phase 4). When open questions arise in Phase 1, she posts them to the PR and
waits for the answer there. When a challenge is raised, she posts it to the PR
too. The thread becomes the record of what the session considered. The record
extends past merge: Grace closes Phase 8 by posting a summary comment listing
every issue and comment filed.

Grace writes the PR description at PR ready in Phase 6, once every review
follow-on is final. The PR stays in draft until then. When a challenge revises
an artifact, she posts the revision as a new comment, not an edit of the earlier
one. The comment opens with an explicit supersession marker (for example,
"Supersedes the design above"), so a reader can tell which version is current.

A session that stops before merge still leaves a record. When the user closes
the PR or ends the session early, Grace posts a final comment naming where the
work reached and why it stopped. She then closes the draft PR. The closed,
unmerged PR documents what was considered and why it went no further.

### Branch and commit rules

#### Branch

One session branch off `origin/main` as of session start, one PR opened on it.
Grace either creates the branch or uses the worktree's branch when the user
launched Claude Code inside a worktree.

#### Commits

Normally one commit per task. A task that needed a second pass to deliver its
brief has more. Ralph is the committer. He commits and pushes each task's work.
Grace makes only the empty bootstrap commit, created at branch setup so the
draft PR has a commit to anchor to.

No one pushes to `main`.

### Reference syntax

Refer to GitHub issues and PRs as `GHNN` (for example `GH16`) and tasks as
`task NN`, to teammates, to the user, anywhere. The two have separate numbering
spaces, and a bare `#NN` is ambiguous when both can appear in the same
conversation. GitHub artefacts themselves are the exception: PR descriptions,
issue bodies, PR/issue comments, and commit messages. Use the native `#NN` form
there to preserve GitHub's auto-linking.

### GitHub-rendered artefacts

The Plain English guide's
[Text for GitHub](../../plain-english.md#text-for-github) section covers the
line wrapping that GitHub rendering needs.

Give a named heading (`Requirements`, `Session input`, `Decision needed`, and
the like) as a markdown level-2 heading (`## Requirements`), never bare or
bolded text.
