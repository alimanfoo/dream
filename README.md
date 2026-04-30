# claude-plugins

A marketplace of [Claude Code](https://claude.com/claude-code) plugins by
[@alimanfoo](https://github.com/alimanfoo).

```
/plugin marketplace add alimanfoo/claude-plugins
```

## `dream:team`

A four-agent team protocol for Claude Code: a lead in the foreground,
a developer that implements, a maintainer that audits coherence per
task, and a per-PR reviewer with fresh context. Hard role boundaries,
depth-first per-task coherence audits, fresh-context PR review,
ancillary findings filed as GitHub issues.

Requires Claude Code's experimental agent teams flag. Set in your
environment or `settings.json`:

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### Installation

```
/plugin install dream@alimanfoo
```

### Usage

```
/dream:team
```

The lead role activates in your current session and spawns the developer and maintainer subagents; the reviewer is spawned later, per-PR.

See [`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## License

MIT — see [LICENSE](LICENSE).
