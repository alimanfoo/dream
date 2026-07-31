# Plain English guide

This guide sets the standard for written text. It covers prompts, documentation,
the messages between agents, the artefacts they write for GitHub, and what they
write to the user.

## Write to inform

Write to inform, not to impress.

## Write to be understood

Your readers include people who do not speak English as a first language, and
agents that act on every word. Write so neither can misunderstand you.

Aim for a reading age of about 11. Age 9 is better. Make it simpler when in
doubt.

## Write as if speaking

Write as if you are speaking to someone. Prefer the sentence constructions of
speech, not those of formal writing. A sentence can use plain words and still
read stiffly, because no one would say it that way. This is about construction,
not tone. Keep the words as plain and precise as ever.

For example: "Sentences that don't flow naturally can still be hard to read,
even if the words are plain and simple.", not "Simple words can still sit in a
construction no fluent writer uses."

## Write for the reader's context

Model the reader: who they are, why they are reading. Cut what the reader does
not need. These shapes recur, and do not bound the rule:

- an example pinned to a name from your own code. For example: "grep for the
  function's name", not "grep -rn 'def parse_header'".
- a definition by contrast with something the reader may not know. For example:
  "This runs on every commit.", not "This runs on every commit, unlike the
  nightly job."
- the history behind a thing, when the reader needs only the thing. For example:
  "Set the timeout to 30 seconds.", not "Set the timeout to 30 seconds. We chose
  30 after load testing."

## Strict narrative order

Write so the reader can follow top to bottom. Each point should make sense from
what came before it. Otherwise, a reader who meets something referenced before
it is explained must look ahead or guess.

- Introduce a concept or term before you use it.
- Do not refer forward. Phrases like "as described below" and "see the next
  section" are forward references. Markdown links to later sections are also
  forward references.
- When one point depends on another, put the other first.

When the reader must follow instructions in sequence, write them in order. For
example: "Knead the dough, then put it in the oven.", not "Put the dough in the
oven, but make sure you knead it first." Other content may come between
instructions, but they must still follow strict narrative order.

## Reason forward

State evidence before you conclude. A conclusion stated first anchors the reader
and the writer. Evidence that follows confirms it rather than tests it.

- State evidence first, then conclude. For example: "The build takes 12 minutes.
  The cache is cold on every run. Warming the cache should help.", not "Warming
  the cache should help. The build takes 12 minutes and the cache is cold."
- State a hypothesis before testing it. For example: "The request might be
  timing out. The logs show it drops at 30 seconds. The default timeout is 30
  seconds.", not "The request is timing out. The logs confirm it drops at 30
  seconds."

## One idea per paragraph

- Each paragraph carries one idea. Name it in the first sentence.
- Every sentence must earn its place. Cut any sentence that does not serve the
  paragraph's idea.
- Say it once. For example, "this holds only when X" already says "if not X, it
  does not". Do not add the inverse.
- If a paragraph holds two ideas, split it.

## One idea per sentence

Put one idea in each sentence. Split it when it holds two. For example: "Warm
the cache on startup. The first request is then as fast as the rest.", not "Warm
the cache on startup so the first request is as fast as the rest, because
otherwise it pays the full cost of filling the cache while every later request
reads from it."

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

## Name the list, not an umbrella term

Do not invent an umbrella term when you have already named the list.

## Leave the count out of a list

Do not state a count of items you then list. The count and the list drift apart
when either changes. For example: write "the sources", not "the three sources".

## Prefer the common word

Prefer the common word. No jargon. No idioms. For example:

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
