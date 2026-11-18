# Sources for dream:agent-mechanics

This file lists the sources behind each section of the guide to agent mechanics,
whose files are in `plugins/dream/skills/agent-mechanics/`. A section's entry
covers that section in all three files of the guide. When you change a section,
check each changed claim against the sources listed for it, and update the list
if the claim rests on a new source.

The Claude API, Claude Code and Hugging Face Transformers sources are their
documentation as of November 2026. The Codex sources are pinned to commit
[`49d657a`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f)
of `openai/codex`. When you move the pin, re-check each section against the
crates listed for it.

## Introduction

- Claude API documentation:
  [glossary](https://platform.claude.com/docs/en/about-claude/glossary)
- Claude Code documentation:
  [glossary](https://code.claude.com/docs/en/glossary),
  [how-claude-code-works](https://code.claude.com/docs/en/how-claude-code-works)

## How the model generates text

- Paper: [Vaswani et al., 2017](https://arxiv.org/abs/1706.03762)
- Hugging Face Transformers documentation:
  [generation utilities](https://huggingface.co/docs/transformers/internal/generation_utils)
- Claude API documentation:
  [glossary](https://platform.claude.com/docs/en/about-claude/glossary),
  [handling-stop-reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons),
  [tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview),
  [working-with-messages](https://platform.claude.com/docs/en/build-with-claude/working-with-messages)
- Claude Code documentation:
  [glossary](https://code.claude.com/docs/en/glossary)

## What the context holds

- Claude API documentation:
  [tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview),
  [working-with-messages](https://platform.claude.com/docs/en/build-with-claude/working-with-messages)
- Claude Code documentation:
  [context-window](https://code.claude.com/docs/en/context-window),
  [glossary](https://code.claude.com/docs/en/glossary),
  [how-claude-code-works](https://code.claude.com/docs/en/how-claude-code-works),
  [memory](https://code.claude.com/docs/en/memory)
- Codex source, by crate:
  [`codex-home`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-home),
  [`config`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config),
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core)

## The turn

- Claude API documentation:
  [handling-stop-reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons),
  [tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- Claude Code documentation:
  [agent-sdk/typescript](https://code.claude.com/docs/en/agent-sdk/typescript),
  [glossary](https://code.claude.com/docs/en/glossary),
  [hooks](https://code.claude.com/docs/en/hooks),
  [interactive-mode](https://code.claude.com/docs/en/interactive-mode),
  [mcp](https://code.claude.com/docs/en/mcp),
  [settings-reference](https://code.claude.com/docs/en/settings-reference),
  [sub-agents](https://code.claude.com/docs/en/sub-agents),
  [tools-reference](https://code.claude.com/docs/en/tools-reference)
- Codex source, by crate:
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`ext/goal`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/goal),
  [`features`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/features)

## Tool calls and permissions

- Claude API documentation:
  [tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- Claude Code documentation:
  [glossary](https://code.claude.com/docs/en/glossary),
  [headless](https://code.claude.com/docs/en/headless),
  [mcp](https://code.claude.com/docs/en/mcp),
  [permissions](https://code.claude.com/docs/en/permissions),
  [plugins/components](https://code.claude.com/docs/en/plugins/components),
  [tools-reference](https://code.claude.com/docs/en/tools-reference)
- Codex source, by crate:
  [`codex-mcp`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-mcp),
  [`config`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config),
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`exec`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec),
  [`protocol`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol)

## Hooks

- Claude Code documentation:
  [agent-sdk/hooks](https://code.claude.com/docs/en/agent-sdk/hooks),
  [context-window](https://code.claude.com/docs/en/context-window),
  [glossary](https://code.claude.com/docs/en/glossary),
  [hooks](https://code.claude.com/docs/en/hooks)
- Codex source, by crate:
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`hooks`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks),
  [`protocol`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol)

## Plugins

- Claude Code documentation: [mcp](https://code.claude.com/docs/en/mcp),
  [plugins](https://code.claude.com/docs/en/plugins),
  [plugins/components](https://code.claude.com/docs/en/plugins/components),
  [plugins/loading](https://code.claude.com/docs/en/plugins/loading),
  [plugins/manifest-reference](https://code.claude.com/docs/en/plugins/manifest-reference),
  [skills](https://code.claude.com/docs/en/skills),
  [sub-agents](https://code.claude.com/docs/en/sub-agents)
- Codex source, by crate:
  [`core-plugins`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins),
  [`exec-server-protocol`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec-server-protocol),
  [`ext/skills`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills),
  [`hooks`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks),
  [`plugin`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/plugin),
  [`skills`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/skills),
  [`utils/plugins`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/plugins)

## Skills

- Claude Code documentation: [skills](https://code.claude.com/docs/en/skills)
- Codex source, by crate:
  [`ext/skills`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills),
  [`models-manager`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager)

## Subagents

- Claude Code documentation:
  [context-window](https://code.claude.com/docs/en/context-window),
  [skills](https://code.claude.com/docs/en/skills),
  [sub-agents](https://code.claude.com/docs/en/sub-agents)
- Codex source, by crate:
  [`agent-roles`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles),
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`models-manager`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager)

## Compaction

- Claude Code documentation:
  [context-window](https://code.claude.com/docs/en/context-window),
  [settings-reference](https://code.claude.com/docs/en/settings-reference)
- Codex source, by crate:
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`model-provider`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/model-provider),
  [`protocol`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol)

## Running an agent from a program

- Claude Code documentation:
  [agent-sdk/agent-loop](https://code.claude.com/docs/en/agent-sdk/agent-loop),
  [agent-sdk/claude-code-features](https://code.claude.com/docs/en/agent-sdk/claude-code-features),
  [agent-sdk/modifying-system-prompts](https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts),
  [agent-sdk/overview](https://code.claude.com/docs/en/agent-sdk/overview),
  [cli-reference](https://code.claude.com/docs/en/cli-reference),
  [headless](https://code.claude.com/docs/en/headless),
  [hooks](https://code.claude.com/docs/en/hooks),
  [permission-modes](https://code.claude.com/docs/en/permission-modes),
  [sessions](https://code.claude.com/docs/en/sessions)
- Codex source, by crate:
  [`app-server-protocol`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/app-server-protocol),
  [`cli`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/cli),
  [`config`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config),
  [`core`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core),
  [`exec`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec),
  [`sdk/python`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/sdk/python),
  [`sdk/typescript`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/sdk/typescript),
  [`tui`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/tui),
  [`utils/cli`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/cli)
