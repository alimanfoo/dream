---
name: catcher
description:
  Only use when the user explicitly runs /dream:catcher, never on a general
  request to watch, monitor, or triage issues. It launches unattended sessions.
  It watches a repository for labelled issues and dispatches a session for each,
  one at a time — the dream team or the solo skill, chosen by the issue's label.
  Each session runs unattended and carries its issue to a pull request for the
  user to merge.
argument-hint: "[team-label] [solo-label] [assignee] [interval]"
---

# Dreamcatcher

Watch a repository for issues marked for the dream team or the solo skill, and
dispatch a fresh session for each, chosen by the issue's label. The sessions
already do the work. This is the coordinator around them. It notices a labelled
issue and dispatches a session for it, one at a time. The work continues while
the user is away.

The coordinator is a shell script, `catch.sh`, in this skill's directory. It
runs a tick on a loop and reads live state each time, so nothing is stored
between ticks. Your job is to gather its configuration, run the preflight
checks, and launch it.

## Arguments

Read the argument the user gives, if any. It can name the team label, the solo
label, the assignee, and the interval:

- a leading `@` marks the assignee
- digits mark the interval in seconds
- a bare word is a label: the first is the team label, the second the solo label

Take whichever are present.

## Gather the configuration

Every option has a default. Use what the argument named, default the rest, and
ask only to override a default. State the labels, assignee, and interval you
resolved before launching, as a plain statement, so a misread surfaces at once.

- **Team label.** The label that dispatches a `/dream:team` session. Defaults to
  `dream:team`, a dedicated label kept apart from labels a human reads.
- **Solo label.** The label that dispatches a `/dream:solo` session. Defaults to
  `dream:solo`, likewise dedicated. An issue needs one of the two labels and the
  right assignee to be picked up. One carrying both goes to the team.
- **Assignee.** Whose issues to pick up. Defaults to `@me`, gh's alias for the
  authenticated user.
- **Interval.** Seconds between ticks. Defaults to 300.

The repository is the one in the current working directory.

## Preflight

Run each check before launching. Stop and tell the user if one fails.

- Run `gh auth status`. It must succeed.
- Confirm git, gh, jq, claude, and tmux are each on the PATH, with a separate
  `command -v` for each. One `command -v` over the whole list passes when any
  single tool resolves.
- Confirm each label exists with `gh label list --search "<label>"`, which
  avoids the 30-label default page. Offer to create either with
  `gh label create` if it is missing.
- Confirm this is the main checkout, not a linked worktree, with
  `test -d "$(git rev-parse --show-toplevel)/.git"`. It must succeed. A linked
  worktree's `.git` is a file, so dispatched worktrees would land in the wrong
  place.

No permission setup is needed here. The coordinator grants each dispatched
session its writes at launch.

## Launch

Run the loop in its own detached tmux session, so it outlives this session. The
user can then attach to watch it tick, the same way they attach to a dispatched
session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --team-label '<team label>' --solo-label '<solo label>' \
   --assignee '<assignee>' --interval <interval> \
   2>&1 | tee -a dreamcatcher.log"
```

Then tell the user:

- that they can watch the loop with `tmux attach -t dreamcatcher`, or follow the
  log with `tail -f dreamcatcher.log`, that `Ctrl+B` then `d` detaches, and that
  `tmux kill-session -t dreamcatcher` stops the loop.
- that each issue runs in its own tmux session named
  `dream-GH<n>-<timestamp>-auto`, and that `Ctrl+B` then `s` switches between
  the loop and every dispatched session, so a session waiting for an answer is
  one keystroke away.
- that tmux sessions stop on reboot, so re-running `/dream:catcher` restarts the
  loop, and that a machine that must survive reboots should run
  `catch.sh --once` from cron or launchd, where each firing runs a single tick.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **Skill by label.** The team label dispatches a `/dream:team` session, the
  solo label a `/dream:solo` session. `/dream:solo` needs no agent teams
  feature, so a solo dispatch launches without one. An issue carrying both
  labels goes to the team. The one-at-a-time slot, worktree setup, and
  unattended permissions are the same either way.
- **One session at a time.** A session holds the slot from dispatch until its
  pull request is merged or closed, so your merge paces the next dispatch. This
  is a granularity choice, letting you size a session by composing issues into
  an umbrella, not a technical limit.
- **Oldest eligible issue first.** Mark an issue blocked by another in the
  GitHub issue view to make it wait for that one. The coordinator skips an issue
  whose blocker is still open, and picks it up once the blocker is closed. Use
  this when one issue depends on another, or when one tidies an area the other
  would otherwise work through.
- **Permissions.** A dispatched session runs in auto mode, with the recurring
  unattended writes passed as narrow allow rules at launch. Auto mode resolves
  these before its classifier runs. A broad `Bash` allow can't serve here: auto
  mode drops broad allow rules and keeps only narrow ones. Auto mode blocks any
  other command it does not clear, and notifies instead of running it
  unattended.
