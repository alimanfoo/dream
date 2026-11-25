# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-25 for the 47.1.0 release. The plugin and the documentation
were read on the release branch, which starts from `f277a9f6`. Its working tree
differed from that commit in the version in the manifest, the new changelog
section, and the consistency review's one fix, to a row of the ledger of special
cases. True documents records what this reading found at `f277a9f6`, before any
fix from the release's consistency review. Each measure is compared with the
measurement for the last release, 47.0.0, tagged `v47.0.0`, whose figures are
given in brackets.

## Results

| Criterion             | Measured                                                                                                    | Status  |
| --------------------- | ----------------------------------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 33 files without a one-sentence purpose (0 of 24)                                                      | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 2 referring skills (at least 4)                        | met     |
| One fact, one home    | 33 rules or facts stated in more than one file (35)                                                         | not met |
| Size                  | 4,284 lines in the plugin (4,331), a change of −47                                                          | no bar  |
| One vocabulary        | 0 uses in the plugin, 0 in the documentation, 0 open issues use retired terms (109 uses on 108 lines, 4, 3) | met     |
| True documents        | 0 statements that the plugin contradicts, at `f277a9f6` (0, after the consistency review fixed 3)           | met     |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page (0, 0)                                                     | met     |
| Versioned contract    | The compatibility page states all three; 47.1.0 is a minor release, as changes to what skills do require    | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce (0)                                         | met     |
| No suppressions       | 0 markers (0)                                                                                               | met     |
| Current tracker       | 0 of 13 open issues out of date (3 of 15)                                                                   | met     |
| Reviewed changes      | 4 of 4 pull requests answer every definition-of-done question (11 of 11)                                    | met     |
| Rules not cases       | 2 special cases not on the ledger; 0 ledger entries with an internal cause (2; 0)                           | not met |
| Few concepts          | 0 concepts added since 47.0.0 (0)                                                                           | met     |
| Symmetry              | 10 unshared or unmatched steps across the three pairs (23)                                                  | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 33 rules or facts are stated in more than one skill,
   subagent file or shared file. The list is under
   [One fact, one home](#one-fact-one-home) below. #1091 covers the four steps
   still written out in both `dream:smith` and `dream:less` whose differences it
   asks about, and the copies in `dream:code-review` and
   `dream:coherence-review`. #1102 covers the copies of the review rules in
   `dream:precedent-review` and `dream:quest`, the report rules of the two
   subagent files, and the reason for an absolute path in `dream:trace` and
   `dream:weave`. #1083 covers the marks, the 11 rules common to the skills in
   the user's voice, and the restatements of the coherent coding guide. No open
   issue covered 6, and this release added them to #1102: the persona paragraph,
   the rule to read the session rules again after a summary, and Mark the PR
   ready for review, all in `dream:smith` and `dream:less`; the change-type
   labels in `assignment-session-pr.md` and `dream:sift`; checking an issue's
   claims against the current code; and writing a draft to a temporary file
   outside the repo.
2. **Rules not cases.** Two special cases are not on the ledger: the
   `AskUserQuestion` tool, named in `assignment-session-rules.md` and four
   skills, and `dream:sift`'s condition on `dreamcatcher.toml`. #1085 covers
   both.
3. **Symmetry.** `dream:smith` and `dream:less` write out 5 steps in each file
   that do the same thing in both, and `dream:code-review` and
   `dream:coherence-review` write out 5. #1091 covers all of them except Mark
   the PR ready for review, which #1086 covered until #1107 closed it and this
   release added to #1102. #1091 also covers the step that `dream:smith` names
   "Review" and `dream:less` "Code review".

## Notes

### Single responsibility and Size

The files that changed since 47.0.0 were read whole, in descending order of
size. The rest, `skills/agent-mechanics/`, `coherent-coding.md`, the review
skills, the subagent files, `dream:scout`, `dream:coherent-coding`,
`branch-bases.md`, `github-text.md`, `subagent-waiting.md`,
`agent-written-marks.json` and the manifest, are unchanged since `v47.0.0`, as
`git diff` shows, and all but the guide to agent mechanics and the coherent
coding guide were read again. Each file has one purpose, stated in the table.
`dream:smith` and `dream:big` are long, but each is one procedure. Each of the
nine `assignment-*.md` files that #1107 added holds one step that `dream:smith`
and `dream:less` share, or, in `assignment-session-rules.md`, the rules that
hold for their whole session.

The change is from the same commands run on a copy of the plugin at `v47.0.0`,
which reproduce that measurement's 4,331 lines.
`git diff --shortstat v47.0.0 HEAD -- plugins/dream` reports 19 files changed,
479 insertions and 526 deletions, a net change of −47. `dream:smith` and
`dream:less` lost 239 lines and the nine shared files hold 158, so the two
skills and what they read fell from 593 lines to 512.

| File                                    | Lines | Change | Purpose                                                                                                        |
| --------------------------------------- | ----: | -----: | -------------------------------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files)     |   986 |      0 | Explains how a coding agent works under Claude Code and Codex.                                                 |
| `coherent-coding.md`                    |   359 |      0 | States the coherent coding guide.                                                                              |
| `skills/spark/`                         |   329 |      0 | Interviews the user and writes a requirements specification.                                                   |
| `skills/weave/`                         |   326 |    +27 | Works out a solution with the user in design models, and writes a design specification.                        |
| `skills/big/`                           |   289 |     +1 | Leads a dreamcatcher campaign through its stages to merge.                                                     |
| `skills/trace/`                         |   258 |      0 | Tours the code with the user and writes a checked reading guide.                                               |
| `skills/quest/`                         |   256 |     +6 | Breaks a design specification into a roadmap of stages, and its sub-issues.                                    |
| `skills/smith/`                         |   234 |   −137 | Carries a well-specified issue to a planned, reviewed pull request.                                            |
| `skills/sift/`                          |   228 |      0 | Triages issues with the user, one decision at a time.                                                          |
| `skills/less/`                          |   120 |   −102 | Carries an easy change to a pull request with one inline review.                                               |
| `skills/plan/`                          |   116 |      0 | Writes an implementation plan.                                                                                 |
| `agents/precedent-reviewer.md`          |   102 |      0 | Reviews a change against the user's past review comments.                                                      |
| `skills/coherence-review/`              |    98 |      0 | Reviews a change for coherence through lenses drawn from the guide.                                            |
| `skills/code-review/`                   |    89 |      0 | Reviews a change through lenses chosen for the diff.                                                           |
| `skills/precedent-review/`              |    71 |      0 | Launches the precedent reviewer and verifies its findings.                                                     |
| `skills/scout/`                         |    59 |      0 | Answers the user's questions on an issue from the code.                                                        |
| `specification-files.md`                |    55 |      0 | Says where a specification file goes and how it reaches a pull request. Renamed from `spec-files.md` by #1106. |
| `agents/code-review-lens.md`            |    50 |      0 | Reviews a diff through one lens.                                                                               |
| `assignment-session-rules.md`           |    41 |    +41 | States the rules that `dream:smith` and `dream:less` follow for the whole session.                             |
| `assignment-session-pr.md`              |    30 |    +30 | Says how to set the session branch and open the session PR.                                                    |
| `subagent-waiting.md`                   |    26 |      0 | Says how to wait for launched subagents under each agent harness.                                              |
| `assignment-cited-material-and-code.md` |    25 |    +25 | Says how to read the cited material and the code, and check the input against the code.                        |
| `skills/coherent-coding/`               |    25 |      0 | Loads the coherent coding guide.                                                                               |
| `.codex-plugin/plugin.json`             |    17 |      0 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice.                        |
| `github-text.md`                        |    15 |      0 | Says how to lay out text that GitHub renders, and how to pass it to `gh`.                                      |
| `assignment-banner.md`                  |    13 |    +13 | Says how to print the banner with the plugin's version.                                                        |
| `assignment-session-input.md`           |    12 |    +12 | Says where the session input comes from.                                                                       |
| `assignment-tests-and-checks.md`        |    12 |    +12 | Says how to find the tests, checks and code generation to run.                                                 |
| `branch-bases.md`                       |    11 |      0 | Says how to find the default branch and the review base.                                                       |
| `assignment-orientation.md`             |    10 |    +10 | Says how to orient to the repository.                                                                          |
| `assignment-working-tree.md`            |     8 |     +8 | Says how to check the working tree and update the default branch.                                              |
| `agent-written-marks.json`              |     7 |      0 | Holds the comment footer and the commit trailers.                                                              |
| `assignment-change-types.md`            |     7 |     +7 | Defines the three change types.                                                                                |
| **Plugin total**                        | 4,284 |    −47 |                                                                                                                |

A zero change can hide edits that add and remove the same number of lines: #1106
changed `dream:spark`, `dream:trace`, `dream:sift` and `dream:plan` without
changing their length.

### No orphaned files

Apart from the 15 `SKILL.md` files and the manifest, the plugin holds 19 files.
Each is referenced by path or link. Counting only skills and subagent files,
`agent-written-marks.json` is referenced from 6 skills, `branch-bases.md` from
5, `coherent-coding.md` from 4, `github-text.md` from 7,
`specification-files.md` from 4, `subagent-waiting.md` from 7, each of the nine
`assignment-*.md` files from `dream:smith` and `dream:less`,
`agents/code-review-lens.md` from 2 skills, `agents/precedent-reviewer.md` from
`dream:precedent-review`, and `claude-code.md` and `codex.md` from
`dream:agent-mechanics`. `dream:smith` and `dream:less` now reach
`agent-written-marks.json` and `github-text.md` through
`assignment-session-rules.md`, and the default branch through
`assignment-working-tree.md`. The fewest referring skills for a shared file is
2, the bar's minimum, for each of the nine new files.

### One fact, one home

A rule counts once however many files repeat it. A one-line summary beside a
link to the rule's home counts as a reference, not a copy; that is how most
skills point to `github-text.md`, and how each numbered step of `dream:smith`
and `dream:less` points to its `assignment-*.md` file. The closing "Use only
when explicitly invoked." in every skill's description is frontmatter that each
skill needs for itself, and is not counted.

The list was made afresh from the files as they stand. #1107 moved 12 of the 16
steps that 47.0.0 counted in both `dream:smith` and `dream:less` into the nine
`assignment-*.md` files. The reading also counts 9 rules that were stated in
more than one file at 47.0.0 but were not counted then, and 1 that #1107 added.
The 33:

- **`dream:smith` and `dream:less`, 7.** Written out in both skills: the opening
  persona, "You are an autonomous software developer…" with "Follow the
  instructions below in order."; step 2's rule to read the session rules again
  whenever the conversation has been summarised, which #1107 added; Implement's
  loop of running the tests, committing with a short subject and pushing at each
  step; the review base, the `origin/<base>...HEAD` target, and weighing each
  finding on its merits, in smith's Review and less's Code review; Write the PR
  description's contribution rules and its issue list; Mark the PR ready for
  review; and Handle what the user posts. The persona and the review text were
  in both at 47.0.0, but not counted. #1091 covers Implement, Review, Write the
  PR description and Handle what the user posts. No open issue covered the
  persona, the rule to read the session rules again, or Mark the PR ready for
  review, which #1086 covered until #1107 closed it; this release added them to
  #1102.
- **Change-type labels, 1.** `assignment-session-pr.md` and `dream:sift` each
  list the labels `enhancement`, `maintenance` and `bug`. 47.0.0 counted sift's
  copy as a third copy of smith and less's Name the session type step. This
  release added it to #1102.
- **The review skills, 6.** As at 47.0.0, since none of the files has changed:
  the default target, Read the diff, keeping only the findings the code
  confirms, and Rank and output, in `dream:code-review`,
  `dream:coherence-review` and `dream:precedent-review`; how to launch a
  subagent file under Codex, in the same three; and that subagents inherit the
  session's model and effort, in those three and `dream:quest`. #1091 covers the
  copies in `dream:code-review` and `dream:coherence-review`, and #1102 those in
  `dream:precedent-review` and `dream:quest`.
- **The marks, 2.** How to apply the comment footer, as a closing blockquote so
  that a reader can tell an agent wrote it, in `dream:spark`, `dream:trace`,
  `dream:weave`, `dream:quest`, `dream:big`, `dream:sift`,
  `assignment-session-rules.md` and `specification-files.md`. How to apply the
  commit trailer, in `assignment-session-rules.md` and `specification-files.md`.
  #1083 covers both.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer. #1102 covers it.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", in `dream:trace` and `dream:weave`. #1102 covers it.
- **The skills in the user's voice, 11.** The 7 that 47.0.0 listed, each still
  in two to four of `dream:spark`, `dream:trace`, `dream:weave` and
  `dream:quest`: one thing per turn, with no recap; plain words, no headings or
  lists in a turn, and no `AskUserQuestion`; no flattery; how to start from the
  seed; that documents drift, so their claims are checked in the code; the two
  fresh readers, launched together and waited for together; and Where it goes.
  Four more were there at 47.0.0 but not counted: think out loud, with "Tell me
  what you're thinking, not what you're doing" in both `dream:weave` and
  `dream:quest`; push back on the user, in all four; tell the user only what you
  have read in the code, with "I don't know yet, let me look" in both
  `dream:weave` and `dream:trace`; and say when you use an analogy and where it
  stops holding, in nearly the same words in `dream:weave` and `dream:trace`.
  #1083 covers the rules common to the four skills.
- **The coherent coding guide, 2.** `dream:less`'s Engineering principles step
  restates "Resolve the root cause" and "The burden of proof is on the
  addition". `dream:sift`'s Judgments restate several of the guide's rules,
  although sift loads the guide. #1083 covers both, and decided to replace each
  restatement with a reference to the guide's section. Since then #1107 has
  added to `dream:less`'s story that it "follows a short summary of the
  engineering principles, rather than loading the full coherent coding guide",
  so the fix for less is a summary beside links to the guide's sections, not a
  load of the guide.
- **Checking an issue's claims against the current code, 1.**
  `assignment-cited-material-and-code.md`, `dream:scout`'s Investigate and
  `dream:sift`'s Judgments each say to check the input's claims against the
  current code, because the code may have changed since the issue was written.
  This release added it to #1102.
- **Drafts in a temporary file, 1.** `dream:smith`'s Review, `dream:plan`,
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` each write their
  draft to a temporary file outside the repo. This release added it to #1102.

### One vocabulary

The searches under [Method](#method) find no retired term that names its concept
in the plugin, the documentation or the open issues. #1106 replaced the 109 uses
that 47.0.0 counted in the plugin and the 4 lines in the documentation, and
renamed `spec-files.md` to `specification-files.md`. A search for the multi-word
terms split across a line break finds none.

The remaining hits are other senses, as at 47.0.0: "brief" as an adjective or a
verb; `children` in `dream:big`, the name of a field in dreamcatcher's input;
the `specs/` folder in `specification-files.md`; "the spec" for an API in
`coherent-coding.md`; "child process" in `codex.md`; "permission host" in
`claude-code.md`; "task" for a piece of work or a TODO item; "plan" for an
implementation plan; and "design" for the solution being worked out, as in "the
design touches". The 47.1.0 section of the changelog names "requirements brief",
"campaign plan" and "session type" as the terms that #1106 replaced, which is
not a use.

The 3 open issues that 47.0.0 counted no longer use a retired term: the issue
sweep edited the comments on #1043 and #1050, and #1105 closed #930.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin at
`f277a9f6`. None is contradicted.

Since 47.0.0, #1105 rewrote the concepts page's "Design specification", the
weave story and weave's row on the home page; #1106 changed the home page's
spark, quest and plan rows and the sample session's "4 steps"; and #1107 changed
the less story. Each agrees with the plugin: the weave story's steps 6 to 12
follow `dream:weave`'s sections from "When the what-ifs stop changing the
design" to "Get it checked before you show me", and its step 11 the design
specification's headings; the less story's steps 2 and 4 match the shared "Read
the cited material and the code" and less's Engineering principles step; and the
home page's rows match the skills. The home page's sift row, "can dispatch
accepted work", is still true at `f277a9f6`; #1085 will remove dispatch and that
phrase together.

Three statements were weighed and not counted:

- The smith and less stories say that the agent opens a draft pull request, but
  not that it posts the session input there as its first comment, which both
  skills now do. That is an omission, not a contradiction.
- The compatibility page says "Each skill is one file that both read."
  `dream:agent-mechanics` has three files, and `dream:smith` and `dream:less`
  now read nine shared files. The sentence says that both agent harnesses read
  the same files, which holds.
- The sample session in `overrides/home.html` omits the Session input and
  Simplification opportunities comments that `dream:smith` posts. It shows a
  selection of steps.

### Docs by purpose

The navigation in `mkdocs.yml` is unchanged since 47.0.0. It puts the home page
alone, the compatibility page and the changelog under Reference, and the
concepts, stories, standard, measurement, release checklist, ledger and
agent-mechanics sources under Development. The home page links only to
dreamcatcher's site and the issue tracker, the compatibility page only to
dreamcatcher's site, the changelog, with this release's section, only to the
compatibility page, the home page and pull requests, and the README only to the
site.

### Versioned contract

The compatibility page, unchanged since 47.0.0, states the interface under "The
interface", the rules for a major, minor and patch release under "Versions", and
version 1 of dreamcatcher's agent contract under "dreamcatcher's contract". The
comparison of skill names from step 1 of the checklist prints nothing. At
`f277a9f6`, the manifest is as at `v47.0.0`, and
`.claude-plugin/marketplace.json` differs only in the plugin's source, which a
pull request, #1104, pinned to the commit tagged `v47.0.0`. Changes to what a
skill does, to `dream:weave` in #1105 and to `dream:less` in #1107, call for a
minor increment. The rename by #1106 of the steps "Name the session type" and
"Read the plan" is not a change to the interface, which names no step. 47.0.0 to
47.1.0 is a minor increment.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows, and neither they nor the scripts have
changed since 47.0.0. Among the pull requests since 47.0.0, no rule was missed
by review more than once. The multi-word retired terms are now gone from the
plugin; the condition that 46.5.0 set for a check on them, that they come back
after removal, has not arisen.

### Current tracker

All 13 open issues were read with their comments, and each claim that work is
done was checked against the plugin. 47.0.0 counted 15 open issues. None counts.
The release's issue sweep updated the agent-written decisions on #1050, #1083
and #1085, which quoted step names and a file name that #1106 and #1107 had
changed.

No open issue uses a retired term for its concept (see
[One vocabulary](#one-vocabulary)). No open issue asks only for work already
done. #1091 is part done: its comments record that #1107 settled Obtain session
input, Read the cited material, Find the tests and checks, Open the session PR,
Orient to the repo, and the names of steps 1 to 10, and it still asks about
Implement, Code review, Write the PR description, Handle what the user posts,
the remaining step names and the review pair. Issue #1042 is half done, as its
decision comment says. The body of #1083 gives 47.0.0's counts, but its decision
comment scopes what remains, and none of that is done. The plugin does not yet
have the change that each of #1049, #1050, #1083, #1085, #1088 and #1102 asks
for. Issues #1043 and #1046 wait on alimanfoo/dreamcatcher#917 and #894, which
are both still open. No open issue concerns only a skill the plugin no longer
has: #686 names `solo`, an earlier name of `dream:less`, but asks for a skill
for every pull request comment. No open issue asks for behaviour that a story
excludes. Issue #1102 has no triage outcome yet.

### Reviewed changes

The window is the pull requests merged since `v47.0.0`, in order of merge: pull
requests #1104, #1105, #1106 and #1107. No commit reached main without a merge.
Each of the 4 says what it changes and why, links the issue it closes or relates
to, or, for #1104, the release pull request it follows, and answers all eleven
definition-of-done questions by title under a "Definition of done" heading. The
answers in #1107 each open with "Yes", and its Explained answer is only "Yes,
above."; the standard says that "Yes" alone is not an answer. The measure counts
an answer that is present, and the other answers in #1107 give their evidence.

### Rules not cases

The ledger has 3 entries, unchanged since 47.0.0 except that #1106 renamed
`spec-files.md` in one. Each is caused by a difference between the agent
harnesses, and each still matches the plugin. At `f277a9f6` the `commitTrailer`
entry named `dream:smith` and `dream:less` as its readers, which since #1107
read the trailer through `assignment-session-rules.md`. The release's
consistency review found this, and the release branch corrects the entry to name
that file. The guide to agent mechanics is not searched for special cases,
because the agent harnesses are its subject. Two special cases elsewhere in the
plugin are not on the ledger:

- `assignment-session-rules.md`, which `dream:smith` and `dream:less` share, and
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` name
  `AskUserQuestion`, a Claude Code tool, to say how not to ask the user a
  question. Under Codex the name refers to nothing.
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`. Triage of #1085 decided to remove dispatch from the
  skill.

The changes since 47.0.0 add no special case. `assignment-banner.md` reads the
version from `.codex-plugin/plugin.json`, which is the manifest under both agent
harnesses, so it does not differ between them.

### Few concepts

The concepts page has 27 entries. Three commits since `v47.0.0` change it, all
from #1105, which rewrote the "Design specification" entry. No entry was added.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, Find simplification opportunities and Collect. They
also state that `dream:less` runs its code review without subagents, and, since
pull request #1107, that it follows a short summary of the engineering
principles rather than loading the coherent coding guide.

- **`dream:smith` and `dream:less`.** Steps 1 to 10 have the same names in both,
  and each points to the same `assignment-*.md` file, except step 3, Engineering
  principles, whose difference less's story states. Five later steps do the same
  thing in both and are written out in each: Implement, smith's Review and
  less's Code review, Write the PR description, Mark the PR ready for review,
  and Handle what the user posts. The two steps that 47.0.0 found in only one
  skill are gone: less's "Don't over-build" is part of its Engineering
  principles, and less now posts the session input as the first comment on its
  pull request. Corresponding names still differ in one place, smith's "Review"
  and less's "Code review".
- **`dream:code-review` and `dream:coherence-review`.** Unchanged since 47.0.0.
  The step headings match. Arguments, Read the diff, Launch the lenses, Combine
  and verify, and Rank and output are written out in both.
- **The two agent harnesses.** Each launch step and `subagent-waiting.md` give
  both agent harnesses corresponding instructions. `claude-code.md` and
  `codex.md` are unchanged since 46.5.0, and each adds to a heading of
  `SKILL.md` only what is specific to its agent harness, so a missing heading is
  not a missing step.

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
  Read every file in the plugin whole, largest first. For the pairs, compare
  their step headings, without the step numbers or the headings inside fenced
  examples, and then their text step by step:

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
  cd plugins/dream && for f in agent-written-marks.json assignment-banner.md assignment-change-types.md assignment-cited-material-and-code.md assignment-orientation.md assignment-session-input.md assignment-session-pr.md assignment-session-rules.md assignment-tests-and-checks.md assignment-working-tree.md branch-bases.md coherent-coding.md github-text.md specification-files.md subagent-waiting.md code-review-lens.md precedent-reviewer.md claude-code.md codex.md; do echo "$f: $(grep -rl --include='*.md' "$f" skills agents *.md | grep -v "$f\$" | tr '\n' ' ')"; done
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
