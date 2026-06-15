# dream plugin for claude code

This repo defines the dream plugin for claude code. You are a coding assistant
helping the user to develop the dream plugin.

## The dream

The plugin is named for its purpose. The dream is **autonomous coherent
coding**: software that agents carry end to end, indefinitely, without the
codebase deteriorating and without the human stepping in to keep it healthy.

**Autonomous** means agent-first. The agents write all the code; the human
brings the value judgements — what to build, which trade-off to accept, what
"good" means here — and as little else as possible. A change that needs the
human to catch a mistake, carry a decision between sessions, or clean up
afterwards is a failure of autonomy, however small.

**Coherent** means everything fits, and stays fitting — self-maintaining and
self-healing. Each session leaves the codebase whole, so the next builds on
solid ground instead of repairing the last one's wake. No drift, no rot, no
periodic human rescue. Coding that can run this way forever is the target.

Naming the dream is not claiming it — it is not reached yet. But every part of
this plugin exists to move toward it, which makes it the axiom every design
decision answers to: does this make agent-led coding more sustainable on its
own, or does it lean on the human to hold something together?

This is not a distant ambition. Generating code is becoming table stakes, not an
advantage. What stays scarce is accepting that code indefinitely without the
codebase rotting, because generation speed and coherence pull against each
other: the faster agents write, the faster duplication and drift pile up, faster
than any human can review. So the durable edge is not a better generator but a
protocol that makes coherence keep pace with generation — a layer a stronger
base model does not hand you for free. A smarter model writes a better single
change; it does not, on its own, single-source a duplicated fact, add a missing
check, or refuse a scope that patches a symptom. Those are disciplines the
protocol imposes, not capabilities the model arrives with.

The line between what to automate and what to keep human is drawn by kind, not
degree. Coherence has a ground truth — code either fits or it does not — so it
can be delegated completely. Intent does not: those value judgements stay with
the human permanently. These are different axes, not two ends of one slider,
which is why the dream pushes both to the extreme at once — the human needed as
rarely as possible for coherence, kept firmly in place for intent. This gives a
test for every human touch. A coherence touch — spotting a duplicated fact,
catching drift, cleaning up after the team — is a defect the protocol should
have caught, and work to design out. An intent touch — choosing scope, accepting
a trade-off at a gate — is the system working, and removing it is itself the
failure. Drive the first toward zero; hold the second in place. The acceptance
gates are not incomplete automation waiting to be removed — they are the channel
intent comes through, to be made cheap but never closed.

Sustaining coherence over a long horizon is, at bottom, a memory problem. What
rots a codebase is not any single bad change but the slow loss of the decisions
that kept it coherent. Human teams hold those in people's heads; an agent team
has no heads — each session is a fresh mind with no memory of the last. So its
coherence-decisions can only live in the environment the sessions share: the
structure of the code, the checks that run, the issues on the tracker. A
decision recorded only as prose — a note a future session must read,
re-understand, and choose to honour — decays under re-interpretation, which is
why a surface keeps recurring even after an issue was filed for it. The
mechanisms that matter most write a decision into a form the next session cannot
drift from: a fact given one home, an invariant made a check. The team's deepest
job is not writing today's code well — the acceptance gates already secure that
— but curating the environment a future amnesiac version of itself will inherit.

## Introduction and orientation

The dream plugin launches a multi-agent team for software development, defined
within the `plugins/dream` folder. The entry point is the
`plugins/dream/skills/team/SKILL.md` skill, which the user invokes via the
`/dream:team` command. The skill spawns the agent team; each agent is defined by
a system prompt in `plugins/dream/agents`. The agents operate by a common
protocol: the shared session flow — phases, roles, and cross-agent mechanics —
is in `plugins/dream/skills/team/protocol.md`, and role-specific operating
detail lives in the agent files.

**Read all of the plugin files, in full, before doing anything else.**

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin** — `protocol.md`, the skill, and the agent files. These
  are the plugin's code; they get installed and run when someone uses
  `/dream:team`.
- **This file (AGENTS.md)** — meta-documentation for the coding assistant
  helping the dream plugin developer. One layer up; describes how to develop the
  plugin. (`CLAUDE.md` is a symlink to it — edit `AGENTS.md` directly; some
  editors refuse to write through a symlink.)

Two ways they get crossed:

- **In chat**, slipping into protocol vocabulary — phase names, role names,
  Ancillary Finding, post-merge sweep — when not inside a `/dream:team` session.
  The developer is developing the protocol, not running it.
- **When writing AGENTS.md**, speaking as if it's inside the protocol. "The
  agents in this protocol", "Surface what investigation reveals", "in a
  SendMessage to a teammate" all treat AGENTS.md as part of the protocol. Use
  third-party voice instead: "the dream-team agents", "the team surfaces…", "to
  another agent".

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

These principles all descend from the dream. Some are subgoals that serve it;
some are disciplines that keep the pursuit honest.

**The burden of proof is on the addition.** New machinery — a mechanism, a
concept, a special case — carries a permanent autonomy tax: the team has to
carry it, apply it correctly, and reconcile it with everything else. Before
adding, test three things in order. Can the apparent need be met by removing
something already there? Can it be met by widening an existing rule until the
special case disappears? Only if both fail is adding the right answer — and it
still has to prove it earns its keep against the tax it imposes.

**Coherent is the baseline, not the ceiling — and the ceiling is higher, not
lower.** A codebase that merely fits together is the floor. The aim above it is
the productive generalisation — a design that names a real concept, a domain
idea or a technical pattern, collapses duplication, reaches the root cause, and
reveals intent, so the code comes out simpler: less to maintain, less for a
future session to carry. The result is simpler to live with, but reaching it is
deeper and usually _more_ work than the change the input named. Default coding
agents rarely reach it; they follow instructions literally, add rather than
restructure, and leave the generalisation unseen. The plugin's job is to set the
conditions that let the team find it.

The disciplines — burden of proof on the addition, the bar against
over-engineering — guard that ambition; they do not cap it. They keep effort
from leaking into _unearned_ complexity (speculative abstraction, gold-plating,
machinery for a future that may not come) so it lands where it compounds. Read
alone they look like a mandate to do the minimum, and that reading inverts the
dream: doing the minimum — the named site and no further — is the agents'
_default_, the perimeter fixation and literal-mindedness the dream exists to
correct (see "What the design is answering"). The question is never "what is the
smallest change?" but "what leaves the codebase most coherent?" — and the honest
answer is usually the larger one.

**Sort every human touch: coherence or intent.** When the human steps in, name
which it is — _The dream_ draws the line. A coherence touch is a defect to
design out; an intent touch is the system working, and stays. The test for any
change: does it remove a coherence touch, or does it lean on the human to hold
something together?

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

**Adding a concept reframes the existing ones.** When you introduce a named
mechanism to a system that already has named mechanisms, the existing ones'
roles shift. Some become special cases of the new one; some become redundant;
some become stale. List every existing concept the new one touches and ask of
each: is it still doing the same job? Has its role narrowed? Is it now
incidental? Adding-while-pruning is the rhythm; adding alone leaves the system
carrying both.

## What the design is answering

Coding agents carry inherent traits that work against the dream. Naming them is
useful, because most of the plugin's machinery exists to answer one or more:

- **Perimeter fixation** — fixes the named site, not the cause, and resists
  working past a tight, mostly self-imposed boundary.
- **Shallow code reading** — guesses names and greps for them instead of
  tracing, and misses what the guess didn't name.
- **Over-engineering** — adds abstraction the need doesn't earn, with no felt
  bound on complexity: no alarm that says step back, this is getting too
  complex, where a human would stop.
- **Add over remove** — reaches for a new line, never a deletion.
- **Sycophancy** — defers to whoever spoke, rather than the evidence.
- **Literal-mindedness** — follows the instance, misses the general rule.
- **Saliency decay** — loses earlier context as the session grows.
- **No memory between sessions** — each session starts with a blank mind.
- **Over-eagerness** — attempts an underspecified ask rather than question it.
- **Reactivity** — answers what's asked, volunteers nothing.

Three things about how the plugin answers these matter more than the list
itself.

**The answer is structural, not exhortative.** The plugin almost never tells an
agent to be less sycophantic or to read code better — an instruction to hold a
different disposition produces no tokens and changes nothing (see "Writing agent
prompts"). Instead it assigns a role whose job is the missing disposition (Ada's
fresh read, Junio's audit), a gate that forces the act (Requirements open
questions answered before any building), or an artifact that carries a decision
past the session that made it. The trait doesn't change; the structure around it
does.

**Two traits are exploited, not fought.** Literal-mindedness is turned into a
lever: name a thing so its plain sense pulls the right way (see "Writing agent
prompts"), and the agent's obedience to the name does the work. Over-eagerness
is the engine behind active memory — an agent that will dutifully attempt
whatever sits in front of it is exactly what a failing check needs, because the
red check becomes a task the next session picks up and fixes without being
asked.

**Some traits still resist structure — the open frontier.** Reactivity is the
hardest: you cannot gate on the absence of a suggestion, because nothing is
there to point at, so the failure is silent. Sycophancy keeps re-emerging for
the same reason. The user catching these at a gate today is the current state,
not the design's resting place — every such catch is a coherence touch the dream
means to drive toward zero (see _The dream_). The win condition is finding the
structure that fires on a silent failure — the way the failing check turned
over-eagerness from liability to mechanism. These traits are where that
structure is still missing, and so where the next work is.

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

Build an instruction paragraph in four parts, in this order: the imperative, the
why, examples, exceptions.

- **Imperative first.** Open with what to do. "Check each scope item for X"
  beats "For each scope item, check whether X" — the qualifier shouldn't bury
  the verb.
- **Then the why.** Give the reason the agent weighs while working: why a
  default is risky, what a check defends.
- **Then examples.** One to three, to anchor a fuzzy criterion. They illustrate;
  they don't bound it (see "Generalise rules; don't pin them to the incident").
- **Then exceptions.** Edge cases come after the main rule, never before it.

The why is the one that motivates the act, not the one that motivates the
design. The reason the protocol or the prompt is _built_ this way — design
history, justification for a decision already made — belongs in the PR
description and commit message, not the instruction. A new mechanism tempts you
to motivate it inline; write the instruction, then move the design-motivation
out.

Not every paragraph needs all four — a bare imperative is enough when the act is
obvious. But hold the order: an exception before the rule, or a why before the
verb, forces the reader to decode before they can act.

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

Write plain English in every prose artifact the repo holds — agent prompts, the
protocol, skill bodies, these dev notes. The reader is the agent who runs the
protocol or the developer who maintains it; both pay a tax on jargon and
indirection. These are the clarity rules for any reader; what's specific to
writing for an LLM agent is in "Writing agent prompts".

- **Don't invent umbrella terms.** If you reach for one ("tree-shaping command")
  to cover a list you've already named, drop it; the examples do the work. Don't
  coin new protocol vocabulary unless it names a genuinely distinct concept
  being introduced for the first time.
- **Plain verbs, not idioms.** "Lands the commit," "ships the change," "the trap
  is" read as code-author shorthand. Say "runs git," "creates the commit," "the
  risk is."
- **Lead with the actor and the action.** "Ralph reads imperative verbs as
  instructions" beats "the trap is verbs like…" — the second form makes the
  reader decode who's trapped before they can act.
- **Lead with the main point; cut tangential consequence detail.** State the
  boundary first. Mention the one or two reasons that actually shape decisions,
  not every downstream effect.
- **Cut a negative that only restates the positive.** "Qualifies only when X"
  already carries "if not X, it doesn't" — don't append the inverse. A negative
  stays when it adds something the positive didn't: a reason, a named failure
  mode, or an action.
- **Generalise rules; don't pin them to the incident.** A rule that surfaces
  from one failure mode (verbs at the tail of a numbered step list) should be
  stated for the general case (git verbs anywhere). Specific examples
  illustrate; they don't narrow the rule.
- **Keep rules small.** A single sentence usually does the work of a
  prescriptive template. Don't add scaffolding (mandatory tails, worked
  examples, taxonomies) unless the bare rule genuinely leaves a real ambiguity.
- **Consistent voice within a list.** A "you never" bullet list shouldn't slip
  into "you do this instead" mid-bullet. Pick the voice and stay in it;
  cross-references can carry the positive alternative.

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
  act on the instruction; is GitHub-visible text in public register); whether it
  serves the dream (is a stored thing ever read, or write-only; does the change
  add a human coherence-touch); adversarial robustness (failures, concurrency,
  GitHub state the protocol doesn't control); security and privacy (what the
  change newly exposes); simplicity and readability (against the
  instruction-paragraph template).
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
marketplace manifests, and YAML frontmatter validation on skill and agent files.

Set up locally:

```bash
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI
on every push and pull request (see `.github/workflows/lint.yml`). The
`claude plugin validate` hook requires the Claude Code CLI on `PATH`; CI
installs it via `npm`.

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
