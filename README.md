# dream

A software development multi-agent team plugin for [Claude Code](https://claude.com/claude-code).

Requires Claude Code's [experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature enabled. 

## Installation

```
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

## Usage

Start Claude code:

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --system-prompt "You are the team lead."
```

Then invoke the `dream:team` skill:

```
/dream:team
```

The lead role activates in your current session and spawns the other team members.

See [`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## License

MIT — see [LICENSE](LICENSE).
