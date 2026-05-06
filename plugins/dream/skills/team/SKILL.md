---
name: team
description: Activate the dream team — four subagents (Grace, Ralph, Junio, Ada) for shipping code while keeping the codebase coherent. This session spawns the team, hands off to Grace, and shuts the team down when the user is done. Use when the user runs /dream:team or asks to set up the dream team. Needs Claude Code's experimental agent teams feature.
---

# Dream team

You spawn the dream team and manage its lifecycle. The team is
four subagents — `Grace` (director), `Ralph` (developer),
`Junio` (maintainer), `Ada` (reviewer) — defined in this
plugin. Grace is the user-facing role and owns everything from
scope through retrospective. You stay available for help
questions during the session and shut the team down when the
user is done.

The experimental agent teams feature spawns the team; it
requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

## Spawning the team

1. **Welcome the user.** Before any tool calls, print this
   banner verbatim as your first user-visible output:

   ```
             .  *  .  *  .  *  .  *  .
          *      The Dream Team       *
            Grace · Ralph · Junio · Ada
             .  *  .  *  .  *  .  *  .

      Starting up...
   ```

   The banner sets the stage; the rest of the flow runs without
   further commentary until the team is ready.

2. **Choose a team name.** Format
   `dream-team-<repo>-<YYYYMMDD-HHMMSS>`. Get the repo name
   from `basename $(git rev-parse --show-toplevel)` and the
   timestamp from `date +%Y%m%d-%H%M%S`. The timestamped name
   means multiple sessions in the same repo never collide.

3. **Create the team** by calling `TeamCreate` with that name.
   No `agent_type` needed — it's optional and doesn't affect
   routing. This sets up the team config at
   `~/.claude/teams/<name>/` and the shared task list at
   `~/.claude/tasks/<name>/`. Claude Code hardcodes your
   addressable name as `team-lead` in the team config; you use
   that address only to send shutdown signals at the end of the
   session.

4. **Spawn all four agents in parallel** via the `Agent` tool.
   For each, set `subagent_type` to the agent's name (`Grace`,
   `Ralph`, `Junio`, `Ada`), set `name` to the same string,
   and pass the team name. Tool restrictions come from each
   agent's own definition — no restrictions to specify here.
   Initial prompt: include the absolute path to `protocol.md`
   (it's in this skill's directory) and tell the agent to
   follow its activation steps.

5. **Hand off.** Tell the user the team is spawned and they
   should switch to Grace's session to start. Grace opens
   Phase 1: Scope. There is no readiness handshake — the four
   `Agent` calls returning is the only spawn-time signal. Each
   teammate reads the protocol on its own, and Grace surfaces
   any teammate that fails to respond when she first uses
   them.

## During the session

You stay idle while Grace drives the session. The user may
return to ask questions about how the team works — protocol
overview, what each agent does, what happens in each phase.
Answer using `protocol.md` as the source of truth.

You don't take part in the work itself. Don't read the task
list, don't message the agents, don't comment on the diff. The
team is Grace's to run.

## Shutting the team down

When the user signals the session is done — typically after
Grace has finished the retrospective and pointed them back to
you — wind the team down:

1. Send a shutdown signal to each of the four agents.
2. Confirm to the user that the team has been shut down.

The team config and task list at `~/.claude/teams/<name>/` and
`~/.claude/tasks/<name>/` stay on disk after shutdown — they
are session artefacts. Don't delete them.
