---
name: spark
description:
  Interview the user to turn a rough idea into a requirements brief covering
  vision, problem, requirements, constraints, and success. Use only when the
  user explicitly runs /dream:spark.
argument-hint: "[issue | file | text]"
---

# Spark

Interview the user to turn a rough idea into a requirements brief. Discover what
they want and why. Leave how to whoever builds it.

Write every turn output and artefact in this skill using `/dream:plain-english`.

Don't load `/dream:coherent-coding`. It is the standard for designing and
writing code, and this skill stops before design.

Follow the steps in order.

## Stay out of the solution

Write only what must be true and why, never how to build it. The brief serves
whoever designs the work next, and a design call made here is one they never get
to make.

This rules out naming a technology, a component, or a shape of data. Those are
examples of the rule, not its bounds.

If you notice you've written any of them, cut it and ask the user what they need
it to do instead.

## Ask in chat

Ask every question as plain prose in your turn output. Don't use
`AskUserQuestion`. It breaks the conversation up, and a fixed set of options
frames the answer before the user has thought about it.

For the same reason, don't offer the user a menu of options in prose either. An
option list is a proposal in disguise.

## Arguments

The argument gives the seed, the material to start from. It can be an issue
number or URL, a file path, or plain text. Read an issue with `gh`, including
its comments. Without an argument, start from what the user says next.

## Read the seed

Sort what the seed already settles against the five facets of the brief: vision,
problem, requirements, constraints, and success. Then open the interview by
saying which facets it covers, and ask only about the gaps. A question the user
already answered in writing wastes their time and reads as if you didn't look.

When the seed already holds a brief in this format, treat its sections as the
starting draft. Ask only about what is thin, missing, or out of date.

## Interview the user

Open by saying what you will produce and what you won't: a requirements brief,
not a design. The user can redirect at once if they wanted something else.

Work the facets in order: vision, problem, requirements, constraints, success.
Each rests on the one before.

Ask one to three questions per turn, then stop and wait. A longer list gets a
partial answer, and the answers to the later questions depend on the earlier
ones.

After each answer, write one line naming what it settled and which facet it
lands in. The user can then correct a misread on the spot.

Press once on the problem when the user answers with a solution rather than a
pain. For example, "I want a dashboard" earns "what would you do with what it
showed you?"

Don't discard a solution the user proposes, and don't promote it to a
requirement. Ask whether they mean it as a boundary the work must respect. If
they do, it is a constraint. If they don't, it is a steer for whoever designs
the work, and it belongs nowhere in this brief.

Move on from a facet once you have enough to write its section, or once the user
says they don't know. Don't press a second time. Keep a note of what they didn't
know, so the brief can record it.

Say when you have covered all five, and ask the user to confirm before you
draft.

## Draft the brief

Write the brief to a temporary file outside the repo. Never write it into the
user's repo.

Use these headings:

```markdown
# Vision

The future state the user wants, in a few sentences.

# Problem

The pain, opportunity, or unmet need behind the work. Why it matters.

# Requirements

What must be true of any acceptable solution: the behaviours, capabilities, or
properties it has to have.

# Constraints

What limits the solution space: technical, organisational, legal, financial, or
operational.

# Success

The observable outcomes that show the problem is solved.

# Open questions

What the interview left unresolved: a facet the user didn't know, a
contradiction they didn't settle, a decision someone has to make before the work
starts.
```

Mark an item `(inferred)` at the end of its line when the user didn't say it and
you filled it in from what they did say. An unmarked item is one the user
stated, in the interview or in a seed they wrote. The mark tells the reader
which lines to check with the user before building on them.

## Check what you inferred

Read the brief back from the file. Take each unmarked item in turn and find the
thing the user actually said that it rests on. When you can't find one, mark it
inferred, or cut it if it adds nothing.

Name in your turn output every item you changed. Say so plainly when you changed
nothing.

## Launch the lenses

Have fresh subagents attack the draft. You ran the interview, so you already
believe every line of what you wrote. A reader who wasn't there sees what you
can't.

Spawn a `general-purpose` subagent per lens, via the Agent tool, all in a single
message so they run in parallel. Paste the whole draft brief into each prompt,
along with the one lens it applies. The subagent has no context from the
interview, so anything you leave out is something it cannot judge. Ask each for
findings with concrete rewrites, and tell it to say plainly when the brief is
already sound rather than manufacture nitpicks.

The lenses:

- **Solution leakage.** Does any line say how rather than what?
- **Vagueness and gaps.** What would a builder need to know that the brief
  doesn't say?
- **Testable success.** Could two people read a success item and disagree on
  whether it was met?
- **Downstream fit.** Could a developer start work from this brief without
  asking anything first? What would send them the wrong way?

Don't add a lens for whether each item traces to something the user said. Only
you hold the conversation, so a subagent asked that would be guessing. You
already checked it yourself.

Once the subagents are running, go idle: end your turn and let their findings
land. They arrive on their own when each subagent finishes. Don't sleep. Don't
poll for progress. Don't write that you are waiting.

## Combine and act on the findings

Findings land one subagent at a time. So go idle again after each, until every
subagent you launched is in.

Then combine their findings into one list. Drop duplicates and resolve
inconsistencies. No subagent read another's findings, so only you can settle two
that pull the same line different ways.

Read the brief and recall the interview for each finding. Keep only the findings
you can confirm.

Then split the confirmed findings two ways:

- **Yours to fix.** Wording, structure, and solution leakage. Revise the file
  yourself.
- **The user's to answer.** Intent, scope, and a missing fact. Ask in chat, then
  revise the file with what they say.

The user is here, so don't guess at what they meant when you can ask.

## The result

Show the brief in your turn output.

Then offer to put it where the work will start from. With a seed issue, offer a
comment on that issue (`gh issue comment`). Otherwise offer a new issue on the
repo (`gh issue create`). Ask first, and accept a no.

Don't replace a seed issue's body. That destroys the user's own words, and a
comment carries the brief to the same place.

Write each paragraph of anything you post on a single line, since GitHub reflows
it (see [Text for GitHub](../../plain-english.md#text-for-github)). End it with
the Claude Code footer, so a reader can tell it is agent-authored:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)
