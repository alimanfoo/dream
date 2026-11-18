# dream plugin for claude code

This repo defines the dream plugin for Claude Code and Codex. You are a coding
assistant helping the user to develop the dream plugin.

## Introduction and orientation

The dream plugin lives in the `plugins/dream` folder.

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin**: the code under `plugins/dream`, which anyone who
  installs the plugin gets.
- **Developer support**: AGENTS.md. It supports plugin development and is not
  part of the installed plugin.

## The enduring documents

These documents carry dream's lasting understanding, and the skills are held to
them. Read them before you work.

- [`docs/concepts.md`](docs/concepts.md) says what the words for dream's domain
  mean. Use its words and no others, in the skills, the documents and the
  issues.
- [`docs/stories.md`](docs/stories.md) records what dream is meant to do: what
  the user does with its skills, what the agent does, and what the user has at
  the end.

## Development notes

Before you change a skill or a subagent file, read the guide to agent mechanics
at `plugins/dream/skills/agent-mechanics/SKILL.md`. It describes how an agent
will read and act on what you write. Before you change code, read the coherent
coding guide at `plugins/dream/coherent-coding.md`. Read both by these paths in
the working tree, not by skill name, since a skill name loads the installed copy
of the plugin, which can be older than the working tree.

When you change the guide to agent mechanics, check each changed claim against
its sources, and update the paragraph's entry in
[`docs/agent-mechanics-sources.md`](docs/agent-mechanics-sources.md). That file
lists the sources that support each paragraph of the guide, and the versions
they are pinned to.

The collaborative product management skills, `dream:sift`, `dream:spark`,
`dream:trace`, `dream:weave` and `dream:quest`, are an experiment, trying a
different approach from the rest of the plugin. They run against repo convention
on purpose, so treat a deviation as deliberate rather than as drift to tidy up.

The bodies of the collaborative product management skills are written in the
user's voice, as if the user typed it: "ask me", "tell me only what you've
read". Don't normalise any of them back to the third person, or into a stack of
orders. The frontmatter `description` stays third person in all of them, since
the harness reads that to pick the skill.

The collaborative product management skills that write a specification all read
[`spec-files.md`](plugins/dream/spec-files.md). It owns where a specification
file goes and how it reaches the user on a pull request, so those skills don't
each carry their own copy of the convention.

Make every skill that needs the default branch or the current branch's review
base read [`branch-bases.md`](plugins/dream/branch-bases.md). It owns how a
skill finds the default branch and the review base.

Keep a simple subagent task prompt inline in the skill that launches it. When a
task prompt earns its own file, put it in `plugins/dream/agents/`, so that one
file serves both agent harnesses. The
[guide to agent mechanics](plugins/dream/skills/agent-mechanics/SKILL.md#subagent-definitions)
says how each agent harness reads a file there.

Name an agent for the job it does, not for the skill that launches it. Under
Claude Code, an agent that shares its skill's name makes a `dream:foo` reference
ambiguous, as the
[guide to agent mechanics](plugins/dream/skills/agent-mechanics/SKILL.md#plugin-names)
explains.

Make every skill that tells the agent to write text that GitHub renders, such as
a pull request description or a comment, link
[`github-text.md`](plugins/dream/github-text.md). It owns how that text is laid
out.

Make every skill that launches subagents under both hosts read
[`subagent-waiting.md`](plugins/dream/subagent-waiting.md). It owns the
cross-host completion rule.

The prose in this repo references a skill, an agent, or an issue label one way
throughout:

- Write a skill reference as `dream:foo`, with no leading slash. Both hosts
  resolve that identifier, so an agent can act on it as written.
- Keep the leading slash, `/dream:foo`, where the reference stands for what a
  person types: the documentation site, a frontmatter `description:` field, a
  launch banner, and a line the agent shows the user.
- Drop the backticks in a frontmatter `description:` field, a markdown heading,
  or a fenced command block.
- Write a skill file's title heading as `dream:foo`, so it names the skill a
  reader came looking for. `scripts/validate_skill.py` checks this on commit.
- Write a subagent-type identifier as `dream:foo`. That is what an `Agent`
  call's `subagent_type` takes.
- Write an issue label as "dream:foo".

This repo is mostly plugin metadata, skills, and agent prompts. There is no test
suite. When changing behaviour, read the affected skill and agent prompts
together. Check that lifecycle, role boundaries, and tool permissions stay
consistent. Run the pre-commit hooks to check formatting. See the Linting
section.

## What the design is answering

Coding agents carry inherent traits that work against good software engineering.
These include:

- **Perimeter fixation**: fixes the named site, not the cause. Resists working
  past a self-imposed boundary.
- **Shallow code reading**: guesses names and greps for them instead of tracing,
  and misses what the guess didn't name.
- **Over-engineering**: adds abstraction the need doesn't earn, with no felt
  bound on complexity.
- **Add over remove**: reaches for a new line, never a deletion.
- **Sycophancy**: defers to whoever spoke, rather than the evidence.
- **Literal-mindedness**: follows the instance, misses the general rule.
- **Saliency decay**: loses earlier context as the session grows.
- **No memory between sessions**: each session starts with a blank mind.
- **Over-eagerness**: attempts an underspecified ask rather than question it.
- **Reactivity**: answers what's asked, volunteers nothing.

Notes on how the plugin answers these:

**The answer is structural, not exhortative.** Telling an agent to be less
sycophantic produces no tokens and changes nothing. The plugin changes the
structure around the trait, not the trait itself. The idea is to exploit agent
traits rather than fight them.

## Writing agent prompts

Writing well for an agent depends on what it needs to know and the shape of an
instruction. How an agent reads what you write is in the guide to agent
mechanics.

### Tell each agent only what it needs

Tell each agent only what it needs to do its job, and cut the rest. The agent
reads every line as potentially actionable. So non-essential background dilutes
the instructions that matter and tempts the agent to act on the aside. Examples:
how a mechanism it isn't part of works, why a past decision was made, what
another role does downstream. When you catch yourself adding context, ask
whether this reader uses it to do their job. If not, cut it.

### Instruction paragraphs

Build an instruction paragraph in this order: any condition, the imperative, the
why, examples, exceptions. Skip any part you don't need, but keep the order of
the parts you use, so the reader knows what to do before they read why.

The why is the one that motivates the act, not the one that motivates the
design. The reason the prompt is _built_ this way (design history, justification
for a decision already made) belongs in the PR description and commit message,
not the instruction.

Two more rules govern the instruction's content:

- **Generalise rules. Don't pin them to the incident.** A rule that surfaces
  from one failure mode (verbs at the tail of a numbered step list) should be
  stated for the general case (git verbs anywhere). Specific examples
  illustrate. They don't narrow the rule.
- **Keep rules small.** A single sentence usually does the work of a
  prescriptive template. Don't add scaffolding (mandatory tails, worked
  examples, taxonomies) unless the bare rule leaves a real ambiguity.

## Linting

The repo uses [`pre-commit`](https://pre-commit.com/) for lightweight checks:

- trailing whitespace, end-of-file newlines, and JSON syntax
- Markdown style (`markdownlint-cli2`, with tuned rules in `.markdownlint.json`)
- Markdown formatting (`prettier`, which reflows prose to an 80-column width, so
  lines never need wrapping by hand)
- Markdown link validation (`remark-validate-links`, which checks within-file
  and cross-file anchor links resolve to real headings)
- invisible characters such as non-breaking spaces, zero-width marks, and bidi
  controls (`scripts/check_invisible_chars.py`)
- `claude plugin validate` on the plugin and marketplace manifests
- GitHub Actions workflow security (`zizmor`, run offline)
- YAML frontmatter validation on skill and agent files
- the documentation index (`uncoded sync`, which regenerates
  `.uncoded/docs.yaml` and the `/uncoded-doc-navigation` skill)

At the start of each session, pull the latest `main` and install the hooks:

```bash
git pull origin main
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI
on every push and pull request (see `.github/workflows/lint.yml`). The
`claude plugin validate` hook requires the Claude Code CLI on `PATH`. CI
installs it via `npm`. The `uncoded` hook requires `uv` on `PATH`. CI provides
it via `astral-sh/setup-uv`.

## Documentation site

The documentation site is built with MkDocs and the Material theme. `mkdocs.yml`
sets the navigation, so add every new page to it. The home page text is in
`docs/index.md`, and the headline and lede are in its front matter. The hero,
including a sample `dream:smith` session, is in `overrides/home.html`, and the
styling is in `docs/assets/dream.css`. The `docs` workflow builds the site on
every pull request that touches it, and publishes it to GitHub Pages from main.

When you add a skill, remove one, or change what one does, update
`docs/index.md`, because it describes every skill. Keep each skill to one row in
its table, so a reader can take in the whole plugin at a glance. When
`dream:smith` changes the steps it reports, update the sample session to match.

Preview the site locally:

```bash
uvx --with-requirements docs/requirements.txt mkdocs serve
```

## Release protocol

There is no release process. The plugin is installed directly from this GitHub
repo's main branch.

When opening a PR, include a version bump in
`plugins/dream/.codex-plugin/plugin.json`, so every change merged to main is
versioned.

`pyproject.toml` has a placeholder version that uv requires. Never bump it. The
plugin's version lives only in `plugins/dream/.codex-plugin/plugin.json`.

The manifest sits under `.codex-plugin` because Codex drops symlinks when it
installs a plugin, and Claude Code follows them. So
`plugins/dream/.claude-plugin/plugin.json` is a symlink to it, and both hosts
read one file.

`claude plugin validate` reads that file too, and warns that it ignores the
`interface` block. Codex needs the block, so leave it in place.

Which part to bump:

- **Major**: a structural or breaking change to existing behaviour.
- **Minor**: an additive, non-breaking change.
- **Micro**: a bug fix.

A change that touches only this developer meta-doc (`AGENTS.md`) or the
documentation site needs no bump. Neither is part of the installed plugin.

Keep the PR description short and current: say what the PR does and why, and
leave line-by-line detail to the diff. Update the body whenever a later commit
materially changes what the PR does.

## Before you start

Load the `uncoded-doc-navigation` skill before searching, reading or editing any
Markdown files in this codebase.
