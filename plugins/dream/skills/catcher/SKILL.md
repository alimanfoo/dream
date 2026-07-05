---
name: catcher
description:
  Watch a repository for labelled issues and dispatch a dream-team session for
  each, one at a time, unattended. Each session runs under autopilot and carries
  its issue to a pull request for the user to merge. Only use when the user
  explicitly runs /dream:catcher, to avoid accidentally launching unattended
  sessions.
argument-hint: "[label] [assignee] [interval]"
---

# Dreamcatcher

Watch a repository for issues marked for the team, and dispatch a fresh
dream-team session for each. The sessions already do the work. This is the
coordinator around them. It notices a labelled issue and dispatches a session
for it, one at a time. The work continues while the user is away.

The coordinator is a shell script, `catch.sh`, in this skill's directory. It
runs a tick on a loop and reads live state each time, so nothing is stored
between ticks. Your job is to gather its configuration, run the preflight
checks, and launch it.

## Arguments

Read the argument the user gives, if any. It can name the label, the assignee,
and the interval. Take whichever are present.

## Gather the configuration

Every option has a default. Use what the argument named, default the rest, and
ask only to override a default.

- **Label.** The label that marks an issue for the team. Defaults to
  `dream:team`, a dedicated label kept apart from labels a human reads. An issue
  needs this label and the right assignee to be picked up.
- **Assignee.** Whose issues to pick up. Defaults to `@me`, gh's alias for the
  authenticated user.
- **Interval.** Seconds between ticks. Defaults to 300.

The repository is the one in the current working directory.

## Preflight

Run each check before launching. Stop and tell the user if one fails.

- Run `gh auth status`. It must succeed.
- Run `command -v git gh jq claude tmux`. They must all be on the PATH.
- Run `gh label list` and confirm the label is present. Offer to create it if it
  is missing.
- Run `git rev-parse --git-common-dir`. It must print `.git`, which means this
  is the main checkout. Any other path means a linked worktree, and dispatched
  worktrees would land in the wrong place.
- Confirm the recurring unattended writes are allowlisted in the user's or the
  host repo's `.claude/settings.json`. Otherwise a dispatched session stalls on
  a permission prompt no one answers. The writes are `gh pr create`,
  `gh pr comment`, `gh pr edit`, `gh pr ready`, `gh issue create`,
  `gh issue comment`, `git commit`, and `git push`, each allowlisted as a
  `Bash(<write>:*)` rule under `permissions.allow`. If any are missing, offer to
  add them.

## Launch

Run the loop in its own detached tmux session, so it outlives this session. The
user can then attach to watch it tick, the same way they attach to a dispatched
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
  the loop. Drive `catch.sh --once` from cron or launchd instead for a machine
  that must survive reboots, where each firing runs a single tick.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **One session at a time.** A session holds the slot from dispatch until its
  pull request is merged or closed, so your merge paces the next dispatch. This
  is a granularity choice, letting you size a session by composing issues into
  an umbrella, not a technical limit.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is closed. Use
  this when one issue depends on another, or when one tidies an area the other
  would otherwise have to work through.
- **Permissions.** A session runs in auto mode and reads
  `.claude/settings.json`, the same as an autopilot session started by hand. A
  command that is neither allowlisted there nor cleared by auto mode blocks and
  notifies instead of running unattended.
