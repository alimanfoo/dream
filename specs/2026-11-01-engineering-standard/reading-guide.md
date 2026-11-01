# Reading guide: dream's quality machinery

This guide accompanies the requirements brief in this folder. It covers the code
and documents behind the engineering standard: what dream has today to keep
itself coherent, where that machinery stops, and what the standards in
dreamcatcher and uncoded consist of.

## The big picture

dream is about 3,500 lines of Markdown, and nothing executes it except another
model. It comes in three pieces:

- **The plugin**, under `plugins/dream`: 15 skills in `skills/*/SKILL.md`, 2
  agent prompts in `agents/`, and shared files that skills point at
  (`plain-english.md`, `coherent-coding.md`, `spec-files.md`,
  `subagent-waiting.md`, `agent-written-marks.json`), plus the manifest in
  `.codex-plugin/plugin.json`.
- **Developer support**: `AGENTS.md`, `.pre-commit-config.yaml` with three
  Python checks in `scripts/`, CI in `.github/workflows/lint.yml`, and a
  one-page docs site (`docs/index.md`, `overrides/home.html`).
- **dreamcatcher**, outside the repo, which installs dream from main and runs
  `dream:smith`, `dream:less`, `dream:big` and `dream:scout` unattended, with
  its own prompt wrapped around each.

The skills form a loop that starts and ends in the tracker. The long-horizon
route runs `dream:spark`, `dream:trace`, `dream:weave` and `dream:quest`, each
writing one file into a shared `specs/<date>-<slug>/` folder. Quest then creates
a parent issue and one child per stage, with `gh issue create --parent` and
`--blocked-by`. Labelling the parent starts a campaign: dreamcatcher runs
`dream:big`, which labels each stage with one of the assignment routes.
dreamcatcher runs `dream:smith` or `dream:less` on each, depending on the route,
and big reviews and merges each stage. Smith's wrap-up round (Collect) files new
issues, and `dream:sift` triages them.

The division of responsibility between dream and dreamcatcher matters
throughout:

- dreamcatcher owns everything between rounds. It cuts the branch and worktree,
  opens the draft pull request with `Closes #N`, relays the user's posts as
  input, wakes the agent for a behind-main or failing-check pull request, gives
  the wrap-up round after a merge or close, and holds any assignment whose issue
  an open issue blocks. Its prompt carries the instructions for all of that.
- dream owns what happens inside a round: what the agent plans, builds, reviews,
  writes and files.
- Quest's issue graph feeds both. dreamcatcher's scheduler relies on the
  blocked-by links to order the stages, and `dream:big` relies on the
  parent/child links, which arrive as `children` in its round input.

In dreamcatcher and uncoded, an agent can check its work against stories and a
test suite. In dream the only thing that runs a skill is another model, so the
only test today is the user reading the output. That's why the user still builds
new skills and features interactively here, and reviews them closely.

Route: read `AGENTS.md` first, then the stops below in order. Read `dream:smith`
early, since most machinery hangs off it, and read dreamcatcher's
`docs/contract.md` and `src/dreamcatcher/prompts.py` together.

## Where the rules are written: `AGENTS.md`

Almost every quality rule dream has lives in `AGENTS.md`. It holds the two
layers, the reference conventions for `dream:foo`, which file owns which shared
rule (`spec-files.md`, `subagent-waiting.md`), the list of agent traits, "the
answer is structural, not exhortative", the advice on writing prompts, and the
release protocol. `CLAUDE.md` pulls it in with `@AGENTS.md`. Smith's "Orient to
the repo" step reads it, and the code review's "alignment" lens checks against
it.

Its one rule about knock-on consequences is an exhortation: "There is no test
suite. When changing behaviour, read the affected skill and agent prompts
together. Check that lifecycle, role boundaries, and tool permissions stay
consistent." It never mentions dreamcatcher.

## The model of the reader: `AGENTS.md` and `plain-english.md`

Read "What the design is answering" and "Writing agent prompts" in `AGENTS.md`,
then "Giving instructions" in `plugins/dream/plain-english.md`.

What's written down:

- the ten agent traits;
- two properties of the reader: agents reason only by producing tokens, and they
  reason forward, so a check has to run after the content exists and name an
  act;
- the reader takes every line as potentially actionable, so background tempts it
  to act on the aside;
- the shape of an instruction: condition, imperative, why, examples, exceptions.
  The guide's first line applies it to prompts.

It is a model for writing orders. The five user-voice skills (`dream:sift`,
`dream:spark`, `dream:trace`, `dream:weave`, `dream:quest`) depart from it on
purpose: they explain what the user wants, in the first person. `AGENTS.md`
exempts them. Open issue #983 says it still tells agents to apply the Plain
English guide to four of them, named by their old names.

Nothing describes the mechanics: what a skill is (text loaded into the running
session, with no return value), or the session loop. The mechanical facts that
are written down are scattered across `subagent-waiting.md` (how each host
waits), `AGENTS.md` (Claude reads `agents/` files as named agents, Codex takes a
file path), and individual skills.

## The machine checks: `.pre-commit-config.yaml`

`lint.yml` runs the same hooks in CI. They check:

- formatting and syntax: whitespace, JSON, YAML, markdownlint, Prettier;
- invisible characters, with `scripts/check_invisible_chars.py`;
- skill frontmatter and the `# dream:foo` title, with
  `scripts/validate_skill.py`. Its allowed keys are Claude Code's list;
- agent frontmatter, with `scripts/validate_agent.py`;
- the manifests, with `claude plugin validate`. At commit time it runs only when
  `plugin.json` or `marketplace.json` changes. CI runs every hook on all files;
- links and anchors, with `remark-validate-links`;
- the docs index, with `uncoded sync`.

The link check is the only cross-file consequence a machine catches. Skills
point at shared files with real links, such as
`../../plain-english.md#text-for-github`, so renaming a heading fails the
commit.

Anything written as prose passes unchecked: a backticked skill name, a `gh`
flag, a dreamcatcher input field, a paragraph copied between skills. Nothing
checks the Codex side (#836). And nothing enforces the checks. Main's branch
protection lists no required status checks, and admins are exempt.

## The reviews on each pull request

`dream:smith` runs `dream:code-review` and then `dream:coherence-review`, and
posts each finding with one response line. `dream:less` runs the code review
inline, with no subagents. `dream:big` leaves detailed review to the stage's
skill.

- `skills/code-review/SKILL.md` picks lenses per diff, and launches
  `agents/code-review-lens.md` for each. Its examples include "reader's context"
  (the Plain English reader) and "alignment" (with `AGENTS.md`), the nearest it
  has to a prompt review.
- `skills/coherence-review/SKILL.md` pastes sections of `coherent-coding.md`
  into three lenses, and keeps a finding only if its fix removes more than it
  adds. The guide is written for code: "one fact, one home" and "same edit,
  every instance" fit skills, while the code-shape ladder of types and smart
  constructors doesn't.
- `skills/precedent-review/SKILL.md` and `agents/precedent-reviewer.md` learn
  the user's standards from their past review comments. No skill has run it
  since #1027 took it out of smith.

Pull request #1035, which added `dream:sift`, shows the reviews working on a
skill: the code review found two paths where the agent would act wrongly, and
the coherence review cut a rule stated twice. All three findings stayed inside
sift. Nothing tells either review to look at the other skills, dreamcatcher's
contract or the docs.

## Shared files and copies

Some facts have one home, with real links from every skill that uses them:

- `spec-files.md`, for spark, trace, weave and quest;
- `subagent-waiting.md`, for seven skills;
- `agent-written-marks.json`, for eight skills and `spec-files.md`;
- `agents/code-review-lens.md`, for both reviews under both hosts.

Elsewhere dream copies. Smith and less share more than 20 paragraphs word for
word (#909 is one of them). The review skills repeat the same launch and verify
text (#791, #689). The user-voice skills share almost no sentences but restate
the same ideas in their own words, and the copies have diverged: spark and weave
offer to file a new issue when there's no seed, and trace and quest don't.
Nothing records whether such a difference is deliberate, and `AGENTS.md` tells
agents to treat these skills' departures from convention as deliberate.

## The dreamcatcher boundary

Read dreamcatcher's `docs/contract.md`, then `src/dreamcatcher/prompts.py`.

The contract is version 1. Its compatibility page says the version goes up when
an existing conforming skill would have to change. It has sections for
assignments, campaigns and conversations, and names smith, less, big and scout
as the working examples. The campaign and conversation sections already say the
skill needn't repeat what dreamcatcher's prompt adds. The assignment section
still says a skill "must instruct the agent to read `pull_request_state` before
anything else", which `_ASSIGNMENT_INPUT_PROMPT` already says. Smith never
mentions the field. #970 is the precedent: the inbox fields came out of smith
and less because dreamcatcher's prompt supplies them.

dreamcatcher has its own hidden marker, `AGENT_POST_MARKER`
(`<!-- dreamcatcher -->`) in `prompts.py`, which the relay in `relay.py` uses to
tell the agent's posts from the user's. dream's visible footer is separate. A
campaign lead leaves the hidden marker off its feedback on a stage's pull
request, so that the feedback reaches the stage's agent.

What the contract leaves out is what dreamcatcher relies on in dream:

- skill names and the `GH{issue}` form, in `default_config.toml`;
- the marketplace `alimanfoo/dream` and plugin `dream@dream`, in
  `repository_setup.py`;
- dream's `SKILL.md` paths, which the contract page links to as examples without
  making them an obligation;
- the footer `> written by an agent`, hardcoded in `issue_conversations.py`;
- quest's blocked-by links, read by `scheduler/blockers.py`.

On dream's side, nothing points at the contract. alimanfoo/dreamcatcher#899
covers correcting it.

## Versions and the install path

The version lives in `plugins/dream/.codex-plugin/plugin.json`, at 46.1.0.
`.claude-plugin/plugin.json` is a symlink to it, and `pyproject.toml`'s 0.1.0 is
a placeholder. `AGENTS.md` asks for a bump in every pull request. 79 commits, 70
of them not merges, have touched the manifest since it moved there on 11 August,
and there are no tags. Only smith's and less's banners read the number. Two pull
requests open at once can take the same number (#991).

`.claude-plugin/marketplace.json` gives the plugin's source as
`./plugins/dream`, so a user gets whatever main held when their host last
fetched the marketplace. That holds for the docs' install commands and for
`dreamcatcher init`. A test earlier in this work showed both hosts accept a
`git-subdir` source pinned to a sha. Claude followed a moved pin on a normal
update. Codex needed a fresh `plugin add` from a local marketplace, and its
behaviour with a Git marketplace is unconfirmed. `AGENTS.md`: "There is no
release process."

## The tracker

Read Collect in `skills/smith/SKILL.md`, then `skills/sift/SKILL.md`.

Collect runs in smith's wrap-up round. It files what it noticed and left out of
scope, every deferred review finding included. It files every bug, caps
maintenance issues at two, and never asks whether the behaviour was intended.
Issue #890 was a bug in this hand-off: Collect ran on an open pull request.

Sift's queue is every open issue with no outcome label. Its judgments include
"Be sceptical of agent-raised issues" and "A bug contradicts a story". When a
repo keeps no stories, it falls back to "other product promises", and dream
keeps none. So a decision that sift settles here ends up only in an issue
comment.

As of today there are 69 open issues, and 5 carry an outcome label. 11 carry the
agent footer, which is a lower bound, because the footer is newer than many of
the issues. Old issues name skills by old names, and some names were reused:

- `craft` became `shape` (18 August), then `weave` (24 September);
- `less` became `solo` (13 July), then `smith` (2 August), and today's
  `dream:less` was added on 17 July;
- `state` became `scout` (24 September). On 27 September the names of
  `dream:scout` and `dream:trace` were swapped.
- `dream:team` and its Ada, Grace, Junio and Ralph agents were removed on 18
  September.

## Hand-kept copies

These restate facts by hand, and nothing checks them:

- `docs/index.md` gives every skill a table row, and smith and less a second one
  under dreamcatcher. It's the nearest thing dream has to stories. `AGENTS.md`
  asks agents to update it. #989 asks for a check on the README, after a line in
  `AGENTS.md` was tried and cut.
- `overrides/home.html` holds a sample smith session. It was last edited on 29
  October, and it omits "Simplification opportunities", which smith gained on 20
  August.
- `AGENTS.md` says to write an issue label as "dream:foo", but no such label
  exists.
- `.pre-commit-config.yaml` calls `CLAUDE.md` a symlink. It's a one-line file
  holding `@AGENTS.md`.

## The yardstick: dreamcatcher's and uncoded's standards

Read dreamcatcher's `docs/standard.md`, `docs/releasing.md`,
`docs/compatibility.md` and `docs/testing.md`, then uncoded's
`docs/compatibility.md`, `docs/stories.md` and
`specs/2026-10-25-engineering-standard/roadmap.md`.

- **The standard.** Four enduring documents: concepts, architecture, stories and
  the standard. Every criterion has a measure, a bar and a check. A machine
  check earns its place only after a criterion "has failed in review more than
  once". Every pull request answers a definition of done, including "Documents
  still true" and "Replaced things removed".
- **The release.** Before each major or minor release, `releasing.md` runs the
  consistency review (uncoded's `uncoded-consistency-review` skill). It sweeps
  the open issues for any word that a "Replaces:" line on the concepts page has
  retired, and remeasures every criterion into `measurement.md`. A shortfall is
  an issue and doesn't hold the release back. The changelog headings pick the
  version, and the agent contract is versioned separately.
- **Skills and versions.** uncoded's `compatibility.md` rules that removing,
  reversing or narrowing a skill's instruction, or reordering a workflow's
  steps, is major. New guidance is minor, and rewording is a patch.
- **Testing.** `testing.md` gives each technique its own heading, saying what it
  establishes and what it doesn't. dreamcatcher tests against agents without
  running one: it replays recorded Claude and Codex streams against golden
  feeds, and puts stand-ins for `gh`, `claude` and `codex` on `PATH`. dream has
  no such page, only "There is no test suite".
- **The route.** uncoded's roadmap has 17 stages, two of which, Ontology and
  Stories, were worked out interactively with the user.

Parts of this assume Python: line counts, import contracts, coverage, the test
suite, and the consistency review, which reads uncoded's namespace map and
stubs. Its finding shape, two quoted claims about one concept that ought to
agree, fits skills as well. The enduring documents, the definition of done, the
"Replaces:" sweep, the changelog and compatibility rules, and the ledger of
special cases don't depend on the language. The ledger already has candidates in
dream: the separate Claude Code and Codex blocks in the review skills.

## The sharp edges

- **Agents follow the purpose, not the letter.** Smith's "Open the session PR"
  says to skip the rest of the step when a pull request is already open, which
  is always the case under dreamcatcher. On #1035 smith adopted dreamcatcher's
  pull request and still posted "Session input" and a label. Predicting what a
  skill change does needs a model of that reader, and dream has none written
  down.
- **One mechanical fact, stated two ways.** Trace and weave pass a subagent an
  absolute path because it "can't resolve a path relative to its own prompt
  file". `dream:coherence-review` says its lenses "can't read" the guide, and
  pastes the text in, even though the lens agent reads files from an absolute
  path under Codex.
- **The contract is lopsided.** It states obligations that dreamcatcher's prompt
  already supplies, and leaves out the names, paths and links that dreamcatcher
  relies on.
- **Checks don't gate.** CI runs, but main requires no status check, and admins
  are exempt.
- **The version means "a PR merged".** Every merge ships to every user at their
  next update. Concurrent bumps collide.
- **Deliberate departures and drift look alike.** The user-voice skills are
  exempt from convention, so an agent can't tell a chosen difference from a
  stale one.
- **No stories, so no bug.** Sift's test for a bug has nothing to read here, and
  Collect files without asking whether the behaviour was intended.
- **Renames orphan issues.** Nothing links an issue to the skill it's about, and
  names have been reused.
