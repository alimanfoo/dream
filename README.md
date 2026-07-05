# dream

A Claude Code plugin for delivering great code and keeping the codebase
coherent, with minimal human input.

`/dream:team` runs a multi-agent team on a task. `/dream:catcher` runs that team
unattended across a repository's labelled issues. Utility skills ship alongside:
`/dream:writing-style` and `/dream:copy-edit`.

Requires Claude Code's
[experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.

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

Team members then start in separate sessions. Switch to the `@Grace` session to
start working.

See
[`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## Prerequisites

The plugin works best when you have the `gh` command line tool available on your
system. This allows the team to interact with GitHub, for example opening a PR
and posting issues.

## Advanced usage

### Alias claude with experimental agent teams support

For convenience, you might like to add something like the following to your
shell customisation script (for example `~/.zshrc`):

```zsh
alias claude-teams="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --teammate-mode auto"
```

This then allows you to run `claude-teams` from the terminal.

### Models and effort

Each agent runs on a default model. Grace and Ada run on Opus, Ralph and Junio
on Sonnet. To override a model, name it when you invoke the skill, for example
`/dream:team with Ralph on opus`. Agents you don't name keep their default.

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

### Autopilot mode

If you are feeling brave, at any point after you have provided the session input
you can switch on autopilot mode by saying:

```text
Autopilot on.
```

...to Grace. She then directs the team autonomously, taking the default at each
acceptance gate instead of waiting for your approval. She still produces every
artifact and runs every review.

Grace will still stop for input in these cases: an open question from the
requirements analysis, or something unexpected turning up during development.
She posts these to the PR and watches it for your reply. This lets you unblock
her there without dropping into the session. If she does stop, she might need a
reminder to re-engage autopilot afterwards to resume full autonomy.

Once the PR is ready, Grace keeps watching it and carries it through:

- a review with feedback sends her back to revise
- a review asking to resolve conflicts has her update the branch so it can merge
- a review asking to defer the merge sends her to the collect stage, leaving the
  PR open for you to merge later
- a merge sends her on to the collect stage
- a close without a merge ends the session as declined

Give your feedback as a PR review. She watches for reviews, not plain PR
comments. You can also give it in the session, but the PR alone is enough to
steer the whole session.

The collect stage still waits for your approval by default. Turn on auto-collect
separately to let it run unattended, filing or commenting on issues without
waiting:

```text
Auto-collect on.
```

You can say this alongside the autopilot command above, or on its own later in
the session. With both on, a session can run from input all the way to a merged
PR with its findings filed, entirely through the PR.

Grace skips the reflect stage, an optional retrospective, when you are not in
the session to run it.

You can also engage both from the start through the worktree branch name.
Include a standalone `auto` token alongside the issue number (for example
`gh83-auto`). Grace then turns on autopilot and auto-collect before Phase 1
opens, without waiting for any input.

## Unattended runs with /dream:catcher

The dreamcatcher watches a repository for labelled issues and dispatches a
dream-team session for each, one at a time. A backlog clears itself while you
are away. Each session runs under autopilot and carries its issue to a pull
request for you to merge. That is the same as an autopilot session you start by
hand.

The dreamcatcher needs `git`, `gh`, `jq`, `claude`, and `tmux` on your PATH,
with `gh` signed in.

Label an issue for the team and assign it to yourself. Start Claude Code from
the main checkout of that repository, not a linked worktree, then run:

```text
/dream:catcher
```

It watches the repository you started Claude Code in. By default it picks up
open issues labelled `dream:team` and assigned to you. Pass a different label as
an argument, for example `/dream:catcher auto`.

The dreamcatcher runs in its own tmux session. Attach to it with
`tmux attach -t dreamcatcher`, or follow its log with
`tail -f dreamcatcher.log`. Each issue it dispatches runs in its own tmux
session. `Ctrl+B` then `s` switches between the dreamcatcher and every running
session, so a session waiting for an answer is one keystroke away.

How it picks work:

- **One session at a time.** A session holds the slot from dispatch until its
  pull request is merged or closed, so your merge paces the next dispatch. Size
  a session by grouping issues under an umbrella issue.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. The dreamcatcher skips a
  blocked issue until its blocker closes, then picks it up.
- **Finished sessions.** The dreamcatcher removes a session's worktree and tmux
  session once its pull request is merged or closed, so they do not pile up.

Each session runs unattended, so it needs its writes allowlisted, either in the
repository's `.claude/settings.json` or your global `~/.claude/settings.json`.
Add this to one of them:

```json
{
  "permissions": {
    "allow": [
      "Bash(gh pr create:*)",
      "Bash(gh pr comment:*)",
      "Bash(gh pr edit:*)",
      "Bash(gh pr ready:*)",
      "Bash(gh pr close:*)",
      "Bash(gh issue create:*)",
      "Bash(gh issue comment:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)"
    ]
  }
}
```

Without it, a session stalls on a permission prompt no one answers. When a
session hits a question it cannot answer, it posts the question to the pull
request and waits. You can reply there without dropping into the session.

It stops on reboot, so re-run `/dream:catcher` to restart it. For a machine that
must survive reboots, drive `catch.sh --once` from cron or launchd. Each firing
runs a single tick.

## Troubleshooting

### Permissions

If you have it on your plan, switch to `auto` permissions mode before launching
the team. This should handle most permissions automatically.

You may still hit occasional permissions blocks, for example when posting to
GitHub.

## License

MIT. See [LICENSE](LICENSE).
