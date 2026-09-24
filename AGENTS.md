# dream plugin for claude code

This repo defines the dream plugin for Claude Code and Codex. You are a coding
assistant helping the user to develop the dream plugin.

## The dream

This project provides tools for autonomous software engineering. The goal is to
enable coding agents to perform high-quality software development with less
input from humans.

## Introduction and orientation

The dream plugin lives in the `plugins/dream` folder.

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin**: the code under `plugins/dream`, which anyone who
  installs the plugin gets.
- **Developer support**: AGENTS.md. It supports plugin development and is not
  part of the installed plugin.

## Development notes

The collaborative product management skills, `dream:spark`, `dream:scout`,
`dream:weave` and `dream:seer`, are an experiment, trying a different approach
from the rest of the plugin. They run against repo convention on purpose, so
treat a deviation as deliberate rather than as drift to tidy up.

The bodies of the collaborative skills are written in the user's voice, as if
the user typed it: "ask me", "tell me only what you've read". Don't normalise
any of them back to the third person, or into a stack of orders. The frontmatter
`description` stays third person in all of them, since the harness reads that to
pick the skill.

Keep a simple subagent task prompt inline in the skill that launches it. When a
task prompt earns its own file, put it in `plugins/dream/agents/`. Claude Code
reads a file there as a named agent, and a plain Codex subagent takes the same
file's absolute path, so one file serves both hosts.

Name an agent for the job it does, not for the skill that launches it. Claude
Code takes an agent's name as a `dream:foo` subagent type, the same shape a
skill reference takes, so an agent sharing its skill's name leaves the reference
ambiguous.

Make every skill that launches subagents under both hosts read
[`subagent-waiting.md`](plugins/dream/subagent-waiting.md). It owns the
cross-host completion rule.

The collaborative skills all read
[`spec-files.md`](plugins/dream/spec-files.md). It owns where a specification
file goes and how it reaches the user on a pull request, so those skills don't
each carry their own copy of the convention.

The prose in this repo references a skill, an agent, or an issue label one way
throughout:

- Write a skill reference as `dream:foo`, with no leading slash. Both hosts
  resolve that identifier, so an agent can act on it as written.
- Keep the leading slash, `/dream:foo`, where the reference stands for what a
  person types: the README, a frontmatter `description:` field, a launch banner,
  and a line the agent shows the user.
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

Coding agents carry inherent traits that work against the dream. These include:

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

Writing well for an agent depends on what it needs to know, the shape of an
instruction, and its properties as a reader.

### Tell each agent only what it needs

Tell each agent only what it needs to do its job, and cut the rest. The agent
reads every line as potentially actionable. So non-essential background dilutes
the instructions that matter and tempts the agent to act on the aside. Examples:
how a mechanism it isn't part of works, why a past decision was made, what
another role does downstream. When you catch yourself adding context, ask
whether this reader uses it to do their job. If not, cut it.

### Instruction paragraphs

The Plain English guide ([`plain-english.md`](plugins/dream/plain-english.md))
sets the shape of an instruction paragraph: the imperative first, then the why,
then examples, then exceptions.

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

### The agent as a reader

These properties of that reader change how you write for it.

**Agents reason by producing tokens**: thinking tokens, turn output, or tokens
written to files or messages. An instruction like "pause and consider X"
produces no tokens and has no effect. The agent reads it and moves on. To make a
check real, direct the agent to externalise: write the answer in turn output or
in an artifact.

**Agents reason forward from context**: they're next-token machines, with no
foresight of what they're about to write. So "before reaching for X, do Y"
doesn't work. The agent doesn't know they're about to reach for X. A check has
to run after the candidate content exists, and it has to name an act: "reread
the draft and cut any X".

## Writing prose

The prose standard for this repo is the Plain English guide
([`plain-english.md`](plugins/dream/plain-english.md)). Follow it for every
prose artifact: agent prompts, the protocol, skill bodies, these dev notes.

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
installs it via `npm`. The `uncoded` hook requires `uvx` on `PATH`. CI provides
it via `astral-sh/setup-uv`.

## Release protocol

There is no release process. The plugin is installed directly from this GitHub
repo's main branch.

When opening a PR, include a version bump in
`plugins/dream/.codex-plugin/plugin.json`, so every change merged to main is
versioned.

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

A change that touches only this developer meta-doc (`AGENTS.md`) needs no bump.
It isn't part of the installed plugin.

Keep the PR description short and current: say what the PR does and why, and
leave line-by-line detail to the diff. Update the body whenever a later commit
materially changes what the PR does.

## Before you start

Load the `uncoded-doc-navigation` skill before searching, reading or editing any
Markdown files in this codebase.
