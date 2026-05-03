# dream

A multi-agent team protocol for [Claude Code](https://claude.com/claude-code).

Requires Claude Code's experimental agent teams flag. Set in your
environment or `settings.json`:

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## Installation

```
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

## Usage

Start Claude code:

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --system-prompt "You are the dream:team lead."
```

Then invoke the `dream:team` skill:

```
/dream:team
```

The lead role activates in your current session and spawns the developer and maintainer subagents; the reviewer is spawned later, per-PR.

See [`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## License

MIT — see [LICENSE](LICENSE).
