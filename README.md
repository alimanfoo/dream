# /dream:team

A multi-agent team for shipping great code while maintaining codebase coherence with minimal hand-holding.

Requires Claude Code's [experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature enabled. 

## Installation

```
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

## Usage

Start Claude Code:

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Then invoke the `dream:team` skill:

```
/dream:team
```

Team members are then spawned in separate sessions. Switch to the `@lead` session to start working.

See [`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## License

MIT — see [LICENSE](LICENSE).
