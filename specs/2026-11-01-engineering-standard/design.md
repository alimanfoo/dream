# Engineering standard: design

This design develops the [requirements](requirements.md), with the
[reading guide](reading-guide.md) as its map of the code.

## What we're building

A development system that converges. Agents and the user keep changing dream,
and the system around those changes brings drift to the surface and turns it
into issues, which are judged and fixed over time. Each round of that settles
the codebase further towards coherence. This work builds the system. It doesn't
do the cleanup itself: duplication and drift that exist today are for the system
to find and fix.

It has six parts:

- releases, so that users get changes only when one is cut, and a version number
  that means something;
- a guide to the mechanics of coding agents, shipped as a skill, that an agent
  loads before it changes a skill;
- dream's intent written down, in a concepts page and stories, separate from the
  skills;
- a feedback loop against drift, made of practices dream mostly has already;
- an engineering standard, with a measure, a bar and a check for each criterion,
  remeasured at each release;
- the infrastructure floor that dreamcatcher and uncoded already meet.

## How it works

### One change, from start to finish

An agent is asked to tighten what `dream:smith` does in its Collect step.
`AGENTS.md` tells it to read the guide to agent mechanics before it changes a
skill, so it knows that a skill is text added to a running session and returns
nothing, and that a resumed session keeps the old text. It reads the stories for
handing off a task, which say what Collect is for. It makes the change.

Its pull request description ends with a "Definition of done" section that
answers the standard's questions. The stories are still true, because the change
keeps what they promise. Every other place that states the same rule changed
with it. The change touches smith, so it reads dreamcatcher's contract and says
the contract is still met. It renames and removes no name. The code and
coherence reviews run as they do today. The pull request merges, and nothing
reaches users yet.

A few days later the user asks for a release. The agent preparing it reads the
descriptions of every pull request merged since the last release and writes the
changelog section. Smith now behaves differently but no name changed, so the
release is minor. It runs the consistency review over the plugin and the docs,
and measures every criterion in the standard. One finding is that spark, weave
and quest each restate "think out loud" in their own words. No open issue owns
that, so it files one. It compares the list of skills with the last release's
and finds none missing. The release pull request merges, the merge commit is
tagged, and a GitHub release is published. Then the agent opens a one-line pull
request that moves the marketplace pointer to the tagged commit, and merges it.

Codex users get the release at their next session. Claude users get it when they
next update. Later, `dream:sift` triages the "think out loud" issue, checking it
against the stories and concepts, and accepts it. dreamcatcher assigns it, and
an agent factors out a shared fragment. At the next release the measurement
shows one fewer copy.

### Releases and versions

**dream's interface is its names.** A name is resolved before any model reads
anything: the host resolves a skill's name when a user types it, and
dreamcatcher resolves the names in its configuration. Everything after the name
is read by a model, and a model adapts. So dream's interface is:

- the plugin's name, `dream`, and its marketplace: the repository
  `alimanfoo/dream` and the marketplace's own name, `dream`, from
  `.claude-plugin/marketplace.json`. Together they make the install ID
  `dream@dream` that the docs and dreamcatcher use;
- the names of its skills;
- which version of dreamcatcher's agent contract it meets;
- which hosts it runs on, Claude Code and Codex.

These are not part of the interface, because a model reads them, or because
someone else defines them:

- what a skill tells the agent to do;
- a skill's arguments. The one exact form, `GH{issue}`, is defined by
  dreamcatcher's contract;
- how the specification skills hand over to each other. Each starts from
  whatever it's given, and any step can be skipped;
- the outcome labels `dream:sift` uses, and the line in `AGENTS.md` that maps
  them. Sift adapts to whatever labels a repo has;
- the `> written by an agent` footer;
- the parent issue, its sub-issues and their blocked-by links. That graph is
  dreamcatcher's input, and dreamcatcher gives it its meaning. Quest, big and
  the user are three of the things that write it.

**The version follows the interface.** A release is major when it renames or
removes a skill, the plugin or the marketplace, moves to a new contract version,
or drops a host. It is minor when it adds a skill or changes what a skill does.
It is a patch when it makes a skill do what it was meant to, or rewords one
without changing what it does. Of ten pull requests merged between 29 October
and 3 November, only the rename of `dream:lead` to `dream:big` (#1023) would
have been major. Three were.

`docs/compatibility.md` states the interface and these rules. No script guards
the interface: a rename or removal shows in a pull request as a deleted skill
folder, and a step in the release checklist compares the skill list with the
last release's.

**Users get a release, not main.** The plugin entry in main's
`.claude-plugin/marketplace.json` becomes a `git-subdir` source that names
`plugins/dream` in this repository at the commit of the latest release. Both
hosts read that file from main, and both install the commit it names. The entry
is a pointer. It moves forward once per release and never back. A published
release never changes, and a bad release is fixed by the next one.

So work in progress stays off what users install, and a campaign can merge stage
after stage without users getting half of it. The user releases often, between
campaigns, as often as merges reach a state worth handing to a user. The user
runs releases too, with no second track that follows main.

**A release takes two merges.** A commit can't contain its own hash, so the
pointer can't move in the release commit. The release pull request merges first,
carrying the new version in `plugin.json` and the new changelog section, and its
merge commit gets the tag `v<version>` and a GitHub release. Then a one-line
pull request moves the pointer to the tagged commit. The agent that prepares the
release does both.

**The changelog is built at release.** A pull request no longer bumps the
version or writes a changelog entry. Its description says what changed for a
user, and whether it renames or removes a name. When it prepares a release, the
agent reads the descriptions of the pull requests merged since the last release,
and writes the section from them.

**The release checklist** lives in `docs/releasing.md`. Before each release:

1. Choose the version from what the merged pull requests changed, by the rules
   above. Compare the skill list with the last release's.
2. Run the consistency review over the plugin and the docs. It asks for one kind
   of finding: two claims about one concept that ought to agree and don't, each
   quoted. Fix what is quick to fix.
3. Measure every criterion in the standard, and replace `docs/measurement.md`
   with the results.
4. Bring the open issues up to date. Search them for each word that a
   "Replaces:" line on the concepts page has retired, such as "host". Rewrite
   each issue that uses one, and close each whose work is done or no longer
   applies, saying why.
5. File an issue for each finding and shortfall that no open issue already owns.
   None of them holds the release back. A failing check does.
6. Write the changelog section and set the version, then merge, tag, publish,
   and move the pointer.

The consistency review is a paragraph in the checklist, not a skill. uncoded's
consistency review skill works from Python symbols, and uncoded installs it only
in a project with Python source roots, so dream has no skill to run. If the
paragraph's findings prove thin, it can grow into a skill then.

The sweep in step 4 and `dream:sift` divide the tracker between them. Sift
triages issues that have no outcome label yet, and never takes up a triaged
issue again. The sweep catches triaged issues that a rename or removal has left
stale. Releases are frequent, so each sweep covers only what went stale since
the last.

**What the hosts do.** These follow from the reading guide and from Codex's
source.

- Every merge to main moves the marketplace's revision, so at its next session
  Codex re-clones the marketplace and reinstalls the same pinned commit. That's
  churn, not harm.
- A new release moves the pointer, which is itself a merge to main, so Codex
  users get it at their next session. Claude users get it when they update, as
  today.
- Codex removes an old version's folder at the first session after a version
  changes, and a session still on that version loses its files. Today that
  happens at every merge. Under releases it happens only at a release, and
  between releases the files never change.

Nobody has yet moved an existing install from the relative path to a pinned
entry. Codex should do it on its own: its forced reinstall clones the pinned
commit. Claude has been seen to install from a pinned entry and to move to a new
pin when it updates. If an existing install doesn't follow the switch at the
first release, reinstalling fixes it, and the changelog says so.

### The guide to agent mechanics

A skill in the plugin, `dream:agent-mechanics`, that explains how a coding agent
works: the reader's analogue of the Python interpreter's documentation. It
covers mechanics only. It holds no claims about how models behave, which can
only be seen in transcripts and shift from one model to the next, and it offers
no opinions or instructions. It gives a conceptual foundation: the fundamental
concepts of a coding agent, from which another model can reason about what a
prompt will do. It names a particular host's behaviour only where that changes
what follows from a concept, and never as a catalogue of differences. "Turn" is
one that earns its place. Claude Code calls each call of the model, with the
tool calls it asks for, a turn, while Codex calls the agent's whole response to
one prompt a turn. In both, the agent ends its turn when the model answers
without asking for another tool, and dream's skills tell agents to do exactly
that. dreamcatcher's concepts page already records this, under "Ambiguous
terms". Facts about how each host installs and updates a plugin belong to
dream's release process, not to the guide. It is written carefully from what's
known, citing docs and source where they exist.

Its first use is in `AGENTS.md`, which tells an agent working on dream to read
it before changing a skill. That puts it in front of the agent at the moment the
agent has to predict what a change will do. It also serves anyone doing context
or prompt engineering for a system with agents in it, who loads it by name.

Within dream, `AGENTS.md` points at it by its path in the working tree,
`plugins/dream/skills/agent-mechanics/SKILL.md`, not by name. Under releases, a
name loads the released copy: before the first release that ships the skill
there is none, and while a pull request changes it the agent would read the old
version. The same rule covers the two guides `AGENTS.md` already relies on: it
points at `plugins/dream/plain-english.md`, as it does today, and at
`plugins/dream/coherent-coding.md`. Smith keeps loading `dream:plain-english`
and `dream:coherent-coding` by name, which is right in every other repository.
In dream's own repository that means smith can have both the released and the
working-tree copy of a guide in context while a pull request changes that guide.
The working-tree copy is the one under review, so that gap is accepted.

This sketch shows the ground it might cover. It is a starting point, not a table
of contents. The agent that writes the guide should develop it from its own
research, and judge from that research which host behaviours change what follows
from a concept.

- The session: a growing transcript of input, thinking, tool calls, tool results
  and turn output. A turn ends when the model stops calling tools.
- How the model reasons: only by producing tokens, forward, one at a time, with
  no foresight of what it is about to write.
- What is in context: the system prompt, the project's `AGENTS.md` or
  `CLAUDE.md`, and the transcript. Nothing carries over from an earlier session.
- What a skill is: a name and description always in context. When invoked, its
  text joins the session with its location. It returns nothing, and the same
  agent carries on.
- Files and paths: the host finds a skill by its name, while the agent resolves
  a path itself. A skill's text stays in the transcript while the files beneath
  it can change.
- Subagents: a fresh session that starts from one prompt and sees nothing of the
  parent's context. Only its final message comes back, and it may have acted
  along the way.
- Tools and permissions: the agent can do only what its tools allow, and in a
  headless run nothing answers a prompt.
- Long sessions: when the transcript outgrows the window, the host summarises
  it, and early detail is lost. Both hosts document this thinly.

### Intent written down

`docs/concepts.md` names the concepts of the domain dream works in and says what
each word means. `docs/stories.md` says what the user and the agents do with
dream, why, and what they see, organised by the practices that `docs/index.md`
already uses: handing off a task, running skills from labelled issues, thinking
it through together, reviewing a change, and planning and writing. dream's
stories cover the practices. dreamcatcher's stories cover the mechanics of
running them unattended.

Both pages are for developers and agents. They sit in the docs site's
Development section, as the other two projects' do. `docs/index.md` stays the
user-facing home page.

The stories are what the judging step of the loop tests a finding against, and
what `dream:sift` reads to tell a bug from intended behaviour. Like uncoded's
Ontology and Stories stages, they are worked out with the user.

### The feedback loop against drift

The loop has four steps, and dream has most of each already.

- **Prevent.** Every pull request description ends with a "Definition of done"
  section, answering each of the standard's questions by title, with evidence.
  `AGENTS.md` asks for it, as dreamcatcher's does, and smith already reads
  `AGENTS.md`. The questions make the author look beyond the diff. dream's
  include whether the documents are still true, whether every copy of a changed
  fact changed with it, whether what it replaces was removed, whether it renames
  or removes a name, and, for a change to smith, less, big or scout, whether
  dreamcatcher's contract is still met. One question puts pressure on the habit
  of adding rather than removing: the pull request states how the plugin's line
  count changed, and a fix or maintenance change that grew it says why. That
  question is not a gate, since a real fix can need a new line.
- **Find.** The reviews on each pull request, smith's Collect filing what it
  noticed nearby, and the consistency review and measurement at each release.
  Each finding becomes an issue. At release, a finding that an open issue
  already owns isn't filed again. Collect doesn't check, and needn't: sift
  closes a duplicate when it triages it.
- **Judge.** `dream:sift`, which tests each finding against the stories and
  concepts.
- **Act.** dreamcatcher assignments, each of which is a pull request that
  answers the definition of done in turn.

The measurement at each release shows whether the loop is converging.

Noise decides whether a loop like this settles or thrashes. A false finding
costs the user triage time at best. At worst it gets "fixed", and the fix is
churn for the next review to find. So the judging step is the one to keep
strongest, and two parts of the loop wait for their judge:

- The "contract still met" question waits for
  [alimanfoo/dreamcatcher#899](https://github.com/alimanfoo/dreamcatcher/issues/899)
  to correct the contract. Today the contract says a skill must tell the agent
  to read `pull_request_state` first, which smith rightly doesn't, so the
  question would report a false violation.
- Releases wait for the concepts, the stories and the standard. The concepts and
  the stories are each worked out with the user in a session of their own. Once
  all three exist, the first release runs the whole checklist like every release
  after it. It has nothing earlier to compare against, so its changelog says it
  is the first release under this process, and its tag is the baseline from then
  on. Until the releases land, merges reach users as they do today.

A machine check is added only when review has missed the same thing more than
once, and the check would be small and exact.

### The standard

`docs/standard.md` starts from dreamcatcher's criteria. Each has a measure, a
bar and a check, and each shortfall becomes an issue.

- Kept, with dream's own examples: One vocabulary, True documents, Docs by
  purpose, Current tracker, Reviewed changes, Machine-checked rules, Few
  concepts, Symmetry (smith and less, the two hosts), and Rules not cases. Its
  ledger is `docs/special-cases.md`, as in the other two projects, and the
  Claude Code and Codex blocks in the skills are its first entries.
- Translated: Cohesive modules becomes one job per skill. No unused exports
  becomes a reader for every shared file and agent. One way becomes one fact,
  one home across skills. No suppressions covers markdownlint and Prettier
  markers, of which there are none today. Versioned contract becomes the
  compatibility page.
- Dropped, because they are about code: Focused functions, Fast readable tests,
  and Invariants by construction.
- Added: Size. At each release it counts the lines of each skill, of the shared
  files and of the plugin in total, with the change since the last release.
  Lines stand in for tokens: Prettier reflows every Markdown file to 80 columns,
  so a line holds a fairly steady amount of text, and a line count is exact on
  both hosts. There is no bar to start with. The change since the last release
  is what draws attention to growth.

The definition of done carries the standard's questions into every pull request.

### dreamcatcher's contract

A change to smith, less, big or scout is checked against dreamcatcher's contract
in three places: the definition of done, the consistency review at each release,
and the compatibility page, which states the contract version dream meets.
Corrections to the contract itself belong to
[alimanfoo/dreamcatcher#899](https://github.com/alimanfoo/dreamcatcher/issues/899).
Until it lands, smith and less don't meet version 1 to the letter, so it lands
before the compatibility page is written.

### The infrastructure floor

dream meets the floor that uncoded's standard takes from dreamcatcher: actions
pinned to commits, read-only `permissions` in every workflow, Dependabot,
zizmor, a `SECURITY.md`, and branch protection on main that requires the checks
and applies to admins. This needs no design.

### The documentation site

The site stops being one page. It keeps `docs/index.md` as its home and gains
two sections, following the other two projects:

- Reference: `compatibility.md` and `changelog.md`.
- Development: `concepts.md`, `stories.md`, `standard.md`, `measurement.md`,
  `releasing.md` and `special-cases.md`.

The site still publishes from main on every push, as the other two projects'
sites do, so between releases it can describe what users don't have yet.

## What changes, and what goes away

- **The version bump in every pull request goes.** The version changes only at
  release, so two pull requests can no longer take the same number (#991), and
  the number says something.
- **The relative-path plugin source goes.** Its replacement, the pinned entry,
  is what keeps work in progress off users. It also stops a merge from changing
  files under a running Codex session.
- **"There is no release process" goes from `AGENTS.md`,** and its release
  protocol is rewritten around the checklist.
- **The exhortation in `AGENTS.md` to read affected prompts together goes.** The
  definition of done replaces it with questions a pull request has to answer.
- **"The agent as a reader" goes from `AGENTS.md`.** Its two properties, that an
  agent reasons only by producing tokens and reasons forward, are mechanics, and
  they move into the guide. So do the facts about how each host runs a subagent
  and names one, and the conventions that rest on them point to the guide. The
  facts about packaging stay in `AGENTS.md`, such as why the manifest sits under
  `.codex-plugin`, since they concern this repository, not agents. The ten
  traits, the advice on telling an agent only what it needs, and the shape of an
  instruction stay.
- **The exemption for the collaborative skills goes from `AGENTS.md`.** Today it
  tells agents to treat any deviation in `dream:sift`, `dream:spark`,
  `dream:trace`, `dream:weave` and `dream:quest` as deliberate. dream now has
  two kinds of skill: those that give an agent instructions, and those written
  in the user's voice. `AGENTS.md` describes both as normal, neither as the
  exception, and both are under the same maintenance: the definition of done,
  the reviews, the consistency review and the measurement.
- **The one-page site goes.** The "one short page needs no search" setting
  changes, and the note in `AGENTS.md` that the site is one page goes. The home
  page keeps hiding its navigation, as dreamcatcher's does, and the other pages
  show it.

## Why it's this and not something else

- **uncoded's rule for skills was not adopted.** It makes removing or narrowing
  an instruction major. Tightening an instruction is how dream improves, so
  under that rule four of the ten pull requests above would have been major, and
  the major number would keep meaning only "behaviour changed". Main went from
  27.1.0 to 46.2.0 in the 12 weeks after 11 August.
- **The pointer is a commit, not a branch.** A `release` branch that a release
  moves would save the second pull request. But Codex's upgrade compares only
  the marketplace's revision on main, so moving the branch alone reaches no
  Codex user until main next moves.
- **The release is two pull requests, not one.** One pull request could carry
  both commits, with the pointer naming the commit before it, but a rebase would
  change that commit's hash and leave the pointer naming a commit that isn't on
  main.
- **Shared files were not turned into skills.** Reaching shared text by name
  would protect sessions from moved files, but Codex has no way to hide a skill
  from the user's menu, so every shared file would appear there.
- **Moving a file is not restricted.** A rule that a release never moves a file
  the previous release names would protect the few sessions that span a release,
  at a cost to every refactor.
- **Per-pull-request changelog entries were not adopted.** In practice agents
  forget some, and the release fills the gaps anyway.
- **The guide holds no claims about behaviour.** Those can only be seen in
  transcripts and shift between models, so the guide keeps to what can be read
  from docs and source.

## What's still open

- The interface is held loosely. It may need refining once it's written down.
- How the guide is used beyond `AGENTS.md`: a review lens that checks skill
  changes against it, an agent raising an issue about a skill, or the
  consistency review reading the skills against it. Each waits until the guide
  has proved useful.
- The bar for Size, and whether to measure tokens as well as lines. Both wait
  for the first measurements.

Related work has issues of its own:

- [#1053](https://github.com/alimanfoo/dream/issues/1053): Codex removes the
  version folder that a running or resumed session is using. This design makes
  that rarer but doesn't address it.
- [#1054](https://github.com/alimanfoo/dream/issues/1054): what `AGENTS.md` and
  `plain-english.md` say about writing prompts may be out of date. It is better
  revisited once the guide exists.
- [#1048](https://github.com/alimanfoo/dream/issues/1048): analysing the feeds
  from real use.
- [alimanfoo/dreamcatcher#899](https://github.com/alimanfoo/dreamcatcher/issues/899):
  correcting dreamcatcher's contract.
