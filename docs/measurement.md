# Measurement

This page holds the latest measurement of dream against
[the standard](standard.md). Step 3 of [the release checklist](releasing.md)
replaces it before each release. Earlier measurements are in Git history.

Measured on 2026-11-25 for the 47.2.0 release. The plugin and the documentation
were read on the release branch, which starts from `ec64a341`, and whose working
tree differed from that commit only in the version in the manifest and the new
changelog section. True documents records what this reading found at `ec64a341`,
before any fix from the release's consistency review. Each measure is compared
with the measurement for the last release, 47.1.0, tagged `v47.1.0`, whose
figures are given in brackets.

## Results

| Criterion             | Measured                                                                                                   | Status  |
| --------------------- | ---------------------------------------------------------------------------------------------------------- | ------- |
| Single responsibility | 0 of 25 files without a one-sentence purpose (0 of 33)                                                     | met     |
| No orphaned files     | 0 unreferenced files; every shared file has at least 2 referring skills (at least 2)                       | met     |
| One fact, one home    | 32 rules or facts stated in more than one file (33)                                                        | not met |
| Size                  | 4,211 lines in the plugin (4,284), a change of −73                                                         | no bar  |
| One vocabulary        | 0 uses in the plugin, 0 in the documentation, 0 open issues use retired terms (0, 0, 0)                    | met     |
| True documents        | 0 statements that the plugin contradicts, at `ec64a341` (0)                                                | met     |
| Docs by purpose       | 0 misplaced pages, 0 links to a Development page (0, 0)                                                    | met     |
| Versioned contract    | The compatibility page states all three; 47.2.0 is a minor release, as a change to what skills do requires | met     |
| Machine-checked rules | 0 rules missed twice by review that a small check could enforce (0)                                        | met     |
| No suppressions       | 0 markers (0)                                                                                              | met     |
| Current tracker       | 0 of 13 open issues out of date (0 of 13)                                                                  | met     |
| Reviewed changes      | 2 of 2 pull requests answer every definition-of-done question (4 of 4)                                     | met     |
| Rules not cases       | 2 special cases not on the ledger; 0 ledger entries with an internal cause (2; 0)                          | not met |
| Few concepts          | 0 concepts added since 47.1.0 (0)                                                                          | met     |
| Symmetry              | 10 unshared or unmatched steps across the three pairs (10)                                                 | not met |

## Shortfalls

Each shortfall is filed as an issue unless an open issue already covers it.

1. **One fact, one home.** 32 rules or facts are stated in more than one skill,
   subagent file or shared file. The list is under
   [One fact, one home](#one-fact-one-home) below. #1091 covers the three steps
   still written out in both `dream:smith` and `dream:less` whose differences it
   asks about, Implement, Review and Write the PR description, and the copies in
   `dream:code-review` and `dream:coherence-review`. #1102 covers the persona
   paragraph and Mark the PR ready for review in `dream:smith` and `dream:less`,
   the change-type labels, checking an issue's claims against the current code,
   drafts in a temporary file, the copies of the review rules in
   `dream:precedent-review` and `dream:quest`, the report rules of the two
   subagent files, and the reason for an absolute path in `dream:trace` and
   `dream:weave`. #1083 covers the marks, the 11 rules common to the skills in
   the user's voice, and `dream:sift`'s restatements of the coherent coding
   guide. #1091 also covers the text of Handle user posts that `dream:smith` and
   `dream:less` share, which its latest comment now lists as open. No issue is
   filed for `dream:less`'s summary of the engineering principles: the decision
   on #1083 keeps it as a deliberate stand-in for the guide, as less's story
   states, under "Weigh a measurement finding against the skill's purpose" in
   `AGENTS.md`.
2. **Rules not cases.** Two special cases are not on the ledger: the
   `AskUserQuestion` tool, named in `assignment-boot.md` and four skills, and
   `dream:sift`'s condition on `dreamcatcher.toml`. #1085 covers both.
3. **Symmetry.** `dream:smith` and `dream:less` write out 5 steps in each file
   that do the same thing in both, and `dream:code-review` and
   `dream:coherence-review` write out 5. #1091 covers Implement, smith's Review
   and less's Code review, whose names also differ, Write the PR description,
   and the 5 steps of the review pair. #1102 covers Mark the PR ready for
   review, and #1091 Handle user posts.

## Notes

### Single responsibility and Size

`git diff --stat v47.1.0 HEAD -- plugins/dream` shows that only #1111 changed
the plugin: it changed `dream:smith` and `dream:less`, added
`assignment-boot.md`, and removed the nine `assignment-*.md` files that #1107
added. Those three files were read whole. Every other file is unchanged since
`v47.1.0`, and its 47.1.0 finding was confirmed and carried forward. Each file
has one purpose, stated in the table. `dream:smith` and `dream:big` are long,
but each is one procedure. `assignment-boot.md` holds what an assignment skill
does before its own work, in lettered steps A to I. Its text is the nine files'
text, apart from its headings, two lead-in lines, and the change types, which
now open "Name the change type".

The change is from the same commands run on a copy of the plugin at `v47.1.0`,
which reproduce that measurement's 4,284 lines.
`git diff --shortstat v47.1.0 HEAD -- plugins/dream` reports 12 files changed,
199 insertions and 272 deletions, a net change of −73. `dream:smith`,
`dream:less` and the shared file they read hold 439 lines, down from 512 at
47.1.0 and 593 at 47.0.0.

| File                                      | Lines | Change | Purpose                                                                                 |
| ----------------------------------------- | ----: | -----: | --------------------------------------------------------------------------------------- |
| `skills/agent-mechanics/` (3 files)       |   986 |      0 | Explains how a coding agent works under Claude Code and Codex.                          |
| `coherent-coding.md`                      |   359 |      0 | States the coherent coding guide.                                                       |
| `skills/spark/`                           |   329 |      0 | Interviews the user and writes a requirements specification.                            |
| `skills/weave/`                           |   326 |      0 | Works out a solution with the user in design models, and writes a design specification. |
| `skills/big/`                             |   289 |      0 | Leads a dreamcatcher campaign through its stages to merge.                              |
| `skills/trace/`                           |   258 |      0 | Tours the code with the user and writes a checked reading guide.                        |
| `skills/quest/`                           |   256 |      0 | Breaks a design specification into a roadmap of stages, and its sub-issues.             |
| `skills/sift/`                            |   228 |      0 | Triages issues with the user, one decision at a time.                                   |
| `skills/smith/`                           |   188 |    −46 | Carries a well-specified issue to a planned, reviewed pull request.                     |
| `assignment-boot.md`                      |   172 |   +172 | States the boot sequence that `dream:smith` and `dream:less` run before their own work. |
| `skills/plan/`                            |   116 |      0 | Writes an implementation plan.                                                          |
| `agents/precedent-reviewer.md`            |   102 |      0 | Reviews a change against the user's past review comments.                               |
| `skills/coherence-review/`                |    98 |      0 | Reviews a change for coherence through lenses drawn from the guide.                     |
| `skills/code-review/`                     |    89 |      0 | Reviews a change through lenses chosen for the diff.                                    |
| `skills/less/`                            |    79 |    −41 | Carries an easy change to a pull request with one inline review.                        |
| `skills/precedent-review/`                |    71 |      0 | Launches the precedent reviewer and verifies its findings.                              |
| `skills/scout/`                           |    59 |      0 | Answers the user's questions on an issue from the code.                                 |
| `specification-files.md`                  |    55 |      0 | Says where a specification file goes and how it reaches a pull request.                 |
| `agents/code-review-lens.md`              |    50 |      0 | Reviews a diff through one lens.                                                        |
| `subagent-waiting.md`                     |    26 |      0 | Says how to wait for launched subagents under each agent harness.                       |
| `skills/coherent-coding/`                 |    25 |      0 | Loads the coherent coding guide.                                                        |
| `.codex-plugin/plugin.json`               |    17 |      0 | The manifest. `.claude-plugin/plugin.json` is a symlink to it and is not counted twice. |
| `github-text.md`                          |    15 |      0 | Says how to lay out text that GitHub renders, and how to pass it to `gh`.               |
| `branch-bases.md`                         |    11 |      0 | Says how to find the default branch and the review base.                                |
| `agent-written-marks.json`                |     7 |      0 | Holds the comment footer and the commit trailers.                                       |
| The nine `assignment-*.md` files, removed |     — |   −158 | Their text is now in `assignment-boot.md`.                                              |
| **Plugin total**                          | 4,211 |    −73 |                                                                                         |

### No orphaned files

Apart from the 15 `SKILL.md` files and the manifest, the plugin holds 11 files.
Each is referenced by path or link. Counting only skills and subagent files,
`agent-written-marks.json` is referenced from 6 skills, `branch-bases.md` from
5, `coherent-coding.md` from 4, `github-text.md` from 7,
`specification-files.md` from 4, `subagent-waiting.md` from 7,
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

The groups in unchanged files are carried forward from 47.1.0, and the groups
that touch `dream:smith`, `dream:less` or `assignment-boot.md` were made afresh.
Pull request #1111 removed one rule that 47.1.0 counted, step 2's rule to read
the session rules again after a summary, and added none: the text it moved into
`assignment-boot.md` was already in one file each. The 32:

- **`dream:smith` and `dream:less`, 6.** Written out in both skills: the opening
  persona, "You are an autonomous software developer…" with "Follow the
  instructions below in order."; Implement's loop of running the tests,
  committing with a short subject and pushing at each step; the review base, the
  `origin/<base>...HEAD` target, and weighing each finding on its merits, in
  smith's Review and less's Code review; Write the PR description's contribution
  rules and its issue list; Mark the PR ready for review; and Handle user posts,
  renamed by #1111 from "Handle what the user posts". #1091 covers Implement,
  Review and Write the PR description, and #1102 the persona and Mark the PR
  ready for review. In Handle user posts, #1111 made a requested change read the
  same in both skills, and the latest comment on #1091 treats the one remaining
  difference, smith going on to Collect, as settled by smith's story. The rest
  of the step, ending the turn, never merging, and the four kinds of post, is
  still written out in both. The release's issue sweep added it to #1091's open
  list.
- **Change-type labels, 1.** `assignment-boot.md`, in "I. Open the session PR",
  and `dream:sift` each list the labels `enhancement`, `maintenance` and `bug`.
  #1102 covers it.
- **The review skills, 6.** As at 47.1.0, since none of the files has changed:
  the default target, Read the diff, keeping only the findings the code
  confirms, and Rank and output, in `dream:code-review`,
  `dream:coherence-review` and `dream:precedent-review`; how to launch a
  subagent file under Codex, in the same three; and that subagents inherit the
  session's model and effort, in those three and `dream:quest`. #1091 covers the
  copies in `dream:code-review` and `dream:coherence-review`, and #1102 those in
  `dream:precedent-review` and `dream:quest`.
- **The marks, 2.** How to apply the comment footer, as a closing blockquote so
  that a reader can tell an agent wrote it, in `dream:spark`, `dream:trace`,
  `dream:weave`, `dream:quest`, `dream:big`, `dream:sift`, `assignment-boot.md`
  and `specification-files.md`. How to apply the commit trailer, in
  `assignment-boot.md` and `specification-files.md`. #1083 covers both.
- **The two subagent files, 1.** The report rules: change nothing, say what
  establishes a claim of absence, two or three sentences, only findings, clean
  is a valid answer. #1102 covers it.
- **Subagent paths, 1.** "A subagent can't resolve a path relative to its own
  prompt file", in `dream:trace` and `dream:weave`. #1102 covers it.
- **The skills in the user's voice, 11.** As at 47.1.0, each still in two to
  four of `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest`: one
  thing per turn, with no recap; plain words, no headings or lists in a turn,
  and no `AskUserQuestion`; no flattery; how to start from the seed; that
  documents drift, so their claims are checked in the code; the two fresh
  readers, launched together and waited for together; Where it goes; think out
  loud; push back on the user; tell the user only what you have read in the
  code; and say when you use an analogy and where it stops holding. #1083 covers
  them.
- **The coherent coding guide, 2.** `dream:less`'s step 2, Adopt the engineering
  principles, restates "Resolve the root cause" and "The burden of proof is on
  the addition". `dream:sift`'s Judgments restate several of the guide's rules,
  although sift loads the guide. #1083 covers sift's. Its decision now scopes
  out less's summary as a deliberate stand-in for the guide, which less does not
  load, as less's story states. The measure has no exception for it, so it still
  counts. No issue is filed, because removing it would remove a difference that
  less needs for its purpose, which "How we judge" in `AGENTS.md` says to keep.
- **Checking an issue's claims against the current code, 1.**
  `assignment-boot.md`, in "G. Read the cited material and the code",
  `dream:scout`'s Investigate and `dream:sift`'s Judgments each say to check the
  input's claims against the current code, because the code may have changed
  since the issue was written. #1102 covers it.
- **Drafts in a temporary file, 1.** `dream:smith`'s Review, `dream:plan`,
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` each write their
  draft to a temporary file outside the repo. #1102 covers it.

### One vocabulary

The searches under [Method](#method) find no retired term that names its concept
in the plugin, the documentation or the open issues. A search for the multi-word
terms split across a line break finds none outside the changelog.

The remaining hits are the other senses that 47.1.0 found: "brief" as an
adjective or a verb, now also in "Turn output" in `assignment-boot.md`;
`children` in `dream:big`, the name of a field in dreamcatcher's input; the
`specs/` folder in `specification-files.md`; "the spec" for an API in
`coherent-coding.md`; "child process" in `codex.md`; "permission host" in
`claude-code.md`; "task" for a piece of work or a TODO item; "plan" for an
implementation plan; and "design" for the solution being worked out. The 47.1.0
section of the changelog names "requirements brief", "campaign plan" and
"session type" as the terms that #1106 replaced, which is not a use, and
comments on #1050 and #1083 name retired terms as the terms #1106 replaced.

### True documents

Every statement of the concepts page, the stories, the standard, the
compatibility page, the home page and `AGENTS.md` was read against the plugin at
`ec64a341`. None is contradicted. None of these documents has changed since
`v47.1.0`, so the reading checked each statement that bears on what #1111
changed. The smith story's steps 2 and 3, which read the issue, open a draft
pull request and post the plan there, follow the boot sequence's steps G and I
and smith's step 3, Plan. The less story's step 4, which follows a short summary
of the engineering principles while making the change, agrees with less's step
2, which now comes after the session PR opens. The home page's "Smith and Less
print the plugin version as they start" holds through step A of the boot
sequence. No document names the shared files, the step numbers or the renamed
steps.

Four statements were weighed and not counted:

- The smith and less stories say that the agent opens a draft pull request, but
  not that it posts the session input there as its first comment. That is an
  omission, not a contradiction, as at 47.1.0.
- The compatibility page says "Each skill is one file that both read."
  `dream:agent-mechanics` has three files, and `dream:smith` and `dream:less`
  read `assignment-boot.md`. The sentence says that both agent harnesses read
  the same files, which holds.
- The sample session in `overrides/home.html` omits the Session input and
  Simplification opportunities comments that `dream:smith` posts. It shows a
  selection of steps.
- `AGENTS.md` lists saliency decay among the tendencies that the plugin counters
  with structure. #1111 removed the rule to read the session rules again after a
  summary, which was an instruction rather than structure. `dream:smith` keeps
  structure that serves it, such as its TODO list and reviews in fresh
  subagents, and the list states a design aim rather than a step's behaviour.

### Docs by purpose

The navigation in `mkdocs.yml`, the home page, the compatibility page, the
changelog and the README are unchanged since 47.1.0. The navigation puts the
home page alone, the compatibility page and the changelog under Reference, and
the concepts, stories, standard, measurement, release checklist, ledger and
agent-mechanics sources under Development. The home page links only to
dreamcatcher's site and the issue tracker, the compatibility page only to
dreamcatcher's site, the changelog only to the compatibility page, the home page
and pull requests, and the README only to the site.

### Versioned contract

The compatibility page, unchanged since 47.0.0, states the interface under "The
interface", the rules for a major, minor and patch release under "Versions", and
version 1 of dreamcatcher's agent contract under "dreamcatcher's contract". The
comparison of skill names from step 1 of the checklist prints nothing. At
`ec64a341`, the manifest is as at `v47.1.0`, and
`.claude-plugin/marketplace.json` differs only in the entry's `sha`, which pull
request #1109 pinned to the commit tagged `v47.1.0`. #1111 changes what
`dream:smith` and `dream:less` do: they adopt their engineering principles after
the session PR opens rather than before orienting to the repo, and no longer
read the session rules again after a summary. That calls for a minor increment.
Its renames of steps and files are not changes to the interface, which names
neither. 47.1.0 to 47.2.0 is a minor increment.

### Machine-checked rules

The hooks in `.pre-commit-config.yaml` are those the standard lists, plus
`zizmor`, which covers the workflows, and neither they nor the scripts have
changed since 47.1.0. Among the pull requests since 47.1.0, no rule was missed
by review more than once.

### Current tracker

All 13 open issues were read with their comments, and each claim that work is
done was checked against the plugin. 47.1.0 counted 13 open issues. None counts.
Since 47.1.0, #1111 closed #1110, a comment on #1102 added the rules that 47.1.0
found no issue for, a comment on #1091 recorded what #1111 settled, and the
decisions on #1083 and #1085 were updated.

No open issue uses a retired term for its concept (see
[One vocabulary](#one-vocabulary)). No open issue asks only for work already
done. #1091 is part done: its latest comment records what #1107 and #1111
settled, and it still asks about Implement, Code review, Write the PR
description, the shared text of Handle user posts, and the review pair. The
decision comment on #1042 says the issue is half done. The plugin does not yet
have the change that each of these asks for: #1049, #1050, #1083, #1085, #1088
and #1102. Issues #1043 and #1046 wait on alimanfoo/dreamcatcher#917 and #894,
which are both still open. No open issue concerns only a skill the plugin no
longer has: #686 names `solo`, an earlier name of `dream:less`, but asks for a
skill for every pull request comment. No open issue asks for behaviour that a
story excludes. Issue #1102 has no triage outcome yet.

Some text on open issues names files or steps that #1111 changed, though none of
it makes an issue count. The release's issue sweep updated the decision on #1042
so that it names `assignment-boot.md` as the home of the "Turn output" rule,
where it said that `dream:smith` and `dream:less` each have one. The body of
issue #1091 and four of its comments name "Handle what the user posts",
"Coherence" and five of the removed `assignment-*.md` files; its latest comment
supersedes them.

### Reviewed changes

The window is the pull requests merged since `v47.1.0`, in order of merge: pull
requests #1109 and #1111. No commit reached main without a merge. Each says what
it changes and why, links the issue it closes or, for #1109, the release pull
request it follows, and answers all eleven definition-of-done questions by title
under a "Definition of done" heading, each with its evidence. The Line count
answer of #1111 gives a net −69, which predates its last commit; the merged
change is −73, and the description does not mention that commit's removal of the
repeated end-of-turn line. The measure counts an answer that is present.

### Rules not cases

The ledger has 3 entries. Since 47.1.0, #1111 changed the `commitTrailer`
entry's location to `assignment-boot.md`, which reads the trailer in "B. Adopt
the session rules". Each entry is caused by a difference between the agent
harnesses, and each still matches the plugin. The guide to agent mechanics is
not searched for special cases, because the agent harnesses are its subject. Two
special cases elsewhere in the plugin are not on the ledger:

- `assignment-boot.md`, which `dream:smith` and `dream:less` share, and
  `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest` name
  `AskUserQuestion`, a Claude Code tool, to say how not to ask the user a
  question. Under Codex the name refers to nothing.
- `dream:sift` offers dispatch only when the repository has a
  `dreamcatcher.toml`. Triage of #1085 decided to remove dispatch from the
  skill.

The changes since 47.1.0 add no special case.

### Few concepts

The concepts page has 27 entries. No commit since `v47.1.0` changes it.

### Symmetry

The concepts page and the stories state the steps that only `dream:smith` has:
Plan, the coherence review, Find simplification opportunities and Collect. They
also state that `dream:less` runs its code review without subagents, and that it
follows a short summary of the engineering principles rather than loading the
coherent coding guide.

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
