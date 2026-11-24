# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-24 for the 47.0.0 release. The plugin and the documentation
were read on the release branch, which starts from `ba0bf8bd`. Its working tree
differed from that commit in the version in the manifest, the new changelog
section, and the fixes from the release's consistency review, which change
`AGENTS.md` and the stories but not the plugin. Each measure is compared with
the measurement for the last release, 46.5.0, tagged `v46.5.0`, whose figures
are given in brackets.

## Results

| Criterion             | Measured                                                                                                        | Status  |
| --------------------- | --------------------------------------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 24 files without a one-sentence purpose (0 of 25)                                                          | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 4 referrers (unchanged)                                    | met     |
| One fact, one home    | 35 rules or facts stated in more than one file (35)                                                             | not met |
| Size                  | 4,331 lines in the plugin (4,566), a change of −235                                                             | no bar  |
| One vocabulary        | 109 uses on 108 lines of the plugin, 4 lines of the documentation, 3 open issues use retired terms (110, 5, 18) | not met |
| True documents        | 0 statements that the plugin contradicts, after the consistency review fixed 3 (1)                              | met     |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page (0, 0)                                                         | met     |
| Versioned contract    | The compatibility page states all three; 47.0.0 is a major release, as removing a skill requires                | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce (0)                                             | met     |
| No suppressions       | 0 markers (0)                                                                                                   | met     |
| Current tracker       | 3 of 15 open issues out of date (24 of 74)                                                                      | not met |
| Reviewed changes      | 11 of 11 pull requests answer every definition-of-done question (2 of 2)                                        | met     |
| Rules not cases       | 2 special cases not on the ledger; 0 ledger entries with an internal cause (3; 0)                               | not met |
| Few concepts          | 0 concepts added since 46.5.0 (0)                                                                               | met     |
| Symmetry              | 23 unshared or unmatched steps across the three pairs (23)                                                      | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 35 rules or facts are stated in more than one skill,
   subagent file or shared file, as at 46.5.0. The list is under
   [One fact, one home](#one-fact-one-home) below. #1083 covers the marks, the
   rules common to the skills in the user's voice, and the restatements of the
   coherent coding guide, 11 in all. #1086 covers 9 of the 16 steps written out
   in both `dream:smith` and `dream:less`, and #1091 the other 7, with the rules
   shared by `dream:code-review` and `dream:coherence-review`. #1102, filed by
   this release, covers the copies of the review rules in
   `dream:precedent-review` and `dream:quest`, the report rules of the two
   subagent files, and the reason for an absolute path in `dream:trace` and
   `dream:weave`.
2. **One vocabulary.** Retired terms name their concepts in 108 lines of the
   plugin and 4 of the documentation: "requirements brief" and "brief", "design"
   for a design specification, "plan" for a roadmap, "task" for an
   implementation step, "session type", "issue type" and "category" for a change
   type, "child" for a sub-issue, and "spec" for a specification. #1082 covers
   the plugin and the documentation. The 3 open issues that use a retired term
   were edited by step 4 of the checklist, the issue sweep, except a quotation
   in the user's own comment on #930.
3. **Current tracker.** 3 of the 15 open issues used a retired term, all in
   comments. The issue sweep edited the agent-written comments; the remaining
   use is in the user's own comment on #930.
4. **Rules not cases.** Two special cases are not on the ledger: the
   `AskUserQuestion` tool named in six skills, and `dream:sift`'s condition on
   `dreamcatcher.toml`. #1085 covers both.
5. **Symmetry.** `dream:smith` and `dream:less` write out 16 shared steps in
   each file, and each has one step the other lacks without a story to say why.
   `dream:code-review` and `dream:coherence-review` write out 5 shared steps in
   each file. #1086 covers 9 of the 16 smith and less steps, and #1091 the other
   7, the two unmatched steps, the 5 review steps and the step names.

## Notes

### Single responsibility and Size

Every file in the plugin was read whole, in descending order of size. Each has
one purpose, stated in the table. `dream:smith` and `dream:big` are long, but
each is one procedure. The change is from the same commands run on a copy of the
plugin at `v46.5.0`, which reproduce that measurement's 4,566 lines.
`git diff --shortstat v46.5.0 HEAD -- plugins/dream` reports 17 files changed,
39 insertions and 274 deletions, a net change of −235.

| File                                | Lines | Change | Purpose                                                                                 |
| ----------------------------------- | ----: | -----: | --------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files) |   986 |      0 | Explains how a coding agent works under Claude Code and Codex.                          |
| `skills/smith/`                     |   371 |      0 | Carries a well-specified issue to a planned, reviewed pull request.                     |
| `coherent-coding.md`                |   359 |      0 | States the coherent coding guide.                                                       |
| `skills/spark/`                     |   329 |      0 | Interviews the user and writes a requirements specification.                            |
| `skills/weave/`                     |   299 |      0 | Works out a design with the user and writes a design specification.                     |
| `skills/big/`                       |   288 |     −1 | Leads a dreamcatcher campaign through its stages to merge.                              |
| `skills/trace/`                     |   258 |      0 | Tours the code with the user and writes a checked reading guide.                        |
| `skills/quest/`                     |   250 |      0 | Breaks a design into a roadmap of stages, and its sub-issues.                           |
| `skills/sift/`                      |   228 |      0 | Triages issues with the user, one decision at a time.                                   |
| `skills/less/`                      |   222 |      0 | Carries an easy change to a pull request with one inline review.                        |
| `skills/plan/`                      |   116 |      0 | Writes an implementation plan.                                                          |
| `agents/precedent-reviewer.md`      |   102 |      0 | Reviews a change against the user's past review comments.                               |
| `skills/coherence-review/`          |    98 |      0 | Reviews a change for coherence through lenses drawn from the guide.                     |
| `skills/code-review/`               |    89 |      0 | Reviews a change through lenses chosen for the diff.                                    |
| `skills/precedent-review/`          |    71 |      0 | Launches the precedent reviewer and verifies its findings.                              |
| `skills/scout/`                     |    59 |      0 | Answers the user's questions on an issue from the code.                                 |
| `spec-files.md`                     |    55 |      0 | Says where a specification file goes and how it reaches a pull request.                 |
| `agents/code-review-lens.md`        |    50 |      0 | Reviews a diff through one lens.                                                        |
| `subagent-waiting.md`               |    26 |      0 | Says how to wait for launched subagents under each agent harness.                       |
| `skills/coherent-coding/`           |    25 |      0 | Loads the coherent coding guide.                                                        |
| `.codex-plugin/plugin.json`         |    17 |      0 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice. |
| `github-text.md`                    |    15 |     +3 | Says how to lay out text that GitHub renders, and how to pass it to `gh`.               |
| `branch-bases.md`                   |    11 |      0 | Says how to find the default branch and the review base.                                |
| `agent-written-marks.json`          |     7 |      0 | Holds the comment footer and the commit trailers.                                       |
| `skills/plain-english/` (removed)   |     0 |   −237 | Removed by #1095.                                                                       |
| **Plugin total**                    | 4,331 |   −235 |                                                                                         |

A zero change can hide edits that add and remove the same number of lines:
`dream:smith`, `dream:sift` and the descriptions of most skills changed without
changing their length.

### No orphaned files

Apart from the 15 `SKILL.md` files and the manifest, the plugin holds 10 files.
Each is referenced by path or link: `agent-written-marks.json` from 9 files,
`branch-bases.md` from 5, `coherent-coding.md` from 4, `github-text.md` from 10,
`spec-files.md` from 4, `subagent-waiting.md` from 7,
`agents/code-review-lens.md` from 2 skills, `agents/precedent-reviewer.md` from
`dream:precedent-review`, and `claude-code.md` and `codex.md` from
`dream:agent-mechanics`. The counts are those of 46.5.0, less the removed
`plain-english.md`.

### One fact, one home

A rule counts once however many files repeat it. A one-line summary beside a
link to the rule's home counts as a reference, not a copy; that is how most
skills point to `github-text.md`. Each of the 35 rules and facts that 46.5.0
listed was checked again in the files as they now stand, and each is still
stated in the same files. The changes since 46.5.0 add no copy: the rule about
passing a multi-line body to `gh` is stated only in `github-text.md`, and the
command that `dream:smith` showed for it is removed. The closing "Use only when
explicitly invoked." that #1100 gave every skill's description is frontmatter
that each skill needs for itself, and is not counted. The 35:

- **`dream:smith` and `dream:less`, 16.** Print the banner, Autonomy,
  Communication style, Turn output, Mark your work, Find the tests and checks,
  Check the working tree, Obtain session input, reading the cited issues with
  their sub-issues and parent, Name the session type, Open the session PR,
  Interrupted work, the opening paragraph of Implement, the issue list in Write
  the PR description, Mark the PR ready for review, and Handle what the user
  posts. `dream:sift` restates the change-type labels a third time. #1086 covers
  the 9 that its decision names: Print the banner, Autonomy, Communication
  style, Turn output, Mark your work, Check the working tree, Name the session
  type, Interrupted work, and Mark the PR ready for review. #1091 covers the
  other 7.
- **The review skills, 6.** The default target, Read the diff, keeping only the
  findings the code confirms, and Rank and output, in `dream:code-review`,
  `dream:coherence-review` and `dream:precedent-review`. How to launch a
  subagent file under Codex, in the same three. That subagents inherit the
  session's model and effort, in those three and `dream:quest`. #1091 covers the
  copies in `dream:code-review` and `dream:coherence-review`. #689 and #791,
  which 46.5.0 cited, are closed as not planned.
- **The marks, 2.** How to apply the comment footer, as a closing blockquote so
  that a reader can tell an agent wrote it, in 8 skills and `spec-files.md`. How
  to apply the commit trailer, in `dream:smith`, `dream:less` and
  `spec-files.md`. #1083 covers both.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", in `dream:trace` and `dream:weave`. #770, which 46.5.0 cited, is
  closed.
- **The skills in the user's voice, 7.** One thing per turn, with no recap;
  plain words, no headings or lists in a turn, and no `AskUserQuestion`; no
  flattery; how to start from the seed; that documents drift, so their claims
  are checked in the code; the two fresh readers, launched together and waited
  for together; and Where it goes. Each appears in two to four of `dream:spark`,
  `dream:trace`, `dream:weave` and `dream:quest`. #1083 covers them.
- **The coherent coding guide, 2.** `dream:less` restates "Resolve the root
  cause" and "The burden of proof is on the addition" in its Coherence and Don't
  over-build steps. `dream:sift`'s Judgments restate several of the guide's
  rules, although sift loads the guide. #1083 covers both.

### One vocabulary

Each line was found by the searches under [Method](#method), then read to judge
whether the term names the concept that retires it. A line is counted once per
term, so line 58 of `dream:quest`, which has both "requirements brief" and
"design", counts twice: 109 uses on 108 lines. At 46.5.0 the same count by term
gave 110. The line numbers are those at `ba0bf8bd`.

- "requirements brief" or "brief", 21: `dream:spark` lines 15, 63, 64, 94, 187,
  216, 225, 231, 237, 274, 275, 277, 298, 299, 309 and 320; `dream:trace` 109
  and 110; `dream:weave` 72 and 73; `dream:quest` 58. #1100 removed the one in
  spark's description. "brief" as an adjective, "Brief" as a verb, and "each
  brief" for a step of `dream:plan` are not counted.
- "design" for a design specification, 19: `dream:weave` 18, 220, 256, 257, 262,
  278 and 282; `dream:quest` 6 (the `argument-hint`), 11, 56, 58, 64, 66, 82,
  87, 187, 193 and 201; `dream:big` 77. "design" for the design being worked
  out, as in "the design touches", "a design decision" or "reaches a design
  together", is not counted.
- "plan" for a roadmap, 16: `dream:big` 11, 18, 41, 69, 74, 81, 82, 106, 152,
  161, 163, 185, 213, 214, 242 and 244. Line 242, "a question about the plan
  itself", was added by #1099.
- "task" for an implementation step, 33: `dream:plan` 11, 14, 15, 30, 32, 35,
  37, 55, 60, 62, 67, 69, 73, 77, 78, 80, 82, 83, 85, 86, 89, 90, 92, 93, 95,
  97, 98, 99, 103, 104, 106, 109 and 110. #1100 removed the one in plan's
  description. "task" in the descriptions of `dream:smith` and `dream:trace`, in
  its TODO-list sense in `dream:smith`, and for a subagent's task is not an
  implementation step.
- "session type", "issue type" and "category" for a change type, 11:
  `dream:smith` 151, 153, 185, 187, 364 and 366; `dream:less` 125, 127, 153 and
  155; `dream:sift` 94.
- "child" for a sub-issue, 4: `dream:quest` 231, 235, 240 and 241. `children` in
  `dream:big` is the name of a field in dreamcatcher's input, and is not
  counted.
- "spec" for a specification, 5: the title of `spec-files.md`, and the link text
  "spec files" in `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest`.
  "the spec" in `coherent-coding.md`'s "Generate the client from the spec" is an
  API specification, and is not counted.

In the documentation, 4 lines: the `dream:spark` row of the home page
("requirements brief"), the `dream:quest` row ("a design"), the `dream:plan` row
("a commit per task"), and "4 tasks" in the sample session in
`overrides/home.html`. #1099 rewrote the `dream:big` row, which removed
"campaign plan". "Host" appears only as the example in `releasing.md` and as
"permission host" in `claude-code.md`, which is a different concept.

3 open issues use a retired term for its concept, in text other than a quotation
of the plugin: #930 ("generate code from the design" in its first comment, and
"the dreamcatcher campaigns design" for a `design.md` in its second), #1043 ("a
settled, green child's pull request" in its decision comment), and #1050 ("The
brief's headings become" and "keep the brief short" in its decision comment). A
retired term in a quoted step name, such as "Name the session type" in #1086, or
named as a term, as throughout #1082, is not counted.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin.
At `ba0bf8bd`, the plugin contradicted 3 statements, which the release's
consistency review found. Each was checked against the plugin, and the release
branch corrects each:

- `AGENTS.md`, "Design rationale", said that `dream:smith`'s Collect step has
  the agent file "an issue for each piece of work it left out of scope". Collect
  caps maintenance issues at two. #1094 introduced the wording.
- The stories' campaign step 9 said that the lead merges a stage "once its
  checks pass". `dream:big`'s "Merge a stage" requires only the checks that the
  repository requires to pass, and lets an `UNSTABLE` stage merge with failing
  checks that have no bearing on it.
- The stories' campaign step 10 said that the lead "holds back" the stages an
  open question bears on. `dream:big` only declines to merge them, and lets
  stages in progress carry on. #1099 introduced the wording.

With those fixes, none disagrees. The disagreement that 46.5.0 found is
resolved: #1100 put every skill's frontmatter `description` in the third person,
as `AGENTS.md` says, and #1095 removed `dream:plain-english`, the last skill
with an imperative description. The home page and the stories no longer describe
`dream:plain-english` (#1095). Every other rule in `AGENTS.md`, which #1094
rewrote, that describes the plugin holds, such as the shared files at the
plugin's root, the two kinds of skill and the title heading that
`scripts/validate_skill.py` checks.

The sample session in `overrides/home.html` omits the Session input and
Simplification opportunities comments that `dream:smith` posts. It shows a
selection of steps, so it is not counted.

### Docs by purpose

The navigation in `mkdocs.yml` is unchanged since 46.5.0. It puts the home page
alone, the compatibility page and the changelog under Reference, and the
concepts, stories, standard, measurement, release checklist, ledger and
agent-mechanics sources under Development. The home page links only to
dreamcatcher's site and the issue tracker, the compatibility page only to
dreamcatcher's site, the changelog, with this release's section, only to the
compatibility page, the home page and pull requests, and the README only to the
site.

### Versioned contract

The compatibility page, unchanged since 46.5.0, states the interface under "The
interface", the rules for a major, minor and patch release under "Versions", and
version 1 of dreamcatcher's agent contract under "dreamcatcher's contract". The
comparison of skill names from step 1 of the checklist prints one line,
`name: plain-english`, the skill that #1095 removed. Removing a skill calls for
a major increment, and 46.5.0 to 47.0.0 is one. At `ba0bf8bd`, the manifest is
as at `v46.5.0`, and `.claude-plugin/marketplace.json` differs only in the
plugin's source, which #1089 pinned to the commit tagged `v46.5.0`. Neither is a
change to the interface.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows. Since 46.5.0, #1090 narrowed the Markdown
hooks' exclusion to the generated skill files, and #1098 made
`scripts/validate_skill.py` require a non-empty `description`. Among the pull
requests since 46.5.0, review missed One vocabulary once: #1099 added "plan" for
a roadmap to `dream:big`, and its Concepts' words answer says it adds no retired
term. "plan" has other senses, so no small check could find it without false
positives. Review missed True documents twice, in #1094 and #1099, as listed
under [True documents](#true-documents), but whether a statement agrees with the
plugin takes a reading, not a small check. No other rule was missed more than
once. The multi-word retired terms are still in the plugin, so the condition
that 46.5.0 set for a check on them, that they come back after removal, has not
arisen.

### Current tracker

All 15 open issues were read with their comments, and each claim that work is
done was checked against the plugin. 46.5.0 counted 74 open issues. 3 issues
count, each for a retired term: issues #930, #1043 and #1050, listed under
[One vocabulary](#one-vocabulary).

No open issue asks for work already done. #1042 is half done, as its decision
comment says, and the half it leaves, a turn-output rule for `dream:big`, is
not. #930, #1049, #1050, #1082, #1083, #1085, #1086 and #1088 each ask for a
change that the plugin does not yet have. No open issue concerns only a skill
the plugin no longer has: #686 names `solo`, an earlier name of `dream:less`,
but asks for a skill for every pull request comment, and #1042 names the removed
Plain English guide but asks for a change to `dream:big`. No open issue asks for
behaviour that a story excludes.

### Reviewed changes

The window is the pull requests merged since `v46.5.0`, in order of merge: pull
requests #1089, #1090, #1093, #1094, #1096, #1095, #1101, #1098, #1097, #1100
and #1099. Dependabot's #1077 and #1078, which reached main as single commits,
are excluded. Each of the 11 says what it changes and why, links the issue it
closes or relates to, or says that none relates to it (#1090), and answers all
eleven definition-of-done questions by title under a "Definition of done"
heading. The measure counts an answer that is present; an answer can still be
wrong, as #1099's Concepts' words answer is (see
[Machine-checked rules](#machine-checked-rules)).

### Rules not cases

The ledger has 3 entries, unchanged since 46.5.0, each caused by a difference
between the agent harnesses, and each still matches the plugin. The guide to
agent mechanics is not searched for special cases, because the agent harnesses
are its subject. Two special cases elsewhere in the plugin are not on the
ledger:

- `dream:smith`, `dream:less`, `dream:spark`, `dream:trace`, `dream:weave` and
  `dream:quest` name `AskUserQuestion`, a Claude Code tool, to say how not to
  ask the user a question. Under Codex the name refers to nothing.
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`. Triage of #1085 decided to remove dispatch from the
  skill.

  46.5.0 also counted `dream:code-review`'s `inline` mode. Triage of #1085
  decided that it is an option of the skill, which any user can pass and its
  `argument-hint` lists, and so not a special case. The plugin's text is
  unchanged; the count falls from 3 to 2 by that decision alone. The changes
  since 46.5.0 add no special case: `dream:big`'s new rule for an open question
  applies to every stage.

### Few concepts

The concepts page has 27 entries. No commit since `v46.5.0` changes it, so no
concept was added.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, Find simplification opportunities and Collect. They
also state that `dream:less` runs its code review without subagents. The step
headings of both pairs are as at 46.5.0, and so are the counts.

- **`dream:smith` and `dream:less`.** 16 steps that do the same thing are
  written out in both, as listed under [One fact, one home](#one-fact-one-home).
  No story states two differences: `dream:less` has a "Don't over-build" step,
  and `dream:smith` posts the session input as the first comment on its pull
  request. The names also differ where the steps correspond: `dream:smith`'s
  "Read the cited material", "Read the code" and "Check the session input
  against the current code" are `dream:less`'s "Read the cited material and the
  code", and "Review" is "Code review". Both have a step named "Coherence":
  `dream:smith`'s loads the guide, and `dream:less`'s states two of its rules.
- **`dream:code-review` and `dream:coherence-review`.** The step headings match.
  Arguments, Read the diff, Launch the lenses, Combine and verify, and Rank and
  output are written out in both.
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
  their step headings, and then their text step by step:

  ```bash
  diff <(grep '^## ' plugins/dream/skills/smith/SKILL.md) <(grep '^## ' plugins/dream/skills/less/SKILL.md)
  diff <(grep '^## ' plugins/dream/skills/code-review/SKILL.md) <(grep '^## ' plugins/dream/skills/coherence-review/SKILL.md)
  ```

  To find text that applies under one agent harness, search outside the guide to
  agent mechanics:

  ```bash
  grep -rn -i -e 'claude code' -e 'codex' -e 'AskUserQuestion' -e 'harness' plugins/dream | grep -v '^plugins/dream/skills/agent-mechanics/'
  ```

- **No orphaned files.** For each file that is not an entry point, list the
  files that name it:

  ```bash
  cd plugins/dream && for f in agent-written-marks.json branch-bases.md coherent-coding.md github-text.md spec-files.md subagent-waiting.md code-review-lens.md precedent-reviewer.md claude-code.md codex.md; do echo "$f: $(grep -rl --include='*.md' "$f" skills agents *.md | grep -v "$f\$" | tr '\n' ' ')"; done
  ```

  Compare the loop's list with `find plugins/dream -type f`, so that a file
  added since the last measurement joins it.

- **One vocabulary.** Search for each retired term on the concepts page's
  "Replaces:" lines, then read each hit. "design", "plan" and "task" have other
  senses, so search for them as whole words and judge each line:

  ```bash
  rg -niP '\bhosts?\b|agent prompt|named agent|\bchild(ren)?\b|\bspecs?\b|requirements brief|\bbriefs?\b|campaign plan|issue type|session type|\bcategor' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md' -g '!docs/assets/**'
  rg -niw 'design|plans?|tasks?' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md' -g '!docs/assets/**'
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
