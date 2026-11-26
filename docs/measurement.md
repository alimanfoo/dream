# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-26 for the 47.3.0 release. The plugin and the documentation
were read on the release branch, which starts from `77bab1ed`, and whose working
tree differed from that commit only in the version in the manifest and the new
changelog section. True documents records what this reading found at `77bab1ed`,
before any fix from the release's consistency review. Each measure is compared
with the measurement for the last release, 47.2.0, tagged `v47.2.0`, whose
figures are given in brackets.

## Results

| Criterion             | Measured                                                                                                   | Status  |
| --------------------- | ---------------------------------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 25 files without a one-sentence purpose (0 of 25)                                                     | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 2 referring skills (at least 2)                       | met     |
| One fact, one home    | 35 rules or facts stated in more than one file (32)                                                        | not met |
| Size                  | 4,172 lines in the plugin (4,211), a change of −39                                                         | no bar  |
| One vocabulary        | 0 uses in the plugin, 0 in the documentation, 0 open issues use retired terms (0, 0, 0)                    | met     |
| True documents        | 0 statements that the plugin contradicts, at `77bab1ed` (0)                                                | met     |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page (0, 0)                                                    | met     |
| Versioned contract    | The compatibility page states all three; 47.3.0 is a minor release, as a change to what skills do requires | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce (0)                                        | met     |
| No suppressions       | 0 markers (0)                                                                                              | met     |
| Current tracker       | 0 of 9 open issues out of date (0 of 13)                                                                   | met     |
| Reviewed changes      | 4 of 4 pull requests answer every definition-of-done question (2 of 2)                                     | met     |
| Rules not cases       | 2 special cases not on the ledger; 0 ledger entries with an internal cause (2; 0)                          | not met |
| Few concepts          | 0 concepts added since 47.2.0 (0)                                                                          | met     |
| Symmetry              | 10 unshared or unmatched steps across the three pairs (10)                                                 | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 35 rules or facts are stated in more than one skill,
   subagent file or shared file. The list is under
   [One fact, one home](#one-fact-one-home) below. Issue #1091 covers the four
   steps still written out in both `dream:smith` and `dream:less` whose
   differences it asks about, Implement, Review, Write the PR description and
   Handle user posts, and the copies in `dream:code-review` and
   `dream:coherence-review`. Issue #1102 covers the persona paragraph and Mark
   the PR ready for review in `dream:smith` and `dream:less`, the change-type
   labels, checking an issue's claims against the current code, drafts in a
   temporary file, the copies of the review rules in `dream:precedent-review`
   and `dream:quest`, the report rules of the two subagent files, and the reason
   for an absolute path in `dream:trace` and `dream:weave`. Issue #1083 covers
   the marks, the 13 rules common to the skills in the user's voice, and
   `dream:sift`'s restatements of the coherent coding guide. No open issue
   covered the turn-output rule that pull request #1114 wrote into `dream:big`,
   which `assignment-boot.md` also states, so this release added it to #1102:
   the decision on #1042 chose to write it in `dream:big` rather than reference
   the assignment skills' boot sequence, so a shared home has to fit both kinds
   of skill. No issue is filed for `dream:less`'s summary of the engineering
   principles: the decision on #1083 keeps it as a deliberate stand-in for the
   guide, as less's story states, under "Weigh a measurement finding against the
   skill's purpose" in `AGENTS.md`.
2. **Rules not cases.** Two special cases are not on the ledger: the
   `AskUserQuestion` tool, named in `assignment-boot.md` and four skills, and
   `dream:sift`'s condition on `dreamcatcher.toml`. Issue #1085 covers both.
3. **Symmetry.** `dream:smith` and `dream:less` write out 5 steps in each file
   that do the same thing in both, and `dream:code-review` and
   `dream:coherence-review` write out 5. Issue #1091 covers Implement, smith's
   Review and less's Code review, whose names also differ, Write the PR
   description, Handle user posts, and the 5 steps of the review pair. Issue
   #1102 covers Mark the PR ready for review.

## Notes

### Single responsibility and Size

`git diff --stat v47.2.0 HEAD -- plugins/dream` shows that three pull requests
changed the plugin. Pull request #1114 added a three-line turn-output rule to
`dream:big`'s "Write to the user". Pull request #1115 focused `dream:trace`'s
big picture and itinerary on the code that the change touches or depends on.
Pull request #1116 reworked `dream:spark`: its staged checklist became one
paragraph, "What I'd like us to work out"; its example questions went from nine
to four, written as prose; the plain-and-simple rule, the thinking examples and
the rule that undid their repetition were removed; and the specification's
template went from six headings to four. Those three files were read whole, and
each keeps its one purpose. Every other file is unchanged since `v47.2.0`, and
its 47.2.0 finding was confirmed and carried forward. `dream:smith` and
`dream:big` are long, but each is one procedure.

The change is from the same commands run on a copy of the plugin at `v47.2.0`,
which reproduce that measurement's 4,211 lines.
`git diff --shortstat v47.2.0 HEAD -- plugins/dream` reports 3 files changed, 89
insertions and 128 deletions, a net change of −39. `dream:spark` falls from 329
lines to 286, below `dream:big`.

| File                                | Lines | Change | Purpose                                                                                 |
| ----------------------------------- | ----: | -----: | --------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files) |   986 |      0 | Explains how a coding agent works under Claude Code and Codex.                          |
| `coherent-coding.md`                |   359 |      0 | States the coherent coding guide.                                                       |
| `skills/weave/`                     |   326 |      0 | Works out a solution with the user in design models, and writes a design specification. |
| `skills/big/`                       |   292 |     +3 | Leads a dreamcatcher campaign through its stages to merge.                              |
| `skills/spark/`                     |   286 |    −43 | Talks an idea through with the user and writes a requirements specification.            |
| `skills/trace/`                     |   259 |     +1 | Tours the code relevant to a change with the user, and writes a checked reading guide.  |
| `skills/quest/`                     |   256 |      0 | Breaks a design specification into a roadmap of stages, and its sub-issues.             |
| `skills/sift/`                      |   228 |      0 | Triages issues with the user, one decision at a time.                                   |
| `skills/smith/`                     |   188 |      0 | Carries a well-specified issue to a planned, reviewed pull request.                     |
| `assignment-boot.md`                |   172 |      0 | States the boot sequence that `dream:smith` and `dream:less` run before their own work. |
| `skills/plan/`                      |   116 |      0 | Writes an implementation plan.                                                          |
| `agents/precedent-reviewer.md`      |   102 |      0 | Reviews a change against the user's past review comments.                               |
| `skills/coherence-review/`          |    98 |      0 | Reviews a change for coherence through lenses drawn from the guide.                     |
| `skills/code-review/`               |    89 |      0 | Reviews a change through lenses chosen for the diff.                                    |
| `skills/less/`                      |    79 |      0 | Carries an easy change to a pull request with one inline review.                        |
| `skills/precedent-review/`          |    71 |      0 | Launches the precedent reviewer and verifies its findings.                              |
| `skills/scout/`                     |    59 |      0 | Answers the user's questions on an issue from the code.                                 |
| `specification-files.md`            |    55 |      0 | Says where a specification file goes and how it reaches a pull request.                 |
| `agents/code-review-lens.md`        |    50 |      0 | Reviews a diff through one lens.                                                        |
| `subagent-waiting.md`               |    26 |      0 | Says how to wait for launched subagents under each agent harness.                       |
| `skills/coherent-coding/`           |    25 |      0 | Loads the coherent coding guide.                                                        |
| `.codex-plugin/plugin.json`         |    17 |      0 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice. |
| `github-text.md`                    |    15 |      0 | Says how to lay out text that GitHub renders, and how to pass it to `gh`.               |
| `branch-bases.md`                   |    11 |      0 | Says how to find the default branch and the review base.                                |
| `agent-written-marks.json`          |     7 |      0 | Holds the comment footer and the commit trailers.                                       |
| **Plugin total**                    | 4,172 |    −39 |                                                                                         |

### No orphaned files

Apart from the 15 `SKILL.md` files and the manifest, the plugin holds 11 files,
the same 11 as at 47.2.0. Each is referenced by path or link. Counting only
skills and subagent files, `agent-written-marks.json` is referenced from 6
skills, `branch-bases.md` from 5, `coherent-coding.md` from 4, `github-text.md`
from 7, `specification-files.md` from 4, `subagent-waiting.md` from 7,
`assignment-boot.md` from `dream:smith` and `dream:less`,
`agents/code-review-lens.md` from 2 skills, `agents/precedent-reviewer.md` from
`dream:precedent-review`, and `claude-code.md` and `codex.md` from
`dream:agent-mechanics`. `dream:smith` and `dream:less` reach
`agent-written-marks.json`, `github-text.md` and the default branch through
`assignment-boot.md`. The fewest referring skills for a shared file is 2, the
bar's minimum, for `assignment-boot.md`.

### One fact, one home

A rule counts once however many files repeat it. A one-line summary beside a
link to the rule's home counts as a reference, not a copy; that is how most
skills point to `github-text.md`, and how step 1 of `dream:smith` and
`dream:less` points to `assignment-boot.md`. The closing "Use only when
explicitly invoked." in every skill's description is frontmatter that each skill
needs for itself, and is not counted.

The groups that touch only unchanged files are carried forward from 47.2.0,
after a check that the changed files leave each as it was. The groups that touch
`dream:big`, `dream:spark` or `dream:trace` were counted afresh from the files
at `77bab1ed`. Pull request #1114 added one rule, the turn-output rule in
`dream:big`. Pull request #1116 removed none of the rules that 47.2.0 counted,
and the recount of the skills in the user's voice found two that were there at
47.2.0 but not counted. The 35:

- **`dream:smith` and `dream:less`, 6.** As at 47.2.0, since neither file has
  changed. Written out in both skills: the opening persona, "You are an
  autonomous software developer…" with "Follow the instructions below in
  order."; Implement's loop of running the tests, committing with a short
  subject and pushing at each step; the review base, the `origin/<base>...HEAD`
  target, and weighing each finding on its merits, in smith's Review and less's
  Code review; Write the PR description's contribution rules and its issue list;
  Mark the PR ready for review; and Handle user posts, apart from smith going on
  to Collect, which smith's story states. Issue #1091 covers Implement, Review,
  Write the PR description and Handle user posts, and #1102 the persona and Mark
  the PR ready for review.
- **Change-type labels, 1.** `assignment-boot.md`, in "I. Open the session PR",
  and `dream:sift` each list the labels `enhancement`, `maintenance` and `bug`.
  Issue #1102 covers it.
- **The review skills, 6.** As at 47.2.0, since none of the files has changed:
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
  trailer, in `assignment-boot.md` and `specification-files.md`. Issue #1083
  covers both.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer. Issue #1102 covers it.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", still in `dream:trace` and `dream:weave`. Issue #1102 covers it.
- **Turn output, 1.** New since 47.2.0. Pull request #1114 gave `dream:big`
  "Keep your turn output brief, usually one sentence per turn, because the user
  follows the parent issue and the stages' pull requests, not the session."
  "Turn output" in `assignment-boot.md` keeps turn output to usually one
  sentence per turn because the user interacts via GitHub. The decision on #1042
  asked for "the same turn-output rule, worded for the lead", written in
  `dream:big` itself rather than referenced from `assignment-boot.md`, which
  holds the boot sequence of the assignment skills. The two state one fact, so
  it counts. The release added it to #1102.
- **The skills in the user's voice, 13.** Recounted from `dream:spark`,
  `dream:trace`, `dream:weave` and `dream:quest` as they stand. The 11 that
  47.2.0 listed are each still in two to four of them: one thing per turn, with
  no recap; how to sound like a person, which is to talk as to someone whose
  idea or problem you find interesting, in plain words and the user's own words
  where they fit, with no headings or lists in a turn and no `AskUserQuestion`;
  no flattery; how to start from the seed; reading the documentation that
  governs the code, which drifts, so its claims are checked in the code; the two
  fresh readers, launched together and waited for together; Where it goes; think
  out loud; push back on the user; tell the user only what you have read in the
  code; and say when you use an analogy and where it stops holding. Pull request
  #1116 removed spark's "keep it plain and simple", so plain words are now in
  `dream:trace`, `dream:weave` and `dream:quest`, and spark keeps the rest of
  that group. It removed the examples from spark's Think out loud and the rule
  that undid their repetition, which only spark stated, and kept the rule, so
  think out loud is still in all four, as is push back. Two more were there at
  47.2.0 but not counted: the user can stop at any time, and "just write it up"
  is an answer, in `dream:spark` and `dream:trace`; and end every turn with a
  next move ready, so that "ok" is a complete answer, in `dream:trace` and
  `dream:weave`. Issue #1083 covers them, and its decision asks for the common
  rules to be counted afresh from the files as they stand.
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
- **Drafts in a temporary file, 1.** `dream:smith`'s Review, `dream:plan`,
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` each still write
  their draft to a temporary file outside the repo. Issue #1102 covers it.

### One vocabulary

The searches under [Method](#method) find no retired term that names its concept
in the plugin, the documentation or the open issues. A search for the multi-word
terms split across a line break finds none outside the changelog.

The remaining hits are the other senses that 47.2.0 found: "brief" as an
adjective or a verb, now also in the turn-output rule that #1114 added to
`dream:big` and in the 47.3.0 changelog section; `children` in `dream:big`, the
name of a field in dreamcatcher's input; the `specs/` folder in
`specification-files.md`; "the spec" for an API in `coherent-coding.md`; "child
process" in `codex.md`; "permission host" in `claude-code.md`; "task" for a
piece of work or a TODO item; "plan" for an implementation plan; and "design"
for the solution being worked out. The 47.1.0 section of the changelog names
"requirements brief", "campaign plan" and "session type" as the terms that #1106
replaced, which is not a use. In the open issues, the hits are "tasks" for
pieces of work and "design" for designing in #1048, smith's step Plan in #1091,
`dream:plan` in a comment on #1102, and `spec-files.md`, the earlier name of a
file, in the decision on #1083.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin at
`77bab1ed`. None is contradicted. Since `v47.2.0`, #1116 changed the concepts
page's "Requirements specification", spark's story and spark's row on the home
page, and #1115 changed trace's story and its row. Each agrees with the skill.
The concepts entry and step 5 of spark's story name the four parts that spark's
four headings hold, and step 5 says which documented requirements the idea
extends or changes, as "Write the specification" does. Step 2 reads the
repository's documented requirements before the seed, as "Learn what this repo
is for" does. Step 3's coverage, its order set by the conversation and its late
constraints follow "What I'd like us to work out". Steps 3 and 4 of trace's
story follow its "Give me the big picture first" and "Take me round, and cover
it all". No document describes `dream:big`'s turn output, which #1114 changed.

Two statements were weighed and not counted:

- Spark's story, its row on the home page and its own description say that it
  interviews the user. The skill now asks to talk the idea through "the way I
  would with a curious colleague over coffee", and #1116's description calls
  that "not an interview". The skill still asks one question per turn and
  follows threads from the answers, which is what the story's steps describe.
- Step 7 of trace's story says the guide has "a section for each component or
  mechanism". Trace's template still reads "one heading per thing worth
  understanding", the phrase its itinerary used before #1115. The itinerary is
  now the components and mechanisms the change touches or depends on, so the
  skill names the same sections two ways, and the story agrees with both.

The four statements that 47.2.0 weighed and did not count still stand as it
judged them, since neither those statements nor the files they concern have
changed: the smith and less stories' omission of the session input comment, the
compatibility page's "Each skill is one file that both read.", the sample
session in `overrides/home.html`, and saliency decay in `AGENTS.md`.

### Docs by purpose

The navigation in `mkdocs.yml`, the compatibility page and the README are
unchanged since 47.2.0. The home page changed only in the rows for `dream:spark`
and `dream:trace`, and the changelog gained the 47.3.0 section in the release's
working tree. The navigation puts the home page alone, the compatibility page
and the changelog under Reference, and the concepts, stories, standard,
measurement, release checklist, ledger and agent-mechanics sources under
Development. The home page links only to dreamcatcher's site and the issue
tracker, the compatibility page only to dreamcatcher's site, the changelog only
to the compatibility page, the home page and pull requests, and the README only
to the site.

### Versioned contract

The compatibility page, unchanged since 47.0.0, states the interface under "The
interface", the rules for a major, minor and patch release under "Versions", and
version 1 of dreamcatcher's agent contract under "dreamcatcher's contract". The
comparison of skill names from step 1 of the checklist prints nothing. At
`77bab1ed`, the manifest is as at `v47.2.0`, and
`.claude-plugin/marketplace.json` differs only in the entry's `sha`, which pull
request #1113 pinned to the commit tagged `v47.2.0`. Pull requests #1114, #1115
and #1116 change what `dream:big`, `dream:trace` and `dream:spark` do, which
calls for a minor increment, and none renames or removes a name in the
interface. 47.2.0 to 47.3.0 is a minor increment.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows, and neither they nor the scripts have
changed since 47.2.0. Among the pull requests since 47.2.0, no rule was missed
by review more than once.

### Current tracker

All 9 open issues were read with their comments, and each claim that work is
done was checked against the plugin. 47.2.0 counted 13 open issues, among them
issue #1110, which pull request #1111 closed as that release was made. Since
then, pull requests #1114, #1115 and #1116 closed issues #1042, #1049 and #1050,
and the decision on #1083 was edited to name pull requests #1115 and #1116 among
the work merged on its files, and to ask for the common rules to be counted
afresh. None of the 9 counts.

No open issue uses a retired term for its concept (see
[One vocabulary](#one-vocabulary)). No open issue asks only for work already
done. Issue #1091 is part done: its latest comment records what #1107 and #1111
settled, and it still asks about Implement, Code review, Write the PR
description, the shared text of Handle user posts, and the review pair. The
plugin does not yet have the change that each of #1083, #1085, #1088 and #1102
asks for. Issues #1043 and #1046 wait on alimanfoo/dreamcatcher#917 and
alimanfoo/dreamcatcher#894, which are both still open, and issues #1048 and #686
wait on discussion. No open issue concerns only a skill the plugin no longer
has: #686 names `solo`, an earlier name of `dream:less`, but asks for a skill
for every pull request comment. No open issue asks for behaviour that a story
excludes. Issue #1102 has no triage outcome yet.

The changes since `v47.2.0` made no issue or decision text stale. Issues #1043
and #1046 name `dream:big`, and issues #1048, #1083, #1085 and #1102 name
`dream:spark` or `dream:trace`. Each cites sections, rules and files that those
changes left as they were. The one decision that cites the changes, on #1083,
describes them correctly.

### Reviewed changes

The window is the pull requests merged since `v47.2.0`, in order of merge: pull
requests #1113, #1114, #1115 and #1116. No commit reached main without a merge.
Each says what it changes and why, links the issue it closes or, for #1113, the
release pull request it follows, and answers all eleven definition-of-done
questions by title under a "Definition of done" heading, each with its evidence.
Each Line count answer matches the merged change: 3 lines added for #1114, 11
added and 10 removed for #1115, and 75 added and 118 removed for #1116. Pull
request #1113 changes nothing in the plugin. The description of #1116 says that
a dreamcatcher assignment wrote the first version and that the pull request was
then taken over and reworked by hand. The Every copy changed answer of #1114
says that the assignment and campaign rules are tailored to their contexts; One
fact, one home counts them as one fact.

### Rules not cases

The ledger has 3 entries, unchanged since 47.2.0. Each entry is caused by a
difference between the agent harnesses, and each still matches the plugin. The
guide to agent mechanics is not searched for special cases, because the agent
harnesses are its subject. Two special cases elsewhere in the plugin are not on
the ledger:

- `assignment-boot.md`, which `dream:smith` and `dream:less` share, and
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` name
  `AskUserQuestion`, a Claude Code tool, to say how not to ask the user a
  question. Under Codex the name refers to nothing. Pull request #1116 kept
  spark's "Ask me in chat".
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`. Triage of #1085 decided to remove dispatch from the
  skill.

The changes since 47.2.0 add no special case. Spark's reading of documented
requirements, which applies when a repository keeps them, and `dream:big`'s
turn-output rule are general rules.

### Few concepts

The concepts page has 27 entries. Since `v47.2.0`, only #1116 changed it,
rewording "Requirements specification" to the specification's new shape. No
concept was added.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, Find simplification opportunities and Collect. They
also state that `dream:less` runs its code review without subagents, and that it
follows a short summary of the engineering principles rather than loading the
coherent coding guide. None of the files in the three pairs has changed since
`v47.2.0`, and the heading comparisons print what they printed then.

- **`dream:smith` and `dream:less`.** Steps 1 and 2 have the same names in both.
  Step 1, Boot, runs the shared `assignment-boot.md`. Step 2, Adopt the
  engineering principles, differs as less's story states. Five later steps do
  the same thing in both and are written out in each: Implement, smith's Review
  and less's Code review, Write the PR description, Mark the PR ready for
  review, and Handle user posts. Corresponding names still differ in one place,
  smith's "Review" and less's "Code review".
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
  cd plugins/dream && for f in agent-written-marks.json assignment-boot.md branch-bases.md coherent-coding.md github-text.md specification-files.md subagent-waiting.md code-review-lens.md precedent-reviewer.md claude-code.md codex.md; do echo "$f: $(grep -rl --include='*.md' "$f" skills agents *.md | grep -v "$f\$" | tr '\n' ' ')"; done
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
