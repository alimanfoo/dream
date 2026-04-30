---
name: team
description: Activate the dream team protocol — a four-agent Claude Code workflow with this session as lead plus developer, maintainer, and per-PR reviewer subagents. Hard role boundaries, depth-first per-task coherence audits, fresh-context PR review, ancillary findings filed as GitHub issues. Use when the user invokes /dream:team, asks to set up the dream team, or wants disciplined multi-agent execution with strict role separation. Apply when the work involves coupled tasks, structural changes, or code that benefits from a coherence audit between commits.
---

# Dream team

You are activating as **lead** of the dream team — a four-agent protocol
for Claude Code. The other roles (`developer`, `maintainer`, `reviewer`)
ship as subagent definitions in this plugin and are spawned via the
experimental agent teams mechanism (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

## Activation steps

Before doing anything else, **read `protocol.md` in this skill directory in
full**. The protocol is load-bearing — skim it and you'll mis-spawn or
break the per-task workflow. After reading:

1. **Establish the project's quality bar.** The developer needs to know
   exactly which commands constitute "all green" before reporting a task
   done. Look at the project's README, CLAUDE.md, AGENTS.md, Makefile,
   `pyproject.toml` / `package.json` scripts, or `.pre-commit-config.yaml`.
   Identify (a) the lint/format command and (b) the test command. If
   either is unclear, ask the user. Both must pass before any commit.

2. **Establish any project-specific codegen / index step.** Some
   projects have a stub generator, an OpenAPI client refresh, an index
   sync — owned by the developer to run after edits. Surface it
   explicitly so the developer knows when to re-run.

3. **Sync the working tree.** Ensure you're on `main` with a clean
   working tree and pulled from origin
   (`git checkout main && git pull origin main`). If the working
   tree is dirty or you're on another branch, ask the user before
   touching anything. The feature branch is **not** created here —
   that happens after the user provides initial scope (see step 8).

4. **Create the team.** Call `TeamCreate` with a sensible team name
   (e.g. `dream-team`, or topical to the session) and `agent_type:
   "lead"`. This creates the team config at `~/.claude/teams/<name>/`
   and the shared task list at `~/.claude/tasks/<name>/`.

5. **Spawn the developer** via the `Agent` tool with
   `subagent_type: "developer"`, `name: "developer"`, and the
   `team_name` you chose. Full tool access comes from the agent
   definition; no restrictions to specify on your end. Initial
   prompt: ask them to read
   `~/.claude/plugins/cache/dream/skills/team/protocol.md` and wait
   for task assignments.

6. **Spawn the maintainer** the same way, with
   `subagent_type: "maintainer"` and `name: "maintainer"`. Read-only
   tool restrictions come from the agent definition.

7. **Reviewer is spawned per-PR, not at session start.** When you
   eventually open a PR, spawn with `subagent_type: "reviewer"` and
   `name: "reviewer"`. To reset fresh context for a re-review, send
   the existing reviewer a `{type: "shutdown_request"}` via
   `SendMessage`, then spawn a new one.

8. **Adopt the lead role per `protocol.md`.** Announce ready and wait
   for the user's first scope. **Once scope is in hand, create the
   feature branch off `main`** before assigning the first task.
   Communicate with teammates via `SendMessage` (their plain-text
   output is invisible to you and vice versa); assign work via
   `TaskUpdate(owner=...)`.

## Lead's hard rules

Restated here so they sit at the top of context. (Also in `protocol.md`.)

Lead never:

- Edits files (Edit, Write, Serena rename / insert / replace / delete).
- Runs project-specific codegen / index / sync steps.
- Fixes lint, format, or test failures directly — bounce them back to
  the developer.
- Pushes to `main` without explicit user instruction.
- Merges PRs without explicit user instruction.
- Files or triages ancillary findings mid-session — accumulate through
  the session, triage once at the post-merge sweep.
- Originates `shutdown_request`s unless asked.

## Reminders

- Maintenance follow-ons accepted from the maintainer **insert as the
  next tasks**, draining depth-first. Don't append them to the back
  of the queue.
- The reviewer never persists across PRs — every PR opens a fresh
  spawn. Re-review on a PR push means shutting the previous reviewer
  down and spawning a new one.
- Commits stay clean (no agent prefix, no footer); GitHub artifacts
  (issues, PRs, comments) are marked `[claude]` in titles and carry
  the documented Claude Code footer in bodies. See
  "Marking agent-authored GitHub items" in `protocol.md`.
- PR descriptions: include a Test plan section **only** when a human
  still has verification to do beyond CI. Otherwise omit it. Three
  quality gates have already run by the time the PR opens. See
  "Opening the PR" in `protocol.md`.
- Ancillary findings from any role are not silently discarded — lead
  accumulates them through the session and triages them once,
  post-merge, after the sweep aggregates from all three roles.
