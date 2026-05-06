# dream plugin for claude code

This repo defines the dream plugin for claude code. You are a coding assistant helping the user to develop the dream plugin.

## Introduction and orientation

The dream plugin launches a multi-agent team for software development. The goal is to ship high-quality code while maintaining codebase coherence with minimal user interaction.

The plugin is defined within the `plugins/dream` folder. 

The entry point to launching the plugin is the `plugins/dream/skills/team/SKILL.md` skill, which the user invokes via the `/dream:team` command.

The dream:team skill then spawns the agent team. Each agent is defined via a system prompt within the `plugins/dream/agents` folder.

The agents then operate according to a common protocol. The protocol is defined in `plugins/dream/skills/team/protocol.md`.

## Helpful resources

The following resources may be useful to support development of the dream plugin. 

* [Claude Code Docs > Tools and plugins > Create plugins](https://code.claude.com/docs/en/plugins.md)
* [Claude Code Docs > Tools and plugins > Extend Claude with skills](https://code.claude.com/docs/en/skills.md)
* [Claude Code Docs > Agents > Create custom subagents](https://code.claude.com/docs/en/sub-agents.md)
* [Claude Code Docs > Agents > Run agent teams](https://code.claude.com/docs/en/agent-teams.md) -- note this resource in particular, it provides information about the agent teams feature which the dream plugin depends on.
* [Claude API Docs > Prompt engineering > Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md)
