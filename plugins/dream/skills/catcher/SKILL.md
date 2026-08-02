---
name: catcher
description:
  Watch a repository for labelled issues and dispatch an autonomous coding
  session for each. Each session runs unattended and carries its issue to a pull
  request for the user to review and merge. Only use when the user explicitly
  runs /dream:catcher.
argument-hint:
  "[--team-label <label>] [--solo-label <label>] [--less-label <label>]
  [--team-effort <effort>] [--solo-model <model>] [--solo-effort <effort>]
  [--less-model <model>] [--less-effort <effort>] [--assignee <user>]
  [--interval <seconds>] [--linger <minutes>] [--max-sessions <n>]"
---

# Dreamcatcher

Watch a repository for issues marked for the `/dream:team`, the `/dream:solo`
skill, or the `/dream:less` skill, and dispatch a fresh session for each, chosen
by the issue's label. The sessions already do the work. This is the coordinator
around them. It notices a labelled issue and dispatches a session for it.

A session holds the slot from dispatch until its pull request is ready for
review, then frees it for the next dispatch. Sessions awaiting review pile up
alongside the one still developing, while the user is away. A cap bounds how
many run at once, so a burst of labelled issues cannot exhaust the machine's
tmux sessions.

The coordinator is a shell script, `catch.sh`, in this skill's directory. It
runs a tick on a loop and reads live state each time, so nothing is stored
between ticks. Your job is to gather its configuration, run the preflight
checks, and launch it.

## Arguments

The user may pass any option below as a `--flag value` pair, in any order:
`--team-label`, `--solo-label`, `--less-label`, `--team-effort`, `--solo-model`,
`--solo-effort`, `--less-model`, `--less-effort`, `--assignee`, `--interval`,
`--linger`, and `--max-sessions`. Take whichever are present.

## Gather the configuration

Every option has a default. Run `catch.sh --help` to see them. Use what the
argument named. Let the script default the rest. Ask the user only whether to
override a default. State the options you resolved before launching, so a
misread surfaces at once.

- **Team label.** The label that dispatches a `/dream:team` session.
- **Solo label.** The label that dispatches a `/dream:solo` session.
- **Less label.** The label that dispatches a `/dream:less` session.
- **Team effort.** The reasoning effort a `/dream:team` session runs under. A
  model override makes no sense here, since each of its agents carries its own
  model.
- **Solo model.** The model a `/dream:solo` session runs under.
- **Solo effort.** The reasoning effort a `/dream:solo` session runs under.
- **Less model.** The model a `/dream:less` session runs under.
- **Less effort.** The reasoning effort a `/dream:less` session runs under.
- **Assignee.** Whose issues to pick up.
- **Interval.** Seconds between ticks.
- **Linger.** Minutes a finished session lingers before it is cleaned up.
- **Max sessions.** Most concurrent live sessions to run.

The repository is the one in the current working directory.

## Preflight

Run each check before launching. Stop and tell the user if one fails.

- Run `gh auth status`. It must succeed.
- Confirm git, gh, jq, claude, and tmux are each on the PATH, with a separate
  `command -v` for each. One `command -v` over the whole list passes when any
  single tool resolves.
- Confirm each label exists with `gh label list --search "<label>"`, which
  avoids the 30-label default page. Offer to create any that is missing with
  `gh label create`.
- Confirm this is the main checkout, not a linked worktree, with
  `test -d "$(git rev-parse --show-toplevel)/.git"`. It must succeed. A linked
  worktree's `.git` is a file, so dispatched worktrees would land in the wrong
  place.

No permission setup is needed here. The coordinator grants each dispatched
session its writes at launch.

## Launch

Run the loop in its own detached tmux session, so it outlives this session. Pass
only the flags the user overrode. The script applies its own default for every
option left out. The user can then attach to watch it tick, the same way they
attach to a dispatched session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   <the flags the user overrode, and no others> \
   2>&1 | tee -a dreamcatcher.log"
```

Then tell the user:

- that they can watch the loop with `tmux attach -t dreamcatcher`, or follow the
  log with `tail -f dreamcatcher.log`, that `Ctrl+B` then `d` detaches, and that
  `tmux kill-session -t dreamcatcher` stops the loop.
- that each issue runs in its own tmux session named
  `dream-GH<n>-<timestamp>-auto`, and that `Ctrl+B` then `s` switches between
  the loop and every dispatched session, so any of them is one keystroke away.
- that tmux sessions stop on reboot, so re-running `/dream:catcher` restarts the
  loop, and that a machine that must survive reboots should run
  `catch.sh --once` from cron or launchd, where each firing runs a single tick.

## How it picks work

Answer questions about the coordinator's behaviour from here.

- **Skill by label.** The team label dispatches a `/dream:team` session, the
  solo label a `/dream:solo` session, the less label a `/dream:less` session. An
  issue needs one of the labels and the right assignee to be picked up. One
  carrying more than one goes to the heaviest: `/dream:team` over `/dream:solo`
  over `/dream:less`. Neither `/dream:solo` nor `/dream:less` needs the agent
  teams feature, so those dispatches launch without one. The slot, worktree
  setup, and unattended permissions are the same for all three.
- **One session develops at a time.** A session holds the slot from dispatch
  until its pull request is ready for review, then frees it for the next
  dispatch. Sessions awaiting review pile up alongside the one still developing,
  up to a cap on how many run at once. Once the pile reaches that cap, dispatch
  defers until the coordinator reclaims a finished session, so the loop cannot
  exhaust the machine's tmux sessions.
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
