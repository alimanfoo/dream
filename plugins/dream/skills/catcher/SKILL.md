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

Start `catch.sh` from this skill's directory. The script owns its configuration,
validation, and runtime behaviour.

Use `claude` as the harness under Claude Code and `codex` under Codex. Pass that
harness and any arguments the user supplied to the script. Do not ask the user
to confirm defaults.

Run the outer tmux command with host access. The catcher manages tmux sessions,
writes data under `$HOME/.dream/catcher`, creates sibling worktrees, and calls
GitHub. It cannot run inside the harness sandbox.

Request escalated permission before you run the command under Codex. Run the
command normally under Claude Code. Claude Code's current permission mode
handles the Bash request.

Run the script in a detached tmux session so it outlives this session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --harness <claude or codex> \
   <the arguments the user supplied> \
   2>&1 | tee -a dreamcatcher.log" &&
  tmux has-session -t '=dreamcatcher'
```

Handle a blocked permission request by its cause:

- Stop if the user refuses the request. Tell the user that the catcher did not
  start. Do not retry the command.
- Stop if the current harness cannot ask the user for permission or Codex's
  automatic reviewer refuses the request. Do not retry the command inside the
  sandbox or change the tmux socket path. Give the user the matching interactive
  steps: start `claude` in the repository's main checkout and run
  `/dream:catcher`, or start `codex` there and run `$dream:catcher`. Tell them
  to approve the tmux command.

Offer the matching non-interactive launch only when the current session has no
approval path.

Under Claude Code:

```bash
claude --print --permission-mode auto /dream:catcher
```

Under Codex:

```bash
codex --approve-for-me exec '$dream:catcher'
```

Do not offer either command again when it was already used for the current
launch.

Tell the user that the catcher started only after both tmux commands pass.
Include these commands:

- `tmux attach -t '=dreamcatcher'` watches it.
- `tail -f dreamcatcher.log` follows its log.
- `tmux kill-session -t '=dreamcatcher'` stops it.
