# Engineering standard: roadmap

Every session that implements a stage should correct the specifications as
details change and say on its pull request what it corrected. It may change how
it delivers the stage when earlier work or implementation discoveries justify
that change. It should raise any change to the roadmap's stages, boundaries,
order or dependencies with the user instead of restructuring the roadmap itself.

Stages marked interactive are worked out with the user in a session of their
own, not handed to an agent to build alone.

## Stage 1: Infrastructure floor

**Delivers.** The floor from the design's "The infrastructure floor", following
uncoded's setup:

- every action in `.github/workflows/lint.yml` and `.github/workflows/docs.yml`
  pinned to a commit, and every remote pre-commit hook frozen to one;
- read-only `permissions` on `lint.yml`, which has none today;
- `.github/dependabot.yml` for the `github-actions`, `pre-commit` and `uv`
  ecosystems, as uncoded has, where `uv` also covers `docs/requirements.txt`,
  with uncoded's one-week cooldown and its groups, except a security group for
  `pre-commit`, which Dependabot has no security updates for;
- zizmor as a pre-commit hook, run offline as uncoded runs it;
- a `SECURITY.md`.

After it merges, the user changes main's branch protection by hand: require the
`lint` check, apply protection to admins, and turn off "require branches to be
up to date". Only `lint` can be required, because the docs build runs only when
the docs change. Before it merges, the user turns on private vulnerability
reporting, which `SECURITY.md` points reporters to, and Dependabot alerts and
security updates, without which the security groups open no pull request.

**Done when.** zizmor passes on both workflows, Dependabot accepts its
configuration, and after the settings change
`gh api repos/alimanfoo/dream/branches/main/protection` shows `lint` required,
admins included and "up to date" off, and the next pull request shows `lint` as
required.

**Leaves for later.** CodeQL, secret scanning and the other repository settings
that uncoded's release reads back. The design doesn't ask for them.

**Needs.** Nothing.

## Stage 2: Concepts (interactive)

**Delivers.** First the site's new structure, done mechanically before the
conversation starts: a `nav` in `mkdocs.yml` with Home and a Development
section, the home page still hiding the navigation it hides today, the "one
short page needs no search" setting revisited, and the note in `AGENTS.md` that
the site is one page removed.

Then `docs/concepts.md`, worked out with the user, in the form of the other two
projects' concepts pages. Each term has an entry that uses only terms defined
before it and ends with the words it replaces. Old skill names go in those
"Replaces:" lines, such as craft and shape for weave, lead for big, and state
for scout. `AGENTS.md` points at the page and says to use its words.

**Done when.** The user has agreed every entry, the site builds in strict mode
with Concepts under Development, and the home page looks as it does today.

**Leaves for later.** Bringing the skills, docs and issues into line with the
words. That is the loop's work, from the first release.

**Needs.** Nothing.

## Stage 3: Compatibility (interactive)

**Delivers.** `docs/compatibility.md`, in a new Reference section of the site,
worked out with the user. It states dream's interface, the version rules and the
hosts, as the design's "Releases and versions" describes. It names the version
of dreamcatcher's contract that dream meets, which alimanfoo/dreamcatcher#899
will have corrected. Writing the interface down is where it gets refined, so
this is the place to change it.

**Done when.** The user has read the written interface and agrees it is the set
of names whose change they would call breaking, and the site builds with
Compatibility under Reference.

**Leaves for later.** Putting the rules in force. They choose versions from the
first release.

**Needs.** Stage 2, for the site's navigation.
[alimanfoo/dreamcatcher#899](https://github.com/alimanfoo/dreamcatcher/issues/899),
so that the contract version it names is one that dream meets.

## Stage 4: Stories (interactive)

**Delivers.** `docs/stories.md`, worked out with the user, under Development. It
opens with why dream exists and how it is used. Then it gives the happy paths
for each practice that `docs/index.md` names: handing off a task, running skills
from labelled issues, thinking it through together, reviewing a change, and
planning and writing. Each story says what the user does, what the agent does,
and what the user sees. The stories say that the specification skills hand over
loosely and any of them can be skipped. They point at dreamcatcher's stories for
the mechanics of running unattended. `AGENTS.md` points at the page as the
record of what dream is meant to do. `dream:sift` already holds the rule that
behaviour contradicting a story is a bug, so `AGENTS.md` doesn't repeat it.

**Done when.** The user has agreed every story, and the site builds with Stories
under Development.

**Leaves for later.** Changing any skill to match a story. A disagreement
between them is a finding for the loop.

**Needs.** Stage 2, for the words the stories are written in.

## Stage 5: `dream:agent-mechanics` (interactive)

**Delivers.** The skill `plugins/dream/skills/agent-mechanics/SKILL.md`, as the
design's "The guide to agent mechanics" describes. An agent first researches and
drafts it, from docs and source, and the user shapes it from there in the
session. The design's sketch of topics is a starting point, not a table of
contents.

`AGENTS.md` changes with it:

- it tells an agent working on dream to read the guide by its working-tree path
  before changing a skill, and points at `plugins/dream/coherent-coding.md` by
  path as well;
- "The agent as a reader" goes, since its two properties move into the guide;
- the facts about how each host runs and names a subagent move into the guide,
  and the conventions that rest on them point to it. The facts about packaging
  stay.

`docs/index.md` gets a row for the skill.

**Done when.** `scripts/validate_skill.py` passes, each claim in the guide cites
where it comes from, and the user has read it and found nothing in it that is an
instruction, an opinion or a claim about how models behave.

**Leaves for later.** Every other use of the guide, such as a review lens.
Revisiting the prompt-writing advice is #1054.

**Needs.** Nothing.

## Stage 6: Standard and definition of done

**Delivers.** `docs/standard.md`, with the aim, the fifteen criteria from the
design's "The standard", each with its measure, bar and check, the definition of
done, and the rule for exceptions. `docs/special-cases.md`, the ledger, with the
Claude Code and Codex blocks in the skills as its first entries. Both go under
Development.

`AGENTS.md` changes:

- it asks every pull request description for a "Definition of done" section that
  answers the standard's questions by title, with evidence;
- that replaces the exhortation to read affected prompts together;
- the exemption for the collaborative skills becomes a description of dream's
  two kinds of skill, those that instruct an agent and those in the user's
  voice, both under the same maintenance.

The definition of done includes "contract still met", for a change to smith,
less, big or scout, and the line-count question from the design's feedback loop.

**Done when.** The site builds with Standard and Special cases under
Development, and the next pull request after this one carries a "Definition of
done" section.

**Leaves for later.** Measuring. The first measurement is the first release's.

**Needs.** Stage 2, for the words the standard uses. Stage 3, for the
compatibility page that "Versioned contract" measures and the interface that
"renames or removes a name" asks about. Stage 4, for the stories that "documents
still true" points at.
[alimanfoo/dreamcatcher#899](https://github.com/alimanfoo/dreamcatcher/issues/899),
so that "contract still met" reads a corrected contract.

## Stage 7: Release process

**Delivers.** `docs/releasing.md`, the checklist from the design's "Releases and
versions", including the consistency review paragraph and the sweep. The
consistency review also reads smith, less, big and scout against dreamcatcher's
contract, as the design's "dreamcatcher's contract" asks. The page says a
release is run by the maintainer agent in an interactive session with the user,
not by dreamcatcher. An empty `docs/changelog.md`, under Reference.

**Done when.** The site builds with both pages, and the checklist names every
step the design gives, in order.

**Leaves for later.** The per-PR version bump rule in `AGENTS.md` and the
marketplace entry. Both change in stage 8, because if the bumps stopped before
the first release, merges in between would reach Codex users with an unchanged
version and Claude users couldn't update.

**Needs.** Stage 3, for the version rules the checklist applies. Stage 2, for
the "Replaces:" lines the sweep searches. Stage 6, for the standard the
checklist measures against.

## Stage 8: First release (interactive)

**Delivers.** The first release, run by the checklist in `docs/releasing.md`.
The maintainer agent runs it in an interactive session with the user, as every
release runs, and does each step after a merge itself. The release pull request
carries:

- fixes from the consistency review, with an issue filed for each other finding;
- the first `docs/measurement.md`, with an issue filed for each shortfall;
- the results of the sweep, which this first time covers every open issue;
- a changelog section saying this is the first release under the new process;
- the next minor version in `plugin.json`;
- the release protocol in `AGENTS.md` rewritten around the checklist: "There is
  no release process" and the per-PR bump with its "Which part to bump" rules
  go, `AGENTS.md` points at `docs/releasing.md` and `docs/compatibility.md`, and
  it asks each pull request description to say what changed for a user and
  whether it renames or removes a name.

Its merge commit is tagged and a GitHub release published. Then a one-line pull
request changes the plugin entry in `.claude-plugin/marketplace.json` to a
`git-subdir` source pinned to the tagged commit. If an existing install doesn't
follow the switch, the user reinstalls, and the changelog says so.

**Done when.** A Claude update and a new Codex session both install the tagged
version, and smith's banner shows it on each host.

**Leaves for later.** The Codex behaviour in #1053.

**Needs.** Stage 7, for the checklist. Stage 6, for the standard it measures
against. Stage 4, for the stories that findings are judged by.
