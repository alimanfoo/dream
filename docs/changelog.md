# Changelog

This page records each release of dream, newest first: what the release changed
for a user, and each name in dream's interface that it renamed or removed. A
release's version follows the rules in [Versions](compatibility.md#versions) on
the compatibility page.

## 47.0.0 (2026-11-24)

`dream:plain-english` is removed, with the Plain English guide that it loaded.
The guide simplified prose at the cost of technical accuracy.
([#1095](https://github.com/alimanfoo/dream/pull/1095))

`dream:big` no longer stops all merging while it waits for your answer to a
question. It holds back only the stages the question bears on, and every stage
when it can't tell which.
([#1099](https://github.com/alimanfoo/dream/pull/1099))

`dream:sift` no longer offers a third option that leads to the same outcome as
one of the other two. ([#1096](https://github.com/alimanfoo/dream/pull/1096))

Comments and pull request descriptions that the skills post on GitHub keep their
line breaks, instead of showing `\n` where a new line belongs.
([#1097](https://github.com/alimanfoo/dream/pull/1097))

Every skill's description, which your agent harness lists for the agent, is in
the third person, and says to use the skill only when it is explicitly invoked.
([#1100](https://github.com/alimanfoo/dream/pull/1100))

This release removes one name from
[the interface](compatibility.md#the-interface): the skill
`dream:plain-english`, which nothing replaces.

## 46.5.0 (2026-11-20)

This is the first release made by dream's release process. Until now, every
change merged to main reached you at once, and each one changed the version.
From this release on, the marketplace installs a tagged release of dream, not
the latest commit on main. Changes reach you only when a release is made, and
the version changes only at a release. Claude Code installs a new release when
you update the plugin, and Codex at your next session.
([#1081](https://github.com/alimanfoo/dream/pull/1081))

If smith's banner still shows 46.4.0 or earlier after you update the plugin
under Claude Code, or start a new session under Codex, remove the plugin and
install it again with the commands on [the home page](index.md#install).

This release renames and removes no name in
[the interface](compatibility.md#the-interface).
