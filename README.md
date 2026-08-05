# dream

A plugin for delivering great code and keeping the codebase coherent, with
minimal human input. It installs under Claude Code and under Codex.

`/dream:team` runs a multi-agent team on a task. `/dream:smith` runs a single
agent on a smaller task. `/dream:less` runs a cut-back single agent on a very
small one. Those two need no agent teams feature. `/dream:catcher` runs any of
them unattended across a repository's labelled issues. Utility skills ship
alongside, and you can run each on its own: `/dream:plain-english`,
`/dream:coherent-coding`, `/dream:copy-edit`, `/dream:code-analysis`,
`/dream:requirements-analysis`, `/dream:design`, `/dream:plan`,
`/dream:coherence-review`, `/dream:code-review`, and `/dream:watcher`.

## Prerequisites

`/dream:team`, and `/dream:catcher` when it dispatches a `/dream:team` session,
need Claude Code's
[experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.
`/dream:smith`, `/dream:less`, and the utility skills do not.

The plugin works best with the `gh` command line tool available. This lets the
team interact with GitHub, for example opening a pull request and posting
issues.

## What runs under Codex

The utility skills run under Codex as they do under Claude Code. Name one the
same way you name any Codex skill, for example `$dream:code-review`.

The session skills need Claude Code. `/dream:smith` and `/dream:less` watch the
pull request for your review, and that watch runs on Claude Code's scheduler,
which Codex has no equivalent of. `/dream:catcher` launches `claude` itself.
`/dream:team` needs the agent teams feature.

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

Team members then start in separate sessions. Switch to the `@Grace` session and
give her the task. Like the single-agent skills, she also takes it from the
branch name. If the name of a worktree branch contains one or more issue numbers
(for example `GH83`), those issues are the task. She then starts without waiting
for you.

The team then runs on its own, with no approval steps. Grace opens a draft pull
request and posts each artifact there as it lands: the requirements analysis,
the code analysis, the design, and the plan. The team develops the work and
reviews it. Grace then marks the pull request ready and watches it for your
review. Once you merge, she files anything the session left out of scope as new
issues.

Grace stops for you on an open question from the requirements analysis, and on
something unexpected turning up later that breaks one of those artifacts. She
posts each to the pull request and waits for your reply there, so you can
unblock her without dropping into the session.

The pull request is enough to steer the whole session. Anything you write there
reaches her: a review, a plain comment, or a note on a line of the diff. It can
send her back to revise, ask her to update the branch so it can merge, ask her
to defer the merge and leave the pull request open, or ask her a question.
Merging sends her on to file the follow-ups. Closing without a merge ends the
session as declined. You can also steer her in the session itself.

See
[`plugins/dream/skills/team/protocol.md`](plugins/dream/skills/team/protocol.md)
for the full protocol.

## Smaller tasks with /dream:smith

`/dream:smith` is a single-agent alternative to the team, for smaller,
well-specified tasks. It needs no agent teams feature. One agent carries the
work from an issue to a pull request marked ready for your review, hands-off,
and files any follow-ups it noticed once you merge.

Use it when a task doesn't need the full team, but you want more than a single
one-shot attempt. The agent runs the work itself and brings in fresh subagents
to plan and review.

Start Claude Code and invoke the skill:

```text
/dream:smith
```

Like the team, it takes the task from the branch name. If the name contains one
or more issue numbers (for example `GH83`), it works on those. Otherwise it asks
you for the task.

It then runs on its own, with no approval steps. It opens a draft pull request,
plans and implements the work, reviews and tidies it, and marks the pull request
ready. It then keeps watching the pull request for your review, the same way a
team session does, and carries out what the review asks. Once you merge, it
files anything it left out of scope as new issues.

## Even smaller tasks with /dream:less

`/dream:less` is a cut-back version of `/dream:smith`, for a very small change
you want carried from issue to pull request fast. It runs the same way as
`/dream:smith`: one agent, no approval steps, watching the pull request for your
review. But it trims the process to match the size of the work. It skips
planning and the separate copy-edit and coherence-review passes. It runs a
lighter code review, writes a minimal pull request description, and files no
follow-ups once you merge.

Start Claude Code and invoke the skill:

```text
/dream:less
```

Reach for it when a change is small and self-contained.

## Unattended runs with /dream:catcher

`/dream:catcher` watches a repository for labelled issues and dispatches a
session for each. It runs the `/dream:team`, the `/dream:smith` skill, or the
`/dream:less` skill, chosen by the issue's label.

One session develops at a time. Sessions awaiting review pile up alongside it,
up to a cap on how many run at once. The issue backlog then clears itself while
you are away. Each session runs unattended and carries its issue to a pull
request for you to merge. That is the same as a session you start by hand.

`/dream:catcher` needs `git`, `gh`, `jq`, `claude`, and `tmux` on your PATH,
with `gh` signed in.

Start Claude Code from the main checkout of that repository, not a linked
worktree, then run:

```text
/dream:catcher
```

It watches the repository you started Claude Code in. By default it picks up
open issues labelled "dream:team", "dream:smith", or "dream:less" and assigned
to you, dispatching the matching skill. Override a label with a flag, for
example `/dream:catcher --team-label auto`.

`/dream:catcher` runs in its own tmux session. Attach to it with
`tmux attach -t dreamcatcher`, or follow its log with
`tail -f dreamcatcher.log`. Each issue it dispatches runs in its own tmux
session. `Ctrl+B` then `s` switches between `/dream:catcher` and every running
session, so a session waiting for an answer is one keystroke away.

How it picks work:

- **Skill by label.** The team label dispatches a `/dream:team` session. The
  smith label dispatches a `/dream:smith` session, for smaller tasks that need
  no team. The less label dispatches a `/dream:less` session, for very small
  ones. An issue carrying more than one goes to the heaviest: `/dream:team` over
  `/dream:smith` over `/dream:less`.
- **One session develops at a time.** A session holds the slot from dispatch
  until its pull request is ready for review, then frees it for the next
  dispatch. Sessions awaiting review pile up alongside the one still developing,
  up to a cap on how many run at once. Once the pile reaches it, dispatch defers
  until `/dream:catcher` reclaims a finished session. Size a session by grouping
  issues under an umbrella issue.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. `/dream:catcher` skips a
  blocked issue until its blocker closes, then picks it up.
- **Finished sessions.** A session's worktree and tmux session persist until its
  own pull request is merged or closed. Several sessions pile up while awaiting
  your review. `/dream:catcher` reclaims each a short while after its pull
  request is merged or closed.

Each session runs unattended. It needs permissions to interact with GitHub:
creating the pull request, posting comments, committing, and pushing.
`/dream:catcher` passes these to it as allow rules at launch. When a session
hits a question it cannot answer, it posts the question to the pull request and
waits. You can reply there without dropping into the session.

It stops on reboot, so re-run `/dream:catcher` to restart it. For a machine that
must survive reboots, drive `catch.sh --once` from cron or launchd. Each firing
runs a single tick.

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

## License

MIT. See [LICENSE](LICENSE).
