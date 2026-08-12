---
name: catcher
description:
  Watch a repository for labelled issues and dispatch an autonomous coding
  session for each. Each session runs unattended in bounded rounds and carries
  its issue to a pull request for the user to review and merge. Only use when
  the user explicitly runs /dream:catcher.
argument-hint:
  "[--harness <claude|codex>] [--smith-label <label>] [--less-label <label>]
  [--smith-model <model>] [--smith-effort <effort>] [--less-model <model>]
  [--less-effort <effort>] [--assignee <user>] [--interval <seconds>]
  [--max-agents <n>]"
---

# Dreamcatcher

Watch a repository for issues marked for the `dream:smith` or `dream:less`
skill. The issue's label tells the coordinator which skill to run. The sessions
already do the work. This is the coordinator around them. It starts a bounded
round for each labelled issue. It later resumes the session when its pull
request has new input.

Each round runs headless in its own tmux session. The round ends when the agent
marks the pull request ready, posts a question it needs the user to answer, or
finishes a later review, merge, or close step. A cap bounds how many agent
rounds run at once, so the user controls token spend.

The coordinator is a shell script, `catch.sh`, in this skill's directory. It
runs a tick on a loop and reads live state each time. It uses git worktrees,
tmux sessions, GitHub state, watcher watermarks, and retained catcher
diagnostics under `$HOME/.dream/catcher`. Your job is to gather its
configuration, run the preflight checks, and launch it.

## Arguments

The user may pass any option shown in the `argument-hint` frontmatter as a
`--flag value` pair, in any order. Take whichever are present.

## Gather the configuration

Every option has a default. Run `catch.sh --help` to see them. Keep each flag
and value the user passed. Let the script default the rest. Ask no configuration
questions unless the user asks to change a default. State the options you
resolved before launching, so the user can correct a misread at once.

- **Smith label.** The label that dispatches a `dream:smith` session.
- **Less label.** The label that dispatches a `dream:less` session.
- **Harness.** Use `claude` when this skill is running under Claude Code. Use
  `codex` when it is running under Codex. An explicit `--harness` argument
  overrides this choice.
- **Smith model.** The model a `dream:smith` session runs under. Its default
  depends on the harness.
- **Smith effort.** The reasoning effort a `dream:smith` session runs under. Its
  default depends on the harness.
- **Less model.** The model a `dream:less` session runs under. Its default
  depends on the harness.
- **Less effort.** The reasoning effort a `dream:less` session runs under. Its
  default depends on the harness.
- **Assignee.** Whose issues to pick up.
- **Interval.** Seconds between ticks.
- **Max agents.** Maximum number of agent rounds to run at once.

The repository is the one in the current working directory.

## Preflight

Run each check before launching. Stop and tell the user if one fails.

- Run `gh auth status`. It must succeed.
- Confirm git, gh, jq, and tmux are each on the PATH, with a separate
  `command -v` for each. Confirm the selected harness is there too: `claude` for
  Claude Code or `codex` for Codex. One `command -v` over the whole list passes
  when any single tool resolves.
- Confirm each label exists with `gh label list --search "<label>"`, which
  avoids the 30-label default page. Offer to create any that is missing with
  `gh label create`.
- Confirm this is the main checkout, not a linked worktree, with
  `test -d "$(git rev-parse --show-toplevel)/.git"`. It must succeed. A linked
  worktree's `.git` is a file, so dispatched worktrees would land in the wrong
  place.

Do not set up permissions here. The coordinator gives each round its
harness-specific unattended permissions when it starts the round.

## Launch

Run the loop in its own detached tmux session, so it outlives this session. Pass
the selected harness even when the user did not name one. Pass the other flags
only when the user overrode them. The script applies its own default for every
other option. The user can then attach to watch it tick, the same way they
attach to a dispatched session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --harness <claude or codex> \
   <the other flags the user overrode, and no others> \
   2>&1 | tee -a dreamcatcher.log"
```

Then tell the user:

- that they can watch the loop with `tmux attach -t dreamcatcher`, or follow the
  log with `tail -f dreamcatcher.log`.
- that `Ctrl+B` then `d` detaches from the tmux session.
- that `tmux kill-session -t dreamcatcher` stops the loop.
- that each running agent round has its own tmux session named
  `dream-catcher-GH<n>-<timestamp>`, and that the tmux session disappears when
  that round ends.
- that each round keeps catcher state under
  `$HOME/.dream/catcher/<owner>/<repo>/dream-catcher-GH<n>-<timestamp>/`:
  `agent.log`, the selected harness settings in `session.json`, the latest PR
  inbox, and the final-round marker. This state stays in place with the worktree
  for debugging.
- that each existing session resumes under its recorded harness, whichever host
  restarts the catcher.
- that tmux sessions stop on reboot. Re-running `dream:catcher` restarts the
  loop.
- that they should run `catch.sh --harness <claude|codex> --once` from cron or
  launchd if the catcher must restart after a reboot. Each run performs one
  tick.

## How it picks work

Use these rules to answer questions about the coordinator's behaviour.

- **Resume before dispatch.** Each tick first looks at existing catcher
  worktrees. If an open pull request has new user posts, or if a merged or
  closed pull request needs its final round, the coordinator resumes that
  session. It dispatches a new issue only when no existing work needs a round.
- **Skill by label.** The smith label dispatches a `dream:smith` session, and
  the less label dispatches a `dream:less` session. An issue needs one of the
  labels and must match the configured assignee. One carrying both goes to
  `dream:smith`.
- **Runner by harness.** `--harness claude` runs the chosen skill under Claude
  Code. `--harness codex` runs it under Codex. The harness changes the runner,
  command, permissions, model defaults, and prompt spelling. The labels keep the
  same meaning.
- **Bounded rounds.** A session does not stay alive while it waits for the user.
  It ends each round when it has no work to do. The coordinator resumes it later
  from the same worktree and session history.
- **Max agents.** `--max-agents` caps live agent rounds, defaulting to one. It
  does not cap how many worktrees or pull requests can be waiting between
  rounds.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is closed. Use
  this when one issue depends on another, or when one tidies an area the other
  would otherwise work through.
- **Finished worktrees.** The coordinator launches one final round after the
  pull request merges or closes. It leaves the worktree, branch, logs, session
  settings, inbox, final marker, and watcher watermark in place for debugging.
- **Permissions.** A Claude Code round runs in auto mode. The coordinator passes
  recurring writes as narrow allow rules. A Codex round starts with
  `--approve-for-me`, workspace-write, and network access. When the coordinator
  resumes a Codex round, it replays the recorded model, effort, sandbox,
  network, and approval settings. Codex does not retain all of them.
