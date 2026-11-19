# Developing dream

This repository holds dream, a plugin of skills for Claude Code and Codex. This
file orients anyone who develops or maintains dream, whether a person or a
coding agent, to the project's essential documents and conventions.

## The repository

Only `plugins/dream` is installed. The rest of the repository supports its
development. Its main parts are:

- `plugins/dream/`: the plugin's skills, subagent files, shared files and
  manifest.
- `.claude-plugin/marketplace.json`: the marketplace that offers the plugin.
- `docs/`, `mkdocs.yml` and `overrides/`: the documentation site.
- `specs/`: the specifications, one folder per piece of work.
- `scripts/`: the scripts that the pre-commit hooks run.
- `AGENTS.md`: this file, which `CLAUDE.md` imports.

A rule written here governs development only. A rule that the installed skills
must follow belongs in the plugin.

## Starting a session

At the start of each harness session, bring your branch up to date with main and
install the pre-commit hooks:

```bash
git pull origin main
uvx pre-commit install
```

Before you search, read or edit any Markdown file, load the
`uncoded-doc-navigation` skill. It directs you to the documentation index,
`.uncoded/docs.yaml`, which lists every Markdown file and its headings.

## The enduring documents

Three documents define dream's vocabulary, its intended behaviour and the
criteria it is held to. Read them before you work. A change to behaviour that
one of them describes updates it in the same pull request.

- [`docs/concepts.md`](docs/concepts.md) defines the terms for dream's domain.
  Use its terms, and not the terms its "Replaces:" lines retire, in the skills,
  the documents and the issues.
- [`docs/stories.md`](docs/stories.md) specifies dream's intended behaviour as
  scenarios. Each story gives the user's goal, the steps that the user and the
  agents take, and the outcome.
- [`docs/standard.md`](docs/standard.md) sets out the criteria dream is held to,
  how each is measured, and what enforces it. Its definition of done applies to
  every pull request.

## Design rationale

The plugin is designed around these tendencies of coding agents, each of which
works against good software engineering:

- **Perimeter fixation**: fixes the site a request names, not the cause, and
  stops at a boundary it has set itself.
- **Shallow code reading**: guesses names and searches for them instead of
  tracing the code, so misses what the guess did not name.
- **Over-engineering**: adds abstraction the requirement does not justify, with
  no limit on complexity.
- **Add over remove**: adds lines rather than deleting them.
- **Sycophancy**: defers to the person it works with rather than to the
  evidence.
- **Literal-mindedness**: follows the instance and misses the general rule.
- **Saliency decay**: attends less to earlier context as a session grows.
- **No memory between sessions**: starts each session with only what its context
  and the repository provide.
- **Over-eagerness**: attempts an underspecified request instead of questioning
  it.
- **Reactivity**: answers what is asked and volunteers nothing.

An instruction not to show a tendency does not remove it. The plugin instead
changes the structure around each tendency, and where it can, works with the
tendency rather than against it. For example, the Collect step of `dream:smith`
has the agent file an issue for each thing it left out of scope, which records
the work that perimeter fixation and reactivity would otherwise drop.

## Changing the plugin

### Read the guides first

Before you change a skill or a subagent file, read the guide to agent mechanics
in `plugins/dream/skills/agent-mechanics/`: `SKILL.md`, then `claude-code.md`
and `codex.md`, since dream runs under both agent harnesses. It describes how a
coding agent reads and acts on what you write. Before you change code, read the
coherent coding guide, `plugins/dream/coherent-coding.md`. Read both by these
paths in the working tree, not by invoking their skills: a skill invoked by name
loads from the installed copy of the plugin, which can be older than the working
tree.

When you change the guide to agent mechanics, check each changed claim against
the sources that
[`docs/agent-mechanics-sources.md`](docs/agent-mechanics-sources.md) lists for
its section, and add any new source to that list. The same file gives the
versions the sources are pinned to.

### Two kinds of skill

Most skills instruct a coding agent. The collaborative product management
skills, `dream:sift`, `dream:spark`, `dream:trace`, `dream:weave` and
`dream:quest`, are written in the user's voice, as if the user had typed them:
"ask me", "tell me only what you've read". Keep each skill in its own kind: do
not rewrite a skill in the user's voice as third-person instructions to the
agent. In every skill, keep the frontmatter `description` in the third person:
the agent harness lists it in the coding agent's context, where the model reads
it to choose a skill. Both kinds are held to the same standard and the same
definition of done.

### Shared files

Each shared file at the plugin's root defines one convention or guide that
several skills follow. Make every skill that follows one reference its file,
rather than keep its own copy:

- [`agent-written-marks.json`](plugins/dream/agent-written-marks.json): the
  comment footer and commit trailer that mark work as written by an agent.
- [`branch-bases.md`](plugins/dream/branch-bases.md): how to find the default
  branch and the current branch's review base.
- [`coherent-coding.md`](plugins/dream/coherent-coding.md): the coherent coding
  guide, for skills that design, write or review code.
- [`github-text.md`](plugins/dream/github-text.md): the layout of text that
  GitHub renders, such as a pull request description or a comment.
- [`spec-files.md`](plugins/dream/spec-files.md): where a specification file
  goes, and how it reaches the user on a pull request.
- [`subagent-waiting.md`](plugins/dream/subagent-waiting.md): how to wait for
  launched subagents to finish, under each agent harness.

### Subagent files

Keep a short subagent task inline in the skill that launches it. When a task is
too long to keep inline, or more than one skill launches it, write it as a
subagent file in `plugins/dream/agents/`, so that one file serves both agent
harnesses. The guide to agent mechanics says how
[Claude Code](plugins/dream/skills/agent-mechanics/claude-code.md#subagent-definitions)
and [Codex](plugins/dream/skills/agent-mechanics/codex.md#subagent-definitions)
each read a file there.

Name a subagent file for the task it performs, not for the skill that launches
it. Under Claude Code, a subagent and a skill with the same name in one plugin
share the scoped name `dream:foo`, so a reference to `dream:foo` is ambiguous,
as the
[guide to agent mechanics](plugins/dream/skills/agent-mechanics/claude-code.md#plugin-names)
explains.

### References to skills, subagent types and labels

Refer to a skill, a subagent type or an issue label in the same way throughout:

- Write a skill reference as `dream:foo`, with no leading slash. Both agent
  harnesses resolve that identifier, so a coding agent can act on it as written.
- Keep the leading slash, `/dream:foo`, where the reference stands for what a
  person types: the documentation site, a frontmatter `description:` field, a
  launch banner, and a line the agent shows the user.
- Drop the backticks in a frontmatter `description:` field, a Markdown heading,
  or a fenced command block.
- Write a skill file's title heading as `dream:foo`, so it names the skill a
  reader came looking for. `scripts/validate_skill.py` checks this on commit.
- Write a subagent-type identifier as `dream:foo`. That is what an `Agent`
  call's `subagent_type` takes.
- Write an issue label as "dream:foo".

## Writing instructions for coding agents

These rules apply to skills and subagent files, which are instructions for
coding agents.

### Tell each agent only what it needs

Tell each agent only what it needs to do its task, and cut the rest. An agent
treats every line as a possible instruction, so background it does not need
dilutes the instructions that matter and can lead it to act on an aside. Typical
examples are how a mechanism it takes no part in works, why a past decision was
made, and what another role does later. For each piece of context you add, ask
whether this reader uses it to do its task. If not, cut it.

### Instruction paragraphs

Order an instruction paragraph as follows: any condition, the imperative, the
reason, examples, exceptions. Omit any part you do not need, but keep the order
of the parts you use, so that the reader knows what to do before reading why.

Give the reason that motivates the action, not the reason the instructions take
their shape. Design history and the justification for a decision already made
belong in the pull request description and the commit message, not in the
instruction.

Two further rules govern an instruction's content:

- **Generalise rules. Don't pin them to the incident.** State a rule that arose
  from one failure for the general case. For example, a rule prompted by git
  verbs at the end of a numbered list of steps applies to git verbs anywhere.
  Examples illustrate a rule; they do not narrow it.
- **Keep rules small.** A single sentence usually does the work of a
  prescriptive template. Do not add structure, such as mandatory closing
  sections, worked examples or taxonomies, unless the bare rule leaves a real
  ambiguity.

## Checks

There is no test suite. The checks are the [pre-commit](https://pre-commit.com/)
hooks that `.pre-commit-config.yaml` configures. The standard's
[Machine-checked rules](docs/standard.md#machine-checked-rules) lists what each
hook enforces in the plugin and its documentation; `zizmor` also audits the
workflows. Run every hook with `uvx pre-commit run --all-files`. CI runs the
same hooks on every pull request and on every push to main, in
`.github/workflows/lint.yml`.

Prettier rewraps Markdown prose at 80 columns, so do not wrap lines by hand.
`uncoded sync` regenerates the documentation index and the
`uncoded-doc-navigation` skill. Two hooks need a tool on `PATH`:
`claude plugin validate` needs the Claude Code CLI, which CI installs with
`npm`, and `uncoded sync` needs `uv`, which CI installs with
`astral-sh/setup-uv`.

## Documentation site

The documentation site is built with MkDocs and the Material theme. `mkdocs.yml`
defines the navigation; add every new page to it. The home page's text is in
`docs/index.md`, with its headline and lede in the front matter. The hero,
including a sample `dream:smith` session, is in `overrides/home.html`, and the
styles are in `docs/assets/dream.css`. The `docs` workflow builds the site for
every pull request that changes `docs/`, `mkdocs.yml`, `overrides/` or the
workflow, and on a push to main it also deploys the site to GitHub Pages.

When you add or remove a skill, or change what one does, update `docs/index.md`,
which describes every skill. Keep each skill to one table row, so that a reader
can take in the whole plugin at a glance. When `dream:smith` changes the steps
it reports, update the sample session to match.

Preview the site locally:

```bash
uvx --with-requirements docs/requirements.txt mkdocs serve
```

## Pull requests

End every pull request description with a "Definition of done" section that
answers each question in
[the standard's definition of done](docs/standard.md#definition-of-done) by its
title, with evidence. The questions make you look beyond the diff to every place
the change affects.

Keep the rest of the description short and current: say what the pull request
does and why, and leave line-by-line detail to the diff. Update the description
whenever a later commit materially changes what the pull request does.

If a pull request changes `plugins/dream`, bump the version in
`plugins/dream/.codex-plugin/plugin.json`, so that every change to the installed
plugin merges to main with its own version. Bump the part that the change calls
for, by the rules on [the compatibility page](docs/compatibility.md#versions).

## Versions and the manifest

There is no release process yet. Users install the plugin from the main branch,
through the marketplace in `.claude-plugin/marketplace.json`.

The plugin's version is set only in `plugins/dream/.codex-plugin/plugin.json`.
`pyproject.toml` has a placeholder version that `uv` requires; never change it.

The manifest is under `.codex-plugin` because Codex drops symlinks when it
installs a plugin, while Claude Code follows them.
`plugins/dream/.claude-plugin/plugin.json` is therefore a symlink to it, and
both agent harnesses read one file. `claude plugin validate` reads it too, and
warns that it ignores the `interface` block. Codex needs that block, so keep it.
