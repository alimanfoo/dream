# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-27 for the 48.0.0 release. The plugin and the documentation
were read on the release branch, which starts from `8687d6e1`, and whose working
tree differs from that commit only in the version in the manifest and the new
changelog section, which step 6 set while this measurement was taken. True
documents records what this reading found at `8687d6e1`, before any fix from the
release's consistency review. Each measure is compared with the measurement for
the last release, 47.3.0, tagged `v47.3.0`, whose figures are given in brackets.
48.0.0 is a major release, because the version of dreamcatcher's agent contract
that dream meets moves from 1 to 2.

## Results

| Criterion             | Measured                                                                                                                               | Status  |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 27 files without a one-sentence purpose (0 of 25)                                                                                 | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 2 referring skills (at least 2)                                                   | met     |
| One fact, one home    | 36 rules or facts stated in more than one file (35)                                                                                    | not met |
| Size                  | 4,204 lines in the plugin (4,172), a change of +32                                                                                     | no bar  |
| One vocabulary        | 0 uses in the plugin, 0 in the documentation, 0 open issues use retired terms (0, 0, 0)                                                | met     |
| True documents        | 0 statements that the plugin contradicts, at `8687d6e1` (0)                                                                            | met     |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page (0, 0)                                                                                | met     |
| Versioned contract    | The compatibility page states all three; 48.0.0 is a major release, as the move to version 2 of dreamcatcher's agent contract requires | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce (0)                                                                    | met     |
| No suppressions       | 0 markers (0)                                                                                                                          | met     |
| Current tracker       | 0 of 8 open issues out of date (0 of 9)                                                                                                | met     |
| Reviewed changes      | 3 of 3 pull requests answer every definition-of-done question (4 of 4)                                                                 | met     |
| Rules not cases       | 2 special cases not on the ledger; 0 ledger entries with an internal cause (2; 0)                                                      | not met |
| Few concepts          | 0 concepts added since 47.3.0 (0)                                                                                                      | met     |
| Symmetry              | 10 unshared or unmatched steps across the three pairs (10)                                                                             | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 36 rules or facts are stated in more than one skill,
   subagent file or shared file. The list is under
   [One fact, one home](#one-fact-one-home) below. Issue #1091 covers the copies
   in `dream:code-review` and `dream:coherence-review`, and the four steps still
   written out both in `dream:smith`, or the shared file it follows, and in
   `dream:less`, whose differences it asks about: Implement, Review, Write the
   PR description and Handle user posts. Issue #1102 covers the persona
   paragraph and Mark the PR ready for review in `dream:smith` and `dream:less`,
   the change-type labels, checking an issue's claims against the current code,
   drafts in a temporary file, the copies of the review rules in
   `dream:precedent-review` and `dream:quest`, the report rules of the two
   subagent files, the reason for an absolute path in `dream:trace` and
   `dream:weave`, and the turn-output rule in `dream:big` and
   `assignment-boot.md`. Issue #1083 covers the marks, the 13 rules common to
   the skills in the user's voice, and `dream:sift`'s restatements of the
   coherent coding guide. No open issue covers two things that pull request
   #1120 wrote: the rule for finding the repository's label for a change type,
   which `collect.md` restates from `assignment-boot.md` because `dream:big`
   does not run the boot sequence, and `dream:big`'s copy of Handle user posts,
   which counts with the `dream:smith` and `dream:less` copies that #1091 names,
   but which #1091 does not name. No issue is filed for `dream:less`'s summary
   of the engineering principles: the decision on #1083 keeps it as a deliberate
   stand-in for the guide, as less's story states, under "Weigh a measurement
   finding against the skill's purpose" in `AGENTS.md`.
2. **Rules not cases.** Two special cases are not on the ledger: the
   `AskUserQuestion` tool, named in `assignment-boot.md` and four skills, and
   `dream:sift`'s condition on `dreamcatcher.toml`. Issue #1085 covers both.
3. **Symmetry.** `dream:smith` and `dream:less` write out 5 steps that do the
   same thing in both, and `dream:code-review` and `dream:coherence-review`
   write out 5. Issue #1091 covers Implement, the code review, Write the PR
   description, Handle user posts, and the 5 steps of the review pair. Issue
   #1102 covers Mark the PR ready for review.

## Notes

### Single responsibility and Size

`git diff --stat v47.3.0 HEAD -- plugins/dream` shows that two pull requests
changed the plugin. Pull request #1120 rewrote `dream:big` to lead a campaign
under version 2 of dreamcatcher's agent contract: it merges the sub-issues' pull
requests into a campaign branch, then reviews the whole change and carries the
campaign's pull request to the user's merge, in six numbered steps that follow
`dream:smith`'s. It moved `dream:smith`'s Review, Find simplification
opportunities and Write the PR description into a new shared file,
`pull-request-handoff.md`, and `dream:smith`'s Collect into another,
`collect.md`, and both skills now follow both files. Pull request #1122 turned
the simplification step in `pull-request-handoff.md` into a third review,
settled like the code and coherence reviews. Those four files were read whole,
and each has one purpose. Every other file is unchanged since `v47.3.0`, and its
47.3.0 finding was confirmed and carried forward. `dream:big` is long, but it is
one procedure. `dream:smith` falls from 188 lines to 78, because its steps from
Review to Collect now live in the shared files; it was not split to reduce its
length.

The change is from the same commands run on a copy of the plugin at `v47.3.0`,
which reproduce that measurement's 4,172 lines.
`git diff --shortstat v47.3.0 HEAD -- plugins/dream` reports 4 files changed,
340 insertions and 308 deletions, a net change of +32: 329 lines added and 297
removed by #1120, and 11 added and 11 removed by #1122.

| File                                | Lines | Change | Purpose                                                                                                               |
| ----------------------------------- | ----: | -----: | --------------------------------------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files) |   986 |      0 | Explains how a coding agent works under Claude Code and Codex.                                                        |
| `coherent-coding.md`                |   359 |      0 | States the coherent coding guide.                                                                                     |
| `skills/weave/`                     |   326 |      0 | Works out a solution with the user in design models, and writes a design specification.                               |
| `skills/big/`                       |   314 |    +22 | Leads a dreamcatcher campaign, from its sub-issues' pull requests to the user's merge of the campaign's pull request. |
| `skills/spark/`                     |   286 |      0 | Talks an idea through with the user and writes a requirements specification.                                          |
| `skills/trace/`                     |   259 |      0 | Tours the code relevant to a change with the user, and writes a checked reading guide.                                |
| `skills/quest/`                     |   256 |      0 | Breaks a design specification into a roadmap of stages, and its sub-issues.                                           |
| `skills/sift/`                      |   228 |      0 | Triages issues with the user, one decision at a time.                                                                 |
| `assignment-boot.md`                |   172 |      0 | States the boot sequence that `dream:smith` and `dream:less` run before their own work.                               |
| `skills/plan/`                      |   116 |      0 | Writes an implementation plan.                                                                                        |
| `agents/precedent-reviewer.md`      |   102 |      0 | Reviews a change against the user's past review comments.                                                             |
| `pull-request-handoff.md`           |   101 |   +101 | States the reviews and the description that hand a finished change over on its pull request.                          |
| `skills/coherence-review/`          |    98 |      0 | Reviews a change for coherence through lenses drawn from the guide.                                                   |
| `skills/code-review/`               |    89 |      0 | Reviews a change through lenses chosen for the diff.                                                                  |
| `skills/less/`                      |    79 |      0 | Carries an easy change to a pull request with one inline review.                                                      |
| `skills/smith/`                     |    78 |   −110 | Carries a well-specified issue to a planned, reviewed pull request.                                                   |
| `skills/precedent-review/`          |    71 |      0 | Launches the precedent reviewer and verifies its findings.                                                            |
| `skills/scout/`                     |    59 |      0 | Answers the user's questions on an issue from the code.                                                               |
| `specification-files.md`            |    55 |      0 | Says where a specification file goes and how it reaches a pull request.                                               |
| `agents/code-review-lens.md`        |    50 |      0 | Reviews a diff through one lens.                                                                                      |
| `subagent-waiting.md`               |    26 |      0 | Says how to wait for launched subagents under each agent harness.                                                     |
| `skills/coherent-coding/`           |    25 |      0 | Loads the coherent coding guide.                                                                                      |
| `collect.md`                        |    19 |    +19 | Says how to file and list the issues for work left out of scope, once the pull request merges.                        |
| `.codex-plugin/plugin.json`         |    17 |      0 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice.                               |
| `github-text.md`                    |    15 |      0 | Says how to lay out text that GitHub renders, and how to pass it to `gh`.                                             |
| `branch-bases.md`                   |    11 |      0 | Says how to find the default branch and the review base.                                                              |
| `agent-written-marks.json`          |     7 |      0 | Holds the comment footer and the commit trailers.                                                                     |
| **Plugin total**                    | 4,204 |    +32 |                                                                                                                       |

### No orphaned files

Apart from the 15 `SKILL.md` files and the manifest, the plugin holds 13 files:
the 11 of 47.3.0, and `pull-request-handoff.md` and `collect.md`, which #1120
added. Each is referenced by path or link. Counting only skills and subagent
files, `agent-written-marks.json` is referenced from 6 skills, `branch-bases.md`
from 4, `coherent-coding.md` from 4, `github-text.md` from 7,
`specification-files.md` from 4, `subagent-waiting.md` from 7,
`assignment-boot.md` from `dream:smith` and `dream:less`,
`pull-request-handoff.md` and `collect.md` each from `dream:smith` and
`dream:big`, `agents/code-review-lens.md` from 2 skills,
`agents/precedent-reviewer.md` from `dream:precedent-review`, and
`claude-code.md` and `codex.md` from `dream:agent-mechanics`. `branch-bases.md`
falls from 5 referring skills to 4, because `dream:smith` now reaches the review
base through `pull-request-handoff.md`. `dream:smith` and `dream:less` reach
`agent-written-marks.json`, `github-text.md` and the default branch through
`assignment-boot.md`. The fewest referring skills for a shared file is 2, the
bar's minimum, for `assignment-boot.md`, `pull-request-handoff.md` and
`collect.md`.

### One fact, one home

A rule counts once however many files repeat it. A one-line summary beside a
link to the rule's home counts as a reference, not a copy; that is how most
skills point to `github-text.md`, how step 1 of `dream:smith` and `dream:less`
points to `assignment-boot.md`, and how `dream:smith` and `dream:big` point to
`pull-request-handoff.md` and `collect.md`. The closing "Use only when
explicitly invoked." in every skill's description is frontmatter that each skill
needs for itself, and is not counted.

The groups that touch only unchanged files are carried forward from 47.3.0,
after a check that the changed files leave each as it was. The groups that touch
`dream:smith`, `dream:big` or the two new shared files were counted afresh from
the files at `8687d6e1`.

The extraction into shared files left the count where it was, apart from one
rule. `pull-request-handoff.md` and `collect.md` give one home to text that
`dream:smith` and `dream:big` both follow, so `dream:big`'s new review,
description and Collect steps add no copy. The copies that `dream:smith` shared
with `dream:less` moved with that text into `pull-request-handoff.md`, and still
count, because `dream:less` does not follow the shared file. `collect.md`
restates one rule that `dream:smith`'s Collect referred to, and that is the one
rule added. `dream:big`'s new Handle user posts joins a group already counted.
The 36:

- **`dream:smith` and `dream:less`, 6.** Written out in both skills, or in
  `pull-request-handoff.md` and `dream:less`: the opening persona, "You are an
  autonomous software developer…" with "Follow the instructions below in
  order."; Implement's loop of running the tests, committing with a short
  subject and pushing at each step; the review base, the `origin/<base>...HEAD`
  target, and weighing each finding on its merits, in the handoff file's Review
  and less's Code review; Write the PR description's contribution rules and its
  issue list, in the handoff file and less; Mark the PR ready for review; and
  Handle user posts, apart from smith going on to Collect, which smith's story
  states. Pull request #1120 gave `dream:big` a Handle user posts that repeats
  the requested change, the question, the answer to a question you raised, and
  "An approval, or anything with nothing to act on, needs no reply.", and, as in
  smith and less, posts where work stopped when the pull request closes and
  never merges it. It counts with the group. Issue #1091 covers Implement,
  Review, Write the PR description and Handle user posts in smith and less, and
  #1102 the persona and Mark the PR ready for review. No open issue names big's
  copy of Handle user posts.
- **Change-type labels, 1.** `assignment-boot.md`, in "I. Open the session PR",
  and `dream:sift` each list the labels `enhancement`, `maintenance` and `bug`.
  Issue #1102 covers it.
- **Finding the repository's label for a change type, 1.** New since 47.3.0.
  `assignment-boot.md`, in "I. Open the session PR", says to run `gh label list`
  to find the repository's closest label for each change type and to apply none
  when there is no clean match. At 47.3.0, `dream:smith`'s Collect referred to
  that procedure, "the same way you did for the PR". `collect.md` now states it
  again, "Use `gh label list` to find the repo's closest label for that type and
  apply it if there is a clean match", because `dream:big`, which also follows
  `collect.md`, does not run the boot sequence. No open issue covers it.
- **The review skills, 6.** As at 47.3.0, since none of the files has changed:
  the default target, Read the diff, keeping only the findings the code
  confirms, and Rank and output, in `dream:code-review`,
  `dream:coherence-review` and `dream:precedent-review`; how to launch a
  subagent file under Codex, in the same three; and that subagents inherit the
  session's model and effort, in those three and `dream:quest`. Issue #1091
  covers the copies in `dream:code-review` and `dream:coherence-review`, and
  #1102 those in `dream:precedent-review` and `dream:quest`.
- **The marks, 2.** How to apply the comment footer, as a closing blockquote so
  that a reader can tell an agent wrote it, still in `dream:spark`,
  `dream:trace`, `dream:weave`, `dream:quest`, `dream:big`, `dream:sift`,
  `assignment-boot.md` and `specification-files.md`. How to apply the commit
  trailer, in `assignment-boot.md` and `specification-files.md`, and now
  `dream:big`, which #1120 gave "End every commit you create with the trailer
  for your harness." Issue #1083 covers both.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer. Issue #1102 covers it.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", still in `dream:trace` and `dream:weave`. Issue #1102 covers it.
- **Turn output, 1.** `dream:big`'s "Write to the user" keeps turn output to
  usually one sentence per turn, now "because the user follows the campaign's
  pull request and the sub-issues' pull requests". "Turn output" in
  `assignment-boot.md` keeps it to usually one sentence per turn because the
  user interacts via GitHub. The release 47.3.0 added it to #1102, which covers
  it.
- **The skills in the user's voice, 13.** As at 47.3.0, since `dream:spark`,
  `dream:trace`, `dream:weave` and `dream:quest` are unchanged: one thing per
  turn, with no recap; how to sound like a person; no flattery; how to start
  from the seed; reading the documentation that governs the code, and checking
  its claims in the code; the two fresh readers, launched together and waited
  for together; Where it goes; think out loud; push back on the user; tell the
  user only what you have read in the code; say when you use an analogy and
  where it stops holding; the user can stop at any time, and "just write it up"
  is an answer; and end every turn with a next move ready. Issue #1083 covers
  them.
- **The coherent coding guide, 2.** `dream:less`'s step 2, Adopt the engineering
  principles, restates "Resolve the root cause" and "The burden of proof is on
  the addition". `dream:sift`'s Judgments restate several of the guide's rules,
  although sift loads the guide. Issue #1083 covers sift's. Its decision scopes
  out less's summary as a deliberate stand-in for the guide, which less does not
  load, as less's story states. The measure has no exception for it, so it still
  counts. No issue is filed, because removing it would remove a difference that
  less needs for its purpose, which "How we judge" in `AGENTS.md` says to keep.
- **Checking an issue's claims against the current code, 1.**
  `assignment-boot.md`, in "G. Read the cited material and the code",
  `dream:scout`'s Investigate and `dream:sift`'s Judgments each say to check the
  input's claims against the current code, because the code may have changed
  since the issue was written. Issue #1102 covers it.
- **Drafts in a temporary file, 1.** The Review in `pull-request-handoff.md`,
  which was `dream:smith`'s Review, `dream:plan`, `dream:spark`, `dream:trace`,
  `dream:weave` and `dream:quest` each still write their draft to a temporary
  file outside the repo. Issue #1102 covers it, naming smith's Review.

One more pair was weighed and not counted. `assignment-boot.md`'s "Autonomy" has
the assignment skills post a question for the user on the pull request, and
`dream:big`'s "Write to the user" has the lead post questions, decisions and
problems on the campaign's pull request. At 47.3.0 `dream:big` posted them on
the parent issue, and that measurement did not count the rule to ask the user on
GitHub rather than in the session, so moving the lead's channel to a pull
request adds no copy.

### One vocabulary

The searches under [Method](#method) find no retired term that names its concept
in the plugin, the documentation or the open issues. A search for the multi-word
terms split across a line break finds none outside the changelog.

The remaining hits are the other senses that 47.3.0 found: "brief" as an
adjective or a verb, in `dream:precedent-review`, `dream:scout`,
`dream:coherent-coding`, `assignment-boot.md`, `dream:big` and the 47.3.0
changelog section; `children` in `dream:big`, the name of a field in
dreamcatcher's input; the `specs/` folder in `specification-files.md`; "the
spec" for an API in `coherent-coding.md`; "child process" in `codex.md`;
"permission host" in `claude-code.md`; "host" as the example in `releasing.md`;
"task" for a piece of work or a TODO item; "plan" for an implementation plan;
and "design" for the solution being worked out, now also in
`pull-request-handoff.md`'s "changing the design" and "design choices" and in
`dream:big`'s "a design decision". The 47.1.0 section of the changelog names
"requirements brief", "campaign plan" and "session type" as the terms that #1106
replaced, which is not a use. In the open issues, the hits are "tasks" for
pieces of work and "design" for designing in #1048, smith's step Plan in #1091,
`dream:plan` and "keep turn output brief" in comments on #1102, and
`spec-files.md`, the earlier name of a file, in the decision on #1083.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin at
`8687d6e1`. None is contradicted. Since `v47.3.0`, #1120 rewrote the campaign
story, the home page's paragraph on campaigns and the compatibility page's
contract version and its sentence on who writes the dependency graph, and #1122
changed step 6 of smith's story, step 12 of the campaign story, the home page's
paragraph on reviews and the sample session in `overrides/home.html`. Each
agrees with the plugin:

- The campaign story's steps 2 to 16 follow `dream:big`'s steps 1 to 6 and "Work
  on the sub-issues": the campaign's draft pull request, reading the work and
  the blocked-by links, dispatch by assignee and label, checking each
  sub-issue's pull request against its goal while leaving detailed code review
  to its agent, passing changes on to affected sub-issues before a merge,
  holding merges on an open question, the review of the whole change through
  `pull-request-handoff.md`, keeping the pull request ready while added
  sub-issues run, and Collect.
- Smith's story step 6 follows the Simplification review in
  `pull-request-handoff.md`, and step 11 follows `collect.md`.
- The compatibility page names version 2 of the contract, and says the user
  writes the dependency graph directly or with `dream:quest`. `dream:big` no
  longer writes blocked-by links, and its Limits leave which sub-issues block
  which to the user.
- The home page's campaign paragraph matches the campaign branch and the
  campaign's pull request, and its review paragraph matches the three reviews
  that `pull-request-handoff.md` runs for Smith and Big.

Three statements were weighed and not counted:

- Step 14 of the campaign story says the lead "keeps the pull request current
  with the default branch and its checks passing". No step of `dream:big` says
  so. The skill does not contradict it: dreamcatcher's finishing-phase round
  prompt has the lead switch to the campaign branch before it acts on
  dreamcatcher's signals, which carry that work.
- The standard's Single responsibility bar names `dream:smith` as a long skill
  whose steps form one procedure and stay whole. `dream:smith` is now 78 lines,
  because #1120 moved its steps from Review to Collect into shared files that
  `dream:big` also follows. With the boot sequence and those files, its
  procedure is still long and still one, and it stays whole.
- Step 4 of the campaign story has the lead assign a sub-issue to "the user's
  account", and `dream:big` assigns it to "the signed-in account". The skill's
  "You and the sub-issue's agent share one GitHub account" makes them the same
  account.

Of the four statements that 47.3.0 weighed and did not count, three still stand
as it judged them: the smith and less stories' omission of the session input
comment; the compatibility page's "Each skill is one file that both read.",
which still holds now that `dream:smith` and `dream:big` also read the two new
shared files; and saliency decay in `AGENTS.md`. The fourth, the sample session
in `overrides/home.html`, now shows the Simplification review that #1122 added,
and omits only the Session input comment. It shows a selection of steps, so it
is still not counted.

### Docs by purpose

The navigation in `mkdocs.yml` and the README are unchanged since 47.3.0, and
the changelog gained only the 48.0.0 section in the release's working tree,
which links only to pull requests and the compatibility page. The home page
changed only in its paragraphs on campaigns and reviews and in the sample
session, and the compatibility page only in two statements; neither change adds
a link. The navigation puts the home page alone, the compatibility page and the
changelog under Reference, and the concepts, stories, standard, measurement,
release checklist, ledger and agent-mechanics sources under Development. The
home page links only to dreamcatcher's site and the issue tracker, the
compatibility page only to dreamcatcher's site, the changelog only to the
compatibility page, the home page and pull requests, and the README only to the
site.

### Versioned contract

The compatibility page states the interface under "The interface", the rules for
a major, minor and patch release under "Versions", and, since #1120, version 2
of dreamcatcher's agent contract under "dreamcatcher's contract". The comparison
of skill names from step 1 of the checklist prints nothing. At `8687d6e1`, the
manifest is as at `v47.3.0`, and `.claude-plugin/marketplace.json` differs only
in the entry's `sha`, which pull request #1118 pinned to the commit tagged
`v47.3.0`. Pull request #1120 moves dream to a new version of dreamcatcher's
contract, which "Versions" makes a major change; its Names kept answer says so.
Pull requests #1120 and #1122 also change what `dream:big` and `dream:smith` do,
and neither renames or removes a name in the interface. 47.3.0 to 48.0.0 is a
major increment.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows, and neither they nor the scripts have
changed since 47.3.0. Among the pull requests since 47.3.0, no rule was missed
by review more than once.

### Current tracker

All 8 open issues were read with their comments, and each claim that work is
done was checked against the plugin. 47.3.0 counted 9 open issues; since then,
pull request #1120 closed #1046, and #1121 was opened and closed by #1122. None
of the 8 counts.

No open issue uses a retired term for its concept (see
[One vocabulary](#one-vocabulary)). No open issue asks only for work already
done. Issue #1091 is part done, as at 47.3.0, and still asks about Implement,
the code review, Write the PR description, the shared text of Handle user posts,
and the review pair. The plugin does not yet have the change that each of these
asks for: #1083, #1085, #1088 and #1102. For example, the "Golden rule" in
`coherent-coding.md`, which issue #1088 asks to narrow, is unchanged. The work
in issue #1043 waits on alimanfoo/dreamcatcher#917, which is still open, and the
work in issues #1048 and #686 waits on discussion. No open issue concerns only a
skill the plugin no longer has: the issue #686 names `solo`, an earlier name of
`dream:less`, but asks for a skill for every pull request comment. No open issue
asks for behaviour that a story excludes. Issue #1102 has no triage outcome yet.

The changes since `v47.3.0` made some issue and decision text stale, without
making it count under the measure:

- The decision on #1043 says to add a rule to `dream:big`'s "Merge a stage" that
  posts on the parent. #1120 renamed that section "Merge a sub-issue's pull
  request" and moved the lead's posts for the user to the campaign's pull
  request. The need it records still stands.
- #1088 cites `dream:smith`'s Review and Collect steps, and its decision puts
  them out of scope. They are now `pull-request-handoff.md` and `collect.md`,
  which `dream:big` also follows.
- #1091 cites `dream:smith`'s "Review" and "Find simplification opportunities".
  Smith's step is now "Review and prepare the pull request", which follows
  `pull-request-handoff.md`, and the simplification step is now the
  Simplification review there. Sharing a step with `dream:less` now means
  sharing text that `dream:big` also follows.
- A comment on #1102 places the temporary-file rule in `dream:smith`'s Review,
  which is now in `pull-request-handoff.md`.

### Reviewed changes

The window is the pull requests merged since `v47.3.0`, in order of merge: pull
requests #1118, #1120 and #1122. No commit reached main without a merge. Each
says what it changes and why, links the issue it closes or, for #1118, the
release pull request it follows, and answers all eleven definition-of-done
questions by title under a "Definition of done" heading, each with its evidence.
Each Line count answer matches the merged change: nothing under `plugins/dream`
for #1118, 329 lines added and 297 removed for #1120, and 11 added and 11
removed for #1122. The Names kept answer of #1120 records the move from version
1 to version 2 of the contract. Its Concepts' words answer says that the skill
defines a sub-issue's "work definition" itself (see
[Few concepts](#few-concepts)).

### Rules not cases

The ledger has 3 entries. Pull request #1120 changed the entry for
`commitTrailer` to stop naming the files that read it, since `dream:big` now
reads it too. Each entry is caused by a difference between the agent harnesses,
and each still matches the plugin. The guide to agent mechanics is not searched
for special cases, because the agent harnesses are its subject. Two special
cases elsewhere in the plugin are not on the ledger:

- `assignment-boot.md`, which `dream:smith` and `dream:less` share, and
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` name
  `AskUserQuestion`, a Claude Code tool, to say how not to ask the user a
  question. Under Codex the name refers to nothing.
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`. Triage of #1085 decided to remove dispatch from the
  skill.

The changes since 47.3.0 add no special case. `dream:big`'s commit trailer "for
your harness" reads the ledgered `commitTrailer`. `pull-request-handoff.md`
speaks of "the input that defines the change" where `dream:smith` said "the
session input", a general rule that serves both skills, and `dream:big`'s choice
of step by the campaign pull request's state is its procedure, not a special
case.

### Few concepts

The concepts page has 27 entries, and no commit has changed it since `v47.3.0`.
No concept was added. Pull request #1120 gave `dream:big` the term "work
definition", which it defines in one sentence, "A sub-issue's work definition is
its body, its comments and any specification it links.", and which no other file
uses. That is a combination of the concepts page's issue and specification, so
it needs no entry there.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, the simplification review and Collect. They also
state that `dream:less` runs its code review without subagents, and that it
follows a short summary of the engineering principles rather than loading the
coherent coding guide. The code-review pair and the guide to agent mechanics are
unchanged since `v47.3.0`.

- **`dream:smith` and `dream:less`.** The heading comparison now shows smith's
  single step 5, "Review and prepare the pull request", where less has two,
  "Code review" and "Write the PR description", besides Plan and Collect, which
  only smith has. Steps 1 and 2 have the same names in both. Step 1, Boot, runs
  the shared `assignment-boot.md`. Step 2, Adopt the engineering principles,
  differs as less's story states. Five later steps do the same thing in both and
  are written out in each: Implement, the code review, Write the PR description,
  Mark the PR ready for review, and Handle user posts. Pull request #1120 moved
  smith's side of the code review and of Write the PR description into
  `pull-request-handoff.md`, which `dream:big` also follows, but `dream:less`
  does not follow it, so the two steps are still written out twice and the count
  is unchanged. Smith's step 5 covers what less does in its steps 4 and 5, so
  corresponding names now differ there across one step against two, where at
  47.3.0 they differed only as smith's "Review" and less's "Code review".
- **`dream:code-review` and `dream:coherence-review`.** Unchanged since 47.0.0.
  The step headings match. Arguments, Read the diff, Launch the lenses, Combine
  and verify, and Rank and output are written out in both.
- **The two agent harnesses.** Each launch step and `subagent-waiting.md` give
  both agent harnesses corresponding instructions, and `dream:big`'s commit
  trailer reads the value for either harness. `claude-code.md` and `codex.md`
  are unchanged since 46.5.0, and each adds to a heading of `SKILL.md` only what
  is specific to its agent harness, so a missing heading is not a missing step.

## Method

Run from the repository root. The plugin is `plugins/dream`, and the
documentation is `docs/`, `overrides/home.html`, `README.md` and `AGENTS.md`.
`v<last>` is the last release's tag.

- **Size.** Per skill folder, then per other file, then the total, which counts
  the symlinked manifest once:

  ```bash
  for d in plugins/dream/skills/*/; do printf '%s\t%s\n' "$(find "$d" -type f -exec cat {} + | wc -l | tr -d ' ')" "$d"; done | sort -rn
  wc -l plugins/dream/agents/*.md plugins/dream/*.md plugins/dream/*.json plugins/dream/.codex-plugin/plugin.json
  find plugins/dream -type f -exec cat {} + | wc -l
  ```

  For the change, extract the last release's plugin into an empty directory
  outside the repository, run the same commands there, and check the net change
  against `git diff --shortstat`:

  ```bash
  git archive v<last> plugins/dream | tar -x -C <empty directory>
  git diff --shortstat v<last> HEAD -- plugins/dream
  ```

- **Single responsibility, One fact, one home, Rules not cases and Symmetry.**
  Read every file in the plugin whole, largest first. A file that
  `git diff --stat v<last> HEAD -- plugins/dream` shows unchanged may instead
  carry its last finding forward, once the finding is confirmed against the
  files that changed. For the pairs, compare their step headings, without the
  step numbers or the headings inside fenced examples, and then their text step
  by step:

  ````bash
  h() { awk '/^```/{f=!f} !f && sub(/^## ([0-9]+\. )?/, "")' "$1"; }
  diff <(h plugins/dream/skills/smith/SKILL.md) <(h plugins/dream/skills/less/SKILL.md)
  diff <(h plugins/dream/skills/code-review/SKILL.md) <(h plugins/dream/skills/coherence-review/SKILL.md)
  ````

  To find text that applies under one agent harness, search outside the guide to
  agent mechanics:

  ```bash
  grep -rn -i -e 'claude code' -e 'codex' -e 'AskUserQuestion' -e 'harness' plugins/dream | grep -v '^plugins/dream/skills/agent-mechanics/'
  ```

- **No orphaned files.** For each file that is not an entry point, list the
  files that name it:

  ```bash
  cd plugins/dream && for f in agent-written-marks.json assignment-boot.md branch-bases.md coherent-coding.md collect.md github-text.md pull-request-handoff.md specification-files.md subagent-waiting.md code-review-lens.md precedent-reviewer.md claude-code.md codex.md; do echo "$f: $(grep -rl --include='*.md' "$f" skills agents *.md | grep -v "$f\$" | tr '\n' ' ')"; done
  ```

  Count only the skills and subagent files among the referrers. Compare the
  loop's list with `find plugins/dream -type f`, so that a file added since the
  last measurement joins it.

- **One vocabulary.** Search for each retired term on the concepts page's
  "Replaces:" lines, then read each hit. "design", "plan" and "task" have other
  senses, so search for them as whole words and judge each line. The third
  search finds a multi-word term split across a line break:

  ```bash
  rg -niP '\bhosts?\b|agent prompt|named agent|\bchild(ren)?\b|\bspecs?\b|requirements brief|\bbriefs?\b|campaign plan|issue type|session type|\bcategor' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md' -g '!docs/assets/**'
  rg -niw 'design|plans?|tasks?' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md' -g '!docs/assets/**'
  rg -niUP 'requirements\s+brief|session\s+type|issue\s+type|campaign\s+plan|agent\s+prompt|named\s+agent|child\s+issue' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md'
  ```

  Search the body and every comment of each open issue, fetched as under Current
  tracker, for the same terms, and read each hit in its sentence.

- **No suppressions.**

  ```bash
  git grep -n -e 'markdownlint-disable' -e 'prettier-ignore' -- '*.md'
  ```

  The only hits are the standard's own description of the measure, and this
  line.

- **Docs by purpose.** Read the `nav` in `mkdocs.yml`, and list the links on the
  home page, the Reference pages and the README:

  ```bash
  grep -no '](\([^)]*\))' docs/index.md docs/compatibility.md docs/changelog.md README.md
  grep -no 'href="[^"]*"' overrides/home.html
  ```

- **Current tracker.** Fetch every open issue with its comments, then read each
  against the plugin, the stories and the list of skills:

  ```bash
  gh issue list --state open --limit 300 --json number,title,body,comments
  ```

- **Reviewed changes.** List the pull requests merged since the last release,
  and the commits that reached main without a merge, such as Dependabot's:

  ```bash
  git log --merges --first-parent --oneline v<last>..HEAD
  git log --first-parent --no-merges --oneline v<last>..HEAD
  ```

  Read each description with `gh pr view <N> --json title,author,body`, and
  check it for each of the definition of done's eleven titles in bold.

- **True documents and Versioned contract.** Read each document named in True
  documents whole, and check each statement it makes about the plugin against
  the plugin. For the version, run the skill-name comparison and the diff of the
  interface's files from step 1 of the checklist.

- **Few concepts.** Count the entries under "Definitions" on the concepts page,
  and list the commits that changed it since the last release:

  ```bash
  git log --oneline v<last>..HEAD -- docs/concepts.md
  ```
