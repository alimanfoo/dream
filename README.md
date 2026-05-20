# /dream:team

A multi-agent team for delivering great code, keeping the codebase coherent, and doing both with minimal input from you.

Requires Claude Code's [experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.

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

Team members then start in separate sessions. Switch to the `@Grace` session to start working.

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

When Grace starts, she detects the worktree, fetches `main`, and
uses the worktree's branch for the session. The primary
checkout stays free for a second session.

## License

MIT — see [LICENSE](LICENSE).
