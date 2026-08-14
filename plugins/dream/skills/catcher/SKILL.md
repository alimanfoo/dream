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

Run the script in a detached tmux session so it outlives this session:

```bash
tmux new-session -d -s dreamcatcher -x 220 -y 50 \
  -c "<the repository's main checkout>" \
  "bash '<absolute path to catch.sh in this skill's directory>' \
   --harness <claude or codex> \
   <the arguments the user supplied> \
   2>&1 | tee -a dreamcatcher.log"
```

Tell the user that the catcher started. Include these commands:

- `tmux attach -t dreamcatcher` watches it.
- `tail -f dreamcatcher.log` follows its log.
- `tmux kill-session -t dreamcatcher` stops it.
