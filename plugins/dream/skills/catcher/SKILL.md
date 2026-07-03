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
polls on a loop and reads live state each time, so nothing is stored between
polls. Your job is to gather its configuration, run the preflight checks, and
launch it.

## Gather the configuration

Ask the user for the following. Launch with what they give plus the defaults.

- **Label.** The label that marks an issue for the team. Required, no default.
  Suggest a dedicated label, such as `auto`, kept apart from labels a human
  reads. An issue needs this label and the right assignee to be picked up.
- **Assignee.** Whose issues to pick up. Defaults to the authenticated user.
- **Interval.** Seconds between polls. Defaults to 300.

The repository is the one in the current working directory.

## Preflight

Check each of these before launching. Stop and tell the user if one fails.

- `gh auth status` succeeds.
- `jq` and `claude` are on the PATH.
- The label exists in the repository. Run `gh label list`. Offer to create it if
  it is missing.
- The current directory is the main checkout, with worktrees as siblings. The
  coordinator creates each session's worktree next to it, named `GH<n>-auto`.

## Launch

Run the script as a detached background process, so it outlives this session:

```bash
nohup bash "<absolute path to catch.sh in this skill's directory>" \
  --label "<label>" --assignee "<assignee>" --interval <interval> \
  > dreamcatcher.log 2>&1 &
```

Then tell the user:

- the process id and the log path, so they can follow it with
  `tail -f dreamcatcher.log` and stop it with `kill <pid>`.
- to see dispatched sessions with `claude agents`, and attach from there to
  answer a session that is waiting.
- that the loop stops on reboot. Re-run `/dream:catcher` to restart it. For a
  machine that must survive reboots, drive `catch.sh --once` from cron or
  launchd instead, which runs a single poll per firing.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **One development session at a time.** A session that has reached PR-ready and
  is waiting for review does not block the next, so pull requests can queue for
  the user while the next issue is worked.
- **Oldest eligible issue first.** To make one issue wait for another, mark it
  blocked by the other in the GitHub issue view. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is merged and
  closed. Use this when one issue depends on another, or when one tidies an area
  the other would otherwise have to work through.
- **Permissions.** A session runs in auto mode with a scoped allowlist of the
  writes it makes often. A rare unlisted command blocks and notifies, which is
  the safety net. The allowlist is at the top of `catch.sh`.
