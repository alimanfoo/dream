# dream plugin for claude code

This repo defines the dream plugin for claude code. You are a coding assistant
helping the user to develop the dream plugin.

## The dream

The dream is **autonomous coherent coding**: agents carry software end to end,
indefinitely, without the codebase deteriorating and without the human stepping
in to keep it healthy.

**Autonomous** means agent-first. Agents write all the code. The human supplies
the value judgements and little else: what to build, which trade-off to accept,
what "good" means here. A change that needs the human to catch a mistake, carry
a decision between sessions, or clean up afterwards is an autonomy failure.

**Coherent** means everything fits and stays fitting. Each session leaves the
codebase whole, so the next builds on solid ground. No drift, no rot, no
periodic human rescue.

The dream is the axiom every design decision answers to. Does this make
agent-led coding more sustainable on its own, or does it lean on the human to
hold something together? A stronger base model does not settle this. It writes a
better single change. But on its own it does not single-source a duplicated
fact, add a missing check, or refuse a scope that patches a symptom. Those
disciplines come from the protocol, not the model.

Coherence and intent split by kind, and the split runs through the whole design.
Coherence has a ground truth: code either fits or it does not. So agents own it
completely. Intent is value judgement, so it stays with the human. This gives a
test for every human touch. A coherence touch is the human spotting a duplicated
fact, catching drift, or cleaning up after the team. It is a defect the protocol
should have caught, so design it out. An intent touch is choosing scope or
accepting a trade-off at a gate. It is the system working, so keep it. Drive
coherence touches toward zero. Hold intent touches in place. The acceptance
gates are the channel intent comes through: make them cheap, never remove them.

Sustaining coherence over a long horizon is a memory problem. Each session is a
fresh mind with no memory of the last. So coherence-decisions can only live in
the environment the sessions share: the structure of the code, the checks that
run, the issues on the tracker. A decision recorded only as prose decays under
re-interpretation, because a future session must re-read it and choose to honour
it. So a surface keeps recurring even after an issue was filed for it. The
mechanisms that matter most write a decision into a form the next session cannot
drift from: a fact given one home, an invariant made a check. Curating that
environment matters more than writing today's code well.

## Introduction and orientation

The dream plugin lives in the `plugins/dream` folder. It launches a multi-agent
team for software development. The entry point is the
`plugins/dream/skills/team/SKILL.md` skill, which the user invokes via the
`/dream:team` command. The skill spawns the agent team. A system prompt in
`plugins/dream/agents` defines each agent. The agents operate by a common
protocol. The shared session flow (phases, roles, and cross-agent mechanics)
lives in `plugins/dream/skills/team/protocol.md`. Role-specific operating detail
lives in the agent files.

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin**: `protocol.md`, the skill, and the agent files. These are
  the plugin's code. The `/dream:team` command installs and runs them.
- **This file (AGENTS.md)**: meta-documentation for the coding assistant helping
  the dream plugin developer. It sits one layer up. It describes how to develop
  the plugin. (`CLAUDE.md` is a symlink to it. Edit `AGENTS.md` directly. Some
  editors refuse to write through a symlink.)

Two ways they get crossed:

- **In chat**, slipping into protocol vocabulary: phase names, role names,
  Ancillary Finding, post-merge sweep.
- **When writing AGENTS.md**, speaking as if it's inside the protocol. For
  example: "The agents in this protocol", "Surface what investigation reveals",
  "in a SendMessage to a teammate". Use third-party voice instead: "the
  dream-team agents", "the team surfaces…", "to another agent".

## Development notes

`protocol.md` is the source of truth for shared session flow and cross-agent
mechanics; role-specific detail goes in the relevant agent file. Keep them
consistent — neither should invent behaviour the other contradicts.

That split follows a general locality principle: **information belongs where it
is acted on, not where it is named.** Each file carries what its readers need to
do their job, not what its writers found interesting to elaborate. The protocol
introduces; the actor acts. When a new mechanism gets sketched in protocol.md
first, the operational detail still needs to move to the agent file of whoever
runs it. `Grace.md`'s Challenge and Autopilot sections are the templates.

Renaming or renumbering a phase, step, or concept ripples past the file you
edit. Step headings carry the phase in the number — `Step 4.5` is phase 4, step
5 — and references to a step or named section, within or across files, are
Markdown anchor links. So renumbering a step, or rewording any heading, changes
its anchor and breaks every link still pointing at the old one; the link checks
(markdownlint's MD051 for within-file links, `remark-validate-links` for
cross-file links, both in pre-commit and CI) fail until they are fixed. A link
can only target a heading, so a sub-point referenced by name needs to be a
heading, not a bold inline label. The checks cover links to a named section;
whole-file mentions and the protocol summary stay plain prose, so also grep
every agent file and the protocol for the old name. `Junio.md` and `Ralph.md`
run parallel for shared mechanics, so the same instruction often lives in both;
edit them in lockstep.

This repo is mostly plugin metadata, skills, and agent prompts. There is no test
suite. When changing behavior, validate by reading the affected skill/agent
prompts together and checking that lifecycle, role boundaries, and tool
permissions stay consistent. Run the pre-commit hooks to check formatting; see
the Linting section.

## Design principles

These principles all descend from the dream.

**The burden of proof is on the addition.** New machinery — a mechanism, a
concept, a special case — carries a permanent cost: the team must carry it,
apply it correctly, and reconcile it with everything else. Before adding, try in
order: can the need be met by removing something already there? By widening an
existing rule until the special case disappears? Only if both fail is adding
right, and it must still earn its keep against that cost.

**Coherent is the baseline, not the ceiling.** A codebase that merely fits is
the floor. Aim higher: the productive generalisation — naming a real concept (a
domain idea or a technical pattern), collapsing duplication, reaching the root
cause, revealing intent — so the code comes out simpler: less to maintain, less
for a future session to carry. Reaching it is usually _more_ work than the
change as literally named, and default agents miss it: they follow instructions
literally, add rather than restructure, and leave the generalisation unseen. The
plugin's job is to set the conditions that let the team find it.

The disciplines — burden of proof on the addition, the bar against
over-engineering — guard this ambition; they do not cap it. They forbid
_unearned_ complexity (speculative abstraction, gold-plating, machinery for a
future that may not come), not the deeper work that lands in coherence. Read as
a mandate to do the minimum, they invert the dream: the minimum is the agents'
default, the perimeter fixation and literal-mindedness the dream exists to
correct (see "What the design is answering"). The question is never "what is the
smallest change?" but "what leaves the codebase most coherent?" — usually the
larger one.

**Sort every human touch: coherence or intent.** When the human steps in, name
which it is — _The dream_ draws the line. The test for any change: does it
remove a coherence touch, or does it lean on the human to hold something
together?

**Judge every input on its merits, not its source.** The team's default pull is
to defer — to accept a teammate's finding because it was raised, to trust
existing code because it is already there, to take the session input's claims as
settled because the user brought them in. That deference is sycophancy, and an
autonomy failure: a team that defers needs the user to catch what it should have
caught itself. Weigh each input on the evidence, whoever supplied it.

**The session input is a seed, not a contract.** This is one instance of judging
input on its merits. The user opens with session input that seeds the
Requirements Analysis; later phases build a more systematic picture from that
seed and may revise it. The team surfaces what investigation reveals, even when
it widens beyond the literal ask — and the user can decline the wider scope
explicitly via the Minimal Scope option.

**Each phase artifact has its own purpose; don't mix concerns.** Requirements
Analysis is about user intent. Code Analysis is about code patterns. Scope is
the work commitment. Design is the proposal. Code-pattern findings don't belong
in the Requirements Analysis, and vice versa.

**Adding a concept reframes the existing ones.** Introducing a named mechanism
to a system that already has named mechanisms shifts the existing ones' roles.
List every existing concept the new one touches and ask of each: is it still
doing the same job? Has its role narrowed? Is it now incidental? Add while
pruning; adding alone leaves the system carrying both.

## What the design is answering

Coding agents carry inherent traits that work against the dream. Naming them is
useful, because most of the plugin's machinery exists to answer one or more:

- **Perimeter fixation** — fixes the named site, not the cause; resists working
  past a self-imposed boundary.
- **Shallow code reading** — guesses names and greps for them instead of
  tracing, and misses what the guess didn't name.
- **Over-engineering** — adds abstraction the need doesn't earn, with no felt
  bound on complexity.
- **Add over remove** — reaches for a new line, never a deletion.
- **Sycophancy** — defers to whoever spoke, rather than the evidence.
- **Literal-mindedness** — follows the instance, misses the general rule.
- **Saliency decay** — loses earlier context as the session grows.
- **No memory between sessions** — each session starts with a blank mind.
- **Over-eagerness** — attempts an underspecified ask rather than question it.
- **Reactivity** — answers what's asked, volunteers nothing.

Three notes on how the plugin answers these:

**The answer is structural, not exhortative.** Telling an agent to be less
sycophantic produces no tokens and changes nothing (see "Writing agent
prompts"). Instead the plugin assigns a role whose job is the missing
disposition (Ada's fresh read, Junio's audit), a gate that forces the act, or an
artifact that carries a decision past the session that made it. The trait
doesn't change; the structure around it does.

**Two traits are exploited, not fought.** Literal-mindedness becomes a lever
when a name's plain sense pulls the right way (see
[Writing agent prompts](#writing-agent-prompts)), and the agent's obedience to
the name does the work. Over-eagerness is the engine behind active memory: an
agent that dutifully attempts whatever sits in front of it picks up a failing
check as a task and fixes it unasked.

**Some traits still resist structure — the open frontier.** Reactivity is the
hardest: you cannot gate on the absence of a suggestion, so the failure is
silent, and sycophancy re-emerges for the same reason. The user catching these
at a gate today is a coherence touch the dream means to drive toward zero (see
_The dream_); finding the structure that fires on a silent failure — the way the
failing check turned over-eagerness from liability to mechanism — is where the
next work is.

## Writing agent prompts

The dream-team agents are LLMs. Writing well for them turns on three things:
what each agent needs to know, the shape of an instruction, and the properties
of the agent as a reader.

### Tell each agent only what it needs

Tell each agent only what it needs to do its job, and cut the rest. The agent
reads every line as potentially actionable, so non-essential background — how a
mechanism it isn't part of works, why a past decision was made, what another
role does downstream — dilutes the instructions that matter and tempts the agent
to act on the aside. When you catch yourself adding context, ask whether this
reader uses it to do their job; if not, cut it. This is the per-reader companion
to the locality principle (see Development notes): locality decides which file
an instruction lives in; this decides whether a given reader needs it at all.

### Instruction paragraphs

WRITING.md sets the shape of an instruction paragraph: the imperative first,
then the why, then examples, then exceptions. An agent instruction adds rules of
its own to that shape.

The why is the one that motivates the act, not the one that motivates the
design. The reason the protocol or the prompt is _built_ this way — design
history, justification for a decision already made — belongs in the PR
description and commit message, not the instruction. A new mechanism tempts you
to motivate it inline; write the instruction, then move the design-motivation
out.

Two more rules govern the instruction's content:

- **Generalise rules; don't pin them to the incident.** A rule that surfaces
  from one failure mode (verbs at the tail of a numbered step list) should be
  stated for the general case (git verbs anywhere). Specific examples
  illustrate; they don't narrow the rule.
- **Keep rules small.** A single sentence usually does the work of a
  prescriptive template. Don't add scaffolding (mandatory tails, worked
  examples, taxonomies) unless the bare rule genuinely leaves a real ambiguity.

### The agent as a reader

Four properties of that reader change how you write for it:

- **Agents reason by producing tokens** — thinking tokens, turn output, or
  tokens written to files or messages. An instruction like "pause and consider
  X" produces no tokens and has no effect; the agent reads it and moves on. To
  make a check real, direct the agent to externalise: write the answer in turn
  output, in a `SendMessage` to another agent, or in an artifact. Tests framed
  as hypothetical dispositions — _would you be willing to X, could you Y, should
  you Z, is this the kind of thing that A_ — read as text and pass without
  firing. Rewrite each as an act: _write X, check Y, name Z_.
- **Agents reason forward from context** — they're next-token machines, with no
  premonition about what they're about to write. So "before reaching for X, do
  Y" doesn't work; the agent doesn't know they're about to reach for X. Checks
  have to fire after the candidate content exists in context. "If you notice
  you've written X" is what works.
- **Agents act on a name's face value** — a literal-following model obeys the
  everyday sense of the words you name things with: slots, moves, roles, phases.
  The name is a stronger instruction than the prose beneath it, so the body
  won't rescue a name that pulls the wrong way. Treat naming as a design
  decision: weigh the word's plain pull against the behaviour you want, and pick
  a different word when they conflict. A name whose plain sense already points
  at the behaviour needs no help from the prose. The same trap fires in reverse
  with words you reach for in passing: the writer draws from general English by
  reflex, while the reader reads each word against the local glossary first.
  _Commit, accept, hold, ready, honestly_ get read in their plugin sense before
  their English one. Before reaching for a word in prose, scan whether it
  already carries weight in the protocol; if it does, pick a different word.
- **Agents have a soft per-turn output budget** — quality falls off as a single
  turn's output grows. Two rich generative acts crammed into one turn compete
  for that budget, and both come out thinner. When a step needs more than one
  substantial output — say a spread of analogies and then a spread of design
  sketches — give each its own turn or message rather than asking for both at
  once.

## Writing prose

The prose standard for this repo is [`WRITING.md`](WRITING.md). Follow it for
every prose artifact — agent prompts, the protocol, skill bodies, these dev
notes. When writing rules and instructions for the dream-team agents, see also
[Writing agent prompts](#writing-agent-prompts).

## Reviewing changes with subagents

A change to this repo is prose — the protocol and the agent prompts — and there
is no test suite, so review is reading. Spawning several subagents in parallel,
each with one narrow lens, reads it more thoroughly than a single pass. These
are suggestions, not a fixed procedure. A few things make it work:

- **One narrow lens per agent.** A lens is a single question — "does the new
  flow break under failure?" — not "review this." Tell each agent to surface
  real findings with concrete rewrites, and to say so plainly when prose is
  already tight rather than manufacture nitpicks.
- **Anchor the lens to this file's rules.** Point each agent at the relevant
  part of these notes — the instruction-paragraph template, the design
  principles, the dream itself — not generic review standards. A lens grounded
  in the repo's own bar catches what a generic one misses.
- **Run them in parallel.** Independent agents don't anchor on each other, so
  they surface different things.
- **Sort the findings; don't just apply them.** Each is one of three: a
  coherence defect to fix now, an intent decision that belongs to the user, or a
  follow-up issue. Judge each on its merits — a subagent raising it is not a
  reason to accept it.

Two ways to divide the work, for two different jobs:

- **Divergent lenses** — a different question per agent, to find problems you
  don't yet know are there. A non-exhaustive set that has paid off: cross-file
  coherence and reference integrity (do protocol.md and the agent files still
  agree, and do the anchor links resolve); lifecycle and edge cases (walk the
  changed flow end to end); agent-prompt efficacy and register (will an agent
  act on the instruction; is GitHub-visible text in public register); and
  whether it serves the dream (is a stored thing ever read, or write-only; does
  the change add a human coherence-touch).
- **One lens, partitioned by file or section** — to apply a single standard you
  already trust, thoroughly. Divide along the existing structure (the per-phase
  steps versus the common rules) so the partitions don't overlap, and give the
  largest file more than one agent.

Reach for divergent lenses when hunting for the unknown; reach for the
partitioned single lens when applying a standard you already hold.

## Linting

The repo uses [`pre-commit`](https://pre-commit.com/) for lightweight checks:
trailing whitespace, end-of-file newlines, JSON syntax, Markdown style
(`markdownlint-cli2` — see `.markdownlint.json` for tuned rules), Markdown
formatting (`prettier` — reflows prose to an 80-column width, so lines never
need wrapping by hand), Markdown link validation (`remark-validate-links` —
checks within-file and cross-file anchor links resolve to real headings),
invisible characters (non-breaking spaces, zero-width marks, bidi controls — see
`scripts/check_invisible_chars.py`), `claude plugin validate` on the plugin and
marketplace manifests, YAML frontmatter validation on skill and agent files, and
the documentation index (`uncoded sync` — regenerates `.uncoded/docs.yaml`, the
heading outline of every Markdown file under the `doc-roots` in `.uncoded.toml`,
and maintains the pointer to it in this file).

At the start of each session, pull the latest `main` and install the hooks:

```bash
git pull origin main
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI
on every push and pull request (see `.github/workflows/lint.yml`). The
`claude plugin validate` hook requires the Claude Code CLI on `PATH`; CI
installs it via `npm`. The `uncoded` hook requires `uvx` on `PATH`; CI provides
it via `astral-sh/setup-uv`.

## Recommended resources

- [Claude Code Docs > Tools and plugins > Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Claude Code Docs > Tools and plugins > Extend Claude with skills](https://code.claude.com/docs/en/skills.md)
- [Claude Code Docs > Agents > Create custom subagents](https://code.claude.com/docs/en/sub-agents.md)
- [Claude Code Docs > Agents > Run agent teams](https://code.claude.com/docs/en/agent-teams.md)
  — The dream plugin depends on this feature. It is experimental; read this doc
  before changing any plugin or team mechanics.
- [Claude API Docs > Prompt engineering > Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md)
  — Read this before changing any skill, protocol, or agent file.

## Release protocol

There is no release process. The plugin is installed directly from this GitHub
repo's main branch.

When opening a PR, include a version bump in
`plugins/dream/.claude-plugin/plugin.json`, so every change merged to main is
versioned. Which part to bump:

- **Major** — a structural or breaking change to the protocol: a phase reshaped,
  steps renumbered, or anything that changes how a session runs or breaks an
  expectation a running team relies on.
- **Minor** — an additive, non-breaking change.
- **Micro** — a bug fix.

A change that touches only this developer meta-doc (`AGENTS.md`) needs no bump —
it isn't part of the installed plugin.

Keep the PR description short and current: say what the PR does and why, and
leave line-by-line detail to the diff. A description that restates the diff
drifts as review-driven follow-up changes the PR's scope, misleading the
reviewer who reads it and leaving an inaccurate record once merged. Less
restatement means less to keep in sync — but still update the body when a later
commit materially changes what the PR does.

<!-- uncoded:docs:start sha256=6a530a01 -->

## How to read documentation in this codebase

`.uncoded/docs.yaml` is an orientation outline: it lists every Markdown file and
its heading hierarchy. Headings are literal text — use `Read` or `grep` to
navigate to a section.

<!-- uncoded:docs:end -->
