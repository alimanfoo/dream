# dream plugin for claude code

This repo defines the dream plugin for claude code. You are a coding assistant helping the user to develop the dream plugin.

## The dream

The plugin is named for its purpose. The dream is
**autonomous coherent coding**: software that agents carry end
to end, indefinitely, without the codebase deteriorating and
without the human stepping in to keep it healthy. Take both
words at full strength.

**Autonomous** means agent-first. The agents write all the
code. The human brings the value judgements — what to build,
which trade-off to accept, what "good" means here — and as
little else as possible. A change that needs the human to catch
a mistake, carry a decision from one session to the next, or
clean up afterwards is a failure of autonomy, however small.

**Coherent** means everything fits, and stays fitting —
self-maintaining and self-healing. Each session leaves the
codebase whole, so the next one builds on solid ground instead
of first repairing the last one's wake. Nothing is left to tidy
up after the fact; there is no drift, no rot, no periodic human
rescue. Coding that can run this way forever is the target.

That is the dream: to unlock the full potential of autonomous
software development. Naming it is not claiming it — it is not
reached yet. But every part of this plugin exists to move
toward it, and that makes it the axiom every design decision
answers to. When a choice is unclear, this settles it: does it
make agent-led coding more sustainable on its own, or does it
lean on the human to hold something together? The design
principles below all descend from this.

This is not a distant ambition. The capability to generate code
is becoming common — table stakes, not an advantage. What stays
scarce is the ability to keep accepting that code indefinitely
without the codebase rotting, because generation speed and
coherence pull against each other: the faster agents write, the
faster duplication and drift pile up, faster than any human can
review. So the durable edge is not a better generator but a
protocol that makes coherence keep pace with generation — and
that is a layer a stronger base model does not hand you for
free. A smarter model writes a better single change; it does
not, on its own, single-source a duplicated fact, add a missing
check, or refuse a scope that patches a symptom. Those are
disciplines the protocol imposes, not capabilities the model
arrives with.

The line between what to automate and what to keep human is
drawn by kind, not degree. Coherence has a ground truth — code
either fits or it does not, drifts or it does not — so it can be
delegated completely. Intent does not: what to build, which
trade-off to accept, what "good" means here are value
judgements, not facts, so they stay with the human permanently.
These are different axes, not two ends of one slider, which is
why the dream pushes both to the extreme at once — the human
needed as rarely as possible for coherence, and kept firmly in
place for intent. This gives a test for every human touch in a
session. A coherence touch — the human spotting a duplicated
fact, catching drift, cleaning up after the team — is a defect:
the protocol should have caught it, and it is work to design
out. An intent touch — choosing the scope, accepting a
trade-off at a gate — is the system working as intended, and
trying to remove it is itself the failure. Same intervention,
opposite verdicts. Drive the first kind toward zero; hold the
second in place. The acceptance gates are not incomplete
automation waiting to be removed — they are the channel intent
comes through, to be made cheap but never closed.

Sustaining coherence over a long horizon is, at bottom, a
memory problem. What rots a codebase is not any single bad
change but the slow loss of the decisions that kept it
coherent. Human teams hold those decisions in people's heads;
an agent team has no heads — each session is a fresh mind with
no memory of the last. So the only place its coherence-decisions
can live is the environment the sessions share: the structure
of the code, the checks that run, the issues on the tracker. A
decision recorded only as prose — a note a future session must
read, re-understand, and choose to honour — decays under
re-interpretation, which is why a surface keeps recurring even
after an issue was filed and fixed for it. The mechanisms that
matter most are the ones that write a decision into a form the
next session cannot drift from: a fact given one home, an
invariant made a check. The team's deepest job is not writing
today's code well — the acceptance gates already secure that —
but curating the environment a future amnesiac version of
itself will inherit.

## Introduction and orientation

The dream plugin launches a multi-agent team for software development.

The plugin is defined within the `plugins/dream` folder.

The entry point to launching the plugin is the `plugins/dream/skills/team/SKILL.md` skill, which the user invokes via the `/dream:team` command.

The dream:team skill then spawns the agent team. Each agent is defined via a system prompt within the `plugins/dream/agents` folder.

The agents then operate according to a common protocol. The shared
session flow — phases, roles, and cross-agent mechanics — is defined
in `plugins/dream/skills/team/protocol.md`. Role-specific operating
detail lives in the agent files under `plugins/dream/agents/`.

**Read all of the plugin files, in full, before doing amything else.**

## Two layers

This repo has two layers, easy to confuse:

- **The dream plugin** — `protocol.md`, the skill, and the
  agent files. These are the plugin's code; they get
  installed and run when someone uses `/dream:team`.
- **This file (AGENTS.md)** — meta-documentation for the
  coding assistant helping the dream plugin developer. One
  layer up; describes how to develop the plugin.

Two ways they get crossed:

- **In chat**, slipping into protocol vocabulary — phase
  names, role names, Ancillary Finding, post-merge sweep —
  when not inside a `/dream:team` session. The developer is
  developing the protocol, not running it.
- **When writing AGENTS.md**, speaking as if it's inside
  the protocol. "The agents in this protocol", "Surface
  what investigation reveals", "in a SendMessage to a
  teammate" all treat AGENTS.md as part of the protocol.
  Use third-party voice instead: "the dream-team agents",
  "the team surfaces…", "to another agent".

## Development notes

`protocol.md` is the source of truth for shared session flow and
cross-agent mechanics. Role-specific detail goes in the relevant agent file. Keep protocol.md and agent files
consistent with each other — neither should invent behaviour the
other contradicts.

That split follows a general locality principle: **information belongs
where it is acted on, not where it is named.** Each file carries what
its readers need to do their job, not what its writers found
interesting to elaborate. The protocol introduces; the actor acts.
When a new mechanism gets sketched in protocol.md first, the
operational detail still needs to move to the agent file of whoever
runs it. `Grace.md`'s Challenge and Autopilot sections are the
templates.

This repo is mostly plugin metadata, skills, and agent prompts. There is no test suite. When changing behavior, validate by reading the affected skill/agent prompts together and checking that lifecycle, role boundaries, and tool permissions remain consistent. Run the pre-commit hooks to check formatting; see the Linting section.

## Design principles

These principles all descend from the dream. Some are subgoals
that serve it; some are disciplines that keep the pursuit
honest.

**The burden of proof is on the addition.** New machinery — a
mechanism, a concept, a special case — carries a permanent
autonomy tax: the team has to carry it, apply it correctly, and
reconcile it with everything else. Complexity is anti-autonomy.
Before adding, test three things in order. Can the apparent
need be met by removing something already there? Can it be met
by widening an existing rule until the special case disappears?
Only if both fail is adding the right answer — and the addition
still has to prove it earns its keep against the tax it imposes.

**Coherent is the baseline, not the ceiling.** A codebase that
merely fits together is the floor. The aim above it is the
productive generalisation — a design that names a real concept,
a domain idea or a technical pattern, collapses duplication, and
reveals intent, so the code comes out simpler: less to maintain,
less for a future session to carry. That simplicity is part of
the dream, not a goal beside it. Default coding agents rarely
reach it; they follow instructions literally, add rather than
restructure, and leave the generalisation unseen. The plugin's
job is to set the conditions that let the team find it — bounded
by the discipline against speculative abstraction: the
generalisation must simplify the code in hand, never add
machinery for a future that may not come.

**Sort every human touch: coherence or intent.** When the human
steps in, name which it is — *The dream* draws the line. A
coherence touch — drift, a duplicated fact, cleanup left behind
— is a defect to design out. An intent touch — choosing scope,
accepting a trade-off at a gate — is the system working, and
stays. Drive coherence touches toward zero; hold intent touches
in place. The test for any change: does it remove a coherence
touch, or does it lean on the human to hold something together?

**Judge every input on its merits, not its source.** The team's
default pull is to defer — to accept a teammate's finding
because it was raised, to trust existing code because it is
already there, to take the session input's claims as settled
because the user brought them in. That deference is sycophancy,
and an autonomy failure: a team that defers needs the user to
catch what it should have caught itself. Weigh each input on the
evidence, whoever supplied it.

**The session input is a seed, not a contract.** This is one
instance of judging input on its merits. The user opens with
session input that seeds the Requirements Analysis; later phases
build a more systematic picture from that seed and may revise
it. The team surfaces what investigation reveals, even when it
widens beyond the literal ask — and the user can decline the
wider scope explicitly via the Minimal Scope option.

**Each phase artifact has its own purpose; don't mix concerns.**
Requirements Analysis is about user intent. Code Analysis is
about code patterns. Scope is the work commitment. Design is the
proposal. Code-pattern findings don't belong in the Requirements
Analysis, and vice versa.

**Adding a concept reframes the existing ones.** When you
introduce a named mechanism to a system that already has named
mechanisms, the existing ones' roles shift. Some become special
cases of the new one; some become redundant; some become stale.
List every existing concept the new one touches and ask of each:
is it still doing the same job? Has its role narrowed? Is it now
incidental? Adding-while-pruning is the rhythm; adding alone
leaves the system carrying both.

## What the design is answering

Coding agents carry inherent traits that work against the
dream. Naming them is useful, because most of the plugin's
machinery exists to answer one or more:

- **Perimeter fixation** — fixes the named site, not the cause.
- **Shallow code reading** — infers from names instead of
  tracing.
- **Over-engineering** — adds abstraction the need doesn't earn.
- **Add over remove** — reaches for a new line, never a
  deletion.
- **Sycophancy** — defers to whoever spoke, rather than the
  evidence.
- **Literal-mindedness** — follows the instance, misses the
  general rule.
- **Saliency decay** — loses earlier context as the session
  grows.
- **No memory between sessions** — each session starts with a
  blank mind.
- **Over-eagerness** — attempts an underspecified ask rather
  than question it.
- **Reactivity** — answers what's asked, volunteers nothing.

Three things about how the plugin answers these matter more
than the list itself.

**The answer is structural, not exhortative.** The plugin
almost never tells an agent to be less sycophantic or to read
code better — an instruction to hold a different disposition
produces no tokens and changes nothing (see "Writing agent
prompts"). Instead it assigns a role whose job is the missing
disposition (Ada's fresh read, Junio's audit), a gate that
forces the act (Requirements open questions answered before
any building), or an artifact that carries a decision past the
session that made it. The trait doesn't change; the structure
around it does. This is why the plugin works where a list of
good intentions wouldn't.

**Two traits are exploited, not fought.** Literal-mindedness is
turned into a lever: name a thing so its plain sense pulls the
right way (see "Writing agent prompts"), and the agent's
obedience to the name does the work. Over-eagerness is the
engine behind active memory — an agent that will dutifully
attempt whatever sits in front of it is exactly what a failing
check needs, because the red check becomes a task the next
session picks up and fixes without being asked. A liability
aimed at the right target becomes a mechanism.

**The traits that resist structure are where the human
stays.** Reactivity is the hardest, because you cannot gate on
the absence of a suggestion — nothing is there to point at, so
the failure is silent. Sycophancy keeps re-emerging for the
same reason. These are exactly the traits whose residue still
leans on the user at a gate — the coherence-or-intent line
from *The dream* drawn through the agent's own grain.

## Writing agent prompts

The dream-team agents are LLMs. Three things matter when
writing or revising their prompts:

- **Agents reason by producing tokens** — thinking tokens,
  turn output, or tokens written to files or messages. An
  instruction like "pause and consider X" produces no tokens
  and has no effect; the agent reads it and moves on. To
  make a check real, direct the agent to externalise: write
  the answer in turn output, in a `SendMessage` to another
  agent, or in an artifact. Tests framed as hypothetical
  dispositions — *would you be willing to X, could you Y,
  should you Z, is this the kind of thing that A* — read
  as text and pass without firing. Rewrite each as an act:
  *write X, check Y, name Z*. The act is the token; the test
  becomes real.
- **Agents reason forward from context** — they're
  next-token machines, with no premonition about what
  they're about to write. So "before reaching for X, do Y"
  doesn't work; the agent doesn't know they're about to
  reach for X. Checks have to fire after the candidate
  content exists in context. "If you notice you've written
  X" is what works.
- **Agents act on a name's face value** — a literal-following
  model obeys the everyday sense of the words you name things
  with: slots, moves, roles, phases. The name is a stronger
  instruction than the prose beneath it, so the body won't
  rescue a name that pulls the wrong way. Treat naming as a
  design decision: when you introduce or rename a concept,
  weigh the word's plain pull against the behaviour you want,
  and pick a different word when they conflict. A name whose
  plain sense already points at the behaviour needs no help
  from the prose. The same trap fires in reverse with words
  you reach for in passing: the writer draws from general
  English by reflex, while the reader reads each word against
  the local glossary first. *Commit, accept, hold, ready,
  honestly* get read in their plugin sense before their
  English one. Before reaching for a word in prose, scan
  whether it already carries weight in the protocol. If it
  does, pick a different word — even a slightly less elegant
  one is safer than a collision.

## Writing prose

When you write or edit prose in this repo — agent prompts, the
protocol, skill bodies — write plain English. The reader is the
agent who will run the protocol or the developer who will
maintain it. Both pay a tax on jargon and indirection.

- **Don't invent umbrella terms.** If you reach for one
  ("tree-shaping command") to cover a list you've already named,
  drop it; the examples do the work. Don't coin new protocol
  vocabulary unless it names a genuinely distinct concept being
  introduced for the first time.
- **Plain verbs, not idioms.** "Lands the commit," "ships the
  change," "the trap is" read as code-author shorthand. Say
  "runs git," "creates the commit," "the risk is."
- **Lead with the actor and the action.** "Ralph reads
  imperative verbs as instructions" beats "the trap is verbs
  like…" — the second form makes the reader decode who's
  trapped before they can act.
- **Open instruction paragraphs with the imperative.** Lead
  with what to do, then 1-3 sentences of examples or
  follow-on, then any exceptions. "Check each scope item for
  X" beats "For each scope item, check whether X" — the
  qualifier shouldn't bury the verb.
- **Lead with the main point; cut tangential consequence
  detail.** State the boundary first. Mention the one or two
  reasons that actually shape decisions, not every downstream
  effect.
- **Generalise rules; don't pin them to the incident.** A rule
  that surfaces from one failure mode (verbs at the tail of a
  numbered step list) should be stated for the general case (git
  verbs anywhere). Specific examples illustrate; they don't
  narrow the rule.
- **Keep rules small.** A single sentence usually does the work
  of a prescriptive template. Don't add scaffolding (mandatory
  tails, worked examples, taxonomies) unless the bare rule
  genuinely leaves a real ambiguity.
- **Consistent voice within a list.** A "you never" bullet list
  shouldn't slip into "you do this instead" mid-bullet. Pick the
  voice and stay in it; cross-references can carry the positive
  alternative.

## Linting

The repo uses [`pre-commit`](https://pre-commit.com/) for lightweight checks: trailing whitespace, end-of-file newlines, JSON syntax, Markdown style (`markdownlint-cli2` — see `.markdownlint.json` for tuned rules), `claude plugin validate` on the plugin and marketplace manifests, and YAML frontmatter validation on skill and agent files.

Set up locally:

```bash
uvx pre-commit install
```

Run all hooks once: `uvx pre-commit run --all-files`. The same hooks run in CI on every push and pull request (see `.github/workflows/lint.yml`). The `claude plugin validate` hook requires the Claude Code CLI on `PATH`; CI installs it via `npm`.

## Recommended resources

- [Claude Code Docs > Tools and plugins > Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Claude Code Docs > Tools and plugins > Extend Claude with skills](https://code.claude.com/docs/en/skills.md)
- [Claude Code Docs > Agents > Create custom subagents](https://code.claude.com/docs/en/sub-agents.md)
- [Claude Code Docs > Agents > Run agent teams](https://code.claude.com/docs/en/agent-teams.md) — The dream plugin depends on this feature. It is experimental; read this doc before changing any plugin or team mechanics.
- [Claude API Docs > Prompt engineering > Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md) — Read this before changing any skill, protocol, or agent file.

## Release protocol

There is no release process. The plugin is installed directly from this GitHub repo's main branch.

When opening a PR, include a version bump. Micro version bump for bug fixes. Minor version bump for all other changes while on the 0.x series. This ensures that all changes that get merged to main will include a version bump.
