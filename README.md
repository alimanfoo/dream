# dream

A plugin for delivering great code and keeping the codebase coherent, with
minimal human input. It installs under Claude Code and Codex.

Choose the workflow that fits the task:

- `/dream:team` gives a substantial task to a four-agent team.
- `/dream:smith` gives a smaller task to one agent, with planning and review.
- `/dream:less` carries a very small task straight through to a pull request.
- `/dream:catcher` runs agents unattended from labelled issues.

The plugin also includes standalone skills for requirements, code analysis,
design, planning, copy-editing, and review. Run the skills list in your host to
see them all.

## Prerequisites

Every skill runs under Claude Code. Codex support is partial: it includes
`dream:smith`, `dream:less`, `dream:catcher`, `dream:spark`, `dream:state`,
`dream:copy-edit`, `dream:code-review`, and `dream:coherence-review`. Put a `$`
in front of a skill's name in a Codex prompt:

```text
$dream:state
```

`/dream:team` needs Claude Code's
[experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.

Install the `gh` command-line tool and sign in when you want dream to work with
GitHub pull requests and issues.

## Installation

Under Claude Code:

```text
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

Under Codex:

```bash
codex plugin marketplace add alimanfoo/dream
codex plugin add dream@dream
```

## Coherent development with /dream:team

Start Claude Code:

```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Then invoke the `/dream:team` skill:

```text
/dream:team
```

Switch to the `@Grace` session and give her the task. If the current branch name
contains issue numbers such as `GH83`, she uses those issues instead.

The team opens a draft pull request, develops and reviews the work, then marks
the pull request ready. Use comments and reviews on that pull request to answer
questions or request changes. Merge when you are satisfied, or close the pull
request to end the session.

## Smaller tasks with /dream:smith

`/dream:smith` carries a smaller, well-specified task through planning,
implementation, and review. It opens a draft pull request and marks it ready
when the work is complete. It needs no agent teams feature.

Run `/dream:smith` under Claude Code or `$dream:smith` under Codex. If the
current branch name contains issue numbers such as `GH83`, Smith uses those
issues as the task. Otherwise it asks you for one.

## Even smaller tasks with /dream:less

`/dream:less` is a cut-back Smith for a small, self-contained change. It skips
planning and the separate copy-edit and coherence-review passes.

Run `/dream:less` under Claude Code or `$dream:less` under Codex.

## Unattended runs with /dream:catcher

`/dream:catcher` watches assigned issues labelled "dream:smith" or "dream:less"
and carries each one to a pull request. It returns to a session when you review,
merge, or close its pull request.

Install `git`, `gh`, `jq`, and `tmux`, and sign in with `gh`. Install the
harness you want to use: `claude` for Claude Code or `codex` for Codex.

Start the harness from the repository's main checkout. The catcher creates
sibling worktrees beside that checkout, so do not start it from a linked
worktree.

The catcher needs host access because it manages tmux sessions, writes data
under `$HOME/.dream/catcher`, creates sibling worktrees, and calls GitHub. When
you launch it interactively, the harness can ask for that access.

Under Claude Code:

1. Run `claude`.
2. Run `/dream:catcher` in the session.
3. Approve the tmux command when Claude asks.

Under Codex:

1. Run `codex`.
2. Run `$dream:catcher` in the session.
3. Approve the tmux command when Codex asks to run it outside the sandbox.

Let Codex's automatic reviewer assess the host-access request when you launch
the catcher non-interactively:

```bash
codex --approve-for-me exec '$dream:catcher'
```

The catcher uses the same harness for the sessions it dispatches.

Add options such as `--smith-label auto` to the skill invocation to use
different issue labels.

Use these commands to control the catcher's tmux session:

- `tmux attach -t =dreamcatcher` watches it.
- `tail -f dreamcatcher.log` follows its log.
- `tmux kill-session -t =dreamcatcher` stops it.

Launch the catcher again after a reboot.

## /dream:team advanced usage

### Alias claude with experimental agent teams support

For convenience, you might like to add something like the following to your
shell customisation script (for example `~/.zshrc`):

```zsh
alias claude-teams="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --teammate-mode auto"
```

This then allows you to run `claude-teams` from the terminal.

### Models and effort

Each agent runs on Opus by default. To override a model, name it when you invoke
the skill, for example `/dream:team with Junio on sonnet`. Agents you don't name
keep their default.

Effort works differently. The team inherits your main session's effort level
when it starts, so to run the agents at a higher or lower effort, set it with
`/effort` before you invoke `/dream:team`. This applies to all four agents
together. Per-agent effort isn't currently supported.

### Concurrent sessions

The team works on one branch in one working tree. To run two sessions on the
same repo at the same time, give each its own `git worktree`:

```bash
git worktree add ../<repo>-<topic> -b <topic> main
cd ../<repo>-<topic>
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

When Grace starts, she detects the worktree, fetches `main`, and uses the
worktree's branch for the session. If the branch name contains one or more issue
numbers (for example `GH83`), she also takes those issues as the session input
and opens Phase 1 with them automatically. The primary checkout stays free for a
second session.

### Configuring tmux

The plugin supports a richer set of features for monitoring the different agents
in the team when you launch Claude Code under tmux. For example, tmux allows you
to see the agents' output in multiple panes in your terminal.

Once you have installed tmux, it's worth a little customisation. For example,
try the following in your `~/.tmux.conf` file:

```text
set -wg pane-border-indicators both
set -wg pane-active-border-style "fg=#ff6600,bold"
set -wg pane-border-style "fg=colour238"
set-option -g focus-events on
```

### Launching Claude under tmux

To launch Claude Code under tmux, first run tmux, then run Claude Code, for
example:

```zsh
tmux
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --teammate-mode auto
```

Then run `/dream:team` from the main session. You should see multiple agent
panes appear.

### Using tmux – useful shortcuts

tmux has many commands you can run with a sequence of shortcut keys. Here are
some useful ones:

- `ctrl+b <space>`: change pane layout
- `ctrl+b <left cursor>`: switch focus to the pane to the left
- `ctrl+b <right cursor>`: switch focus to the pane to the right
- `ctrl+b z`: zoom in to the focused pane only (press again to return to
  multiple panes)
- `ctrl+b [`: enter scroll mode, which allows you to scroll back within a pane
  (use `<escape>` to exit scroll mode)
- `ctrl+b :`: enter configuration mode (for example, then type
  `select-pane -P 'fg=cyan' <enter>` to change text colour in the currently
  focused pane)

## Troubleshooting

A `/dream:team`, `/dream:smith`, or `/dream:less` session prints the plugin
version as it starts. Quote that version when you report a problem.

### Permissions

If you have it on your plan, switch to `auto` permissions mode before launching
the team. This should handle most permissions automatically.

You may still hit occasional permissions blocks, for example when posting to
GitHub.

### Dreamcatcher cannot create its tmux socket

`error creating ... (Operation not permitted)` means the tmux command ran inside
the harness sandbox. Changing the socket path will not help. Restart the catcher
with the supported launch steps above.

## License

MIT. See [LICENSE](LICENSE).
