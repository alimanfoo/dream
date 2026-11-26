# Changelog

This page records each release of dream, newest first: what the release changed
for a user, and each name in dream's interface that it renamed or removed. A
release's version follows the rules in [Versions](compatibility.md#versions) on
the compatibility page.

## 47.3.0 (2026-11-26)

`dream:spark` talks your idea through the way a curious colleague would, and
builds the requirements specification around stories. Instead of working down a
checklist, it lets the conversation set the order, and makes sure that by the
end it has covered why you want the change, the stories of how you see it
working, from the happy paths to what should happen when someone makes a mistake
or something fails, and the constraints a solution must work within. It leaves
constraints until the idea has taken shape, unless you raise them. The
specification it writes has four headings: "What do I want and why?", "How do I
see it working?", "What limits this?" and "What's still open?". Each story gives
its goal, its steps and its outcome. Spark also reads any documented
requirements your repository keeps, and says which ones the idea extends or
changes. ([#1116](https://github.com/alimanfoo/dream/pull/1116))

`dream:trace` keeps its tour to the code relevant to your change: its opening
story covers that code, and every stop is a component or mechanism the change
will touch or depend on. ([#1115](https://github.com/alimanfoo/dream/pull/1115))

`dream:big` keeps its turn output brief, since you follow the parent issue and
the stages' pull requests rather than the session.
([#1114](https://github.com/alimanfoo/dream/pull/1114))

This release renames and removes no name in
[the interface](compatibility.md#the-interface).

## 47.2.0 (2026-11-25)

`dream:smith` and `dream:less` start by running one shared boot sequence, with
its steps lettered A to I, and then adopt their engineering principles: smith
loads the coherent coding guide, and less follows its short summary. Smith now
loads the guide after opening the session PR, not before it orients to the
repository. Neither skill now rereads its session rules after the conversation
is summarised. The steps after the boot are renumbered, and "Handle what the
user posts" is now "Handle user posts".
([#1111](https://github.com/alimanfoo/dream/pull/1111))

This release renames and removes no name in
[the interface](compatibility.md#the-interface).

## 47.1.0 (2026-11-25)

`dream:weave` now works out the solution in design models chosen to suit it,
such as a component model with its interfaces, a data model, a lifecycle or an
algorithm. Once the what-ifs stop changing the design, you and the agent choose
the models, sketch each one, and walk the use case that motivates the work
through them, developing the models at each step. You then test them with the
other use cases, their errors and faults, and a failure of each assumption the
design rests on. The design specification it writes presents the chosen models
and the walk of the motivating use case, so its headings change.
([#1105](https://github.com/alimanfoo/dream/pull/1105))

`dream:less` now does what `dream:smith` does in the steps they share: it
orients to the whole repository, looks for all of its tests and checks, not only
the test command, checks the issue against the code as it is now, and posts the
session input as the first comment on its pull request. The two skills share the
text of these steps, and number their steps with the same names.
([#1107](https://github.com/alimanfoo/dream/pull/1107))

The skills use the terms that dream's concepts page defines, such as
"requirements specification" for a requirements brief, "roadmap" for a campaign
plan and "change type" for a session type. Two step names change with them:
"Name the change type" in `dream:smith` and `dream:less`, and "Read the roadmap"
in `dream:big`. ([#1106](https://github.com/alimanfoo/dream/pull/1106))

This release renames and removes no name in
[the interface](compatibility.md#the-interface).

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
