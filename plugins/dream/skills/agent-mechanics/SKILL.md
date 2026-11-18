---
name: agent-mechanics
description:
  Explains how a coding agent works under Claude Code and Codex, covering the
  context, the turn, skills, subagents, tools and compaction. Use when
  predicting what a prompt, a skill or a subagent file will make an agent do.
---

# dream:agent-mechanics

This guide describes the mechanics of a coding agent: what is in its context,
how a turn runs, and what happens when it invokes a skill, starts a subagent,
calls a tool or runs out of room. It covers Claude Code and Codex, and names a
difference between them only where the difference changes what follows. Each
claim links to its source.

## How the model reasons

A language model generates text one token at a time. To generate each token, it
computes over the whole context, meaning every token before it. The generated
token is then appended to the context, and the model computes again to generate
the next one. This process is called autoregressive generation ([Claude
glossary][api-glossary]). The computation for one position can draw only on
earlier positions ([Vaswani et al., 2017, §3.2.3][transformer]).

Three consequences follow.

1. **Nothing exists outside the context.** The model's trained weights are
   fixed. The computation that generates each token is determined by the tokens
   in the context, and nothing from it persists except the token it generates.
   There is no hidden process apart from token generation. Thinking is token
   generation too: the model generates tokens in a thinking block, which is part
   of the context but usually not shown to the user.
2. **Reasoning is token generation.** The model's reasoning consists of the
   tokens it generates: its thinking, its turn output and its tool calls. Each
   generated token is appended to the context, and the next token is generated
   from that context.
3. **Generation runs forward only.** When the model generates a token, the
   tokens after it don't exist yet. A generated token can't be revised. The
   model can only generate further tokens, and those can contradict or correct
   the earlier ones.

## The context

The agent harness builds the context. When a harness session starts, the context
holds the agent harness's system prompt, the repository's instruction files, and
the name and description of each available skill. The instruction files are
`CLAUDE.md` under Claude Code and `AGENTS.md` under Codex ([Claude Code
memory][cc-memory-load], [Codex `agents_md.rs`][cx-agents-md]).

As the session runs, the agent harness appends to the context each input, each
token the model generates, and each tool result. It can also append messages of
its own ([system reminder][cc-glossary-reminder]).

A new harness session starts with a fresh context. Nothing from an earlier
session is in it, except what the agent harness loads again from disk ([how
Claude Code works][cc-sessions]).

## The turn

A tool call is a structured block of tokens that names a tool and gives the
tool's input. When the model generates a tool call, its generation stops and the
agent harness runs the tool. The agent harness then appends the tool's result to
the context, and the model generates again from that context ([Claude tool
use][api-tool-use], [Codex `turn.rs`][cx-turn]).

This loop repeats until the model generates a response that contains no tool
call. That response is the turn output, and it ends the turn. A turn starts when
input arrives, usually a message from the user ([Claude Code
glossary][cc-glossary-turn], [Codex `turn.rs`][cx-turn]). Between turns the
model generates nothing. The next turn starts only when new input arrives.

A tool can change things outside the context, such as a file on disk or the
state of a repository. The context gains only the tool call and the result that
the agent harness appends.

## What a skill is

A skill is a folder whose one required file, `SKILL.md`, holds a name, a
description and a body. When a harness session starts, the agent harness appends
the name and description of every available skill to the context ([Claude Code
skills][cc-skills-invoke], [Codex `fragments.rs`][cx-fragments]).

Invoking a skill appends its body to the context ([Claude Code
skills][cc-skills-life], [Codex `fragments.rs`][cx-fragments]). Either the user
or the agent can invoke a skill. Nothing else happens: invoking a skill starts
no other process, transfers no control and returns no value. The same model goes
on generating tokens, from a context that now includes the body.

## Files and paths

The agent harness finds a skill or a subagent by its name. The agent finds a
file by its path, which it resolves itself.

A relative path in a skill has no fixed base. Codex's skill list tells the agent
to resolve it against the directory that holds the `SKILL.md` ([Codex
`catalog_prompt.rs`][cx-catalog]). Claude Code puts the skill's directory at the
head of the loaded text, as "Base directory for this skill" (observed in a
Claude Code transcript; not documented). A shell command runs in the working
directory, not in the skill's directory ([Claude Code skills][cc-skills-cwd]).

An installed plugin is a copy. Claude Code copies a marketplace plugin into a
directory named for its version, so the copy's path changes with each version
([Claude Code plugins][cc-plugin-cache]). The copy in use is therefore not the
one in a repository's working tree, and a name such as `dream:foo` loads the
installed copy.

## Subagents

A subagent is a second agent that the first agent starts with a tool call. It
runs in a context of its own ([Claude Code subagents][cc-sub-context], [Codex
`multi_agents_spec.rs`][cx-spawn-spec]).

What the subagent starts with depends on how it is started:

- **A fresh subagent** starts from a system prompt and the task message the
  parent wrote. It does not see the parent's transcript or the skills the parent
  has loaded. Under Claude Code, it also loads the repository's instruction
  files ([Claude Code subagents][cc-sub-context]), and its system prompt is the
  body of the subagent file with the working directory appended, without the
  file's location ([Claude Code subagents][cc-sub-files]).
- **A fork** starts with a copy of the parent's whole transcript ([Claude Code
  subagents][cc-sub-fork]). In Codex's multi-agent version 2, a spawned agent is
  a fork unless the call passes `fork_turns: "none"` ([Codex
  `spawn.rs`][cx-spawn-v2]). In version 1 it is fresh unless the call passes
  `fork_context: true` ([Codex `multi_agents_spec.rs`][cx-spawn-spec]). Which
  version runs depends on the configuration and the model ([Codex
  `config/mod.rs`][cx-mav]).

A subagent works with its own tools while it runs, so the files it writes and
the commands it runs take effect ([Claude Code subagents][cc-sub-checkpoints]).
When it finishes, its final message returns to the parent. Its tool calls do not
([Claude Code subagents][cc-sub-fork], [Codex
`multi_agents_spec.rs`][cx-spawn-spec]).

The two agent harnesses deliver that final message differently:

- **Claude Code** starts a subagent in the background by default. Its result
  reaches the parent as a notification, which starts a later turn ([Claude Code
  subagents][cc-sub-background]).
- **Codex** returns control to the parent at once. The parent calls `wait_agent`
  to block until an agent reaches a final status, and `list_agents` to see which
  agents are still running ([Codex `multi_agents_spec.rs`][cx-spawn-spec]).

The two agent harnesses also name subagents differently:

- **Claude Code** reads each Markdown file in a plugin's `agents/` directory as
  a subagent type, named with the plugin's prefix, such as
  `my-plugin:code-reviewer` ([Claude Code subagents][cc-sub-scoped]). A skill in
  the same plugin is named the same way ([Claude Code skills][cc-skills-name]),
  so a skill and a subagent type can share a name.
- **Codex** reads agent roles only from its configuration: the `agents` table
  and TOML files in a configuration folder's `agents/` directory ([Codex
  `loader.rs`][cx-roles-loader], [Codex `discovery.rs`][cx-roles-discovery]). It
  does not read a plugin's `agents/` files. A plain Codex subagent can read such
  a file only when the task message gives it the path.

## Tools and permissions

The agent acts only through its tools. Before a tool call runs, the agent
harness checks it against the permission mode and rules, and either runs it,
asks the user, or denies it ([Claude Code permissions][cc-permissions]).

When no one can answer a request for approval, the call does not run. In a
`claude -p` run in Manual mode, a call that needs approval is denied unless
something else approves it ([Claude Code headless][cc-headless-perm]). Under
Codex's `never` approval policy, a failed call returns to the model and is never
put to the user ([Codex `protocol.rs`][cx-approval]). A denied call returns to
the model as a tool result, and the turn continues ([Claude Code
headless][cc-headless-perm], [Codex `protocol.rs`][cx-approval]).

## Compaction

When the context nears the model's limit, the agent harness compacts it: it
replaces the earlier transcript with a summary that the model writes. Detail
that is not in the summary is gone from the context.

- **Claude Code** keeps the system prompt, and loads the project-root
  `CLAUDE.md` and up to five recently used files again from disk. It attaches
  the most recent copy of each invoked skill, up to 5,000 tokens each and 25,000
  in all, dropping the oldest first ([Claude Code context window][cc-compact]).
- **Codex** keeps the summary and the user's most recent messages, up to about
  20,000 tokens ([Codex `compact.rs`][cx-compact]). It can compact during a turn
  as well as between turns ([Codex `turn.rs`][cx-turn-compact]).

A subagent compacts its own context, separately from its parent ([Claude Code
subagents][cc-sub-compact]).

## Sources

The Codex sources are pinned to commit `49d657a` of `openai/codex`. The Claude
Code sources are its documentation as of November 2026.

[api-tool-use]:
  https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works
[api-glossary]: https://platform.claude.com/docs/en/about-claude/glossary
[cc-compact]:
  https://code.claude.com/docs/en/context-window#what-survives-compaction
[cc-glossary-reminder]: https://code.claude.com/docs/en/glossary#system-reminder
[cc-glossary-turn]: https://code.claude.com/docs/en/glossary#turn
[cc-headless-perm]:
  https://code.claude.com/docs/en/headless#turn-off-permission-prompts-in-unattended-runs
[cc-memory-load]:
  https://code.claude.com/docs/en/memory#how-claude-md-files-load
[cc-permissions]: https://code.claude.com/docs/en/permissions#permission-system
[cc-plugin-cache]:
  https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins
[cc-sessions]:
  https://code.claude.com/docs/en/how-claude-code-works#work-with-sessions
[cc-skills-cwd]:
  https://code.claude.com/docs/en/skills#how-injected-commands-run
[cc-skills-invoke]:
  https://code.claude.com/docs/en/skills#control-who-invokes-a-skill
[cc-skills-name]:
  https://code.claude.com/docs/en/skills#how-a-skill-gets-its-command-name
[cc-skills-life]: https://code.claude.com/docs/en/skills#skill-content-lifecycle
[cc-sub-background]:
  https://code.claude.com/docs/en/sub-agents#tools-permissions-and-results-of-background-subagents
[cc-sub-checkpoints]:
  https://code.claude.com/docs/en/skills#run-skills-in-a-subagent
[cc-sub-compact]: https://code.claude.com/docs/en/sub-agents#auto-compaction
[cc-sub-context]:
  https://code.claude.com/docs/en/sub-agents#what-loads-at-startup
[cc-sub-files]: https://code.claude.com/docs/en/sub-agents#write-subagent-files
[cc-sub-fork]:
  https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation
[cc-sub-scoped]:
  https://code.claude.com/docs/en/sub-agents#invoke-subagents-explicitly
[transformer]: https://arxiv.org/abs/1706.03762
[cx-agents-md]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L1-L19
[cx-approval]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1206
[cx-catalog]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs
[cx-compact]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L733-L800
[cx-fragments]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs
[cx-mav]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1780-L1807
[cx-roles-discovery]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/discovery.rs
[cx-roles-loader]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs
[cx-spawn-spec]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs
[cx-spawn-v2]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs#L213-L239
[cx-turn]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L200-L213
[cx-turn-compact]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L718-L730
