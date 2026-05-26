# dream plugin for claude code

This repo defines the dream plugin for claude code. You are a coding assistant helping the user to develop the dream plugin.

## Introduction and orientation

The dream plugin launches a multi-agent team for software development. The goal is to deliver high-quality code, keep the codebase coherent, and do both with minimal input from the user.

The plugin is defined within the `plugins/dream` folder.

The entry point to launching the plugin is the `plugins/dream/skills/team/SKILL.md` skill, which the user invokes via the `/dream:team` command.

The dream:team skill then spawns the agent team. Each agent is defined via a system prompt within the `plugins/dream/agents` folder.

The agents then operate according to a common protocol. The shared
session flow — phases, roles, and cross-agent mechanics — is defined
in `plugins/dream/skills/team/protocol.md`. Role-specific operating
detail lives in the agent files under `plugins/dream/agents/`.

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin** — `protocol.md`, the skill, and the
  agent files. These are the plugin's code; they get
  installed and run when someone uses `/dream:team`.
- **This file (AGENTS.md)** — meta-documentation for the
  coding assistant helping the dream plugin developer. One
  layer up; describes how to develop the plugin.

Two ways they get crossed:

- **In chat**, slipping into protocol vocabulary — phase
  names, role names, Ancillary Finding, post-merge sweep —
  when not inside a `/dream:team` session. The developer is
  developing the protocol, not running it.
- **When writing AGENTS.md**, speaking as if it's inside
  the protocol. "The agents in this protocol", "Surface
  what investigation reveals", "in a SendMessage to a
  teammate" all treat AGENTS.md as part of the protocol.
  Use third-party voice instead: "the dream-team agents",
  "the team surfaces…", "to another agent".

## Development notes

`protocol.md` is the source of truth for shared session flow and
cross-agent mechanics. Role-specific detail goes in the relevant agent file. Keep protocol.md and agent files
consistent with each other — neither should invent behaviour the
other contradicts.

This repo is mostly plugin metadata, skills, and agent prompts. There is no test suite. When changing behavior, validate by reading the affected skill/agent prompts together and checking that lifecycle, role boundaries, and tool permissions remain consistent. Run the pre-commit hooks to check formatting; see the Linting section.

## Design principles

The dream plugin's goal is **autonomous coherent coding** —
great code with minimal user intervention.

Coherent is the baseline, not the ceiling. The deeper aim is
for the team to find the productive generalisation — a design
that names a real concept, a domain idea or a technical
pattern, collapses duplication, and reveals intent — so the
code comes out simpler, easier to maintain, easier to test
and check for correctness, and cheaper to build on. Default
coding agents rarely get there: they follow instructions
literally, add rather than restructure, and leave the latent
generalisation unseen. Setting the conditions that let the
team find it is part of the dream. It stays bounded by the
discipline against speculative abstraction — the
generalisation must genuinely simplify the code in hand,
never add machinery for a future that may not come.

Several principles follow:

- **Evaluate every change against autonomy.** A change that
  makes the team more responsive to user pushback doesn't
  count — it papers over the failure rather than preventing
  it. The team should catch what would otherwise require
  user redirection.
- **The team judges every input on its merits, not its
  source.** The dream team's default pull is to defer — to
  accept a teammate's finding because it was raised, to trust
  existing code because it's already there, to take the
  session input's claims as settled because the user brought
  them in. That deference is sycophancy, and it is an autonomy
  failure: a team that defers needs the user to catch what it
  should have caught itself. The team weighs each input on the
  evidence, whoever supplied it; "the session input is a seed"
  below is one instance.
- **The session input is a seed, not a contract.** The user
  opens with session input that seeds the Requirements
  Analysis.
  Subsequent phases build a more systematic picture from
  that seed and may revise it. The team surfaces what
  investigation reveals, even when it widens beyond the
  literal ask. The user can decline the wider scope
  explicitly via the Minimal Scope option.
- **Each phase artifact has its own purpose; don't mix
  concerns.** Requirements Analysis is about user intent.
  Code Analysis is about code patterns. Scope is the work
  commitment. Design is the proposal. Code-pattern findings
  don't belong in the Requirements Analysis, and vice versa.

## Writing agent prompts

The dream-team agents are LLMs. Three things matter when
writing or revising their prompts:

- **Agents reason by producing tokens** — thinking tokens,
  turn output, or tokens written to files or messages. An
  instruction like "pause and consider X" produces no tokens
  and has no effect; the agent reads it and moves on. To
  make a check real, direct the agent to externalise: write
  the answer in turn output, in a `SendMessage` to another
  agent, or in an artifact.
- **Agents reason forward from context** — they're
  next-token machines, with no premonition about what
  they're about to write. So "before reaching for X, do Y"
  doesn't work; the agent doesn't know they're about to
  reach for X. Checks have to fire after the candidate
  content exists in context. "If you notice you've written
  X" is what works.
- **Agents act on a name's face value** — a literal-following
  model obeys the everyday sense of the words you name things
  with: slots, moves, roles, phases. The name is a stronger
  instruction than the prose beneath it, so the body won't
  rescue a name that pulls the wrong way. Treat naming as a
  design decision: when you introduce or rename a concept,
  weigh the word's plain pull against the behaviour you want,
  and pick a different word when they conflict. A name whose
  plain sense already points at the behaviour needs no help
  from the prose.

## Writing prose

When you write or edit prose in this repo — agent prompts, the
protocol, skill bodies — write plain English. The reader is the
agent who will run the protocol or the developer who will
maintain it. Both pay a tax on jargon and indirection.

- **Don't invent umbrella terms.** If you reach for one
  ("tree-shaping command") to cover a list you've already named,
  drop it; the examples do the work. Don't coin new protocol
  vocabulary unless it names a genuinely distinct concept being
  introduced for the first time.
- **Plain verbs, not idioms.** "Lands the commit," "ships the
  change," "the trap is" read as code-author shorthand. Say
  "runs git," "creates the commit," "the risk is."
- **Lead with the actor and the action.** "Ralph reads
  imperative verbs as instructions" beats "the trap is verbs
  like…" — the second form makes the reader decode who's
  trapped before they can act.
- **Open instruction paragraphs with the imperative.** Lead
  with what to do, then 1-3 sentences of examples or
  follow-on, then any exceptions. "Check each scope item for
  X" beats "For each scope item, check whether X" — the
  qualifier shouldn't bury the verb.
- **Lead with the main point; cut tangential consequence
  detail.** State the boundary first. Mention the one or two
  reasons that actually shape decisions, not every downstream
  effect.
- **Generalise rules; don't pin them to the incident.** A rule
  that surfaces from one failure mode (verbs at the tail of a
  numbered step list) should be stated for the general case (git
  verbs anywhere). Specific examples illustrate; they don't
  narrow the rule.
- **Keep rules small.** A single sentence usually does the work
  of a prescriptive template. Don't add scaffolding (mandatory
  tails, worked examples, taxonomies) unless the bare rule
  genuinely leaves a real ambiguity.
- **Consistent voice within a list.** A "you never" bullet list
  shouldn't slip into "you do this instead" mid-bullet. Pick the
  voice and stay in it; cross-references can carry the positive
  alternative.

## Linting

The repo uses [`pre-commit`](https://pre-commit.com/) for lightweight checks: trailing whitespace, end-of-file newlines, JSON syntax, Markdown style (`markdownlint-cli2` — see `.markdownlint.json` for tuned rules), `claude plugin validate` on the plugin and marketplace manifests, and YAML frontmatter validation on skill and agent files.

Set up locally:

```bash
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI on every push and pull request (see `.github/workflows/lint.yml`). The `claude plugin validate` hook requires the Claude Code CLI on `PATH`; CI installs it via `npm`.

## Recommended resources

- [Claude Code Docs > Tools and plugins > Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Claude Code Docs > Tools and plugins > Extend Claude with skills](https://code.claude.com/docs/en/skills.md)
- [Claude Code Docs > Agents > Create custom subagents](https://code.claude.com/docs/en/sub-agents.md)
- [Claude Code Docs > Agents > Run agent teams](https://code.claude.com/docs/en/agent-teams.md) — The dream plugin depends on this feature. It is experimental; read this doc before changing any plugin or team mechanics.
- [Claude API Docs > Prompt engineering > Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md) — Read this before changing any skill, protocol, or agent file.

## Release protocol

There is no release process. The plugin is installed directly from this GitHub repo's main branch.

When opening a PR, include a version bump. Micro version bump for bug fixes. Minor version bump for all other changes while on the 0.x series. This ensures that all changes that get merged to main will include a version bump.
