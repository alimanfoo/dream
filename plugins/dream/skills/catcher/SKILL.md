---
name: catcher
description:
  Watch a repository for labelled issues and hand each to a dream-team session,
  one at a time, unattended. Each session runs under autopilot and carries
  itself to a merged pull request. Use when the user runs /dream:catcher or asks
  to pick up issues automatically while away.
argument-hint: "[label]"
---

# Dreamcatcher

Watch a repository for issues marked for the team, and hand each to a fresh
dream-team session. The sessions already do the work. This is the coordinator
around them: it notices a labelled issue and starts a session for it, one at a
time, so the work continues while the user is away.

The coordinator is a shell script, `catch.sh`, in this skill's directory. It
runs a tick on a loop and reads live state each time, so nothing is stored
between ticks. Your job is to gather its configuration, run the preflight
checks, and launch it.

## Arguments

Read the argument the user gives, if any. A word given this way is the label.
Use it directly and skip asking for the label below.

## Gather the configuration

Ask the user for what the argument did not supply. Launch with what they give
plus the defaults.

- **Label.** The label that marks an issue for the team. Required, no default.
  Suggest a dedicated label, such as `auto`, kept apart from labels a human
  reads. An issue needs this label and the right assignee to be picked up.
- **Assignee.** Whose issues to pick up. Defaults to `@me`, gh's alias for the
  authenticated user.
- **Interval.** Seconds between ticks. Defaults to 300.

The repository is the one in the current working directory.

## Preflight

Run each check before launching. Stop and tell the user if one fails.

- Run `gh auth status`. It must succeed.
- Run `command -v git gh jq claude tmux`. All five must be on the PATH.
- Run `gh label list` and confirm the label is present. Offer to create it if it
  is missing.
- Run `git rev-parse --git-common-dir`. It must print `.git`, which means this
  is the main checkout. Any other path means a linked worktree, and dispatched
  worktrees would land in the wrong place.
- Confirm the recurring unattended writes are allowlisted in the user's or the
  host repo's `.claude/settings.json`, so a dispatched session does not stall on
  a permission prompt no one answers. The writes are `gh pr create`,
  `gh pr comment`, `gh pr edit`, `gh pr ready`, `gh issue create`,
  `gh issue comment`, `git commit`, and `git push`.

## Launch

Run the loop in its own detached tmux session, so it outlives this session and
the user can attach to watch it tick, the same way they attach to a dispatched
session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --label '<label>' --assignee '<assignee>' --interval <interval> \
   2>&1 | tee -a dreamcatcher.log"
```

Then tell the user:

- to watch the loop with `tmux attach -t dreamcatcher`, or follow the log with
  `tail -f dreamcatcher.log`. Detach with `Ctrl+B` then `d`. Stop the loop with
  `tmux kill-session -t dreamcatcher`.
- that each issue runs in its own tmux session named
  `dream-GH<n>-<timestamp>-auto`. `Ctrl+B` then `s` switches between the loop
  and every dispatched session, so a session waiting for an answer is one
  keystroke away.
- that tmux sessions stop on reboot, and re-running `/dream:catcher` restarts
  the loop. For a machine that must survive reboots, drive `catch.sh --once`
  from cron or launchd instead, which runs a single tick per firing.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **One session at a time.** A session holds the slot from dispatch until its
  pull request is merged or closed, so your merge paces the next dispatch. This
  is a granularity choice, letting you size a session by composing issues into
  an umbrella, not a technical limit.
- **Oldest eligible issue first.** To make one issue wait for another, mark it
  blocked by the other in the GitHub issue view. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is closed. Use
  this when one issue depends on another, or when one tidies an area the other
  would otherwise have to work through.
- **Permissions.** A session runs in auto mode and reads
  `.claude/settings.json`, the same as an autopilot session started by hand. A
  command that is neither allowlisted there nor cleared by auto mode blocks and
  notifies instead of running unattended.
