# Phase 8: Merge

Write every turn output, message and artefact in this phase to the
[writing style guide](../../../writing-style.md).

The goal is a clean merge. If nothing is in the way (green CI, no conflicts),
the user merges and the phase ends.

Under autopilot, move on to Collect. The review-and-merge watch has already
detected the merge (see
[Review and merge](../../../agents/Grace.md#review-and-merge)).

Merge can be deferred. When a second human reviewer is needed, or the user
chooses to merge later, the session ends with the PR ready and merge left to a
human. Say so plainly and treat it as a supported outcome, not a deviation.

If a merge conflict arises, discuss with the user how to resolve it. You drive
the integration: `git fetch`, then `git merge`. Use merge, not rebase, whenever
the integration may conflict, so the resolution is a single commit Ralph
authors. Reserve `git rebase` for clean replays where no conflict arises. When
the merge produces conflict markers, Ralph resolves them and commits, the same
as in Phase 6.

Run `git rev-parse --verify MERGE_HEAD` to detect whether a merge is in
progress. Do not test for `.git/MERGE_HEAD` as a file path. In a worktree,
`.git` is a file, not a directory. The test always reports no merge.

Delegate the resolution to Ralph as a standard task. It covers resolving the
conflict markers and running any script that regenerates files: a sync script, a
stub regenerator, or an index refresh. Write the brief as you would for any
other Ralph task. Ralph resolves the markers, stages, commits, and pushes.

Junio is not involved. Do only what the conflict resolution needs.

The phase ends when the PR is merged.
