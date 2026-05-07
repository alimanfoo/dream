---
name: team
description: Activate the dream team — four subagents (Grace, Ralph, Junio, Ada) for shipping code while keeping the codebase coherent. Use when the user runs /dream:team or asks to set up the dream team. Needs Claude Code's experimental agent teams feature.
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
   `~/.claude/tasks/<name>/`.

4. **Spawn all four agents in parallel** via the `Agent` tool.
   For each, set `subagent_type` to `dream:<Name>` (e.g.
   `dream:Grace`), `name` to `<Name>`, and pass the team name.
   Use this initial prompt template, substituting `<Name>` and
   `<role>`:

   ```
   Boot sequence:

   1. Read the protocol at <absolute path to protocol.md in
      this skill's directory>.
   2. Read your role file at <absolute path to
      ../../agents/<Name>.md> and assume the role of <Name>,
      the <role> on the dream team.
   3. Then run any boot/orientation steps that role file
      specifies.
   ```

   Roles: Grace is *director*, Ralph is *developer*, Junio is
   *maintainer*, Ada is *reviewer*.

   The role-file read in step 2 is load-bearing. Claude Code's
   team-spawn loader currently does not append the
   agent-definition body to a teammate's system prompt
   ([anthropics/claude-code#30703](https://github.com/anthropics/claude-code/issues/30703)),
   so the role file has to be loaded by the agent at boot via
   this prompt. Without it, teammates come up with no
   role-specific instructions and rely only on `protocol.md`
   plus harness defaults. Once #30703 is fixed, step 2 (and
   this note) can be dropped; the role files themselves don't
   need to change.

5. **Hand off.** Tell the user the team is spawned and they
   should switch to Grace's session to start. Grace opens
   Phase 1: Scope. There is no readiness handshake — the four
   `Agent` calls returning is the only spawn-time signal.

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
