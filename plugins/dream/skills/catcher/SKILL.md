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
- Run `command -v git gh jq claude`. All four must be on the PATH.
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

Run the script as a detached background process, so it outlives this session:

```bash
nohup bash "<absolute path to catch.sh in this skill's directory>" \
  --label "<label>" --assignee "<assignee>" --interval <interval> \
  < /dev/null > dreamcatcher.log 2>&1 &
disown
echo "dreamcatcher pid: $!"
```

Capture and report the printed pid in the same command, because shell state does
not survive into a later call.

Then tell the user:

- the pid and the log path, so they can follow it with
  `tail -f dreamcatcher.log` and stop it with `kill <pid>`.
- to see dispatched sessions with `claude agents`, and attach from there to
  answer a session that is waiting.
- that the loop stops on reboot, and re-running `/dream:catcher` restarts it.
  For a machine that must survive reboots, drive `catch.sh --once` from cron or
  launchd instead, which runs a single tick per firing.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **One session at a time.** A session holds the slot from dispatch until its
  pull request is merged or closed, so your merge frees the coordinator to pick
  up the next issue. Two live background teams would evict each other, so the
  coordinator never runs a second one alongside a session still in flight.
- **Oldest eligible issue first.** To make one issue wait for another, mark it
  blocked by the other in the GitHub issue view. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is closed. Use
  this when one issue depends on another, or when one tidies an area the other
  would otherwise have to work through.
- **Permissions.** A session runs in auto mode and reads
  `.claude/settings.json`, the same as an autopilot session started by hand. A
  command that is neither allowlisted there nor cleared by auto mode blocks and
  notifies instead of running unattended.
