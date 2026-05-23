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

## Development notes

`protocol.md` is the source of truth for shared session flow and
cross-agent mechanics. Role-specific detail goes in the relevant agent file. Keep protocol.md and agent files
consistent with each other — neither should invent behaviour the
other contradicts.

This repo is mostly plugin metadata, skills, and agent prompts. There is no test suite. When changing behavior, validate by reading the affected skill/agent prompts together and checking that lifecycle, role boundaries, and tool permissions remain consistent. Run the pre-commit hooks to check formatting; see the Linting section.

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

In normal coding-assistant conversation (i.e. when we are not
inside a `/dream:team` session), don't use protocol vocabulary —
phase names, role names, Ancillary Finding, post-merge sweep,
and so on. The user is developing the protocol, not running it.

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
