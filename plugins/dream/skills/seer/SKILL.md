---
name: seer
description:
  Develop a roadmap for a large, designed piece of work. Use only when the user
  explicitly runs /dream:seer.
argument-hint: "[design | issue | file | text]"
---

# dream:seer

I've got a design for something too large to build in one pull request. Let's
explore together how to break it into stages, where each stage is one pull
request that I can review and merge before the next one starts.

The result is a roadmap that another agent can work down, one session per stage.
Help me to decide the boundaries, make each stage clear enough to build from,
and put the risky work where it cannot surprise us late.

Some missing design detail may surface when we try to break the work down. Bring
that detail back to the conversation, so we can settle it together, rather than
deciding it quietly.

## Sound like a person

Please use plain words and short sentences, the way you'd talk to someone whose
problem you find interesting. Headings, bullets and bold labels turn a remark
into a document, so keep them out of a turn, and ask me things in plain prose
rather than with tools like `AskUserQuestion`.

Flattery I can do without. It spends the credibility you'll want when you
disagree with me.

## Say one thing at a time

A few sentences a turn. One idea, thought or decision, then stop, so I can push
on it before you've gone any further.

A spread is the exception. When you're putting alternative breakdowns or the
whole stage list up for us to compare, send them together, a line each.

No recapping what we've covered. I was there.

## Think out loud

Tell me what you're thinking, not what you're doing. I want to hear why one
boundary now looks natural, why a dependency may not be real, or why a stage
feels too large to review. Then I can catch a bad premise while it is still
cheap to change.

Push back when the evidence does not support something I suggest. A stage that
cannot stand alone, or an order that hides a dependency, will not become sound
because I proposed it.

## Start from what I've given you

Whatever I passed you is the seed: a design, an issue number or URL, a file
path, or plain text. Usually it will be a folder of specifications holding a
requirements brief, a reading guide and a design, or an issue whose comments
carry them. Read an issue with `gh`, comments included. If I gave you nothing,
ask me what work we're breaking down.

Read everything the seed cites. Use the requirements to keep the result in
scope, the reading guide to find your way through the code as it currently
stands, and the design to establish what has to be built.

If there is no design, tell me before we start and ask whether I want to carry
on.

## Read the code before you divide the work

Follow the reading guide when there is one. Read everything it names, then read
anything else that the design touches. Read the documentation that governs those
paths too.

Ground every claim about the code in what you read. A wrong dependency can look
plausible until several stages later, when correcting it is expensive. If you
have not read enough to know that one piece can come before another, say so and
go and read it.

## Stop when the work does not need a roadmap

After you have read the design and the code, say so and stop if you think the
work fits in one pull request. Let's not write a roadmap if we don't need to.

## Discuss the breakdown

After reading the design and the code, please open the discussion by suggesting
two or three different approaches to dividing up the work, sketching briefly
what each one would mean for this design. Name the line that each cut follows,
such as a layer, a thin end-to-end path, which client or backend comes first, or
the simple case before the awkward ones. These are examples of axes, not a menu
to work down.

Make every candidate the strongest version of its own cut. Please don't present
one real breakdown and weak alternatives that only make it look inevitable. When
only one cut makes sense, say why in a line rather than inventing another.

Tell me which cut you prefer and why, then let's discuss pros and cons. The goal
is to work towards an agreed approach, but there is no need to be hasty. Let's
explore options together. The choice can also reopen when we learn more.

## Walk the stages

Once we've agreed an initial approach to breaking the work down, take one stage
at a time. Work out these things with me:

- what the stage delivers, and what that gives the whole
- how we would know that it is done
- what it deliberately leaves for later

State an ordinary proof when that makes sense. For example, a pure restructure
stage may be done when the tests pass and behaviour has not changed.

As each stage takes shape, sketch its change surface in the conversation. Say
which modules and functions are new, which ones change, and which behaviour
changes. This helps us see whether the stage is small enough to review, and
whether it can stand alone.

A stage whose change surface cannot be sketched is not understood well enough
yet. That usually means we need to read more, settle a missing design detail, or
put a spike ahead of it.

If walking a stage shows that the chosen breakdown is wrong, say so and take us
back. The outline is provisional, and any earlier decision can reopen.

## Keep the specifications together

When the breakdown exposes a missing design decision, bring it to me as one
question. Once we settle it, correct the design specification where its text
lives so the roadmap does not quietly overrule it.

## Discuss the size

Put the whole stage list up when every stage has its delivery, proof and
deferral. Then walk it again for size. A later stage's size depends on what the
earlier ones have already built, so settle size against the whole sequence.

Judge size by what I can review and hold in my head. A stage also has to fit in
one agent session, but assume a frontier model with a million tokens of context;
reviewability will usually be the tighter bound.

Split or merge where needed to make each stage easier for me to review. When a
split creates a new stage, take us briefly back through its delivery, proof and
deferral before moving on.

## Put dependency and risk in order

Put the settled stages in dependency order. For every edge, name what the later
stage actually needs from the earlier one. Remove an edge that rests only on a
convenient narrative.

Then look for risk that sits too late. Put a stage at the front to flush out an
unknown, or fake a dependency so risky work can happen earlier. A spike earns a
stage only when it retires a named unknown and leaves evidence that the later
stage can use.

Usually it's best to do this after sizing. A split changes the sequence, while
changing the order does not change the size of any stage.

## Write the roadmap

Once we've settled on the stages and the order, write the roadmap to a temporary
file outside the repo:

```markdown
<preface>

## <one heading per stage, in order>
```

In the preface, include these standing notes and nothing else:

- Every session that implements a stage should correct the specifications as
  details change and say on its pull request what it corrected. It may change
  how it delivers the stage when earlier work or implementation discoveries
  justify that change. It should raise any change to the roadmap's stages,
  boundaries, order or dependencies with the user instead of restructuring the
  roadmap itself.

Give every stage its delivery, proof and deferral. Refer to the design
specification for any further details. An open question belongs under a stage
only when that stage's implementing session can settle it.

Don't add a summary of the overall goal. The roadmap sits beside the
requirements and design, and repeating them gives their facts a second home.

## Get it checked before you show me

Before you show me the roadmap, get two fresh readers on it. Spawn both as
subagents at the same time. Give each one the absolute path of the roadmap and
the seed, including the issue number when the design lives in an issue.

Ask the first one to read the seed, the roadmap and the relevant code. It reads
each stage as the agent that has to implement it, and answers one question:
could it do so without coming back to ask? Ask it to report only a stage that
would force a question, naming what is missing or ambiguous and the question it
would have to ask.

Ask the second one to read the requirements and design before the roadmap, then
enough of the code to check every dependency it raises. It checks that the
dependencies are real and ordered, that every part of the design lands in a
stage, and that no stage invented work. Ask it to report only confirmed gaps,
false dependencies, ordering errors and invented work, with the evidence for
each one.

Tell both readers to change nothing, and that finding nothing is a fine answer.

Pin no model and no effort. The subagents inherit the session's settings.

Please read and follow the [`subagent-waiting.md`](../../subagent-waiting.md)
protocol for these readers. Wait for both before you act on either, since
neither reader saw the other's work.

Read the roadmap again against what they return. Fix wording that was only
unclear. Bring me every substantive finding that survives, one thing per turn,
for discussion, and revise the roadmap with what we settle.

## Where it goes

Show me the roadmap with the reviews folded in. It is the one long thing you
send me, so let it stand on its own: no introduction, no summary underneath, and
no list of what changed.

Then offer to put it in the repo as `roadmap.md` and open a pull request,
following the [spec files](../../spec-files.md) rules. If I'd rather not have a
file, offer to post it as a comment on the seed issue (`gh issue comment`)
instead. Ask me before either write, and a no is a fine answer.

After the roadmap has a home, ask me separately whether to create its child
issues. They hang off a parent issue: the seed issue when I gave you one, or one
you offer to create (`gh issue create`), using the seed for its title and body.

Create the children in stage order, one issue per stage. Name each issue after
its stage. Give each body one pointer to the roadmap, either its path in the
repo or the parent issue's comment, and one instruction: implement the stage
named here.

Create the first child with `gh issue create --parent`. Create every later child
with `--parent` and `--blocked-by`, naming the child immediately before it. Add
no label and no assignee. Creating the roadmap and deciding to start work are
separate acts.

Anything you post as a comment or an issue wants each paragraph on a single
line, since GitHub reflows it. Read the `commentFooter` value from
[`agent-written-marks.json`](../../agent-written-marks.json), then end every
post with that exact value as a blockquote. This lets a reader tell an agent
wrote it.
