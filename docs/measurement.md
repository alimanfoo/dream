# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-20 for the 46.5.0 release, the first release made by the
release checklist. The plugin and the documentation were read on the release
branch, which starts from `0e20e8cd`, with the fixes from the release's
consistency review applied. There is no earlier measurement and no earlier
release tag, so no measure has a baseline to compare against.

## Results

| Criterion             | Measured                                                                          | Status  |
| --------------------- | --------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 25 files without a one-sentence purpose                                      | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 4 referrers                  | met     |
| One fact, one home    | 35 rules or facts stated in more than one file                                    | not met |
| Size                  | 4,566 lines in the plugin; no baseline                                            | no bar  |
| One vocabulary        | 110 lines in the plugin, 5 in the documentation, 18 open issues use retired terms | not met |
| True documents        | 1 statement that the plugin contradicts                                           | not met |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page                                  | met     |
| Versioned contract    | The compatibility page states all three; no earlier release                       | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce                   | met     |
| No suppressions       | 0 markers                                                                         | met     |
| Current tracker       | 24 of 74 open issues out of date                                                  | not met |
| Reviewed changes      | 2 of 2 pull requests answer every definition-of-done question                     | met     |
| Rules not cases       | 3 special cases not on the ledger; 0 ledger entries with an internal cause        | not met |
| Few concepts          | 0 concepts added since the criterion came into force                              | met     |
| Symmetry              | 23 unshared or unmatched steps across the three pairs                             | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 35 rules or facts are stated in more than one skill,
   subagent file or shared file. The list is under
   [One fact, one home](#one-fact-one-home) below. #909, #791, #689 and #770
   cover some of them.
2. **One vocabulary.** Retired terms name their concepts in 110 lines of the
   plugin and 5 of the documentation: "requirements brief" and "brief", "design"
   for a design specification, "plan" for a roadmap, "task" for an
   implementation step, "session type", "issue type" and "category" for a change
   type, "child" for a sub-issue, and "spec" for a specification. The open
   issues that use one are left to the issue sweep.
3. **True documents.** `AGENTS.md` says to keep every skill's frontmatter
   `description` in the third person, but 13 of the 16 skills use the
   imperative.
4. **Current tracker.** 24 of the 74 open issues use a retired term, ask for
   work already done, or concern a skill the plugin no longer has. Step 4 of the
   checklist, the issue sweep, brings these to the bar.
5. **Rules not cases.** Three special cases are not on the ledger: the
   `AskUserQuestion` tool named in six skills, `dream:code-review`'s `inline`
   mode, and `dream:sift`'s condition on `dreamcatcher.toml`.
6. **Symmetry.** `dream:smith` and `dream:less` write out 16 shared steps in
   each file, and each has one step the other lacks without a story to say why.
   `dream:code-review` and `dream:coherence-review` write out 5 shared steps in
   each file.

## Notes

### Single responsibility and Size

Every file in the plugin was read whole, in descending order of size. Each has
one purpose, stated in the table. `dream:smith` and `dream:big` are long, but
each is one procedure.

| File                                | Lines | Purpose                                                                                 |
| ----------------------------------- | ----: | --------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files) |   986 | Explains how a coding agent works under Claude Code and Codex.                          |
| `skills/smith/`                     |   371 | Carries a well-specified issue to a planned, reviewed pull request.                     |
| `coherent-coding.md`                |   359 | States the coherent coding guide.                                                       |
| `skills/spark/`                     |   329 | Interviews the user and writes a requirements specification.                            |
| `skills/weave/`                     |   299 | Works out a design with the user and writes a design specification.                     |
| `skills/big/`                       |   289 | Leads a dreamcatcher campaign through its stages to merge.                              |
| `skills/trace/`                     |   258 | Tours the code with the user and writes a checked reading guide.                        |
| `skills/quest/`                     |   250 | Breaks a design into a roadmap of stages, and its sub-issues.                           |
| `skills/plain-english/` (2 files)   |   237 | Loads the Plain English guide.                                                          |
| `skills/sift/`                      |   228 | Triages issues with the user, one decision at a time.                                   |
| `skills/less/`                      |   222 | Carries an easy change to a pull request with one inline review.                        |
| `skills/plan/`                      |   116 | Writes an implementation plan.                                                          |
| `agents/precedent-reviewer.md`      |   102 | Reviews a change against the user's past review comments.                               |
| `skills/coherence-review/`          |    98 | Reviews a change for coherence through lenses drawn from the guide.                     |
| `skills/code-review/`               |    89 | Reviews a change through lenses chosen for the diff.                                    |
| `skills/precedent-review/`          |    71 | Launches the precedent reviewer and verifies its findings.                              |
| `skills/scout/`                     |    59 | Answers the user's questions on an issue from the code.                                 |
| `spec-files.md`                     |    55 | Says where a specification file goes and how it reaches a pull request.                 |
| `agents/code-review-lens.md`        |    50 | Reviews a diff through one lens.                                                        |
| `subagent-waiting.md`               |    26 | Says how to wait for launched subagents under each agent harness.                       |
| `skills/coherent-coding/`           |    25 | Loads the coherent coding guide.                                                        |
| `.codex-plugin/plugin.json`         |    17 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice. |
| `github-text.md`                    |    12 | Says how to lay out text that GitHub renders.                                           |
| `branch-bases.md`                   |    11 | Says how to find the default branch and the review base.                                |
| `agent-written-marks.json`          |     7 | Holds the comment footer and the commit trailers.                                       |
| **Plugin total**                    | 4,566 |                                                                                         |

There is no earlier release, so there is no change to report. The next
measurement reports each count's change from these.

### No orphaned files

Apart from the 16 `SKILL.md` files and the manifest, the plugin holds 11 files.
Each is referenced by path or link: `agent-written-marks.json` from 9 files,
`branch-bases.md` from 5, `coherent-coding.md` from 4, `github-text.md` from 10,
`spec-files.md` from 4, `subagent-waiting.md` from 7,
`agents/code-review-lens.md` from 2 skills, `agents/precedent-reviewer.md` from
`dream:precedent-review`, `claude-code.md` and `codex.md` from
`dream:agent-mechanics`, and `plain-english.md` from `dream:plain-english`.

### One fact, one home

A rule counts once however many files repeat it. A one-line summary beside a
link to the rule's home counts as a reference, not a copy; that is how most
skills point to `github-text.md`. The 35 rules and facts:

- **`dream:smith` and `dream:less`, 16.** Print the banner, Autonomy,
  Communication style, Turn output, Mark your work, Find the tests and checks,
  Check the working tree, Obtain session input, reading the cited issues with
  their sub-issues and parent, Name the session type, Open the session PR,
  Interrupted work, the opening paragraph of Implement, the issue list in Write
  the PR description, Mark the PR ready for review, and Handle what the user
  posts. `dream:sift` restates the change-type labels a third time. The
  consistency review for this release made the same three edits in both files,
  which is the cost of the copies. #909 covers the cited-material rule.
- **The review skills, 6.** The default target, Read the diff, keeping only the
  findings the code confirms, and Rank and output, in `dream:code-review`,
  `dream:coherence-review` and `dream:precedent-review`. How to launch a
  subagent file under Codex, in the same three. That subagents inherit the
  session's model and effort, in those three and `dream:quest`. #791 and #689
  cover the shared tail.
- **The marks, 2.** How to apply the comment footer, as a closing blockquote so
  that a reader can tell an agent wrote it, in 8 skills and `spec-files.md`. How
  to apply the commit trailer, in `dream:smith`, `dream:less` and
  `spec-files.md`. `agent-written-marks.json` holds only the values.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", in `dream:trace` and `dream:weave`. #770 covers it.
- **The skills in the user's voice, 7.** One thing per turn, with no recap;
  plain words, no headings or lists in a turn, and no `AskUserQuestion`; no
  flattery; how to start from the seed; that documents drift, so their claims
  are checked in the code; the two fresh readers, launched together and waited
  for together; and Where it goes. Each appears in two to four of `dream:spark`,
  `dream:trace`, `dream:weave` and `dream:quest`.
- **The coherent coding guide, 2.** `dream:less` restates "Resolve the root
  cause" and "The burden of proof is on the addition" in its Coherence and Don't
  over-build steps. `dream:sift`'s Judgments restate several of the guide's
  rules, although sift loads the guide.

### One vocabulary

Each line was found by searching for the retired term, then read to judge
whether the term names the concept that retires it.

- "requirements brief" or "brief": 22 lines in `dream:spark`, `dream:trace`,
  `dream:weave` and `dream:quest`, and the `dream:spark` row of the home page.
- "design" for a design specification: 19 lines in `dream:weave`, `dream:quest`
  (including its `argument-hint`) and `dream:big`, and the `dream:quest` row of
  the home page.
- "plan" for a roadmap: 15 lines of `dream:big`, and "campaign plan" in the
  `dream:big` row of the home page.
- "task" for an implementation step: 34 lines of `dream:plan`, the `dream:plan`
  row of the home page, and "4 tasks" in the sample session in
  `overrides/home.html`.
- "session type", "issue type" and "category" for a change type: 11 lines in
  `dream:smith`, `dream:less` and `dream:sift`.
- "child" for a sub-issue: 4 lines of `dream:quest`. `children` in `dream:big`
  is the name of a field in dreamcatcher's input, and is not counted.
- "spec" for a specification: the title of `spec-files.md`, and the link text
  "spec files" in four skills.

"Host" appears only as the example in `releasing.md` and as "permission host" in
`claude-code.md`, which is a different concept. "task" in the descriptions of
`dream:smith` and `dream:trace`, and in its TODO-list sense in `dream:smith`, is
not an implementation step.

18 open issues use a retired term for its concept: the 14 listed under
[Current tracker](#current-tracker), and #837, #983, #114 and #115, which are
counted there because their work is done or their skill is gone. "Host repo" in
other issues means the target repository, not an agent harness.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin.
One disagrees with it:

- `AGENTS.md`, under "Two kinds of skill", says to keep every skill's
  frontmatter `description` in the third person. The descriptions of
  `dream:big`, `dream:code-review`, `dream:coherence-review`,
  `dream:coherent-coding`, `dream:plain-english`, `dream:plan`,
  `dream:precedent-review`, `dream:quest`, `dream:scout`, `dream:sift`,
  `dream:spark`, `dream:trace` and `dream:weave` open with an imperative, such
  as "Review changed code".

The sample session in `overrides/home.html` omits the Simplification
opportunities comment that `dream:smith` posts after its reviews. It shows a
selection of steps, so it is not counted.

### Docs by purpose

The navigation in `mkdocs.yml` puts the home page alone, the compatibility page
and the changelog under Reference, and the concepts, stories, standard,
measurement, release checklist, ledger and agent-mechanics sources under
Development. The home page links only to dreamcatcher's site and the issue
tracker, the compatibility page only to dreamcatcher's site, the changelog only
to the compatibility page and the home page, and the README only to the site.

### Versioned contract

The compatibility page states the interface under "The interface", the rules for
a major, minor and patch release under "Versions", and version 1 of
dreamcatcher's agent contract under "dreamcatcher's contract". No release
precedes this one, so no increment can break the rules. Step 1 of the checklist
chooses this release's version.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows. The definition of done came into force
with #1076, and since then no review has missed a rule more than once, so no
rule meets the measure. The multi-word retired terms, such as "requirements
brief", "session type" and "campaign plan", have no other sense in the plugin,
so a search for them would have no false positives. If they come back after they
are removed, a check qualifies.

### Current tracker

All 74 open issues were read with their comments, and each claim that work is
done was checked against main. An issue counts when it meets any of these
conditions. No open issue asks for behaviour that a story excludes.

- **Work already done, 7:** #749 and #767 (the home page groups the skills and
  links the issue tracker), #790 (the plugin uses neither spelling), #837
  (`subagent-waiting.md` replaced the wait wording), #857 (no skill pins a
  model), #983 (`AGENTS.md` no longer names the Plain English guide), and #991
  (this release's `AGENTS.md` ends the version bump in every pull request).
- **A skill the plugin no longer has, 3:** #114, #115 and #549 concern only the
  files and steps of `dream:team`.
- **A retired term, 14:** "task" for an implementation step in #458, #386, #387,
  #306, #274, #317 and #331; "host" for an agent harness in #835, #844 and
  #1015; "requirements brief", "spec" and "host" in #1044 and #1048; and
  "design" for a design specification in #930 and #961.

Many other issues were written about `dream:team` or another removed skill but
still apply to a current skill, and are not counted. Issues that are only partly
done, such as #54, #358, #1042 and #1046, are not counted either. A retired term
is counted only where it names the concept whose entry retires it: "host repo"
means the repository, and "Agent Skills spec" names an outside standard.

### Reviewed changes

This is the first release, so "since the last release" has no meaning. The
window is instead the pull requests merged since the definition of done came
into force: #1076, which added it, and #1080. Neither is from Dependabot. Each
says what it changes and why, links its issue and roadmap stage, and answers all
eleven definition-of-done questions by title, with evidence.

### Rules not cases

The ledger has 3 entries, each caused by a difference between the agent
harnesses. Following #1076, the guide to agent mechanics is not searched for
special cases, because the agent harnesses are its subject. Three special cases
elsewhere in the plugin are not on the ledger:

- `dream:smith`, `dream:less`, `dream:spark`, `dream:trace`, `dream:weave` and
  `dream:quest` name `AskUserQuestion`, a Claude Code tool, to say how not to
  ask the user a question. Under Codex the name refers to nothing.
- `dream:code-review` has an `inline` mode that runs the lenses without
  subagents. Only `dream:less` uses it, so its cause is a choice this project
  made.
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`.

### Few concepts

The concepts page has 27 entries. It last changed on 2026-11-18, before #1076
put this criterion in force, and its entries were written for stage 2 of the
engineering standard's roadmap, in `specs/2026-11-01-engineering-standard/`.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, Find simplification opportunities and Collect. They
also state that `dream:less` runs its code review without subagents.

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
  `codex.md` differ by six headings, but each adds to a heading of `SKILL.md`
  only what is specific to its agent harness, so a missing heading is not a
  missing step.

## Method

Run from the repository root. The plugin is `plugins/dream`, and the
documentation is `docs/`, `overrides/home.html`, `README.md` and `AGENTS.md`.

- **Size.** Per skill folder, then per other file, then the total, which counts
  the symlinked manifest once:

  ```bash
  for d in plugins/dream/skills/*/; do printf '%s\t%s\n' "$(find "$d" -type f -exec cat {} + | wc -l | tr -d ' ')" "$d"; done | sort -rn
  wc -l plugins/dream/agents/*.md plugins/dream/*.md plugins/dream/*.json plugins/dream/.codex-plugin/plugin.json
  find plugins/dream -type f -exec cat {} + | wc -l
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
  cd plugins/dream && for f in agent-written-marks.json branch-bases.md coherent-coding.md github-text.md spec-files.md subagent-waiting.md code-review-lens.md precedent-reviewer.md claude-code.md codex.md plain-english.md; do echo "$f: $(grep -rl --include='*.md' "$f" skills agents *.md | grep -v "$f\$" | tr '\n' ' ')"; done
  ```

- **One vocabulary.** Search for each retired term on the concepts page's
  "Replaces:" lines, then read each hit. "design", "plan" and "task" have other
  senses, so search for them as whole words and judge each line:

  ```bash
  rg -niP '\bhosts?\b|agent prompt|named agent|\bchild(ren)?\b|\bspecs?\b|requirements brief|\bbriefs?\b|campaign plan|issue type|session type|\bcategor' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md'
  rg -niw 'design|plans?|tasks?' plugins/dream docs overrides README.md AGENTS.md -g '!docs/concepts.md' -g '!docs/measurement.md'
  ```

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

- **Current tracker.** Fetch every open issue, then read each body against the
  plugin, the stories and the list of skills:

  ```bash
  gh issue list --state open --limit 300 --json number,title,body
  ```

- **Reviewed changes.** List the pull requests merged in the window, and read
  each description:

  ```bash
  git log --merges --first-parent --oneline v<last>..HEAD
  gh pr view <N> --json title,author,body
  ```

  For this first release, there is no `v<last>`. The window starts after
  `43249563`, the merge before #1076:
  `git log --merges --first-parent --oneline 43249563..HEAD`.

- **True documents and Versioned contract.** Read each document named in True
  documents whole, and check each statement it makes about the plugin against
  the plugin.
