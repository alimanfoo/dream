# Engineering standard

This page says what dream holds itself to. It is one of the three enduring
documents, beside [the concepts page](concepts.md), which fixes the words, and
[the stories](stories.md), which fix what the user does and sees. This page says
how good the result has to be, and how we tell. It adapts the standard that
[dreamcatcher](https://github.com/alimanfoo/dreamcatcher/blob/main/docs/standard.md)
keeps.

The standard covers the plugin and its documentation. The plugin is its skills,
its subagent files and the files they share. It covers every skill alike,
whether the skill gives a coding agent instructions or is written in the user's
voice. The repository's infrastructure, such as its workflows and its dependency
updates, is kept in force by its own checks, and each check is explained where
it is configured.

## The aim

dream aims to be as simple, clear, consistent and elegant as the finest open
source projects. Those four words have a precise meaning here.

- **Simple** means there is no more of it than the job needs. Each part is small
  enough to hold in mind, and each thing is said in one place.
- **Clear** means a reader who knows the domain can find the skill for a
  practice from its name, read it in one sitting, and is told nothing twice.
- **Consistent** means the same idea looks the same everywhere it appears, and
  every rule we state is one a reader can check.
- **Elegant** means special cases dissolve into general rules, so that nothing
  in the plugin is arbitrary and nothing could be taken away.

The criteria below turn each word into something we can measure.

## Criteria

Each criterion has a short title, which names it everywhere, and opens with its
full statement. Each then has a **measure**, which says what number or fact we
read; a **bar**, which says what value passes; and a **check**, which says what
enforces it.

The check is a machine where a machine can tell cheaply and without false
alarms, and a reviewer everywhere else. Review is a check in its own right, not
a gap waiting for a tool. A mechanical check earns its place only when a
criterion has failed in review more than once and the check would be small and
exact. Adding checks is not progress towards the standard. Meeting the criteria
is.

### Simplicity

#### One job per skill

Each skill, subagent file and shared file does one job.

- Measure: skills, subagent files and shared files for which review cannot name
  the one job they do, read largest first.
- Bar: zero. A skill is split where a clean boundary gives each part a job of
  its own, never to meet a line count. A long skill that reads as a sequence of
  steps, such as `dream:smith`, stays whole.
- Check: review, ordered by the line counts that [Size](#size) reports and
  focused on any file a change grows.

#### A reader for every file

Every file in the plugin has the readers it is there for.

- Measure: files in the plugin that no skill or subagent file links, and shared
  files that fewer than two skills or subagent files link. A shared file is one
  at the plugin's root, such as `branch-bases.md`.
- Bar: zero. A file is shared because two or more readers need it, and a file
  with one reader lives in that reader's skill folder or in the reader itself. A
  subagent file needs only one skill that launches it, since it sits in
  `agents/` for Claude Code to read, not to be shared.
- Check: review.

#### One fact, one home

Each fact is stated in one place.

- Measure: places where two skills, subagent files or shared files state the
  same rule or fact in their own words.
- Bar: zero. Every other file that needs the fact links its home. For example,
  `branch-bases.md` owns how a skill finds the default branch, and each skill
  that needs it reads that file.
- Check: review, guided by the consistency review before each release.

#### No suppressions

Nothing is suppressed.

- Measure: `markdownlint-disable`, `markdownlint-disable-next-line` and
  `prettier-ignore` markers in the repository's Markdown.
- Bar: zero. A Markdown rule that does not fit dream is turned off for every
  file in `.markdownlint.json`, as `MD013` is, so that the rule itself is what
  changes.
- Check: review.

#### Size

The plugin is no larger than its jobs need.

- Measure: the lines of each skill folder, each subagent file and each shared
  file, and of the plugin in total, with the change since the last release.
  Lines stand in for tokens: Prettier reflows every Markdown file to 80 columns,
  so a line holds a fairly steady amount of text, and a line count reads the
  same under every agent harness.
- Bar: none yet. The change since the last release is what draws attention to
  growth.
- Check: the measurement before each release, and the definition of done's
  [Line count](#definition-of-done) question on each pull request.

### Clarity

#### One vocabulary

Each concept has one word, the one the concepts page gives it.

- Measure: disagreements that the consistency review reports between two claims
  about one concept, in the skills, subagent files, shared files, documents and
  issues, and uses of a word that the concepts page replaces.
- Bar: zero.
- Check: the consistency review before each release, and review of any pull
  request that names a concept.

#### True documents

The enduring documents are true.

- Measure: statements in the concepts page, the stories and this standard that
  the plugin contradicts.
- Bar: zero. A pull request that moves the plugin past one of them corrects it
  in the same change and says so.
- Check: review, through the definition of done's
  [Documents still true](#definition-of-done) question.

#### Docs by purpose

Documentation is organised by purpose.

- Measure: whether a user can install dream and choose a skill without reading
  the pages for the people and agents who change dream.
- Bar: three kinds of page, kept apart. The home page installs dream and says
  what each skill does, one row per skill. Pages under Reference say what stays
  the same between releases and what changed. Pages under Development are for
  the people and agents who change dream. The README is a short entrance to the
  site. Pages for users do not link to the pages under Development.
- Check: review of the docs map, which `uncoded sync` writes.

#### Versioned contract

dream's interface is versioned.

- Measure: whether [the compatibility page](compatibility.md) states the
  interface, the rules for a major, minor and patch release, and the version of
  dreamcatcher's agent contract that dream meets, and whether each release that
  renames or removes a name in the interface is major.
- Bar: all hold.
- Check: review, through the definition of done's
  [Names kept](#definition-of-done) and
  [Contract still met](#definition-of-done) questions, and the comparison of the
  skill list with the last release's before each release.

### Consistency

#### Machine-checked rules

A rule that review keeps missing is checked by a machine.

- Measure: rules that have failed review more than once, that a small and exact
  check could enforce, and that no machine checks.
- Bar: zero. These rules are checked:
  - Every skill's frontmatter is valid, and its title heading is its name.
    `scripts/validate_skill.py` checks it.
  - Every subagent file's frontmatter is valid. `scripts/validate_agent.py`
    checks it.
  - The plugin and marketplace manifests are valid. `claude plugin validate`
    checks them.
  - Every link between Markdown files resolves to a file and a heading.
    `remark-validate-links` checks it.
  - Markdown follows one style and one layout. `markdownlint-cli2` and Prettier
    check it.
  - No Markdown file holds an invisible character.
    `scripts/check_invisible_chars.py` checks it.

  Review checks every other rule until it fails more than once.

- Check: the pre-commit hooks named beside each rule, which CI runs on every
  push and pull request.

#### Current tracker

The tracker is current.

- Measure: open issues that name a concept by a word the concepts page replaces,
  that ask for work already done, that concern a skill the plugin no longer has,
  or that ask for what a story rules out.
- Bar: zero.
- Check: the triage of the open issues before each release, and `dream:sift` for
  each issue that has no triage outcome yet.

#### Reviewed changes

Every change is reviewed against this standard.

- Measure: pull requests merged since the last release that explain what they
  change and why, link any relevant issue or specification, and answer the
  definition of done.
- Bar: all of them, apart from the dependency updates that Dependabot raises.
- Check: review, which reads the answers before the pull request merges.

### Elegance

These criteria rest more on review than the others. An objection under them must
name the question that fails and show the evidence. Elegance is not a word for
"I would have done it differently".

#### Rules not cases

Rules, not cases.

- Measure: text in the plugin that applies to one particular situation rather
  than states a general rule, such as a step that differs by agent harness, and
  the ledger in [`docs/special-cases.md`](special-cases.md) that lists each one
  with its cause.
- Bar: every such case is on the ledger, and every entry has an external cause,
  such as a difference between the agent harnesses. Nothing on the ledger exists
  because of a choice this project made.
- Check: review, asking of each new case whether it would go if a rule were
  stated more generally.

#### Few concepts

Concept economy.

- Measure: the change to the concepts page in each pull request, against the
  case its specification makes.
- Bar: a change adds a concept only when its specification shows that the
  existing concepts cannot compose to it. Removing a concept needs no case.
- Check: review, through the definition of done's
  [Concepts' words](#definition-of-done) question. A specification arrives in a
  pull request like any other change.

#### Symmetry

Parallel things have parallel parts.

- Measure: the steps that exist for one of a parallel pair and not the other, or
  exist twice. The parallel pairs are `dream:smith` and `dream:less`,
  `dream:code-review` and `dream:coherence-review`, and the two agent harnesses,
  Claude Code and Codex.
- Bar: each pair has parallel steps with parallel names, and shares text where
  its two halves do the same thing. An asymmetry stands only where the concepts
  page or the stories name the difference.
- Check: review, reading the docs map, which `uncoded sync` writes.

## Definition of done

A pull request is done when its author can answer yes to each of these
questions.

1. **Explained.** It says what it changes and why, and links any issue or
   specification.
2. **Checks pass.** Every pre-commit hook and every required check passes, and
   none is suppressed or bypassed.
3. **One job.** What it adds meets [One job per skill](#one-job-per-skill), and
   every file it adds has
   [the readers it is there for](#a-reader-for-every-file).
4. **Concepts' words.** Every word it introduces is on the concepts page, or the
   concepts page grew in the same change, and it uses no word the concepts page
   replaces.
5. **Documents still true.** Any document it makes false, it corrects: the
   enduring documents, the compatibility page, the home page and `AGENTS.md`.
6. **Every copy changed.** Every other place that states a fact it changes
   changed with it.
7. **Replaced things removed.** It removes what it replaces.
8. **Names kept.** It renames or removes no name in the interface that
   [the compatibility page](compatibility.md) states, or it says which.
9. **Contract still met.** A change to `dream:smith`, `dream:less`, `dream:big`
   or `dream:scout` still meets the version of dreamcatcher's agent contract
   that the compatibility page names, read against the contract itself.
10. **Cases on the ledger.** Every case it adds that applies to one particular
    situation is on the ledger with its external cause.
11. **Line count.** It states how many lines it adds to the plugin or removes
    from it, and a bug fix or maintenance change that adds lines says why.

A pull request answers each question under a "Definition of done" heading,
starting with the question's title in bold, not its number, and giving its
evidence. "Yes" alone is not an answer. A question that does not apply is
answered with the reason, such as "It changes none of those skills."

## Exceptions

A criterion may be waived for one place, never in general. The waiver is written
where the check will read it, such as an entry on the ledger for
[Rules not cases](#rules-not-cases). A waiver with no reason a reader can find
is a violation.

## Measurement

Every criterion is measured again before each release, and the enduring
documents are read against the plugin. The measurement, in
`docs/measurement.md`, holds the latest results and says how each was taken, so
the next measurement can repeat it. Each shortfall is an issue, and none holds a
release back.
