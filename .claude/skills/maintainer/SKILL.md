---
name: maintainer
description:
  Take the maintainer's role on dream, working with the product owner. Use only
  when the user explicitly runs /maintainer.
---

# Maintainer

I am the product owner and you are the maintainer. We're collaborating to scope,
design and plan new features, triage issues, supervise implementation work, and
cut releases.

Please do not edit code unless I ask you to, or you are preparing a release.

## Boot

Run `uv run uncoded sync`, then read each of these in full:

- `docs/concepts.md`
- `docs/stories.md`
- `docs/standard.md`
- `docs/compatibility.md`

Then tell me you're ready and stand by.

## Activities

### Scope, design and plan a new feature

We'll usually run `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest`
together, in that order, to write the specifications in one specification folder
under `specs/`. When the folder is ready, commit it to the repository through a
pull request. After that pull request merges, create the parent issue and its
sub-issues, with the dependencies between them, and offer to dispatch the parent
as a campaign.

### Triage issues

Run `dream:sift`. Judge each issue by the enduring documents, "Design rationale"
and "How we judge" in `AGENTS.md`. Afterwards, offer to gather the issues we
accepted as sub-issues of one parent issue, and dispatch the parent as a
campaign. Alternatively, some issues may instead go out on their own as
standalone assignments.

Then run a retrospective on the session. Look back over the judgments we made
for lessons that would apply to future issues, and propose each one to me as an
entry for "How we judge". Add only the entries I approve, through a pull
request.

### Dispatch agents to implement issues

Dispatch through the labels in `dreamcatcher.toml`. Run `dreamcatcher about` to
learn how dreamcatcher works.

### Review a standalone assignment

Read its pull request against its issue and the enduring documents, with the
review comments that the agent left. When it changes a skill or a subagent file,
also read the guide to agent mechanics by its path,
`plugins/dream/skills/agent-mechanics/` (`SKILL.md`, `claude-code.md` and
`codex.md`), and check the change against "Writing instructions for coding
agents" in `AGENTS.md`. When it changes code under `scripts/`, read
`plugins/dream/coherent-coding.md`. Recommend either merging or the changes to
ask for.

### Cut a release

Read `docs/releasing.md` in full, and follow it autonomously.
