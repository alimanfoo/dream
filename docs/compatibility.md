# Compatibility

This page says what dream keeps the same from one release to the next, and how a
release's version number tells you what changed. dream follows these rules from
its first release. Until then, every merge to the default branch reaches users
as soon as it lands, and the version changes with every pull request.

## The interface

dream's interface is its names. A name is resolved before any language model
reads anything: an agent harness resolves a skill's name when a user types it,
and dreamcatcher resolves the skill names in its configuration. Everything a
name leads to is read by a coding agent, and a coding agent adapts to what it
reads.

The interface is:

- the plugin's name, `dream`;
- the marketplace that offers the plugin: the repository `alimanfoo/dream`, and
  the marketplace's own name, `dream`, from `.claude-plugin/marketplace.json`.
  With the plugin's name, they make the install ID `dream@dream`, which the
  install commands and dreamcatcher use;
- the name of each skill in the plugin, such as `dream:smith`;
- the version of dreamcatcher's agent contract that dream meets;
- the agent harnesses that dream runs on.

These are not part of the interface, because a coding agent reads them, or
because something else defines them:

- what a skill tells the coding agent to do;
- a skill's arguments. The one exact form, `GH123`, is defined by dreamcatcher's
  contract;
- how the specification skills hand over to each other. Each starts from
  whatever it is given, and any of them can be skipped;
- the triage outcome labels that `dream:sift` uses, and the line in a
  repository's `AGENTS.md` that maps them. Sift adapts to whatever labels a
  repository has;
- the `> written by an agent` footer;
- a parent issue, its sub-issues and the links that say which blocks which.
  dreamcatcher gives that graph its meaning, and `dream:quest`, `dream:big` and
  the user are three of the things that write it;
- the names of the plugin's subagent files and the paths of its files. Only
  dream's own skills use them.

## Versions

A version has three parts, `major.minor.patch`. A release takes the highest part
that any of its changes calls for.

- **Major**: it renames or removes a skill, the plugin or the marketplace, moves
  to a new version of dreamcatcher's contract, or drops an agent harness.
- **Minor**: it adds a skill or an agent harness, or changes what a skill does.
- **Patch**: it makes a skill do what it was meant to, or rewords a skill
  without changing what it does.

## Agent harnesses

dream runs on Claude Code and Codex. Each skill is one file that both read.

## dreamcatcher's contract

dream meets version 1 of
[dreamcatcher's agent contract](https://alimanfoo.github.io/dreamcatcher/contract/).
Under it, `dream:smith` and `dream:less` are assignment skills, `dream:big` is a
campaign skill, and `dream:scout` is a conversation skill. dreamcatcher's
default configuration runs each of them.

The contract's version is dreamcatcher's, and is independent of dream's.
dreamcatcher's
[compatibility page](https://alimanfoo.github.io/dreamcatcher/compatibility/#agent-contract)
says when it changes.
