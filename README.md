# dream

A plugin for delivering great code and keeping the codebase coherent, with
minimal human input. It installs under Claude Code and under Codex.

`/dream:team` runs a multi-agent team on a task. `/dream:smith` runs a single
agent on a smaller task. `/dream:less` runs a cut-back single agent on a very
small one. Neither needs the agent teams feature. `/dream:catcher` runs
`/dream:smith` and `/dream:less` unattended across a repository's labelled
issues. Utility skills you can run on their own ship alongside:
`/dream:plain-english`, `/dream:coherent-coding`, `/dream:copy-edit`,
`/dream:code-analysis`, `/dream:state`, `/dream:spark`,
`/dream:requirements-analysis`, `/dream:craft`, `/dream:design`, `/dream:plan`,
`/dream:coherence-review`, `/dream:code-review`, and `/dream:watcher`. Two of
those cover requirements. `/dream:spark` interviews you to turn a rough idea
into a brief. `/dream:requirements-analysis` produces one on its own, from
material you already wrote. Two more read the code behind a task.
`/dream:code-analysis` reads it on its own. `/dream:state` explores it with you,
so you come away understanding it too, and leaves a reading guide with every
claim in it checked against the code. Two more reach a design. `/dream:design`
produces one on its own. `/dream:craft` works one out with you at a whiteboard,
asking what if until the shape stops moving, then what breaks until nothing more
comes off.

## Prerequisites

Every skill runs under Claude Code. Codex support is partial. `dream:smith`,
`dream:less`, and `dream:catcher` now run there alongside `dream:spark`,
`dream:state`, `dream:copy-edit`, `dream:code-review`, and
`dream:coherence-review`. Put a `$` in front of the skill's name in a Codex
prompt:

```text
$dream:state
```

`/dream:team` needs Claude Code's
[experimental agent teams](https://code.claude.com/docs/en/agent-teams) feature.

The plugin works best with the `gh` command line tool available. This lets the
plugin interact with GitHub, for example opening a pull request and posting
issues.

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
ready. Then it ends its turn. If you started it by hand, tell it when to check
the pull request. If `/dream:catcher` dispatched it, the catcher resumes it when
you review, merge, or close the pull request. Once you merge, it files anything
it left out of scope as new issues.

## Even smaller tasks with /dream:less

`/dream:less` is a cut-back version of `/dream:smith`, for a very small change
you want carried from issue to pull request fast. It runs the same bounded-round
way as `/dream:smith`: one agent, no approval steps, and a pull request for your
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
session for each. It runs the `/dream:smith` or `/dream:less` skill, chosen by
the issue's label.

Each session runs as bounded headless rounds. A round opens or updates the pull
request, posts a question if it needs your answer, marks the pull request ready
when the work is ready, and ends. The catcher watches existing pull requests and
resumes a session when you review, merge, or close one. A cap on live agent
rounds controls how many token-spending processes run at once.

`/dream:catcher` needs `git`, `gh`, `jq`, and `tmux` on your PATH, with `gh`
signed in. It also needs the runner you select: `claude` for Claude Code or
`codex` for Codex.

Start Claude Code from the main checkout of that repository, not a linked
worktree, then run:

```text
/dream:catcher
```

To run the same lifecycle under Codex, start Codex from the main checkout and
run:

```text
$dream:catcher --harness codex
```

The harness defaults to Claude Code.

It watches the repository you started Claude Code in. By default it picks up
open issues labelled "dream:smith" or "dream:less" and assigned to you,
dispatching the matching skill. Override a label with a flag, for example
`/dream:catcher --smith-label auto`.

`/dream:catcher` runs in its own tmux session. Attach to it with
`tmux attach -t dreamcatcher`, or follow its log with
`tail -f dreamcatcher.log`. Each running agent round has its own tmux session
named `dream-catcher-GH<n>-<timestamp>`, which disappears when that round ends.
The round's output is appended to
`$HOME/.dream/catcher/<owner>/<repo>/dream-catcher-GH<n>-<timestamp>/agent.log`.
Catcher state there also records the selected harness settings, the latest PR
inbox, and the final-round marker, and stays in place with the worktree for
debugging. Restart the catcher with the same harness to resume those sessions.

How it picks work:

- **Resume before dispatch.** Each tick first checks existing catcher worktrees.
  It resumes a session whose open pull request has new user posts, or whose
  merged or closed pull request needs one final round. It dispatches a new issue
  only when no existing work needs a round.
- **Skill by label.** The smith label dispatches a `/dream:smith` session, for
  smaller tasks. The less label dispatches a `/dream:less` session, for very
  small ones. An issue carrying both goes to `/dream:smith`.
- **Runner by harness.** `--harness claude` runs the chosen skill under Claude
  Code. `--harness codex` runs it under Codex. The harness changes the runner,
  permissions, and model defaults, not the label semantics.
- **Max agents.** `--max-agents` caps live agent rounds, defaulting to one. It
  does not cap how many pull requests can be waiting between rounds. Raise it to
  spend faster.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. `/dream:catcher` skips a
  blocked issue until its blocker closes, then picks it up.
- **Finished worktrees.** `/dream:catcher` launches one final round after the
  pull request merges or closes. It leaves the worktree, branch, logs, session
  settings, inbox, final marker, and watcher watermark in place for debugging.

Each session runs unattended. It needs permissions to interact with GitHub:
creating the pull request, posting comments, committing, and pushing. The Claude
Code harness launches in auto mode with narrow allow rules. The Codex harness
uses automatic approval review, workspace-write, and network access. When a
session hits a question it cannot answer, it posts the question to the pull
request and ends the round. You can reply there without dropping into the
session.

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
