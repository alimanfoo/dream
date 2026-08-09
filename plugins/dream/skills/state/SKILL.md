---
name: state
description:
  Explore the code behind a task with the user, and leave a verified reading
  guide to it. Use only when the user explicitly runs /dream:state.
argument-hint: "[requirements | issue | file | text]"
---

# dream:state

I'm about to design or build something, and I don't know this code well enough
yet. So before anyone designs anything, I'd like the two of us to read and learn
about the code together.

I'd like two things out of it. A picture of how this code actually works, good
enough that I can judge a design choice later. And something written down for
whoever picks this up next, whether that's me in a fortnight, a colleague, or
the agent that designs from it.

That written thing is a reading guide rather than a substitute for reading. It
says what to read and in what order, and gives enough of a frame up front that
the code makes sense when you get there.

## Never make anything up

This is the one I care about most. I've noticed that agents sometimes read code
lazily and then tell me things that are plausible, close, and wrong, and that's
very hard for me to catch.

So please tell me only what you've actually read. Not what a name suggests, not
what code like this usually does, not what a comment claims. If you haven't read
it yet, say so and go and read it. "I don't know yet, let me look" is a fine
thing to say to me, and I'd much rather have that than a good guess.

The documentation counts here too. Read it, because it tells you what the code
is meant to do and which conventions it's meant to keep, and that's worth
knowing. But please don't pass any of it on to me as fact before you've seen it
in the code. Docs go stale, and one repeated back to me is no better than a
guess and harder to spot, because it sounds official.

Carry a citation with everything you tell me: the file and line, or the symbol.
Then I can go and look, and it means you had to open the file to say it.

If at any point you notice you've told me something about the code without
having read it first, or guessed or invented anything, stop right there and tell
me. Then go and read the code and correct yourself. Everything gets checked at
the end anyway, but a correction while we're still talking about it is worth far
more to me than one an hour later.

## Start from what I've given you

Whatever I passed you is the scope: a requirements brief, an issue number or
URL, a file path, or plain text. Usually it'll be a brief from `/dream:spark`,
sitting as a comment on an issue. Read an issue with `gh`, comments included.

That's what draws the line around which code is relevant. If I gave you nothing,
ask me what we're about to work on, and use my answer.

## Read it all first, and let me watch

Please explore and read the relevant code before you tell me anything about it.
Read it all, then you'll know what matters. I'd rather wait a few minutes than
get a confident answer based on the first file you opened.

Read the documentation that governs those paths too — the nearest `AGENTS.md` or
`CLAUDE.md`, and any technical docs for that part of the system.

Say what you're opening and why as you go. A line each time, not a report. It's
interesting to watch, and it lets me ask why you're in there.

## Lay the guide out before you say anything about the code

Write the guide to a temporary file outside the repo. Lay out its headings
first, while they're still empty, in these four layers:

```markdown
## Where we are

## The parts

## How it works

## The sharp edges
```

**Where we are** is one paragraph: what this code is for, and where it sits.

**The parts** are the components the work touches, what each is for, and where
each one lives. Then the boundaries and conventions between them, and for each
convention, how it holds: a type, a check, documentation, or nothing but habit.

**How it works** is how the machine actually behaves: the control flow and the
data flow through those parts, and the algorithms doing the real work. It's the
layer that does most of the work for me, so give it room. Where a use case
exercises a good deal of it, walking that one through at a high level — what
calls what, what happens to the data, where the decisions get made — is usually
the most concrete way in, and the easiest for me to follow.

**The sharp edges** are what resisted understanding, and what looks like earlier
over-building or patching round a problem. Name it and say where it lives.
Whether it can be cut or untangled is for whoever designs next, not for us now.

Under each heading, say where to go and read: the file, and the function or
symbol worth starting from. Someone should be able to work out from the guide
what to open next, and go in already knowing roughly what they'll find.

Every heading under those four is a waypoint. Keep them small enough that one
waypoint is one thing worth understanding. An empty waypoint is somewhere we
haven't been yet, so the file itself shows what's left.

## Let me steer, and cover it all anyway

Start with the bird's eye view: where we are, what the parts are, and how they
fit and flow together. Not the detail of any of it, just enough of the whole
shape that I've got somewhere to hang everything that comes after. Going
straight to a waypoint drops me into one corner of a place I haven't seen yet.

Then tell me what the waypoints are and let me pick where to zoom in. That's the
one place I'm happy to be handed a list of options, because you've seen this
ground and I haven't.

Fill each waypoint in as we cover it. When I stop steering, work down whatever's
still empty and bring it to me.

Please don't finish while a waypoint is still empty. If I keep steering one way,
I'd still like to hear about the parts I never picked — I don't know what's down
there, so I can't know to ask. That's a rule for you rather than for me, though.
I can stop whenever I like, and "just write it up" is an answer: fill the rest
in yourself from what you've read, and carry on to the checking and the guide.

If a waypoint turns out not to be relevant after all, write down why. That fills
it like any other.

## Say one thing at a time

A few sentences a turn is about right: one thing, and the question it raises.
I'm in a conversation with you, not reading a document. Too much detail at once,
or a wall of facts, and I'll probably give up and go and read the code myself.

If you could tell me only one thing about what you've just read, what would it
be? Tell me that, and leave it there. The rest keeps until its own turn.

No need to recap what we've covered. I was there.

## Sound like a person

Talk to me the way you'd talk to someone whose problem you find interesting.
Plain words and short sentences. Please use my words where they make sense, and
different ones where they'd be clearer or fit the domain better.

Headings, bullets and bold labels turn a remark into a document, so I'd rather
they stayed out of a turn. If something needs a list, it was probably too much
to send me at once anyway.

Ask me things in plain prose in your turn output, rather than with
`AskUserQuestion`. And tell me what you're thinking, so a question comes out of
a thought I can see and correct: "this is the third place reading the same flag,
which makes me wonder whether anything owns it — where does it get set?" A
question with no thought behind it starts to feel like a form field.

Please push back on me, too. If something I say doesn't square with what the
code shows, say so and show me. That's most of the value in doing this together.

## Write down everything you tell me

Every claim you make to me goes into the guide, under a waypoint, with its
citation. The guide is the record of what was said, not a summary written at the
end.

If something isn't worth writing down, it probably isn't worth asserting to me
either.

## Get it checked before you show me the final guide

You read this code, so you believe your own read of it, including the parts you
filled in. Someone who wasn't here has to check it.

Spawn one `general-purpose` subagent with the Agent tool, on Sonnet. Give it the
absolute path of the guide — a subagent can't resolve a path relative to its own
prompt file.

Ask it to work through the waypoints one at a time, keeping a todo list so it
covers every one of them. At each waypoint, take every claim, open what its
citation points to, and read enough around it to settle the claim: the whole
function where the claim is about what it does, the callers where it's about who
uses it, every step where it's about a sequence. Then write down the claim, what
it read, and whether the code bears the claim out. Tell it to settle each one on
the code rather than on a name, a comment, a docstring or a doc, and to say a
claim isn't borne out when it couldn't settle it. Then to return only the claims
the code doesn't bear out, and to say plainly when that's none of them rather
than reaching for something to report.

Once it's running, go idle: end your turn and let its report land. It arrives on
its own when the subagent finishes. Don't sleep, don't poll for progress, and
don't write that you're waiting.

Then read what it sends back, and please don't check any of it again yourself.
It read the code and reached a verdict, and doing it twice just gives a
confident wrong answer a second chance.

Then tell me, plainly, everything that came back unsupported — including
something you told me an hour ago, because I'll have been building on it since.
Say what you told me, what the code actually shows, and what that changes. Then
fix the guide.

## Then tidy the guide up

Cut it down to what's worth keeping, by editing the file you've just had checked
rather than writing a fresh one from it. Cutting, compressing and reordering
can't introduce a claim nobody checked. Rewriting can.

Keep the shape: the high level before the detail, and every detail hanging off
the structure it belongs to, so a reader always knows where they are. Keep the
pointers into the code, too. A line I can act on — open this file, start at this
function — is worth more to me than a paragraph describing it.

Short, please. Compressed enough that coming back to this in a fortnight is
easy, and short enough that I read it rather than skim it.

## Where it goes

Show me the guide. It's the one long thing you send me, so let it stand on its
own: no introduction and no summary underneath.

Then, if I want it somewhere the work can start from, offer to post it as a
comment on the issue I gave you (`gh issue comment`). Ask me first, and a no is
a fine answer.

Anything you post wants each paragraph on a single line, since GitHub reflows
it. End it with the Claude Code footer, so a reader can tell an agent wrote it:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)
