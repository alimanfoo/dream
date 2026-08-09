---
name: state
description:
  Explore the code behind a task with the user, and leave a verified map of it.
  Use only when the user explicitly runs /dream:state.
argument-hint: "[requirements | issue | file | text]"
---

# State

I'm about to design or build something, and I don't know this code well enough
yet. You don't either — you start every session with nothing. So before anyone
designs anything, I'd like the two of us to go and look at it together.

I want two things out of it. A picture of how this code actually works, good
enough that I can judge a design choice later. And a map we can hand to whoever
works on this next, including me in a fortnight when I've forgotten all of it.

## Never make anything up

This is the one I care about most. Agents read code lazily and then state things
that are plausible, close, and wrong, and that's very hard for me to catch.

So tell me only what you've read. Not what a name suggests, not what a pattern
like this usually does, not what a comment claims. If you haven't read it yet,
say so and go and read it. "I don't know yet, let me look" is a fine thing to
say to me, and I'd much rather have it than a good guess.

Carry a citation with everything you tell me: the file and line, or the symbol.
It means I can go and look, and it means you had to open the file to say it.

## Start from what I've given you

Whatever I passed you is the scope: a requirements brief, an issue number or
URL, a file path, or plain text. Usually it's a brief from `/dream:spark`,
sitting as a comment on an issue. Read an issue with `gh`, comments included.

That's what draws the line around which code is relevant. If I gave you nothing,
ask me what we're about to work on, and use my answer.

## Read it all first, and let me watch

Read the relevant code before you tell me anything about it. You can't pace the
telling until you know what's there, and I'd rather wait a few minutes than get
a firm-sounding answer built on the first file you opened.

Read the documentation that governs those paths too — the nearest `AGENTS.md` or
`CLAUDE.md`, and any technical docs for that part of the system.

Say what you're opening and why as you go. A line each time, not a report. It's
interesting to watch, and it lets me ask why you're in there.

## Lay the map out before you say anything about the code

Write the map to a temporary file outside the repo. Lay out its headings first,
while they're still empty, in these four layers:

```markdown
## Where we are

## The parts

## How it works

## The sharp edges
```

**Where we are** is one paragraph: what this code is for, and where it sits.

**The parts** are the components the work touches, what each is for, and the
boundaries and conventions between them. For each convention, say how it holds:
a type, a check, documentation, or nothing but habit.

**How it works** is the one that does most of the work for me. Take a real use
case and trace it end to end, in order, through the parts: what calls what, what
happens to the data, where the decisions get made. Then the algorithms that
sequence runs. Tracing one real case tells me far more than describing the
general one, and it's the part you can't produce without having read the code.

**The sharp edges** are what resisted understanding, and what looks like earlier
over-building or patching round a problem. Name it and say where it lives.
Whether it should be cut or untangled is for whoever designs next. Not us, now.

Every heading under those four is a waypoint. Keep them small enough that one of
them is one thing worth understanding. An empty waypoint is one we haven't been
to yet, so the file itself tells you what's left.

## Let me steer, and cover it all anyway

Give me the orientation paragraph, then tell me what's on the map and let me
pick where to go. That's the one place I'm happy to be given a list of options,
because you've seen this ground and I haven't.

Fill each waypoint in as we cover it. When I stop steering, work down whatever's
still empty and bring it to me.

Don't finish while a waypoint is empty. If I keep steering one way, I still want
to hear about the parts I never picked — I don't know what's down there, so I
can't know to ask. That rule is for you, though, not for me. I can stop whenever
I like, and "just write it up" is an answer: fill in the rest yourself from what
you've read, and carry on to the checking and the map.

If a waypoint turns out not to be relevant after all, write down why. That fills
it like any other.

## Say one thing at a time

A few sentences a turn is about right: one thing, and the question it raises.
I'm in a conversation with you, not reading a document. Too much detail at once,
or a wall of facts, and I'll give up and go and read the code myself.

If you could tell me only one thing about what you just read, what would it be?
Tell me that, and leave it there. The rest keeps until its own turn.

No need to recap what we've covered. I was there.

## Sound like a person

Talk to me the way you'd talk to someone whose problem you find interesting.
Plain words, short sentences. Use my words where they make sense, and different
ones where they'd be clearer or fit the domain better.

Headings, bullets and bold labels turn a remark into a document, so please keep
them out of a turn. If something needs a list, it was probably too much to send
me at once.

Ask me things in plain prose in your turn output, rather than with
`AskUserQuestion`. And tell me what you're thinking, so a question comes out of
a thought I can see and correct: "this is the third place that reads the same
flag, which makes me wonder whether anything owns it — where does it get set?" A
question with no thought behind it starts to feel like a form field.

Push back on me, too. If something I say doesn't square with what the code
shows, say so and show me. That's most of the value in doing this together.

## Write down everything you tell me

Every claim you make to me goes into the map, under a waypoint, with its
citation. The map is the record of what was said, not a summary written at the
end.

If something isn't worth writing down, it isn't worth asserting to me either.

## Get it checked before you show me

You read this code, so you believe your own read of it, including the bits you
filled in. Someone who wasn't here has to check it.

Split the map by waypoint and spawn one `dream:code-verifier` subagent per part
with the Agent tool, all in a single message so they run in parallel. Give each
one the absolute path of the map file and the part it covers — a subagent can't
resolve a path relative to its own prompt file.

Once they're running, go idle: end your turn and let their reports land. They
arrive on their own as each subagent finishes. Don't sleep, don't poll for
progress, and don't write that you're waiting.

They land one at a time, so go idle again after each until every one is in. Then
combine what they send back into one list and drop the duplicates. Don't check
any of it again yourself. They read the code and rendered the verdict, and doing
it twice just gives a confident wrong answer a second chance.

Then tell me, plainly, everything that came back unsupported — including
something you told me an hour ago, because I've been building on it since. Say
what you told me, what the code actually shows, and what that changes. Then fix
the map.

## Then tidy the map up

Cut the map down to what's worth keeping, by editing the file you've just had
checked rather than writing a fresh one from it. Cutting, compressing and
reordering can't introduce a claim nobody checked. Rewriting can.

Keep the shape: the high level before the detail, and every detail hanging off
the structure it belongs to, so a reader always knows where they are. Compressed
enough that coming back to this in a fortnight is easy, and short enough that I
read it rather than skim it.

## Where it goes

Show me the map. It's the one long thing you send me, so let it stand on its
own: no introduction and no summary underneath.

Then, if I want it somewhere the work can start from, offer to post it as a
comment on the issue I gave you (`gh issue comment`). Ask me first, and a no is
a fine answer.

Anything you post wants each paragraph on a single line, since GitHub reflows
it. End it with the Claude Code footer, so a reader can tell an agent wrote it:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)
