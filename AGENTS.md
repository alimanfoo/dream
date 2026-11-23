# Developing dream

dream is a plugin of skills for Claude Code and Codex. This is its contributor
guide: what to read before you work, and the conventions this repository
follows.

## The repository

Users install only `plugins/dream`; everything else supports its development.
Rules here govern development. Rules that the installed skills follow belong in
the plugin.

## Starting a session

At the start of each session, update from main and install the pre-commit hooks:

```bash
git pull origin main
uvx pre-commit install
```

Before you search, read or edit Markdown, load the `uncoded-doc-navigation`
skill. It points you to `.uncoded/docs.yaml`, an index of every Markdown file
and its headings.

## The enduring documents

Three documents define dream's vocabulary, its intended behaviour and its
quality criteria. Read them before you work. A pull request that changes
behaviour one of them describes updates that document too.

- [`docs/concepts.md`](docs/concepts.md): the vocabulary.
- [`docs/stories.md`](docs/stories.md): the intended behaviour.
- [`docs/standard.md`](docs/standard.md): the quality criteria and the
  definition of done.

## Design rationale

The plugin is designed around these tendencies of coding agents:

- **Perimeter fixation**: fixes the site a request names, not the cause, and
  stops at a boundary it has set itself.
- **Shallow code reading**: guesses names and searches for them instead of
  tracing the code, so misses what the guess did not name.
- **Over-engineering**: adds abstraction the requirement does not justify, with
  no limit on complexity.
- **Addition over removal**: adds lines rather than deleting them.
- **Sycophancy**: defers to the person it works with rather than to the
  evidence.
- **Literal-mindedness**: follows the instance and misses the general rule.
- **Saliency decay**: attends less to earlier context as a session grows.
- **No memory between sessions**: starts each session with only what its context
  and the repository provide.
- **Over-eagerness**: attempts an underspecified request instead of questioning
  it.
- **Reactivity**: answers what is asked and volunteers nothing.

An instruction not to show a tendency does not remove it. The plugin counters
each tendency with structure, such as a step or a subagent, and where it can,
puts the tendency to work. For example, `dream:smith`'s Collect step has the
agent file an issue for each piece of work it left out of scope, which perimeter
fixation and reactivity would otherwise drop.

## How we judge

Apply these judgments, alongside the enduring documents and the design
rationale, whenever you weigh a proposed change. Each records a lesson from past
triage; add one only with the user's approval.

- **Recorded behaviour outranks predicted behaviour.** How agents behave under a
  skill is established by records of harness sessions that ran it: pull
  requests, issue comments and session transcripts. A prediction made by reading
  the skill's text is a hypothesis until such a record confirms it.
- **An instruction has a cost in every session.** Each instruction in a skill
  adds tokens to the context of every harness session that invokes the skill,
  and competes with the skill's other instructions for the model's attention. It
  helps only in the cases it covers, so weigh that cost against how often those
  cases occur.
- **Change the system that defines the behaviour.** When a fix in a skill would
  restate how dreamcatcher, an agent harness or GitHub behaves, or compensate
  for that behaviour, make the fix in that system instead. If the system is
  outside the user's control, close the issue and record the behaviour as a
  limitation in the closing comment.
- **Weigh a measurement finding against the skill's purpose.** The release
  measurement reports each place where the plugin misses a criterion of the
  standard, such as Symmetry between paired skills. When the fix for a finding
  would remove a difference that a skill needs for its purpose, such as less
  using fewer tokens than smith, keep the difference and state it in the
  stories.

## Changing the plugin

### Read the guides first

Before you change a skill or a subagent file, read the guide to agent mechanics
in `plugins/dream/skills/agent-mechanics/`: `SKILL.md`, then `claude-code.md`
and `codex.md`. Before you change code, read `plugins/dream/coherent-coding.md`.
Read both from the working tree, not by invoking their skills: an invoked skill
loads from the installed plugin, which may be an older release.

When you change the guide to agent mechanics, check each changed claim against
the sources that
[`docs/agent-mechanics-sources.md`](docs/agent-mechanics-sources.md) lists for
its section, and add any new source to that list.

### Two kinds of skill

Most skills instruct a coding agent. The collaborative product management
skills, `dream:sift`, `dream:spark`, `dream:trace`, `dream:weave` and
`dream:quest`, are written in the user's voice, as if the user had typed them:
"ask me", "tell me only what you've read". Do not rewrite a skill in the user's
voice as third-person instructions to the agent.

In every skill, write the frontmatter `description` in the third person, because
the agent harness lists it in the coding agent's context, where the model reads
it to choose a skill.

### Shared files

Each file at the plugin's root holds one convention or guide that several skills
follow. Reference the file from a skill; don't copy its content.

### Subagent files

Keep a short subagent task inline in the skill that launches it. Move it to a
subagent file in `plugins/dream/agents/` when it is long or more than one skill
launches it.

Name a subagent file for the task it performs, not for the skill that launches
it, because under Claude Code a subagent and a skill with the same name share
the scoped name `dream:foo`, which makes a reference to it ambiguous (see the
[guide to agent mechanics](plugins/dream/skills/agent-mechanics/claude-code.md#plugin-names)).

### References to skills, subagent types and labels

Use these forms for references to skills, subagent types and labels:

- Write a skill reference as `dream:foo`, with no leading slash. Both agent
  harnesses resolve that identifier, so a coding agent can act on it as written.
- Write `/dream:foo`, with a leading slash, where the reference stands for what
  a person types: the documentation site, a frontmatter `description:` field, a
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

Tell each agent only what it needs to do its task. An agent treats every line as
a possible instruction, so background it does not need dilutes the instructions
that matter and can lead it to act on an aside. Typical examples are how a
mechanism works when the agent takes no part in it, why a past decision was
made, and what another role does later. Before you add a piece of context, ask
whether this reader needs it for its task.

### Instruction paragraphs

Order the parts of an instruction paragraph as condition, imperative, reason,
examples, exceptions. Omit the parts you do not need, and keep the rest in that
order, so that the reader knows what to do before it reads why.

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
hooks in `.pre-commit-config.yaml`, which CI (`.github/workflows/lint.yml`) runs
on every pull request and every push to main. Run them all with
`uvx pre-commit run --all-files`. The standard's
[Machine-checked rules](docs/standard.md#machine-checked-rules) says what each
enforces.

Prettier formats Markdown at 80 columns, and `uncoded sync` regenerates
`.uncoded/docs.yaml` and the `uncoded-doc-navigation` skill. Don't hand-wrap
Markdown, and don't hand-edit the generated files.

## Documentation site

Add every new page to the navigation in `mkdocs.yml`. When you add, remove or
change what a skill does, update `docs/index.md`. Keep each skill to one table
row, so the table shows the whole plugin at a glance. When `dream:smith` changes
the steps it reports, update the sample session in `overrides/home.html` to
match.

Preview the site locally:

```bash
uvx --with-requirements docs/requirements.txt mkdocs serve
```

## Pull requests

Answer [the definition of done](docs/standard.md#definition-of-done) in every
pull request description, as the standard specifies. Keep the rest of the
description short and current: say what the pull request does and why, and leave
line-by-line detail to the diff. Update the description whenever a later commit
changes what the pull request does.

Say what the pull request changes for a user, and whether it renames or removes
a name in [the interface](docs/compatibility.md#the-interface): the next
release's changelog is written from these descriptions. Leave the version and
the changelog alone; both change only at a release.

## Releases and the manifest

Users install a release, not main: the plugin entry in
`.claude-plugin/marketplace.json` is pinned to the latest release's tagged
commit. Make a release only when the user asks for one, in a harness session
with them, by following [the release checklist](docs/releasing.md). It sets the
version by the rules on
[the compatibility page](docs/compatibility.md#versions).

The plugin's version lives only in `plugins/dream/.codex-plugin/plugin.json`.
The version in `pyproject.toml` is a placeholder that `uv` requires; never
change it.

The manifest is a real file under `.codex-plugin/`, and
`.claude-plugin/plugin.json` is a symlink to it, because Codex drops symlinks
when it installs a plugin and Claude Code follows them. `claude plugin validate`
warns that it ignores the `interface` block; keep the block, which Codex needs.
