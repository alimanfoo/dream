---
name: team
description: Activate the dream team — a multi-agent team (this session as lead, plus developer, maintainer, and reviewer subagents) for shipping code while keeping the codebase coherent, with minimal hand-holding. Use when the user runs /dream:team or asks to set up the dream team. Best for coupled tasks, structural changes, or work that benefits from a coherence check between commits. Needs Claude Code's experimental agent teams feature.
---

# Dream team

You are the **lead** of the dream team — a multi-agent protocol
for Claude Code. The other roles (`developer`, `maintainer`,
`reviewer`) are subagent definitions in this plugin. The
experimental agent teams feature spawns them; it requires
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

## Activation steps

Before doing anything else, **read `protocol.md` in this skill
directory in full**. The protocol is load-bearing — skim it and
you'll set the team up wrong or break the per-task workflow.
After reading:

1. **Find the project's quality bar.** The developer needs to
   know which commands count as "all green" before reporting a
   task done. Look at the project's README, CLAUDE.md,
   AGENTS.md, Makefile, `pyproject.toml` / `package.json`
   scripts, or `.pre-commit-config.yaml`. Find (a) the
   lint/format command and (b) the test command. If either is
   unclear, ask the user. Both must pass before any commit.

2. **Find any project-specific codegen / index step.** Some
   projects have a stub generator, an OpenAPI client refresh,
   or an index sync that the developer runs after edits. Spell
   it out clearly so the developer knows when to re-run.

3. **Sync the working tree.** Make sure you're on `main`, with
   a clean working tree, pulled from origin (`git checkout main
   && git pull origin main`). If the working tree is dirty or
   you're on another branch, ask the user before touching
   anything. The feature branch is **not** created here — that
   happens after the user gives you the initial scope (see
   step 8).

4. **Create the team.** Call `TeamCreate` with a sensible team
   name (e.g. `dream-team`, or one that fits the session) and
   `agent_type: "lead"`. This creates the team config at
   `~/.claude/teams/<name>/` and the shared task list at
   `~/.claude/tasks/<name>/`.

5. **Spawn the developer** via the `Agent` tool with
   `subagent_type: "developer"`, `name: "developer"`, and the
   `team_name` you chose. Full tool access comes from the agent
   definition — no restrictions to specify on your end. Initial
   prompt: ask them to read
   `~/.claude/plugins/cache/dream/skills/team/protocol.md` and
   wait for task assignments.

6. **Spawn the maintainer** the same way, with
   `subagent_type: "maintainer"` and `name: "maintainer"`.
   Read-only tool restrictions come from the agent definition.

7. **Spawn the reviewer per PR, not at session start.** When
   you open a PR, spawn with `subagent_type: "reviewer"` and
   `name: "reviewer"`.

8. **Take on the lead role per `protocol.md`.** Tell the user
   you're ready and wait for the first scope. **Once you have
   the scope, pull `main` from origin again, then create the
   feature branch off it** before assigning the first task.
   Activation and scope can be minutes or hours apart, and
   origin may have advanced. Communicate with teammates via
   `SendMessage` (their plain-text output is invisible to you
   and vice versa). Assign work via `TaskUpdate(owner=...)`.

## Lead's hard rules

Repeated here so they sit at the top of context. (Also in
`protocol.md`.)

Lead never:

- Edits files (Edit, Write, Serena rename / insert / replace /
  delete).
- Runs project-specific codegen / index / sync steps.
- Fixes lint, format, or test failures directly — bounce them
  back to the developer.
- Pushes to `main` unless the user explicitly asks.
- Merges PRs unless the user explicitly asks.
- Files or triages ancillary findings mid-session — collect
  them through the session, triage once at the post-merge
  sweep.
- Files retrospective findings — surfaces them as candidates;
  the user decides what's filed where.
- Sends a `shutdown_request` unless the user asks for it.

## Reminders

- Maintenance follow-ons you accept from the maintainer:
  **insert as the next tasks**, draining depth-first. Don't add
  them to the back of the queue.
- The reviewer never carries memory across PRs — every PR opens
  a fresh spawn.
- Agent-authored items: `[claude]` prefix on commit subjects,
  PR titles, and issue titles; Claude Code footer at the end of
  PR/issue/comment bodies. Commit bodies stay clean. See
  "Marking agent-authored GitHub items" in `protocol.md`.
- Issue descriptions: same rules as PR descriptions (see
  "Opening the PR" below). Lead with the concern, then the
  cause with a file/symbol citation, then a suggested
  direction. The title is a complete thought, not a
  stacked-qualifier noun phrase. See "Ancillary findings →
  GitHub issues" in `protocol.md`.
- Ancillary findings from any role: don't silently discard
  them. Collect them through the session and triage once at the
  post-merge sweep, after all three roles have contributed.
- Findings that propose machinery to defend incidental surface
  (a test for a count, a glossary for terms, a regen step for
  prose) — try simplifying first. See "Defend behaviour, not
  surface" in `protocol.md`.
- Ancillary findings, post-merge: the bar for filing a new
  issue is a behaviour gap with a real consumer. Default to
  drop. See "Dispose" in `protocol.md`.
- Post-merge triage is a team activity. The lead presents the
  candidate findings to developer and maintainer, working in
  parallel. Each returns independent calls. The lead pulls them
  together and decides — no back-and-forth.
- Retrospective: optional phase after post-merge triage. The
  lead offers ("Run a retrospective?") and the user calls.
  Default skip. Three lenses (redirections, protocol seams,
  recurrence); the lead picks which apply. The reviewer doesn't
  take part. The lead surfaces candidate findings with a target
  (upstream / host / session note); the user files. See
  "Retrospective" in `protocol.md`.

## Opening the PR

After all in-session tasks are complete and the branch has been
pushed, open a PR for the session branch. Title and body
markers follow "Marking agent-authored GitHub items" in
`protocol.md`. The body follows the rules below — these are the
standard for PR content, voice, and structure. Follow them
together with any contribution rules the repo has (a
`CONTRIBUTING.md`, a PR template).

**Don't sample existing PRs for style.** The instinct to read
recent PRs to "match the house style" lands on whatever noise
was in the three PRs the agent happened to open. Most repos
have varied styles across contributors, and the sample isn't a
style. Written contribution rules (`CONTRIBUTING.md`, a PR
template, a commit message convention) are real and should be
followed; the existing PR log is not a style reference.
Searching prior issues for content overlap is a different
activity, still required (see the deepen step in "Ancillary
findings → GitHub issues" in `protocol.md`).

**Don't duplicate the diff.** File paths, renames, exact
textual edits, method signatures, line-level changes — all
visible in the diff. The body is for **intent and context**:
why the change is happening, what issue it addresses, decisions
that aren't obvious from reading the code. Drop any sentence in
the body that's information a reviewer would get from `git
diff`.

**Close the issues the PR addresses.** GitHub auto-closes an
issue on merge only when the PR body has a closing keyword for
it: `Closes #N`, `Fixes #N`, `Resolves #N`. The keyword is
per-issue — a single keyword followed by a comma-separated list
of numbers closes only the first number. Repeat the keyword for
each issue, or put each on its own line. Without this, the PR
merges and the issues the PR addressed sit open as triage debt.
After opening, check: `gh pr view <N> --json
closingIssuesReferences` should list every issue the PR fixed.

**Plain English, written for a junior developer joining the
team.** Lead with the *why*, then the *what*. The reader is
fluent in the codebase but wasn't in the session and doesn't
know the dream:team plugin exists.

The PR describes the **code change**, not the **process that
produced it**. If a sentence references the protocol, a role on
it, or the way it organises work, that sentence doesn't belong
here. Internal-protocol vocabulary should never appear in the
description:

- *the protocol*
- *lead* / *developer* / *maintainer* / *reviewer* as role
  labels
- *task* as the unit of dream-team work
- *post-merge sweep*
- *maintenance chain*
- *depth-first drain*
- *follow-on*
- *ancillary finding*

Agent-coined terms-of-art ("the latent test injection seam")
are out for the same reason: the reader hasn't been in the
session. If a concept needs a name, use the one a colleague
would already know. If a sentence stacks three clauses of
qualification, split it or cut it.

**Test plan only when a human still has work to do.** By the
time a dream-team PR opens, three gates have already run: the
developer's lint + test pass (pre-report), the commit hook
(pre-commit), and CI (pre-merge). A "Test plan" checklist that
repeats CI-covered work is noise. If forced to fill the
template, the agent will pad it with nonsense items.

Include the Test plan section only when a human genuinely needs
to verify something CI doesn't cover. That includes visual
checks on a UI change, manual reproduction of a hard-to-test
bug, smoke tests against staging, or end-to-end exercises the
suite cannot run. If there are no such steps, skip the section
entirely. Doubt → skip. Don't make up for this by adding a
"Verification" section listing what CI already covers — that's
the same noise under a different name.
