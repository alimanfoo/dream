# /dream:team

A multi-agent team for delivering great code, keeping the codebase coherent, and doing both with minimal input from you.

Requires Claude Code's [experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.

## Installation

```text
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

## Basic usage

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

## Prerequisites

The plugin works best when you have the `gh` command line tool available on your system. This allows the team to interact with GitHub, e.g., opening a PR and posting issues.

## Advanced usage

### Alias claude with experimental agent teams support

For convenience, you might like to add something like the following to your shell customisation script (e.g., `~/.zshrc`):

```zsh
alias claude-teams="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --teammate-mode auto"
```

This then allows you to run `claude-teams` from the terminal.

### Concurrent sessions

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

### Configuring tmux

The plugin supports a richer set of features for monitoring the different agents in the team when launched under tmux. For example, tmux allows you to see the agents output in multiple panes in your terminal.

Once you have installed tmux, it's worth a little customisation. E.g., try the following in your `~/.tmux.conf` file:

```text
set -wg pane-border-indicators both
set -wg pane-active-border-style "fg=#ff6600,bold"
set -wg pane-border-style "fg=colour238"
set-option -g focus-events on
```

### Launching Claude under tmux

To launch Claude Code under tmux, first run tmux, then run Claude Code, e.g.:

```zsh
tmux
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --teammate-mode auto
```

Then run `/dream:team` from the main session, you should see multiple agent panes appear.

### Using tmux – useful shortcuts

tmux has many commands which can be run via a sequence of shortcut keys. Here are some useful ones:

* `ctrl+b <space>` – change pane layout
* `ctrl+b <left cursor>` – switch focus to the pane to the left
* `ctrl+b <right cursor>` – switch focus to the pane to the right
* `ctrl+b z` – zoom in to the focused pane only (press again to return to multiple panes)
* `ctrl+b [` – enter scroll mode, which allows you scroll back within a pane (use `<escape>` to exit scroll mode)
* `ctrl+b :` – enter configuration mode (e.g., then type `select-pane -P 'fg=cyan' <enter>` to change text colour in the currently focused pane)

### Autopilot mode

If you are feeling brave, at any point after you have provided the session input you can switch on autopilot mode by saying:

```text
Autopilot on, proceed autonomously through to PR ready for user review.
```

...to Grace. This *should* mean that Grace directs the team autonomously all the way through to PR ready for human review, without needing any further input.

There are exceptions though when Grace will still stop and ask for input, e.g., if there are open questions arising from the requirements analysis, or if something unexpected turns up during development. If Grace does stop, she might need a reminder to re-engage autopilot after that to resume full autonomy.

## Troubleshooting

### Permissions

If you have it on your plan, switch to `auto` permissions mode before launching the team. This should handle most permissions automatically.

You may still hit some occasional permissions blocks, e.g., when posting to GitHub.

## License

MIT — see [LICENSE](LICENSE).
