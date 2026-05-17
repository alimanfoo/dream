# /dream:team

A multi-agent team for shipping great code while maintaining codebase coherence with minimal hand-holding.

Requires Claude Code's [experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature enabled.

## Installation

```text
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

## Usage

Start Claude Code:

```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Then invoke the `dream:team` skill:

```text
/dream:team
```

Team members are then spawned in separate sessions. Switch to the `@Grace` session to start working.

See [`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## Concurrent sessions

The team works on one branch in one working tree. To run two
sessions on the same repo at the same time, give each its own
`git worktree`:

```bash
git worktree add ../<repo>-<topic> -b <topic> main
cd ../<repo>-<topic>
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Grace's boot detects the worktree, fetches `main`, and adopts
the worktree's branch as the session branch. The primary
checkout stays free for a second session.

## License

MIT — see [LICENSE](LICENSE).
