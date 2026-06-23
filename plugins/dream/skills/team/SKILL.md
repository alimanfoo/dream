---
name: team
description:
  Activate the dream team. Four subagents (Grace, Ralph, Junio, Ada) deliver
  code while keeping the codebase coherent. Use when the user runs /dream:team
  or asks to set up the dream team. Needs Claude Code's experimental agent teams
  feature.
---

# Dream team

You spawn the dream team and manage its lifecycle. The team is four subagents
defined in this plugin: `Grace` (director), `Ralph` (developer), `Junio`
(maintainer), and `Ada` (reviewer). Grace is the user-facing role and owns
everything from scope through retrospective. You stay available for help
questions during the session.

The experimental agent teams feature spawns the team. It requires
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

Grace does all the session's GitHub writes. She opens the PR at the start. As
the session runs, she posts each accepted artifact (`gh pr create`,
`gh pr comment`, and others). Claude Code's auto-mode classifier may prompt you
to approve these writes. Allowlist `gh pr create` and `gh pr comment` in
`~/.claude/settings.json` or the host project's `.claude/settings.json` to skip
the prompts.

## Spawning the team

1. **Welcome the user.** Print this banner verbatim as your first user-visible
   output, before any tool calls:

   ```text
             .  *  .  *  .  *  .  *  .
          *      The Dream Team       *
            Grace · Ralph · Junio · Ada
             .  *  .  *  .  *  .  *  .

      Starting up...
   ```

   The banner is the only output before the team is ready. The rest of the flow
   runs without further commentary.

2. **Spawn all four agents in parallel** via the `Agent` tool. For each, set
   `subagent_type` to `dream:<Name>` (for example `dream:Grace`) and `name` to
   `<Name>`. Use this initial prompt template:

   ```text
   Initial instructions:

   1. Read the protocol at <absolute path to protocol.md in
      this skill's directory>.
   2. Then run your boot sequence.
   ```

   Roles: Grace is _director_, Ralph is _developer_, Junio is _maintainer_, Ada
   is _reviewer_.

   **Model overrides.** If the user's invocation names a model for an agent,
   pass that model in the agent's `Agent` call, overriding the definition's
   default. For example, `/dream:team with Ralph on opus` puts Ralph on opus.
   Agents the invocation doesn't name keep their own model. Effort can't be set
   per agent this way. The team inherits the main session's effort. If the user
   wants a different level, tell them to set `/effort` before invoking.

3. **Hand off.** Tell the user the team is spawned and they should switch to
   Grace's session to start. Grace opens Phase 1: Requirements. The team uses no
   readiness handshake. The four `Agent` calls returning is the only spawn-time
   signal.

## During the session

You stay idle while Grace drives the session. The user may return to ask
questions about how the team works: protocol overview, what each agent does,
what happens in each phase. Answer using `protocol.md` for shared session flow
and phase overview, and the relevant role file for role-specific mechanics.

You don't take part in the work itself. Don't read the task list. Don't message
the agents. Don't comment on the diff. The team is Grace's to run.
