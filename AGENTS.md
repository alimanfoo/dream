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
codebase whole, so the next builds on solid ground. The codebase does not drift,
rot, or need periodic human rescue.

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
should have caught, so design it out. An intent touch is choosing scope or a
trade-off in the issue that seeds a session, or in the review of its pull
request. It is the system working, so keep it. Reduce coherence touches to zero.
Keep intent touches. The issue that seeds a session and the review that closes
it are the channel intent comes through: keep them cheap, never remove them.

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

A lighter skill, `/dream:smith`, does similar work with a single agent instead
of a team. It carries one or more issues to a pull request on its own, spawning
subagents only to plan and review, and needs no agent teams feature.

An even lighter skill, `/dream:less`, carries a very small change from issue to
pull request, with a process cut back to match.

A coordinator skill, `/dream:catcher`, watches a repository for labelled issues
and dispatches a session for each. One session develops at a time. Sessions
awaiting review pile up alongside it. The issue's label picks the skill: a
`/dream:team` session, a lighter `/dream:smith` one, or the lightest
`/dream:less` one. It lets the work run unattended while the user is away.

The plugin also ships utility skills the user can run on their own.

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin**: the code under `plugins/dream`, which anyone who
  installs the plugin gets. Its main feature is the dream team: the
  [/dream:team skill](plugins/dream/skills/team/SKILL.md), its
  [protocol](plugins/dream/skills/team/protocol.md), and the
  [agent files](plugins/dream/agents). A
  [/dream:catcher skill](plugins/dream/skills/catcher/SKILL.md) coordinates
  unattended runs, dispatching a session for each labelled issue, with the label
  picking a `/dream:team`, `/dream:smith`, or `/dream:less` session. One session
  develops at a time. Sessions awaiting review pile up alongside it. A
  [/dream:smith skill](plugins/dream/skills/smith/SKILL.md) runs a single-agent
  version, for smaller tasks with no team. A
  [/dream:less skill](plugins/dream/skills/less/SKILL.md) runs a cut-back
  single-agent version, for very small changes. Utility skills ship alongside
  the team.
- **Developer support**: AGENTS.md. It supports plugin development and is not
  part of the installed plugin. (`CLAUDE.md` is a symlink to AGENTS.md. Edit
  `AGENTS.md` directly. Some editors refuse to write through a symlink.)

Two guides sit at the plugin root, not inside any one skill: the
[Plain English guide](plugins/dream/plain-english.md) and the
[coherent coding guide](plugins/dream/coherent-coding.md). The whole plugin
works to them, the team agents at runtime and the utility skills when invoked.
So each standard has one home, shared by all of them. A skill or agent file
loads a guide rather than restating a rule from it. The
[/dream:less skill](plugins/dream/skills/less/SKILL.md) is a deliberate
exception for both guides, since it carries only the bare minimum for changes
small enough to skip the full guides. It inlines a subset of rules from the
coherent coding and plain English guides instead of loading either in full. The
[/dream:spark skill](plugins/dream/skills/spark/SKILL.md) and the
[/dream:state skill](plugins/dream/skills/state/SKILL.md) are the other
exceptions, and load neither. Both are written in the user's voice, which can't
name a document to load without breaking its own register.

Ways the two layers get crossed:

- **In chat**, slipping into protocol vocabulary: phase names, role names,
  ancillary finding, post-merge sweep.
- **When writing AGENTS.md**, speaking as if it's inside the protocol. For
  example: "The agents in this protocol", "Surface what investigation reveals",
  "in a SendMessage to a teammate". Use third-party voice instead: "the
  dream-team agents", "the team surfaces…", "to another agent".

## Development notes

`protocol.md` is the source of truth for shared session flow and cross-agent
mechanics. Role-specific detail goes in the relevant agent file. Keep them
consistent. Neither should invent behaviour the other contradicts.

That split follows a general locality principle: **information belongs where it
is acted on, not where it is named.** Each file carries what its readers need to
do their job, not what its writers found interesting to elaborate. When someone
sketches a new mechanism in protocol.md first, move the operational detail to
the agent file of whoever runs it. `Grace.md`'s challenge and watch sections are
the templates.

The README lists the utility skills a user can run on their own. That list is
their one home. Add a new skill of this kind there. `coherence-review` is one
such skill.

`/dream:spark` and `/dream:requirements-analysis` overlap on purpose.
`/dream:spark` interviews the user to draw requirements out of them.
`/dream:requirements-analysis` produces them on its own, from material the user
already wrote. The duplication between them is a decision, not a defect, so
don't single-home it.

`/dream:state` and `/dream:code-analysis` overlap on purpose too. Both read the
code behind a task to ground the design work that follows. `/dream:state`
explores it with the user, so the user comes away understanding it as well.
`/dream:code-analysis` reads it on its own. The duplication between them is a
decision, not a defect, so don't single-home it.

`/dream:spark` and `/dream:state` are an experiment, trying a different approach
from the rest of the plugin. They run against repo convention on purpose, so
treat a deviation as deliberate rather than as drift to tidy up.

`/dream:spark` and `/dream:state` are the two skills the user experiences as a
conversation, and both bodies are written in the user's voice, as if the user
typed it: "ask me", "tell me only what you've read". Every other prompt in the
plugin programs an agent precisely. These two shape a conversation, so they open
one rather than describing one. An agent continues the register it is handed,
which makes this the strongest lever there is on how the conversation feels.
Don't normalise either back to the third person, or into a stack of orders.
Judge an edit to either by what the person on the other end experiences, not by
what the skill covers. A change that makes one more thorough at the cost of
feeling like a form is the wrong trade.

The frontmatter `description` stays third person in both, since the harness
reads that to pick the skill. Both bodies ask for plain writing in their own
words rather than naming the
[Plain English guide](plugins/dream/plain-english.md), for the same reason:
nobody says "load this document" out loud.

The register carries a precise protocol without loosening it. `/dream:spark`
specifies its fresh-reader subagent in the user's voice, and `/dream:state`
specifies its verification pass the same way. A step that needs to be exact is
written exactly, in the first person, rather than lifted out into a third-person
block.

Keep `/dream:copy-edit` off both bodies. It rewrites prose towards the Plain
English guide, a different end point, and the register is what would go. A
`/dream:smith` session runs it over everything the branch changed, so skip that
pass on a branch touching either file. This only arises here, where the plugin's
own skills develop the plugin. Everywhere else copy-edit is doing its job.

A skill that fans a review out to parallel subagents must wait for every one of
them, then combine their findings into one list before it returns or applies any
finding. Findings land one subagent at a time, and no subagent reads another's
passage or another's findings. So only the skill, and only once every subagent
is in, can drop a duplicate or settle two findings that pull the same site
different ways. `code-review`, `coherence-review`, and `copy-edit` all carry
this step. Give a new such skill the same one.

Any skill that takes findings from a subagent confirms them too, whether it
spawned one or several. Only one place does that confirming. The lens subagents
of `code-review` and `coherence-review` don't confirm a finding. So both skills
confirm each one against the code themselves. The `dream:copy-editor` subagent
does confirm each finding against the guide before returning it, and `state`'s
subagent confirms each claim against the code. So `copy-edit` and `state` don't
confirm them again. Pick one of those two homes for a new such skill. Don't pick
both.

A skill that spawns subagents must also tell the agent to go idle while they
run, rather than sleep, poll, or narrate the wait. `code-review`,
`coherence-review`, `copy-edit`, `smith`, `spark`, and `state` each carry that
line at the spawn site. Give a new one the same line.

All four agents read protocol.md, so it covers only what they share, and it does
so in the third person. A rule for one agent alone goes in that agent's file,
written there as a plain instruction to that agent. When such a rule lands in
protocol.md, move it. Don't reword it in the third person to make it fit. Two
signs it is in the wrong place: it tells the reader to do something ("go idle"),
or only one agent ever needs it.

Renaming, renumbering, or removing a phase, step, or concept ripples past the
file you edit. Step headings carry the phase in the number (for example,
`Step 5.4` is phase 5, step 4). References to a step or named section, within or
across files, are Markdown anchor links. So renumbering a step, or rewording any
heading, changes its anchor and breaks every link still pointing at the old one.
These link checks fail until you fix them. Markdownlint's MD051 covers
within-file links. `remark-validate-links` covers cross-file links. Both run in
pre-commit and CI. A link can only target a heading, so a sub-point referenced
by name needs to be a heading, not a bold inline label. The checks cover links
to a named section. Whole-file mentions and the protocol summary stay plain
prose. Also grep all plugin files, and AGENTS.md, for the old name.

A cross-file link only works if its reader ever opens the target file. Each
dream-team agent reads its own file and `protocol.md` at boot, never another
agent's file or one of Grace's `grace/phase<N>.md` files. A link from `Junio.md`
into `Ralph.md` or `grace/phase3.md` resolves for `remark-validate-links`, since
both files sit on disk together, but the agent reading `Junio.md` never follows
it. State the fact directly instead of citing where another agent's instructions
happen to say it too.

The plugin's prose names a phase or step by its lowercase name and the word
"phase" or "step", linked to its section: "the collect phase", "the decide
step", not a bare "Collect" or "Decide", which read as verbs. The section
headings, the phase list, and the "Phase N: name" and "Step N.M: name" labels
keep their capitals as structural titles.

The plugin's prose references a skill, an agent, or an issue label one way
throughout:

- Write a skill invocation as `/dream:foo`, a leading slash in backticks. Drop
  the backticks in a frontmatter `description:` field, a markdown heading, or a
  fenced command block.
- Write a subagent-type identifier as `dream:foo`, since it is not a slash
  command.
- Write an issue label as "dream:foo".
- `catch.sh` keeps its own shell register, where backticks and quotes would
  misread.
- Keep a skill reference (`/dream:team`) distinct from the multi-agent team
  concept, "the dream team", which stays plain prose.

This repo is mostly plugin metadata, skills, and agent prompts. There is no test
suite. When changing behaviour, read the affected skill and agent prompts
together. Check that lifecycle, role boundaries, and tool permissions stay
consistent. Run the pre-commit hooks to check formatting. See the Linting
section.

## Design principles

These principles all descend from the dream. They are what it implies for
building the plugin. The general design and implementation disciplines live in
the [coherent coding guide](plugins/dream/coherent-coding.md), which governs
work here like any other codebase. The machinery it weighs is the protocol's
own, a mechanism or a role or a phase.

**Sort every human touch: coherence or intent.** When the human steps in, name
which it is. _The dream_ draws the line. The test for any change: does it remove
a coherence touch, or does it lean on the human to hold something together?

**Judge every input on its merits, not its source.** The team's default pull is
to defer: to accept a teammate's finding because it was raised, to trust
existing code because it is already there, to take the session input's claims as
settled because the user brought them in. That deference is sycophancy, and an
autonomy failure: a team that defers needs the user to catch what it should have
caught itself. Weigh each input on the evidence, whoever supplied it.

**The session input is a seed, not a contract.** This is one instance of judging
input on its merits. The user opens with session input that seeds the
requirements analysis. Later phases build a more systematic picture from that
seed and may revise it. The team surfaces what investigation reveals, even when
it widens beyond the literal ask. The user can decline the wider scope by
pushing back in their review of the pull request.

**Each phase artifact has its own purpose. Don't mix concerns.** Requirements
analysis is about user intent. Code analysis is about code patterns. Design is
the proposal and the work it commits to. Code-pattern findings don't belong in
the requirements analysis, and vice versa.

## What the design is answering

Coding agents carry inherent traits that work against the dream. Naming them is
useful, because most of the plugin's machinery exists to answer one or more:

- **Perimeter fixation**: fixes the named site, not the cause. Resists working
  past a self-imposed boundary.
- **Shallow code reading**: guesses names and greps for them instead of tracing,
  and misses what the guess didn't name.
- **Over-engineering**: adds abstraction the need doesn't earn, with no felt
  bound on complexity.
- **Add over remove**: reaches for a new line, never a deletion.
- **Sycophancy**: defers to whoever spoke, rather than the evidence.
- **Literal-mindedness**: follows the instance, misses the general rule.
- **Saliency decay**: loses earlier context as the session grows.
- **No memory between sessions**: each session starts with a blank mind.
- **Over-eagerness**: attempts an underspecified ask rather than question it.
- **Reactivity**: answers what's asked, volunteers nothing.

Notes on how the plugin answers these:

**The answer is structural, not exhortative.** Telling an agent to be less
sycophantic produces no tokens and changes nothing (see "Writing agent
prompts"). Instead the plugin assigns a role whose job is the missing
disposition (Ada's fresh read, Junio's audit), a gate that forces the act, or an
artifact that carries a decision past the session that made it. The plugin
changes the structure around the trait, not the trait itself.

**Exploit agent traits rather than fight them.** Literal-mindedness and
over-eagerness are two examples, not the only ones. Literal-mindedness becomes a
lever when a name's plain sense pulls the right way (see
[Writing agent prompts](#writing-agent-prompts)), and the agent's obedience to
the name does the work. Over-eagerness is the engine behind active memory: an
agent that dutifully attempts whatever sits in front of it picks up a failing
check as a task and fixes it unasked.

## Writing agent prompts

The dream-team agents are LLMs. Writing well for them depends on what each agent
needs to know, the shape of an instruction, and the properties of the agent as a
reader.

### Tell each agent only what it needs

Tell each agent only what it needs to do its job, and cut the rest. The agent
reads every line as potentially actionable. So non-essential background dilutes
the instructions that matter and tempts the agent to act on the aside. Examples:
how a mechanism it isn't part of works, why a past decision was made, what
another role does downstream. When you catch yourself adding context, ask
whether this reader uses it to do their job. If not, cut it. This is the
per-reader companion to the locality principle (see Development notes). Locality
decides which file an instruction lives in. This decides whether a given reader
needs it at all.

### Instruction paragraphs

The Plain English guide ([`plain-english.md`](plugins/dream/plain-english.md))
sets the shape of an instruction paragraph: the imperative first, then the why,
then examples, then exceptions. An agent instruction adds rules of its own to
that shape.

The why is the one that motivates the act, not the one that motivates the
design. The reason the protocol or the prompt is _built_ this way (design
history, justification for a decision already made) belongs in the PR
description and commit message, not the instruction. A new mechanism tempts you
to motivate it inline. Write the instruction, then move the design-motivation
out.

Two more rules govern the instruction's content:

- **Generalise rules. Don't pin them to the incident.** A rule that surfaces
  from one failure mode (verbs at the tail of a numbered step list) should be
  stated for the general case (git verbs anywhere). Specific examples
  illustrate. They don't narrow the rule.
- **Keep rules small.** A single sentence usually does the work of a
  prescriptive template. Don't add scaffolding (mandatory tails, worked
  examples, taxonomies) unless the bare rule leaves a real ambiguity.

### The agent as a reader

Four properties of that reader change how you write for it.

**Agents reason by producing tokens**: thinking tokens, turn output, or tokens
written to files or messages. An instruction like "pause and consider X"
produces no tokens and has no effect. The agent reads it and moves on. To make a
check real, direct the agent to externalise: write the answer in turn output, in
a `SendMessage` to another agent, or in an artifact. Tests framed as
hypothetical dispositions (_would you be willing to X, could you Y, should you
Z, is this the kind of thing that A_) read as text and pass without firing.
Rewrite each as an act: _write X, check Y, name Z_.

**Agents reason forward from context**: they're next-token machines, with no
foresight of what they're about to write. So "before reaching for X, do Y"
doesn't work. The agent doesn't know they're about to reach for X. A check has
to run after the candidate content exists, and it has to name an act rather than
wait on a realisation: "reread the draft and cut any X", not "if you notice
you've written X". Noticing is not something an agent does unprompted, so a
check that waits for it never fires.

Rereading carries its own scope, which is the other reason to prefer it. It
reaches only what persists: a file, a draft, a message not yet sent. A turn
already streamed to the user can't be reread, so shape that one up front
instead. Say what it holds ("one question a turn") and where the rest goes
("everything else keeps until its own turn"), so the constraint drives the
writing rather than judging it afterwards.

**Agents act on a name's face value**: a literal-following model obeys the
everyday sense of the words you name things with: slots, moves, roles, phases.
The name is a stronger instruction than the prose beneath it, so the body won't
rescue a name that pulls the wrong way. Treat naming as a design decision. Weigh
the word's plain pull against the behaviour you want. Pick a different word when
they conflict. The same trap fires in reverse with words you reach for in
passing. The writer draws from general English by reflex. The reader reads each
word against the local glossary first. _Commit, accept, hold, ready, honestly_
get read in their plugin sense before their English one. Before reaching for a
word in prose, scan whether it already carries weight in the protocol. If it
does, pick a different word.

**Agents have a soft per-turn output budget**: quality falls off as a single
turn's output grows. Two rich generative acts crammed into one turn compete for
that budget, and both come out thinner. When a step needs more than one
substantial output (say a spread of analogies and then a spread of design
sketches), give each its own turn or message rather than asking for both at
once.

## Writing prose

The prose standard for this repo is the Plain English guide
([`plain-english.md`](plugins/dream/plain-english.md)). Follow it for every
prose artifact: agent prompts, the protocol, skill bodies, these dev notes. When
writing rules and instructions for the dream-team agents, see also
[Writing agent prompts](#writing-agent-prompts).

## Reviewing changes with subagents

A change to this repo is prose: the protocol and the agent prompts. The repo has
no test suite, so review is reading. Spawning several subagents in parallel,
each with one narrow lens, reads it more thoroughly than a single pass. These
are suggestions, not a fixed procedure. A few things make it work:

- **One narrow lens per agent.** A lens is a single question ("does the new flow
  break under failure?"), not "review this." Tell each agent to surface real
  findings with concrete rewrites, and to say so plainly when prose is already
  tight rather than manufacture nitpicks.
- **Anchor the lens to this file's rules.** Point each agent at the relevant
  part of these notes (the instruction-paragraph template, the design
  principles, the dream itself), not generic review standards. A lens grounded
  in the repo's own bar catches what a generic one misses.
- **Run them in parallel.** Independent agents don't anchor on each other, so
  they surface different things.
- **Sort the findings. Don't just apply them.** Each is one of three: a
  coherence defect to fix now, an intent decision that belongs to the user, or a
  follow-up issue. Judge each on its merits.

Ways to divide the work, for two different jobs:

- **Divergent lenses**: a different question per agent, to find problems you
  don't yet know are there. A non-exhaustive set that has paid off:
  - cross-file coherence and reference integrity: do protocol.md and the agent
    files still agree, and do the anchor links resolve?
  - lifecycle and edge cases: walk the changed flow end to end.
  - agent-prompt efficacy and register: will an agent act on the instruction,
    and is GitHub-visible text in public register?
  - whether it serves the dream: is a stored thing ever read, or write-only?
    Does the change add a human coherence-touch?
- **One lens, partitioned by file or section**: to apply a single standard you
  already trust, thoroughly. Divide along the existing structure (the per-phase
  steps versus the common rules) so the partitions don't overlap, and give the
  largest file more than one agent.

Use divergent lenses when you do not yet know what problems exist. Use the
partitioned single lens when you have a standard to apply.

## Linting

The repo uses [`pre-commit`](https://pre-commit.com/) for lightweight checks:

- trailing whitespace, end-of-file newlines, and JSON syntax
- Markdown style (`markdownlint-cli2`, with tuned rules in `.markdownlint.json`)
- Markdown formatting (`prettier`, which reflows prose to an 80-column width, so
  lines never need wrapping by hand)
- Markdown link validation (`remark-validate-links`, which checks within-file
  and cross-file anchor links resolve to real headings)
- invisible characters such as non-breaking spaces, zero-width marks, and bidi
  controls (`scripts/check_invisible_chars.py`)
- `claude plugin validate` on the plugin and marketplace manifests
- YAML frontmatter validation on skill and agent files
- the documentation index (`uncoded sync`, which regenerates
  `.uncoded/docs.yaml` and the `/uncoded-doc-navigation` skill)

At the start of each session, pull the latest `main` and install the hooks:

```bash
git pull origin main
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI
on every push and pull request (see `.github/workflows/lint.yml`). The
`claude plugin validate` hook requires the Claude Code CLI on `PATH`. CI
installs it via `npm`. The `uncoded` hook requires `uvx` on `PATH`. CI provides
it via `astral-sh/setup-uv`.

## Release protocol

There is no release process. The plugin is installed directly from this GitHub
repo's main branch.

When opening a PR, include a version bump in
`plugins/dream/.claude-plugin/plugin.json`, so every change merged to main is
versioned. Which part to bump:

- **Major**: a structural or breaking change to the protocol, one that changes
  how a session runs or breaks an expectation a running team relies on.
  Examples: a phase reshaped, steps renumbered.
- **Minor**: an additive, non-breaking change.
- **Micro**: a bug fix.

A change that touches only this developer meta-doc (`AGENTS.md`) needs no bump.
It isn't part of the installed plugin.

Keep the PR description short and current: say what the PR does and why, and
leave line-by-line detail to the diff. A description that restates the diff
drifts when review-driven follow-up changes the PR's scope. The stale
description then misleads the reviewer, and leaves an inaccurate record once
merged. Less restatement means less to keep in sync. Still update the body when
a later commit materially changes what the PR does.

## Before you start

Load the `uncoded-doc-navigation` skill before searching, reading or editing any
Markdown files in this codebase.
