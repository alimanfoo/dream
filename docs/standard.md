# Engineering standard

This page defines the engineering standards that dream adheres to. It sets out
the criteria the project is held to, how each is measured, and what enforces it.
It is one of three enduring documents. The other two are
[the concepts page](concepts.md), which defines the terms for dream's domain,
and [the stories](stories.md), which specify dream's intended behaviour as
scenarios. Each story gives the user's goal, the steps that the user and the
agents take, and the outcome. The page is adapted from
[dreamcatcher's engineering standard](https://github.com/alimanfoo/dreamcatcher/blob/main/docs/standard.md).

The standard covers the plugin and its documentation. The plugin is the
directory `plugins/dream`: its skills, its subagent files in `agents/`, its
manifest, and its shared files. A shared file is a file at the plugin's root
that skills or subagent files reference, such as `branch-bases.md`. An entry
point is a file that the agent harness loads without a reference from another
file: each skill's `SKILL.md`, and the manifest. The documentation is the site
built from `docs/`, the README and `AGENTS.md`. Every skill is held to the same
criteria, whether it instructs a coding agent or is written in the user's voice.
The repository's infrastructure, such as its CI workflows, its Dependabot
configuration and its pre-commit configuration, is outside the scope of this
standard.

## The aim

The project aims for four properties, defined as follows.

- **Simple**: every file and instruction in the plugin is needed for a skill to
  do its work, each file is small enough to understand in one reading, and each
  fact is stated in one place.
- **Clear**: a reader who knows the domain can identify the skill for a task
  from its name, and each term has one meaning, used the same way in every file.
- **Consistent**: the same idea takes the same form wherever it appears, and
  each rule is enforced, by an automated check or by review.
- **Elegant**: behaviour follows from a few general rules and concepts, and a
  special case exists only where a constraint outside the project requires it.

The criteria below are grouped by property, and each one makes part of its
property measurable.

## Criteria

Each criterion is identified by its heading, by which the definition of done and
reviewers refer to it. A criterion opens with a statement of the requirement,
followed by a **measure**, the count or fact that is observed; a **bar**, the
value of the measure that passes; and a **check**, the mechanism that detects a
failure.

Three mechanisms serve as checks:

- **Automated checks**: the pre-commit hooks, which CI runs on every pull
  request and on every push to main.
- **Review**: a reviewer's reading of a pull request before it merges, including
  its answers to the [definition of done](#definition-of-done).
- **Release checks**: the consistency review, the issue sweep and the
  [measurement](#measurement), which [the release checklist](releasing.md) runs
  before each release, starting with the first release.

Review is the check for every criterion that does not qualify for an automated
check under [Machine-checked rules](#machine-checked-rules). It is the intended
check for those criteria, not a stopgap. Meeting the criteria is the goal;
adding automated checks is not.

### Simplicity

#### Single responsibility

Each skill, subagent file and shared file has a single responsibility: one
purpose, which a reviewer can state in one sentence.

- Measure: the number of skills, subagent files and shared files whose purpose a
  reviewer cannot state in one sentence.
- Bar: zero. A skill is split only at a boundary that leaves each part with a
  single responsibility, never to reduce its length. A long skill whose steps
  form one procedure, such as `dream:smith`, stays whole.
- Check: review of each file that a pull request adds or enlarges, and, at each
  measurement, of every file in descending order of the line counts that
  [Size](#size) reports.

#### No orphaned files

Every file in the plugin other than an entry point is referenced, by link or by
path, from at least one skill or subagent file, and every shared file from at
least two.

- Measure: the number of files, other than entry points, that no skill or
  subagent file references, plus the number of shared files that fewer than two
  skills or subagent files reference.
- Bar: zero. A shared file with only one referencing file belongs with that file
  instead: in the same skill's folder, or inline. A subagent file needs only one
  referencing skill, the one that launches it. It sits in `agents/` because
  Claude Code registers each file there as a subagent type, not because it is
  shared.
- Check: review.

#### One fact, one home

Each rule or fact in the plugin has a single source of truth: one file states
it, and every other file that needs it references that file.

- Measure: the number of rules or facts that more than one skill, subagent file
  or shared file states, whether verbatim or paraphrased.
- Bar: zero. For example, `branch-bases.md` states how a skill finds the default
  branch, and each skill that needs the default branch references it.
- Check: review. The consistency review before each release also reports copies
  that have come to disagree, but not copies that still agree.

#### Size

The plugin's size is measured, and its growth is reported in every pull request
and at every release.

- Measure: the line count of each skill folder, each subagent file and each
  shared file, and of the plugin in total, with the change since the last
  release. Line count is a proxy for token count that does not depend on any
  model's tokenizer. Prettier wraps Markdown prose at 80 columns, so a line of
  prose holds a roughly constant amount of text; tables and code blocks are not
  wrapped.
- Bar: none. Size has no threshold; reporting the change makes growth visible to
  review.
- Check: the measurement before each release, and the definition of done's
  [Line count](#definition-of-done) question on each pull request.

### Clarity

#### One vocabulary

Each concept defined on [the concepts page](concepts.md) is referred to by the
term defined there, and never by a term that its "Replaces:" line retires.

- Measure: the number of places in the plugin, the documentation and the open
  issues that use a retired term for the concept it names.
- Bar: zero.
- Check: review of each pull request that refers to a concept, and the issue
  sweep before each release.

#### True documents

The documents that describe the plugin agree with its current behaviour. They
are the three enduring documents, the compatibility page, the home page and
`AGENTS.md`.

- Measure: the number of statements in those documents that the plugin
  contradicts.
- Bar: zero. When a pull request changes behaviour that one of them describes,
  it updates that document and says so in its description.
- Check: review, through the definition of done's
  [Documents still true](#definition-of-done) question, and the consistency
  review before each release.

#### Docs by purpose

The documentation site is organised by audience into three sections. The home
page tells a user how to install dream and what each skill does, in one table
row per skill. Pages under Reference state what stays the same between releases
and what each release changed. Pages under Development are for the people and
coding agents who change dream. The README is a short introduction that links to
the site.

- Measure: the number of pages placed in a section for a different audience,
  plus the number of links from the home page, the Reference pages or the README
  to a Development page.
- Bar: zero.
- Check: review of the site navigation in `mkdocs.yml` and of the documentation
  index, `.uncoded/docs.yaml`, which lists every Markdown file and its headings.

#### Versioned contract

[The compatibility page](compatibility.md) defines dream's public interface, and
each release's version number follows from the changes to that interface, by the
rules the page states.

- Measure: whether the compatibility page states the interface, the rules for a
  major, minor and patch release, and the version of dreamcatcher's agent
  contract that dream meets; and the number of releases whose version increment
  does not follow those rules.
- Bar: the page states all three, and no release breaks the rules.
- Check: review, through the definition of done's
  [Names kept](#definition-of-done) and
  [Contract still met](#definition-of-done) questions, and, before each release,
  a comparison of the skill list with the previous release's.

### Consistency

#### Machine-checked rules

An automated check enforces each rule that review has missed more than once,
provided a small check can enforce the rule with no false positives.

- Measure: the number of rules that review has missed more than once, that a
  small check could enforce with no false positives, and that no automated check
  enforces.
- Bar: zero.
- Check: review of each violation that an earlier review missed.

The automated checks that apply to the plugin and its documentation are these
pre-commit hooks:

- `pre-commit-hooks`: no trailing whitespace, a final newline in every file, no
  merge conflict markers, no large added files, and valid JSON and YAML.
- `scripts/validate_skill.py`: every skill's frontmatter is valid, and its title
  heading is its name.
- `scripts/validate_agent.py`: every subagent file's frontmatter is valid.
- `claude plugin validate`: the plugin and marketplace manifests are valid.
- `remark-validate-links`: every link between Markdown files resolves to a file
  and, where it names one, a heading.
- `markdownlint-cli2` and Prettier: Markdown follows one set of style rules and
  one layout.
- `scripts/check_invisible_chars.py`: no text file contains an invisible
  character.
- `uncoded sync`: the documentation index is current.

#### No suppressions

No lint or formatting rule is disabled for part of a file or for a single file.

- Measure: the number of `markdownlint-disable`,
  `markdownlint-disable-next-line` and `prettier-ignore` markers in the
  repository's Markdown.
- Bar: zero. A rule that does not suit the project is disabled for every file in
  `.markdownlint.json`, as `MD013` is. Files that are not authored source, such
  as generated skill files, are excluded from the Markdown hooks in
  `.pre-commit-config.yaml`; an exclusion is not a suppression.
- Check: review.

#### Current tracker

The open issues on GitHub are consistent with the current plugin and its
documents.

- Measure: the number of open issues that use a retired term, ask for work
  already done, concern a skill the plugin no longer has, or ask for behaviour
  that a story excludes.
- Bar: zero.
- Check: the issue sweep before each release, and `dream:sift` for each issue
  that has no triage outcome yet.

#### Reviewed changes

Every pull request is reviewed against this standard before it merges.

- Measure: the number of pull requests merged since the last release whose
  description omits any of these: what it changes and why, a link to any issue
  or specification it relates to, and answers to the definition of done.
- Bar: zero, excluding the dependency updates that Dependabot opens.
- Check: review, which reads the answers before the pull request merges.

### Elegance

These three criteria are checked by review alone, and call for more judgement
than the others. A finding under them must name the bar that is not met and give
the evidence. A preference for a different design is not a finding.

#### Rules not cases

The plugin specifies behaviour by general rules. A special case is text that
applies to one particular situation rather than stating a general rule. A
special case exists only where a constraint outside the project requires it, and
the ledger of special cases, [`docs/special-cases.md`](special-cases.md),
records it with that constraint as its cause. For example, a step that differs
by agent harness is a special case, and a difference between the agent harnesses
is its external cause.

- Measure: the number of special cases in the plugin that are not on the ledger,
  plus the number of ledger entries whose cause is a choice this project made.
- Bar: zero.
- Check: review, which asks of each new special case whether a more general rule
  would remove it.

#### Few concepts

The concepts page defines no concept that a combination of its existing concepts
can express.

- Measure: the number of concepts added to the concepts page without a
  specification showing that no combination of the existing concepts expresses
  them.
- Bar: zero. Removing a concept needs no justification.
- Check: review, through the definition of done's
  [Concepts' words](#definition-of-done) question. The specification is itself
  committed in a pull request, so review reads the justification with the
  change.

#### Symmetry

Where two parts of the plugin are variants of one another, they have
corresponding steps with corresponding names, and they share the text of any
step that does the same thing in both. The pairs of variants are `dream:smith`
and `dream:less`, `dream:code-review` and `dream:coherence-review`, and the
instructions for the two agent harnesses, Claude Code and Codex.

- Measure: the number of steps that one member of a pair has and the other
  lacks, plus the number of steps that do the same thing in both members but are
  written out in each rather than shared.
- Bar: zero, except where the concepts page or the stories state the difference
  between the two members.
- Check: review, comparing each pair step by step, starting from their headings
  in the documentation index.

## Definition of done

A pull request is done when its author can answer yes to each of these
questions, or can give the reason a question does not apply.

1. **Explained.** Does its description say what it changes and why, and link any
   issue or specification it relates to?
2. **Checks pass.** Does every pre-commit hook and every required CI check pass,
   with none suppressed or bypassed?
3. **Files justified.** Does every file it adds or changes meet
   [Single responsibility](#single-responsibility), and every file it adds meet
   [No orphaned files](#no-orphaned-files)?
4. **Concepts' words.** Is every domain term it introduces defined on the
   concepts page, or added to it in the same pull request, and does it avoid
   every term the concepts page retires?
5. **Documents still true.** Does every document that
   [True documents](#true-documents) covers still agree with the plugin?
6. **Every copy changed.** Does it change every other place that states a fact
   it changes?
7. **Replaced things removed.** Does it remove what it replaces?
8. **Names kept.** Does it leave unchanged every name in the interface that
   [the compatibility page](compatibility.md) defines? If not, does its
   description list each name it renames or removes?
9. **Contract still met.** If it changes `dream:smith`, `dream:less`,
   `dream:big` or `dream:scout`, does the skill still meet the version of
   dreamcatcher's agent contract that the compatibility page names, read against
   the contract itself?
10. **Cases on the ledger.** Is every special case it adds recorded on the
    ledger with its external cause?
11. **Line count.** Does it state the lines it adds to and removes from the
    plugin, as `git diff --shortstat` reports them for `plugins/dream` against
    its base branch? If it is a bug fix or maintenance change that grows the
    plugin, does it say why?

The pull request description answers each question under a "Definition of done"
heading. Each answer starts with the question's title in bold, not its number,
and gives the evidence for it. "Yes" alone is not an answer. An answer that a
question does not apply gives the reason, such as "It changes none of those
skills."

## Exceptions

A criterion may be waived for a specific location, never for the project as a
whole. The waiver is recorded with its reason where the criterion's check will
find it, such as an automated check's configuration or a comment beside a
suppression marker. A waiver without a stated reason is a violation of the
criterion.

## Measurement

Before each release, every criterion is measured and the enduring documents are
read against the plugin. The results replace the previous ones in
`docs/measurement.md`, which records how each measure was taken so that the next
measurement can repeat it. The first release creates that page. Each shortfall
is filed as an issue unless an open issue already covers it. A shortfall does
not block a release.
