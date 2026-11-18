---
name: agent-mechanics
description:
  Explains how a coding agent works under Claude Code and Codex, covering the
  context, the turn, skills, subagents, tools and compaction. Use when
  engineering a system that has LLM agents in it, such as a prompt, a skill, a
  subagent file or a program that runs agents, to reason about what the agents
  will do.
---

# dream:agent-mechanics

This guide describes the mechanics of a coding agent, for reasoning about what
the agents in a system will do: a prompt, a skill, a subagent file or a program
that runs agents. It covers what is in an agent's context, how a turn runs, and
what happens when an agent invokes a skill, starts a subagent, calls a tool or
runs out of room. It names a difference between Claude Code and Codex only where
the difference changes what follows. Each section cites its sources.

A coding agent is a language model that works on software by using tools in a
loop. An agent harness, such as Claude Code or Codex, is the program that runs
the loop: it supplies the tools and manages the model's context. A harness
session is one conversation between a user and a coding agent, run by an agent
harness.

## How the model reasons

A language model generates text one token at a time. The sequence of tokens from
which it generates the next token is its context. To generate each token, the
model computes over the whole context. The generated token is then appended to
the context, and the model computes again to generate the next one. This process
is called autoregressive generation ([Claude glossary][api-glossary]).

Two consequences follow.

1. **Only the context carries forward.** The model's trained weights are fixed.
   The computation that generates each token is determined by the tokens in the
   context, and nothing from it carries forward except the token it generates.
   So thinking carries forward only as tokens: the model generates them in a
   thinking block, which is usually not shown to the user.
2. **Generation runs forward only.** When the model generates a token, the
   tokens after it don't exist yet, and the computation for each token draws
   only on that token and the ones before it ([Vaswani et al., 2017,
   §3.2.3][transformer]). A generated token can't be revised. The model can only
   generate further tokens, and those can contradict or correct the earlier
   ones.

## What the context holds

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

A turn is the agent's whole response to one input, usually a message from the
user. It starts when the input arrives and ends when the model generates a
response that contains no tool call. That response is the turn output ([Claude
Code glossary][cc-glossary-turn], [Codex `turn.rs`][cx-turn]). Between turns the
model generates nothing.

Within a turn, the model can call tools. A tool call is a structured block of
tokens that names a tool and gives the tool's input. When the model generates a
tool call, its generation stops and the agent harness runs the tool. The agent
harness then appends the tool's result to the context, and the model generates
again from that context ([Claude tool use][api-tool-use], [Codex
`turn.rs`][cx-turn]).

A tool can change things outside the context, such as a file on disk or the
state of a repository. The context gains only the tool call and the result that
the agent harness appends.

## What a skill is

A skill is a folder whose one required file, `SKILL.md`, holds a name, a
description and a body. When a harness session starts, the agent harness appends
the name and description of every available skill to the context ([Claude Code
skills][cc-skills-invoke], [Codex `fragments.rs`][cx-fragments]).

Either the user or the agent can invoke a skill. Invoking it appends its body to
the context ([Claude Code skills][cc-skills-life], [Codex
`fragments.rs`][cx-fragments]). Nothing else happens: invoking a skill starts no
other process, transfers no control and returns no value. The same model goes on
generating tokens, from a context that now includes the body.

The body stays in the context once it is appended. Editing the skill's file
afterwards doesn't change the tokens already appended, so a session that loaded
the body keeps that copy, including when it is resumed ([Claude Code
skills][cc-skills-life], [how Claude Code works][cc-resume]).

## Files and paths

Apart from what the agent harness loads itself, a file enters the context only
when the agent generates a tool call that reads it. That includes a file that a
skill refers to ([Claude Code skills][cc-skills-files]).

The agent resolves the file's path itself, so a relative path has no fixed base.
Codex's list of skills tells the agent to resolve a skill's relative paths
against the folder that holds its `SKILL.md` ([Codex
`catalog_prompt.rs`][cx-catalog]). Claude Code instead replaces
`${CLAUDE_SKILL_DIR}` in a skill's body with that folder ([Claude Code
skills][cc-skills-subst]). A shell command runs in the working directory,
wherever the skill is ([Claude Code skills][cc-skills-cwd]).

Invoking a skill by name, such as `dream:foo`, loads it from the installed
plugin, not from a path. An installed plugin is a copy, kept apart from any
repository's working tree ([Claude Code plugins][cc-plugin-cache]).

## Subagents

A subagent is a second agent that an agent starts with a tool call. It has a
context of its own, and it is either fresh or a fork. A fresh subagent's context
starts with its own system prompt and the task message, and none of the parent's
context. A fork's context starts with a copy of the parent's context. Which kind
starts depends on the call and the agent harness ([Claude Code
subagents][cc-sub-context], [Codex `spawn.rs`][cx-spawn-v2]).

When a subagent finishes, its final turn output is appended to the parent's
context. Nothing else from its context is ([Claude Code subagents][cc-sub-fork],
[Codex `multi_agents_spec.rs`][cx-spawn-spec]). What its tools changed outside
the context stays changed, though, since a subagent calls tools like any agent.

The two agent harnesses find subagent files differently. Claude Code reads each
file in a plugin's `agents/` directory as a subagent type, named with the
plugin's prefix as a skill is, so `dream:foo` could name either ([Claude Code
subagents][cc-sub-scoped]). Codex doesn't read a plugin's `agents/` directory
([Codex `loader.rs`][cx-roles-loader]). A Codex subagent reads such a file only
when its task message gives the path.

## Tools and permissions

Before the agent harness runs a tool call, it checks the call against its
permission settings. It then runs the call, asks the user, or denies it ([Claude
Code permissions][cc-permissions]). When no one is there to answer, a call that
needs approval is denied. The denial is appended to the context as the call's
result ([Claude Code headless][cc-headless-perm], [Codex
`protocol.rs`][cx-approval]).

## Compaction

When the context nears the model's limit, the agent harness compacts it: it
replaces earlier parts of the context with a summary that the model generates.
What the summary leaves out is no longer in the context. The agent harness then
appends some content again, such as the instruction files ([Claude Code context
window][cc-compact], [Codex `compact.rs`][cx-compact]).

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
[cc-resume]:
  https://code.claude.com/docs/en/how-claude-code-works#resume-or-fork-sessions
[cc-sessions]:
  https://code.claude.com/docs/en/how-claude-code-works#work-with-sessions
[cc-skills-files]: https://code.claude.com/docs/en/skills#add-supporting-files
[cc-skills-cwd]:
  https://code.claude.com/docs/en/skills#how-injected-commands-run
[cc-skills-subst]:
  https://code.claude.com/docs/en/skills#available-string-substitutions
[cx-catalog]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs
[cc-skills-invoke]:
  https://code.claude.com/docs/en/skills#control-who-invokes-a-skill
[cc-skills-life]: https://code.claude.com/docs/en/skills#skill-content-lifecycle
[cc-sub-context]:
  https://code.claude.com/docs/en/sub-agents#what-loads-at-startup
[cc-sub-fork]:
  https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation
[cc-sub-scoped]:
  https://code.claude.com/docs/en/sub-agents#invoke-subagents-explicitly
[transformer]: https://arxiv.org/abs/1706.03762
[cx-agents-md]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L1-L19
[cx-approval]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1206
[cx-compact]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L673-L800
[cx-fragments]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs
[cx-roles-loader]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs
[cx-spawn-spec]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs
[cx-spawn-v2]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs#L213-L239
[cx-turn]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L200-L213
