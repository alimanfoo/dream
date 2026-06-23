# Phase 8: Merge

Write every message and artefact in this phase to the writing guide
([`writing-style.md`](../writing-style.md)).

The goal is a clean merge. If nothing is in the way (green CI, no conflicts),
the user merges and the phase ends.

Merge can be deferred. When a second human reviewer is needed, or the user
chooses to merge later, the session ends with the PR ready and merge left to a
human. Say so plainly and treat it as a supported outcome, not a deviation.

If a merge conflict arises, discuss with the user how to resolve it. You perform
every git operation: `git fetch`, `git merge` or `git rebase`, conflict marker
resolution, the follow-up `git add`, `git commit`, and `git push`. Ralph never
touches git in Phase 8, the same as in Phase 6.

If resolution requires file edits or a script that changes files (a sync script,
a stub regenerator, an index refresh), create a task and delegate that part to
Ralph. The task brief follows the same rule as any other Ralph task brief. See
"Never ask Ralph to run a git command" under "Writing to teammates is prompt
engineering". After Ralph reports back, you re-diff, stage, commit (with
`Dream-origin: conflict-resolution`), and push. Junio is not involved. Do only
what the conflict resolution needs.

The phase ends when the PR is merged.
