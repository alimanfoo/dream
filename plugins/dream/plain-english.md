# Plain English guide

Follow this guide in everything you write. That means prompts, documentation,
the messages you send other agents, what you post on GitHub, and what you say to
the user.

## Write as if speaking

Write as if you are speaking to someone. Prefer the sentence constructions of
speech, not those of formal writing. A sentence can use plain words and still
read stiffly, because no one would say it that way. This is about construction,
not tone. Keep the words as plain and precise as ever.

For example: "Sentences that don't flow naturally can still be hard to read,
even if the words are plain and simple.", not "Simple words can still sit in a
construction no fluent writer uses."

## Write to inform

Write to inform, not to impress.

## Write to be understood

Your readers include people who do not speak English as a first language. Write
so they cannot misunderstand you.

Leave in the words that show how the other words relate. English lets you drop
them, and a first-language reader puts them back without noticing. Your reader
may not.

- Keep "that". Write "the file that the parser reads", not "the file the parser
  reads".
- Repeat the word rather than leave a gap. Write "the parser reads the header,
  and the renderer reads the body", not "the parser reads the header, the
  renderer the body".
- Put a preposition between stacked nouns. Write "the chain that picks the most
  telling input", not "the most-telling-input fallback chain".
- Keep the subject and the verb at the front. Write "the parser ignores every
  other event type", not "Ignored: every other event type".

Drop a word when putting it in makes the sentence harder to read. That happens
when several "that"s land in one sentence.

## Write for the reader's context

Model the reader: who they are, why they are reading. Cut what the reader does
not need to know. These shapes recur, and do not bound the rule:

- an example pinned to a name from your own code. For example: "grep for the
  function's name", not "grep -rn 'def parse_header'".
- a definition by contrast with something the reader may not know. For example:
  "This runs on every commit.", not "This runs on every commit, unlike the
  nightly job."
- the history behind a thing, when the reader needs only the thing. For example:
  "Set the timeout to 30 seconds.", not "Set the timeout to 30 seconds. We chose
  30 after load testing."

## Strict narrative order

Write instructions in the order the reader must follow them. For example: "Knead
the dough, then put it in the oven.", not "Put the dough in the oven, but make
sure you knead it first." Other content may come between instructions, but they
must still follow strict narrative order.

The same holds beyond instructions. A reader who meets a point before the one it
rests on must look ahead or guess.

- When one point depends on another, put the other first.
- Do not refer forward. Phrases like "as described below" and "see the next
  section" are forward references. Markdown links to later sections are also
  forward references.

## Reason forward

State evidence before you conclude. A conclusion stated first anchors the reader
and the writer. Evidence that follows confirms it rather than tests it. For
example: "The build takes 12 minutes. The cache is cold on every run. Warming
the cache should help.", not "Warming the cache should help. The build takes 12
minutes and the cache is cold."

State a hypothesis before testing it. For example: "The request might be timing
out. The logs show it drops at 30 seconds. The default timeout is 30 seconds.",
not "The request is timing out. The logs confirm it drops at 30 seconds."

## One idea per paragraph

Each paragraph carries one idea. Name it in the first sentence. If a paragraph
holds two ideas, split it.

## Say it once

Say it once. For example, "this holds only when X" already says "if not X, it
does not". Do not add the inverse.

## Use active voice

Use active voice. For example: "The parser reads the file before validation.",
not "The file is read by the parser before validation."

## Writing lists

- Put steps in a vertical list, not a run-on sentence.
- Leave a blank line before and after a list. Without it, markdown formatters
  absorb any text that follows directly into the last bullet.

## One reading per sentence

Be precise. A reader who can take a sentence two ways may pick the wrong one.
Read each sentence in isolation and check whether a second meaning fits.

- Rewrite an ambiguous sentence: one with two plausible readings.
- Rewrite a near-ambiguous sentence too: one a skim reader could misread.
- Mark a warning with "don't do Y". A bare imperative for the warning reads as
  another instruction, contradicting the first. For example:
  - "Hold the lock until the write completes. Don't release it after the first
    row, because the next row would see stale data.", not "Hold the lock until
    the write completes. Release it after the first row, and the next row sees
    stale data."

## Giving instructions

Build an instruction in parts, in this order: the imperative, the why, examples,
exceptions.

- Open with the verb, so the reader sees what to do first. For example:
  - "Pull the latest main before you branch, to avoid a conflict.", not "To
    avoid a conflict, pull the latest main before you branch."
- Give the why. Say what the instruction defends, or why a default is risky.
- Give one to three examples. They show the rule. They do not bound it.
- Put exceptions last. An edge case comes after the main rule, never before. For
  example:
  - "Save on exit. If the file is read-only, skip it.", not "Unless the file is
    read-only, save on exit."

A bare imperative is enough when the act is obvious. Skip the parts you do not
need.

Hold the order even so. A why before the verb, or an exception before the rule,
makes the reader decode before they can act.

Name the actor. Say who or what does the action, not "the trap is" or "there
is".

Lead with what to do. Add what not to do only to support it.

## Use a small vocabulary

Use a small, consistent vocabulary. One word per meaning, one meaning per word,
within each piece of text you write. Do not swap in a synonym for variety.

## Leave the count out of a list

Do not state a count of items you then list. The count and the list drift apart
when either changes. For example: write "the sources", not "the three sources".

## Prefer the common word

Prefer the common word. No jargon or idioms, unless they convey important
meaning that no plain words can. Don't invent a term when plain words already
say it. For example:

- "X owns the schema", not "X is the operational source of truth"
- "might go out of sync", not "has drift potential"
- "now only handles country", not "has narrowed its role to country-only"
- "use", not "leverage"
- "essential", not "load-bearing"
- "the API", not "the surface area"

## Use verbs, not noun forms

Use verbs, not noun forms of verbs. Write "decide", not "make a decision".

## Skip the Latin

Skip the Latin. Write "for example", not "e.g.".

## Skip the flourish

Skip the flourish. No filler opener. No three-part lists for effect. No neat
opposites. No clever closing line. For example:

- "The cache is the bottleneck.", not "Here's my honest take: the cache is the
  bottleneck."

## Text for GitHub

Write each paragraph on a single line when GitHub renders it: pull request and
issue descriptions, and comments. GitHub reflows each paragraph to the reader's
window, so a hard-wrapped paragraph breaks into short, uneven lines. Newlines
inside fenced code blocks and between table rows are structural. Leave those
alone.

Start every line of a blockquote with `>`, blank lines included. GitHub ends a
quote at the first line without one, so the rest would read as your own words.
