---
name: catcher
description:
  Watch a repository for labelled issues and dispatch an autonomous coding
  session for each. Each session runs unattended in bounded rounds and carries
  its issue to a pull request for the user to review and merge. Only use when
  the user explicitly runs /dream:catcher.
argument-hint:
  "[--smith-label <label>] [--less-label <label>] [--smith-model <model>]
  [--smith-effort <effort>] [--less-model <model>] [--less-effort <effort>]
  [--assignee <user>] [--interval <seconds>] [--max-agents <n>]"
---

# Dreamcatcher

Use `catch.sh` in this skill's directory. The script owns its configuration,
validates it, and controls runtime behaviour.

Use `claude` as the harness under Claude Code and `codex` under Codex. Pass that
harness and any arguments the user supplied to the script. Do not ask the user
to confirm defaults.

Read the repository owner and name, then use both in the coordinator's tmux
session name. Replace dots with plus signs, since tmux rewrites dots as
underscores and GitHub does not allow plus signs in repository names. Stop if
the repository lookup fails, so an incomplete name cannot collide with another
catcher.

Run the script in that detached tmux session so the catcher keeps running after
this session ends:

```bash
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner) || exit 1
session="${repo//./+}-dreamcatcher"

tmux new-session -d -s "$session" -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --harness <claude or codex> \
   <the arguments the user supplied> \
   2>&1 | tee -a dreamcatcher.log" || exit 1
```

Tell the user only after `tmux new-session` succeeds. Replace `$session` below
with its value, then include the session name and these commands:

- `tmux attach -t "=$session"` watches the coordinator.
- `tail -f dreamcatcher.log` follows the coordinator log.
- `tmux kill-session -t "=$session"` stops the coordinator.
