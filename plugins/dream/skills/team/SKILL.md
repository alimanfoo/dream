---
name: team
description: Activate the dream team — four subagents (lead, developer, maintainer, reviewer) for shipping code while keeping the codebase coherent. This session spawns the team, hands off to the lead, and shuts the team down when the user is done. Use when the user runs /dream:team or asks to set up the dream team. Needs Claude Code's experimental agent teams feature.
---

# Dream team

You spawn the dream team and manage its lifecycle. The team is
four subagents — `lead`, `developer`, `maintainer`, `reviewer` —
defined in this plugin. The lead is the user-facing role and
owns everything from scope through retrospective. You stay
available for help questions during the session and shut the
team down when the user is done.

The experimental agent teams feature spawns the team; it
requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

## Spawning the team

1. **Choose a team name.** Format
   `dream-team-<repo>-<YYYYMMDD-HHMMSS>`. Get the repo name
   from `basename $(git rev-parse --show-toplevel)` and the
   timestamp from `date +%Y%m%d-%H%M%S`. The timestamped name
   means multiple sessions in the same repo never collide.

2. **Create the team** by calling `TeamCreate` with that name
   and `agent_type: "lead"`. This sets up the team config at
   `~/.claude/teams/<name>/` and the shared task list at
   `~/.claude/tasks/<name>/`.

3. **Spawn all four agents in parallel** via the `Agent` tool.
   For each, set `subagent_type` to the role (`lead`,
   `developer`, `maintainer`, `reviewer`), set `name` to the
   same string, and pass the team name. Tool restrictions come
   from each agent's own definition — no restrictions to
   specify here. Initial prompt: include the absolute path to
   `protocol.md` (it's in this skill's directory) and tell the
   agent to follow its activation steps.

4. **Wait for all four acks.** Each agent sends a single
   plain-text reply: `lead ready`, `developer ready`,
   `maintainer ready`, `reviewer ready`. Don't proceed until
   all four have landed. If any agent fails to ack — error,
   timeout, or anything other than the expected line — stop
   and surface the failure to the user. Don't auto-retry.
   Don't try to fix it yourself.

5. **Hand off.** Once all four acks are in, tell the user the
   team is ready and they should switch to the lead session to
   start. The lead opens Phase 1: Scope.

## During the session

You stay idle while the lead drives the session. The user may
return to ask questions about how the team works — protocol
overview, what each agent does, what happens in each phase.
Answer using `protocol.md` as the source of truth.

You don't take part in the work itself. Don't read the task
list, don't message the agents, don't comment on the diff. The
team is the lead's to run.

## Shutting the team down

When the user signals the session is done — typically after the
lead has finished the retrospective and pointed them back to
you — wind the team down:

1. Send a shutdown signal to each of the four agents.
2. Confirm to the user that the team has been shut down.

The team config and task list at `~/.claude/teams/<name>/` and
`~/.claude/tasks/<name>/` stay on disk after shutdown — they
are session artefacts. Don't delete them.
