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

This guide describes the mechanics of a coding agent. It is for engineering a
system that has agents in it, such as a prompt, a skill, a subagent file or a
program that runs agents. From the mechanics, the reader can reason about what
the agents in that system will do.

A coding agent has two parts: a language model and an agent harness, such as
Claude Code or Codex. The model does one thing. When the agent harness calls it,
it generates tokens from the context it is given. The agent harness does
everything else: it builds the context, calls the model, runs the tools that the
model's output asks for, and appends what results. A harness session is one
conversation between a user and a coding agent, run by an agent harness.

So the model decides and the agent harness acts. The model generates only from
its context, and almost everything else in an agent's mechanics is about what
the agent harness puts into that context, keeps outside it, or takes out of it.
Where Claude Code and Codex differ in a way that matters to what an agent will
do, the guide says so.

## How the model generates text

When the agent harness calls a language model, the model generates text one
token at a time. The sequence of tokens from which it generates the next token
is its context. To generate each token, the model computes over the whole
context. The generated token is then appended to the context, and the model
computes again to generate the next one. This process is called autoregressive
generation ([Claude glossary][api-glossary]).

Two consequences follow.

1. **The context is the model's only state.** Everything the model computes is
   determined by its weights, which are fixed, and the tokens in its context.
   Generating a token is the only way the model adds to what its later
   computation can draw on. Thinking is no exception: it is tokens the model
   generates in a thinking block, which is usually not shown to the user.
2. **Generation runs forward only.** When the model generates a token, the
   tokens after it don't exist yet, and nothing computed for an earlier token
   depends on a later one ([Vaswani et al., 2017, §3.2.3][transformer]). A
   generated token can't be revised. The model can only generate further tokens,
   and those can contradict or correct the earlier ones.

So, for a given model, what the model generates next depends only on what is in
its context, and what the agent harness does next depends on what the model
generates. The agent harness decides most of what is in the context.

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
Claude Code works][cc-sessions]). Whatever needs to outlast a session has to be
kept outside the context, such as in a file, and loaded again.

## The turn

Most of what the context gains, it gains during a turn. A turn is the agent's
whole response to one input, usually a message from the user. When the input
arrives, the agent harness appends it to the context and calls the model. The
model generates until it stops, either at a tool call or at the end of a
response. If it stopped at a tool call, the agent harness acts on the call,
appends the result, and calls the model again. If the response contains no tool
call, it is the turn output, and the turn ends ([Claude Code
glossary][cc-glossary-turn], [Claude tool use][api-tool-use], [Codex
`turn.rs`][cx-turn]). Between turns the agent harness doesn't call the model, so
nothing is generated.

A tool call is a structured block of tokens that names a tool and gives the
tool's input. The model only generates it. The agent harness decides what to do
with it: it checks the call against its permission settings, and then runs the
call, asks the user, or denies it ([Claude Code permissions][cc-permissions]).
When no one is there to answer, a call that needs approval is denied ([Claude
Code headless][cc-headless-perm], [Codex `protocol.rs`][cx-approval]). Either
way, the agent harness appends a result to the context: the tool's output or the
denial.

A tool can change things outside the context, such as a file on disk or the
state of a repository. The context gains only the tool call and its result, so
the model can draw on a change only through what the result says about it.

## Skills

A skill shows the same split between a file and what the context holds of it. A
skill is a folder whose one required file, `SKILL.md`, holds a name, a
description and a body. When a harness session starts, the agent harness appends
the name and description of every available skill to the context ([Claude Code
skills][cc-skills-invoke], [Codex `fragments.rs`][cx-fragments]). The body stays
outside until the skill is invoked.

A skill is invoked when the user names it in their input, or when the model
generates a tool call that asks for it. Either way, the agent harness appends
the skill's body to the context ([Claude Code skills][cc-skills-life], [Codex
`fragments.rs`][cx-fragments]). Nothing else happens: invoking a skill starts no
other process, transfers no control and returns no value. The agent harness
calls the same model as before, with a context that now includes the body.

The appended body is a copy. Editing the skill's file afterwards doesn't change
the tokens already appended, so a session that loaded the body keeps that copy,
including when it is resumed ([Claude Code skills][cc-skills-life], [how Claude
Code works][cc-resume]). When a skill is invoked by name, such as `dream:foo`,
the agent harness loads the copy installed with its plugin, which is kept apart
from any repository's working tree ([Claude Code plugins][cc-plugin-cache]).

Other files that a skill refers to stay outside the context until the model
generates a tool call that reads one ([Claude Code skills][cc-skills-files]).
The model writes the file's path into that call, so a relative path in a skill
reaches the right file only if the model resolves it correctly. Codex's list of
skills tells the model to resolve a skill's relative paths against the folder
that holds its `SKILL.md` ([Codex `catalog_prompt.rs`][cx-catalog]). Claude Code
replaces `${CLAUDE_SKILL_DIR}` in a skill's body with that folder ([Claude Code
skills][cc-skills-subst]). A shell command runs in the working directory,
wherever the skill is ([Claude Code skills][cc-skills-cwd]).

## Subagents

A subagent is a second agent with a context of its own. The model asks for one
with a tool call, and the agent harness starts it. It is either fresh or a fork.
A fresh subagent's context starts with its own system prompt and the task
message, and none of the parent's context. A fork's context starts with a copy
of the parent's context. Which kind starts depends on the call and the agent
harness ([Claude Code subagents][cc-sub-context], [Codex
`spawn.rs`][cx-spawn-v2]).

When a subagent finishes, the agent harness appends its final turn output to the
parent's context. Nothing else from its context is ([Claude Code
subagents][cc-sub-fork], [Codex `multi_agents_spec.rs`][cx-spawn-spec]). What
its tool calls changed outside the context stays changed, though, since the
agent harness runs a subagent's tool calls as it runs any other.

A subagent's instructions can come from a file, and here the two agent harnesses
differ. Claude Code reads each file in a plugin's `agents/` directory as a
subagent type, named with the plugin's prefix as a skill is, so `dream:foo`
could name either ([Claude Code subagents][cc-sub-scoped]). Codex doesn't read a
plugin's `agents/` directory ([Codex `loader.rs`][cx-roles-loader]). Under
Codex, such a file reaches a subagent only when its task message gives the path
and its model generates a tool call that reads it.

## Compaction

Compaction works the other way: it takes things out of the context. When the
context nears the model's limit, the agent harness calls the model to generate a
summary, and replaces earlier parts of the context with it. What the summary
leaves out is no longer in the context, so the model can no longer draw on it.
Files on disk are untouched, and the agent harness then appends some content
again, such as the instruction files ([Claude Code context window][cc-compact],
[Codex `compact.rs`][cx-compact]).

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
