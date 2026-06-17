---
name: team
description:
  Activate the dream team — four subagents (Grace, Ralph, Junio, Ada) for
  delivering code while keeping the codebase coherent. Use when the user runs
  /dream:team or asks to set up the dream team. Needs Claude Code's experimental
  agent teams feature.
---

# Dream team

You spawn the dream team and manage its lifecycle. The team is four subagents —
`Grace` (director), `Ralph` (developer), `Junio` (maintainer), `Ada` (reviewer)
— defined in this plugin. Grace is the user-facing role and owns everything from
scope through retrospective. You stay available for help questions during the
session and shut the team down when the user is done.

The experimental agent teams feature spawns the team; it requires
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

The session writes to GitHub through Grace: she opens the PR at the start and
posts each accepted artifact as the session runs (`gh pr create`,
`gh pr comment`, and others). Claude Code's auto-mode classifier may prompt you
to approve these writes. To skip the prompts, allowlist `gh pr create` and
`gh pr comment` in `~/.claude/settings.json` or the host project's
`.claude/settings.json` — this pre-approves them for the session.

## Spawning the team

1. **Welcome the user.** Before any tool calls, print this banner verbatim as
   your first user-visible output:

   ```text
        ✨ ☁️  ·  🌙  ·  ☁️ ✨
       🌙   The Dream Team   🌙
        ✨ ☁️  ·  🌙  ·  ☁️ ✨

         Grace  —  director
         Ralph  —  developer
         Junio  —  maintainer
         Ada    —  reviewer

         Starting up...
   ```

   The banner sets the stage; the rest of the flow runs without further
   commentary until the team is ready.

2. **Spawn all four agents in parallel** via the `Agent` tool. For each, set
   `subagent_type` to `dream:<Name>` (e.g. `dream:Grace`) and `name` to
   `<Name>`. Use this initial prompt template:

   ```text
   Initial instructions:

   1. Read the protocol at <absolute path to protocol.md in
      this skill's directory>.
   2. Then run your boot sequence.
   ```

   Roles: Grace is _director_, Ralph is _developer_, Junio is _maintainer_, Ada
   is _reviewer_.

   **Model overrides.** If the user's invocation names a model for an agent —
   for example "/dream:team with Ralph on opus" — pass that model in the agent's
   `Agent` call, overriding the definition's default. Agents the invocation
   doesn't name keep their own model. Effort can't be set per agent this way:
   the team inherits the main session's effort, so if the user wants a different
   level, tell them to set `/effort` before invoking.

3. **Hand off.** Tell the user the team is spawned and they should switch to
   Grace's session to start. Grace opens Phase 1: Requirements. There is no
   readiness handshake — the four `Agent` calls returning is the only spawn-time
   signal.

## During the session

You stay idle while Grace drives the session. The user may return to ask
questions about how the team works — protocol overview, what each agent does,
what happens in each phase. Answer using `protocol.md` for shared session flow
and phase overview, and the relevant role file for role-specific mechanics.

You don't take part in the work itself. Don't read the task list, don't message
the agents, don't comment on the diff. The team is Grace's to run.

## Shutting the team down

When the user signals the session is done — typically after Grace has finished
the retrospective and pointed them back to you — shut the team down:

1. Send a shutdown signal to each of the four agents.
2. Confirm to the user that the team has been shut down.

Cleanup happens automatically when the session exits, so the shutdown signal is
a courtesy that ends the agents' turns gracefully rather than a teardown you
must complete.
