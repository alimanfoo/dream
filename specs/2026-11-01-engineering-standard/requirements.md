# Engineering standard

This brief develops [GH1044](https://github.com/alimanfoo/dream/issues/1044) and
its comments.

## What do I want to be able to do?

I want dream to meet the same kind of engineering standard that uncoded and
dreamcatcher now hold themselves to, adapted to a repo of skills rather than
Python. Ultimately it's about quality. Right now I mean the quality of the
codebase and of the machinery that keeps it that way, so that people and agents
can change dream and add to it without breaking things. Whether the product
works as intended in real use matters too, but that's a different problem, and
I'll take it separately.

When a change brings in a new concept, behaviour or feature, I want its knock-on
consequences to come to the surface, so the skills don't drift into
contradicting each other and nothing that dreamcatcher relies on breaks.

## What's wrong or missing today?

Most of what has broken in dream is drift. A rule gets tightened in one copy and
not the other. The same text lives in several skills. A file that was split out
for two readers ends up with one. The README or AGENTS.md goes stale. A format
changes in one place and breaks whatever reads it somewhere else.

The rest is changes to intended behaviour, and nothing separate from the skills
says what that intent is. The skills themselves are the only record, so an edit
changes the intent as well, and nobody can tell whether that was on purpose.

Agents don't have a good mental model of how LLMs work and how skills work. With
Python they can predict what a change will do. With prompts they can't, and I
often have to explain what kind of prompting will work and why. For example, in
dreamcatcher #884 an agent wrote `dreamcatcher about` as a set of orders to the
reading agent. I had to rework it in #885 into an explanation of how
dreamcatcher works, which leaves the reader to decide what to do.

The issues that agents raise often describe real behaviour under some condition,
but the agent doesn't know whether it's a bug or what I meant. In the Python
projects, writing the stories down, including the intended error handling,
helped with that. Here, agents raising issues about the skills also lack a model
of the reader. So the tracker fills up with things I have to wade through, and
the backlog is full of stale issues about skills we've dropped, such as
dream:team.

There's no release, so there's nowhere to stop and check. Every merge ships, the
version is at 46, and the version number doesn't tell anyone much.

## What has to be true of anything I'd accept?

dream has its intent written down, concisely, and in a form that doesn't just
repeat the skills. There's a concepts page, and there are stories that describe
the practices: how we expect the skills to be used, for what, how a user invokes
them and works with them, what we expect the agents to do, and the workflows
they fit into. The skills should fit together into a coherent set of practices,
especially with dreamcatcher in the mix. dream's stories cover the practices,
and dreamcatcher's cover the mechanics of running them unattended.

Agents working on dream have a guide to the agent as a reader of prompts: how
another model will act on what they write, so they can predict the consequences
of a change to a skill. It explains the mechanics of an LLM coding agent, the
flow of a session: user input, thinking tokens, tool calls, turn output, more
tool calls, and so on. It's almost the agent's analogue of the Python
interpreter. It also explains what a skill really is. Skills look like function
calls, with parameters and output, so a coding agent trying to understand one
thinks in those terms. But a skill doesn't return anything. It just injects
context and instructions into the current agent's session. Subagents are the
ones more like function calls: you launch one with an input prompt and wait
until it returns its final result to the parent session, with possible
side-effect actions in between.

The guide ships in the plugin, perhaps as something like `dream:agentic-coding`,
so it serves both dream's own development and any agent doing context or prompt
engineering for a system that has agents in its architecture. It explains the
mechanics of coding agents and offers no opinions or instructions. It's context
an agent can reason from, the same way I wanted `dreamcatcher about` to explain
the machinery rather than give instructions. I'd hope it describes what's common
to coding agents, since details specific to one harness could go stale.

What `AGENTS.md` and `plain-english.md` say about writing prompts may be out of
date. It dates from when I understood agents less well and was engineering
prompts for good instruction following, because Claude was horrendous at writing
instruction prompts: they were impossible to review, and the actual instructions
were buried. Sometimes a prompt does still need clear instructions, and then a
consistent style helps, so it's obvious when something is meant as an
instruction rather than some other kind of context.

Changes to skills get reviewed as prompts, building on that guide. That's an
aspiration, because the review is only as good as its model of the reader.

There's more back pressure on drift. A machine checks what it can, and review by
an LLM is fine where a machine can't.

A change to dream:smith, dream:less, dream:big or dream:scout is checked against
the contract that dreamcatcher already writes down for assignments, campaigns
and conversations. The contract is what dreamcatcher relies on but doesn't
prompt for itself. What dreamcatcher's own prompts supply isn't part of it. So
where dreamcatcher's contract today requires a skill to say something its prompt
already supplies, such as reading `pull_request_state` first or answering
`NO_REPLY`, the contract is out of date. And it leaves out things dreamcatcher
does rely on, such as the skill names, invoking them with `GH{issue}`, and the
paths it links to. The hand-offs between dream's own skills count too, but
they're softer. My usual route for long-horizon work is spark, trace, weave and
quest, then merge the specs, set up the parent issue and sub-issues, and
dispatch a campaign. I sometimes skip spark, trace or even weave when a design
came from somewhere else, and dream:big only needs the parent issue and its
sub-issues, however they came about.

Users install dream the standard way, from the repo's main branch, and get
changes only when a release is cut. Installing any other way is less convenient
for them. Work in progress stays off what users install until it's ready to
release.

Versions mean something, and there's a release protocol with QA steps before
each release, as in the other projects: a consistency review, a measurement
against the standard, and a sweep of the issues for anything stale or described
in old terms.

## What limits this?

No model calls in CI. CI runs on every commit, and that's too much. One review
per pull request is fine, since code-review and coherence-review already run on
most of them, and so is one review per release for what a pull request can't
easily catch.

The guide to the reader may be hard to write. Without a strong model of the
reader, a review of prompts will spin out, generate false positives and get
confused, and the implementing agent won't judge well which findings to accept.

## How will I know it worked?

When a change brings in a new concept, behaviour or feature, its knock-on
consequences come to the surface, so the skills don't drift into an inconsistent
state, and nothing dreamcatcher relies on breaks.

The issues that agents raise here, about dream itself, are real bugs or
maintenance issues. What dream's skills file in other codebases is mostly out of
my control, because it depends on the cognitive architecture that's been built
for those codebases. I can triage everything, clean up the tracker and keep it
maintained, without wading through false positive bug reports or maintenance
suggestions.

## What's still open?

- Whether dream needs a versioned contract of its own, and at what grain. Some
  skills follow protocols much more than others.
- How strict the hand-offs between dream's own skills should be.
- dreamcatcher's contract needs correcting to match, which is a change in
  dreamcatcher.
- Analysing the feeds from real use, to see whether the product works as
  intended, is a separate issue. It still needs filing.
