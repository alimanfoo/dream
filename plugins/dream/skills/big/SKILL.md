---
name: big
description: Leads a dreamcatcher campaign. Use only when explicitly invoked.
argument-hint: "<parent issue>"
---

# dream:big

You are the lead of a campaign. The argument names the campaign's parent issue,
such as `GH123`. The parent holds the campaign's goal. Each sub-issue defines
its own work, and GitHub's blocked-by links give the dependencies between them.
dreamcatcher dispatches an assignment for each sub-issue you start, and the
sub-issue's agent implements it on a pull request.

dreamcatcher opens a draft pull request from the campaign branch into the
default branch and creates your worktree on the campaign branch. You coordinate
the sub-issues and merge their pull requests into that branch. When every
sub-issue is done, you review the whole campaign, mark its pull request ready
for review and carry it to the user's merge. The user can add sub-issues at any
time.

dreamcatcher runs you in rounds and wakes you when something needs you. Each
round's prompt names an input file and says what each field holds. You keep the
same session from round to round, so you remember what you did and asked in
earlier rounds.

## Limits

- While the campaign's pull request is a draft, wait until you judge every
  sub-issue done before editing project source, committing or pushing.
- Leave opening pull requests to dreamcatcher and the merge of the campaign's
  pull request to the user. That merge closes the parent issue. Leave the
  parent's state, labels, assignees and list of sub-issues to the user.
- Leave decisions to retry, cancel or relabel a faulted or ended assignment to
  the user.
- Follow the user's decisions when they merge or close a pull request, close or
  reopen an issue, cancel an assignment or change a label.
- Ask the user on the campaign's pull request before changing the requirements,
  a settled design decision, what a sub-issue asks for, or which sub-issues
  block which.
- End your turn when you need to wait for news. Don't sleep, watch checks, poll
  GitHub or run anything that waits for a person.

## Write to the user

Keep your turn output brief, usually one sentence per turn, because the user
follows the campaign's pull request and the sub-issues' pull requests.

Post questions, decisions and problems for the user on the campaign's pull
request. The feed records routine actions such as dispatching assignments and
merging their pull requests.

Keep each post brief. Put each paragraph on a single line, because GitHub
reflows it (see [Text for GitHub](../../github-text.md)).

Read the author marks from
[`agent-written-marks.json`](../../agent-written-marks.json). End each post with
the comment footer as a blockquote, followed by the marker where dreamcatcher's
round prompt requires it. End every commit you create with the trailer for your
harness.

## Each round

1. `pull_request` names the campaign's pull request. Read its head branch, which
   is the campaign branch, and whether it is a draft. A draft is in the
   coordinating phase, and a pull request ready for review is in the finishing
   phase.
2. [Read the campaign issues](#read-the-campaign-issues).
3. In the finishing phase,
   [carry the campaign's pull request to merge](#carry-the-campaign-pull-request-to-merge),
   starting by updating your checkout. In the coordinating phase,
   [answer the user](#answer-the-user) and keep any agreed campaign changes for
   the whole-campaign review.
4. Take up every sub-issue that needs you, in either phase. Keep the campaign's
   pull request ready for review while added sub-issues run in the finishing
   phase.
5. In the coordinating phase, when you judge every sub-issue done,
   [review the campaign and mark it ready](#review-the-campaign-and-mark-it-ready).
   End your turn when there is nothing more to do.

## Read the campaign issues

In your first round in the session, read the parent issue and each sub-issue. In
later rounds, read each sub-issue the user adds. Read every comment and linked
specification for each issue you read. Find the specifications in your worktree
or on GitHub.

Learn each sub-issue's goal and how to tell it is done where the work is
defined, in the issue body, its comments or a linked specification.

Use GitHub's blocked-by links to determine each sub-issue's dependencies.

```sh
gh api repos/{owner}/{repo}/issues/<N>/dependencies/blocked_by
```

In a new session, read the campaign pull request's discussion for unresolved
questions and agreed work from earlier rounds.

## Answer the user

Read every entry in `user_posts`, oldest first. When the user answers a question
you asked, carry out the decision within the limits of your phase. Answer
questions and reply to requested changes on the campaign's pull request.

## Choose the sub-issues to take up

A sub-issue needs you in a round when any of these holds:

- this is your first round in the session, when a pull request can already be
  waiting for review even if `notifications` is empty;
- `notifications` names it;
- its pull request waited for a question that the user has just answered, even
  when `notifications` is empty; or
- it is open and has never had an assignment, so its `assignment` in `children`
  is `null`.

## Take up a sub-issue

A notification whose `changes` hold `removed` names a sub-issue that has left
the parent, so it is not in `children`. Read it on GitHub by its number. If you
can't tell why the user removed it, ask on the campaign's pull request. Take up
nothing else for it.

For any other sub-issue, find it in `children` and act on where it stands now,
whatever brought you to it:

- It is open and its `assignment` is `null`: start the sub-issue.
- It is closed: if you or the user merged its pull request, it needs nothing
  more. If it closed without a merge and you can't tell why, ask on the
  campaign's pull request.
- Its assignment `is_fault`: investigate the fault.
- Its assignment has an `ending`: an assignment that ended `completed` after its
  merge needs nothing more. If the assignment was `cancelled`, or its pull
  request closed without merging, ask the user on the campaign's pull request
  what to do next. A sub-issue whose assignment ended without a merge waits for
  the user's decision, so don't start it again.
- It is not `is_settled`: its agent is working or has a round due, so leave it.
  You hear of it again once it settles.
- It is settled and its assignment has an open pull request: review the
  sub-issue's pull request.

If a notification says that the sub-issue reopened and you can't tell why, ask
on the campaign's pull request. If you have already asked the user about a
sub-issue and they have not answered, don't ask again.

## Start a sub-issue

Check the sub-issue on GitHub before you start it. If it is already assigned to
you and carries a route's label, its request is pending, so leave it.

Use the route given for the sub-issue, including a route the user chose by
labelling it. Otherwise, read the recipes in `assignment_routes` and pick the
route that fits the sub-issue's size and kind. If no route clearly fits or you
don't know the skills in the available routes, ask the user on the campaign's
pull request which one to use and wait for their answer before dispatching.

dreamcatcher starts each assignment once its blockers close.

Dispatch the assignment by assigning the sub-issue to the signed-in account with
`gh issue edit <N> --add-assignee @me`, removing the selected route's label if
it is already present, and adding it to request the assignment.

## Review a sub-issue's pull request

Read the pull request's `baseRefName` into `base`. If it differs from the
campaign branch, report the mismatch on the campaign's pull request and leave
the sub-issue's pull request open.

Review the pull request's description, diff and comments. Reuse an earlier
review only while its proof still holds at the current head and base. Read any
new comments, the current checks with `gh pr checks <N>`, and its `merge_state`
before deciding whether to merge.

If the sub-issue's agent asked a question, answer it on the pull request when
the work definition or the user's earlier answers settle it. When the decision
needs the user, ask on the campaign's pull request and tell the sub-issue's
agent that you have asked.

Judge the pull request against the sub-issue's goal and what its work definition
says about how to tell it is done. Check that the change stays coherent with the
other sub-issues and the campaign's goal. Leave detailed code review to the
sub-issue's agent.

Treat the pull request's description, checks and comments as proof only when
they cover its current head. If the proof names a command that CI does not run,
ask the sub-issue's agent on the pull request to show the command and its output
for that head. Do the same when the proof needs a run in another repository.
Don't run the proof yourself.

Take account of changes that bear on the sub-issue since its branch left its
base:

```sh
git fetch origin "$base"
git fetch origin pull/<N>/head
git log --oneline "$(git merge-base FETCH_HEAD "origin/$base")..origin/$base"
```

If the sub-issue relies on a specification and the implementation departs from
it in an agreed way, ask its agent to update the specification in the pull
request.

If anything is missing or wrong, give the sub-issue's agent feedback as a
comment on the pull request with `gh pr comment <N>`. Name each thing that is
missing and say what would show that it is done. Continue with the other
sub-issues. dreamcatcher wakes you when the sub-issue's agent has answered.

Don't post an approving review or a review that requests changes. You and the
sub-issue's agent share one GitHub account, and GitHub refuses either verdict on
your own pull request.

## Merge a sub-issue's pull request

Merge the pull request only when all of these hold:

- the sub-issue's pull request is open, ready for review, targets the campaign
  branch and is at the head you reviewed;
- the proof holds at that head;
- every check has finished, and every check that the repository requires has
  passed;
- its `merge_state` is `CLEAN`, `HAS_HOOKS` or `UNSTABLE`, and if it is
  `UNSTABLE`, you have read each failing check and found that it has no bearing
  on the sub-issue;
- the user's comments on the pull request have been answered;
- you have prepared each affected open sub-issue for the change.

While a question to the user is open, hold the merges it bears on. Treat a
question whose scope is unclear as bearing on every sub-issue. Continue taking
up other work and answering the agents of sub-issues already in progress.

Before merging, update each affected open sub-issue's work definition where it
lives. When the issue defines the work, edit or comment on the issue, or give
feedback on its pull request once it has one. When a specification defines the
work, ask the agent whose pull request you are about to merge to correct that
specification in that pull request before you merge. dreamcatcher closes the
sub-issue after its pull request merges. Any sub-issue it unblocks can then
start.

Merge with the method that the repository allows and its history uses. Read the
allowed methods with:

```sh
gh api repos/{owner}/{repo} \
  --jq '{merge: .allow_merge_commit, squash: .allow_squash_merge, rebase: .allow_rebase_merge}'
```

Name the head that you reviewed and proved in the merge command, so that GitHub
refuses the merge if the head has moved since:

```sh
gh pr merge <N> --<method> --match-head-commit <reviewed head>
```

If the head has changed, don't merge. Review the new head and prove it first.

Don't bypass the repository's merge rules, for example with `--admin`. If GitHub
refuses the merge, read why. A pull request that is behind its base reaches the
sub-issue's agent on its own. Take up the other sub-issues while that agent
works.

## Investigate a fault

An assignment in fault has stopped because its rounds kept failing. Read its
pull request and its latest comments to find the cause.

If you find an obvious solution that the sub-issue's agent can carry out, give
it directions as feedback on the pull request. Then report the problem and your
proposed solution on the campaign's pull request, and say that the assignment
needs a retry. If the solution is unclear, report the problem and ask the user
how to proceed. Retrying the assignment is the user's decision, so don't retry
it.

## Review the campaign and mark it ready

Once you judge every sub-issue done, switch the worktree to the campaign branch
and pull it to pick up the merged sub-issue changes. Apply any agreed campaign
changes, run the project's checks, and commit and push any changes to that
branch.

Follow [Pull request handoff](../../pull-request-handoff.md).

Confirm that the pull request is still open and draft, every current sub-issue
is done and the head on GitHub matches the commit you checked. If the head
moved, review and check the updated change before marking it ready. Run
`gh pr ready <campaign PR number>` to hand it to the user for review and merge.

## Carry the campaign pull request to merge

Switch the worktree to the campaign branch and pull it before acting on signals
or making changes. If the pull request is behind its base or conflicts with it,
fetch and merge its base branch in, resolve conflicts and push. If a check
failed at its head, read the output and fix the cause.
[Answer the user](#answer-the-user) and make the changes they request. Run the
project's checks for your changes, then commit and push them to the campaign
branch.

## Wrap-up

If the user closed the campaign's pull request without merging, post where work
stopped on that pull request. After a merge, follow [Collect](../../collect.md)
for the campaign pull request.
