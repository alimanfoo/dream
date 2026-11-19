# Releasing

A release of dream is a commit on main, tagged `v<version>`, whose
`plugins/dream/.codex-plugin/plugin.json` sets the plugin's `version` and whose
[changelog](changelog.md) has a section for that version. A GitHub release is
published from the tag. The plugin entry in main's
`.claude-plugin/marketplace.json` is a `git-subdir` source whose `sha` names the
tagged commit of the latest release. Both agent harnesses read the marketplace
from main and install the commit that the entry names, so the changes merged to
main after a release reach no user until the entry names a later release.

A release takes two pull requests, because a commit cannot contain its own hash.
The release pull request sets the version and adds the changelog section, and
its merge commit is the commit that is tagged. A second pull request then sets
the entry's `sha` to that commit.

A coding agent runs each release in a harness session with the user, when the
user asks for one. dreamcatcher does not run releases. The agent performs every
step in order, including the tag, the GitHub release and the second pull
request, which follow the merge of the first.

The last release is the one with the highest `v<version>` tag, and the steps
compare main against that tag. The first release has no earlier tag. It skips
those comparisons, its changelog section says that it is the first release made
by this process, and its second pull request replaces the entry's relative-path
source with the `git-subdir` source that step 8 pins.

The release pull request's branch starts from the current main, and every step
that changes the repository commits to it.

## 1. Choose the version

The changes in a release are the pull requests merged into main since the last
release's tag. List their merge commits, and read each pull request's
description and diff:

```bash
git log --merges --first-parent --oneline v<last>..HEAD
```

The version's increment is the highest that any of them calls for, under the
rules in [Versions](compatibility.md#versions) on the compatibility page. Those
rules classify a change by its effect on the interface that the page defines, so
compare each part of the interface with the last release directly, as well as
through the descriptions. The skill names, which are the `name` fields in the
skills' frontmatter, differ wherever this prints a line:

```bash
diff <(git grep -h '^name:' v<last> -- 'plugins/dream/skills/*/SKILL.md' | sort) \
     <(git grep -h '^name:' HEAD -- 'plugins/dream/skills/*/SKILL.md' | sort)
```

The plugin's name, the marketplace's name and repository, the version of
dreamcatcher's agent contract and the agent harnesses are in these files. The
entry's `sha` in `.claude-plugin/marketplace.json` changes at every release, and
that change is not a change to the interface.

```bash
git diff v<last> HEAD -- plugins/dream/.codex-plugin/plugin.json \
  .claude-plugin/marketplace.json docs/compatibility.md
```

## 2. Run the consistency review

The consistency review reads the plugin and the documentation, as
[the standard](standard.md) defines them, for statements that contradict each
other. A finding is a pair of statements about one concept that cannot both be
true, each quoted with its file and heading. A difference in wording between
statements that agree is not a finding.

The review also reads `dream:smith`, `dream:less`, `dream:big` and `dream:scout`
against the version of dreamcatcher's agent contract that
[the compatibility page](compatibility.md#dreamcatchers-contract) names, each
under the role that the page gives it. A finding is a requirement that the
contract places on a skill of that role and the skill does not meet, quoted from
the contract.

Fix each finding whose fix is small enough to review in the release pull
request. The rest are filed in step 5.

## 3. Measure the standard

Take the measure of every criterion in [the standard](standard.md), and replace
`docs/measurement.md` with the results, as the standard's
[Measurement](standard.md#measurement) section describes. A shortfall is a
measure that does not meet its criterion's bar.

## 4. Run the issue sweep

The issue sweep brings the open issues to the bar of
[Current tracker](standard.md#current-tracker). It changes issues on GitHub, not
the release branch.

Search the open issues for each term that a "Replaces:" line on
[the concepts page](concepts.md) retires, such as "host". A retired term is a
finding only where it names the concept whose entry retires it. Edit each issue
that uses one so that it uses the concept's term. Close each issue that asks for
work already done on main, concerns a skill the plugin no longer has, or asks
for behaviour that a story excludes, with a comment that gives the reason.

## 5. File the findings

File an issue for each finding from step 2 that the release pull request does
not fix, and for each shortfall from step 3, unless an open issue already
reports it. Findings and shortfalls do not hold a release back. A failing check
does: the release pull request merges only when every pre-commit hook and every
required CI check passes on it.

## 6. Write the changelog and set the version

Add a section to the top of the changelog, headed by the version and the date of
the release. Write it from the pull requests read in step 1. It says what
changed for a user, links each pull request, and lists each name in the
interface that the release renames or removes, with the name that replaces it,
if any.

Set `version` in `plugins/dream/.codex-plugin/plugin.json`, which
`plugins/dream/.claude-plugin/plugin.json` links to. Both agent harnesses detect
an update by a change in this field. Claude Code replaces its cached copy of a
plugin only when the version it computes, which is this field when it is set,
differs from the installed version. Codex reinstalls a plugin only when its
version changes.

## 7. Merge, tag and publish

Open the release pull request and merge it with a merge commit. Tag that merge
commit `v<version>`, push the tag, and publish a GitHub release from the tag,
with the changelog section as its notes.

## 8. Pin the marketplace entry

Open a pull request whose only change sets the `sha` of the plugin entry in
`.claude-plugin/marketplace.json` to the full 40-character hash of the tagged
commit, which `git rev-parse 'v<version>^{commit}'` prints, and merge it. Until
it merges, the entry names the last release, and no user receives the new one.
Once it merges, Codex installs the release at a user's next session, and Claude
Code installs it when the plugin is next updated.
