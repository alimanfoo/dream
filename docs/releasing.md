# Releasing

This page is the checklist for a release of dream. A release gives users the
changes merged since the last release, under a version number that says what
kind of change they are.

A coding agent runs each release in a harness session with the user, when the
user asks for one. dreamcatcher does not run releases. The agent works through
the steps in order, and does each step itself, including those that follow a
merge.

The first release has no earlier release to compare with. It skips each
comparison with the last release, and its changelog section says that it is the
first release under this process.

Start from a new branch for the release pull request. Every change that the
steps make to the repository goes on it.

## 1. Choose the version

Read the description of each pull request merged since the last release's tag.
Choose the version by the rules on
[the compatibility page](compatibility.md#versions), taking the highest part
that any of the pull requests calls for.

Then compare the skill list with the last release's, since a skill that has gone
was renamed or removed, and makes the release major:

```bash
git diff --name-status v<last version> HEAD -- 'plugins/dream/skills/*/SKILL.md'
```

## 2. Run the consistency review

Read the plugin and the documentation for one kind of finding: two claims about
one concept that ought to agree and don't. Quote both claims in each finding.
Then read `dream:smith`, `dream:less`, `dream:big` and `dream:scout` against the
version of dreamcatcher's agent contract that
[the compatibility page](compatibility.md#dreamcatchers-contract) names, and
report each place where a skill does not meet it. Fix each finding that is quick
to fix.

## 3. Measure the standard

Measure every criterion in [the standard](standard.md), as its
[Measurement](standard.md#measurement) section describes, and replace
`docs/measurement.md` with the results.

## 4. Run the issue sweep

Bring the open issues up to date. Search them for each word that a "Replaces:"
line on [the concepts page](concepts.md) retires, such as "host". Rewrite each
issue that uses one for the concept it names. Close each issue whose work is
done or no longer applies, and say why in a comment.

These changes are to GitHub, not to the branch.

## 5. File the findings

File an issue for each finding from the consistency review and each shortfall
from the measurement that no open issue already owns. None of them holds the
release back. A failing check does.

## 6. Write the changelog and set the version

Add a section at the top of [the changelog](changelog.md), headed with the
version and the date. Write it from the pull request descriptions that you read
in step 1: say what changed for a user, and name each name in the interface that
the release renames or removes. Set the version in
`plugins/dream/.codex-plugin/plugin.json`.

## 7. Merge, tag and publish

Open the release pull request and merge it. Tag its merge commit `v<version>`,
push the tag, and publish a GitHub release from it, with the changelog section
as its notes.

## 8. Move the pointer

Open a pull request that changes one thing: the commit that the plugin entry in
`.claude-plugin/marketplace.json` names, to the tagged commit. Merge it. Both
agent harnesses install the commit that this entry names, so users get the
release only once this pull request merges.
