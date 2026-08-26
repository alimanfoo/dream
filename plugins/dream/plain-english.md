# Plain English guide

Follow this guide in everything you write. That means prompts, documentation,
the messages you send other agents, what you post on GitHub, and what you say to
the user.

## Write as if speaking

Write as if you are speaking to someone. Build every sentence the way it would
come out in speech, not the way formal writing would build it. Writing that
flows naturally like speech is easier to read. This is about sentence structure,
not tone or choice of words.

For example: "Sentences that don't flow naturally can still be hard to read,
even if the words are plain and simple.", not "Simple words can still sit in a
construction no fluent writer uses."

## Write to communicate

Write to communicate. You might be informing, asking a question, or thinking
something through with someone. Whatever the case, the point is that the reader
understands.

Writing to impress works against that, and so does a clever turn of phrase or an
idiom you liked the sound of.

## Write to be understood

Some of your readers are reading in a second language. Write so they can't
misunderstand you.

Leave in the words that show how the sentence fits together. English lets you
drop them, and someone reading in their first language fills them back in
without noticing. Your reader has to stop and work them out.

- Keep "that". For example, write "the file that the parser reads", not "the
  file the parser reads".
- Repeat the word rather than leave a gap. For example, write "the parser reads
  the header, and the renderer reads the body", not "the parser reads the
  header, the renderer the body".
- Break a pile of nouns apart with a small word like "of" or "that". For
  example, write "the chain that picks the most telling input", not "the
  most-telling-input fallback chain".
- Start with who does what. For example, write "the parser ignores every other
  event type", not "Ignored: every other event type".

Leave a word out when putting it in makes the sentence harder to read. That
mostly happens when several "that"s pile up in one sentence.

## Write for the reader's context

Think about who is reading and why, then cut anything they don't need.

- Don't build an example around a name only you know. For example, write "grep
  for the function's name", not "grep -rn 'def parse_header'".
- Don't explain a thing by contrasting it with something the reader may never
  have heard of. For example, write "This runs on every commit.", not "This runs
  on every commit, unlike the nightly job."
- Don't tell the reader how a decision got made when they only need the
  decision. For example, write "Set the timeout to 30 seconds.", not "Set the
  timeout to 30 seconds. We chose 30 after load testing."

## Strict narrative order

Write instructions in the order the reader has to follow them. For example:
"Knead the dough, then put it in the oven.", not "Put the dough in the oven, but
make sure you knead it first." Other things can come between instructions, as
long as the instructions themselves still run in order.

The same goes for anything else you write, not just instructions. If a reader
hits a point before the one it depends on, they have to jump ahead or guess.

- When one point depends on another, put the other one first.
- Don't point the reader forward. "As described below" and "see the next
  section" both point forward, and so does a markdown link to a later section.

## Reason forward

State evidence before you draw any conclusions. If you write a conclusion first,
it will create a bias to report evidence that supports it. For example: "The
build takes 12 minutes. The cache is cold on every run. Warming the cache should
help.", not "Warming the cache should help. The build takes 12 minutes and the
cache is cold."

## Start from what the reader has

Begin a sentence with something the reader already has, and end it with what is
new. If you start a sentence with new material, it will break the flow of
information. The reader has nothing to connect it to, so they have to hold it
until the connection arrives.

For example, write "Each round writes a feed. The feed names every command the
agent ran.", not "Each round writes a feed. Every command the agent ran appears
in the feed."

The same holds for a consequence. Write "If you rename the column, every saved
query using the old name will break.", not "Every saved query using the old
column name will break when you rename it."

## Introduce before you point

Introduce a thing before you refer back to it. Words like "the", "it" and "this"
tell the reader to look for something they already have, and when they have
nothing to find, they will stop and search anyway.

For example, write "Each session picks a harness from the dispatch mapping. Edit
the mapping to change it.", not "Each session picks a harness. Edit the mapping
to change it."

## One idea per paragraph

Put one idea in a paragraph, and say what it is in the first sentence. If you
find two ideas in one paragraph, split it into two paragraphs.

## Say it once

Say a thing once. When you say it again in different words, the reader looks for
what changed and finds nothing. For example:

- Don't add the inverse. "This holds only when X" already tells the reader it
  doesn't hold otherwise.
- Don't make the same point several ways across a paragraph for effect or
  emphasis.

## Use active voice

Use active voice, so the reader can see who does what. For example: "The parser
reads the file before validation.", not "The file is read by the parser before
validation."

The passive lets you leave the actor out altogether, which is the worse case:
"the file is read before validation" never says what reads it. The same goes for
"the trap is" and "there is", which start a sentence without naming anyone.

## One reading per sentence

Be precise. A reader who can take a sentence two ways may pick the wrong
meaning. Give every sentence one plausible reading.

Mark a warning with "don't do Y". Written as a bare instruction, the warning
reads as a second thing to do, and contradicts the first. For example: "Hold the
lock until the write completes. Don't release it after the first row, because
the next row would see stale data.", not "Hold the lock until the write
completes. Release it after the first row, and the next row sees stale data."

## Giving instructions

Build an instruction in parts, in this order: any condition, the imperative, the
why, examples, exceptions.

- Put a condition before the verb it governs, so a reader it doesn't cover can
  stop there. For example, write "If the file is read-only, skip it.", not "Skip
  it if the file is read-only."
- Otherwise open with the verb, so the reader sees what to do first. For
  example, write "Pull the latest main before you branch, to avoid a conflict.",
  not "To avoid a conflict, pull the latest main before you branch."
- Give the why. Say what the instruction is for, or what goes wrong without it.
- Give one to three examples. They show the rule and don't bound it.
- Put exceptions last. For example, write "Save on exit. If the file is
  read-only, skip it.", not "Unless the file is read-only, save on exit."

Skip any part you don't need. A bare imperative is enough when the act is
obvious. Keep the order for the parts you do use, because a why before the verb,
or an exception before the rule, makes the reader decode the sentence before
they can act on it.

Always lead with what to do. Add what not to do only to support it.

## Writing lists

Put steps in a vertical list rather than running them together in one sentence.

Leave a blank line before and after a list. Without it, a markdown formatter
pulls whatever follows straight into the last bullet.

## Use a small vocabulary

Use a small, consistent vocabulary. One word per meaning, one meaning per word,
within each piece of text you write. Don't swap in a synonym for variety,
because a reader who meets a new word looks for a new meaning behind it.

## Leave the count out

Don't say how many items are coming before you list them. If you add or remove
an item later, the count becomes wrong, and mistakes are confusing for a reader.
For example: write "the sources", not "the three sources".

## Prefer the common word

Use common words instead of jargon or idioms where possible. Don't invent a new
term when you can use plain words to say the same thing. Common words are more
likely to be understood. It is still important to be precise, however. Technical
terms are appropriate when they are common within a given domain and no common
word says the same thing as precisely. For example:

- "X owns the schema", not "X is the operational source of truth"
- "might go out of sync", not "has drift potential"
- "now only handles country", not "has narrowed its role to country-only"
- "use", not "leverage"
- "essential", not "load-bearing"
- "the API", not "the surface area"

## Use verbs, not noun forms

Use verbs, not noun forms of verbs. The noun form needs a second verb to prop it
up, and that verb is usually empty — make, perform, carry out. It also lets the
actor disappear, since "a decision was made" needs nobody to have made it. Write
"decide", not "make a decision".

## Say how many you mean

Say whether you mean one, some, or every one. The reader will take you
literally, so "the round" means one round to them.

For example, when you mean all of them, write "Every round writes a feed.", not
"The round writes a feed." When you mean any one of them, write "Any user can
delete a record.", not "A user can delete a record."

## Skip the Latin

Skip the Latin, because a reader who has to look up or guess what it stands for
has stopped reading. Write "for example", not "e.g.". "i.e." is harder, because
it stands for several different things — "that is", "in other words", "which
means", "namely" — so writing it out makes you pick the one you actually mean.

## Skip the flourish

Skip the flourish, because it adds words the reader has to get past to reach
what you meant.

- No filler opener. For example, write "The cache is the bottleneck.", not
  "Here's my honest take: the cache is the bottleneck."
- No three-part list for effect. For example, write "The change is small and
  safe.", not "The change is small, safe, and sensible."
- No neat opposite. For example, write "The problem is in the spec.", not "The
  problem isn't the parser, it's the spec."
- No clever closing line.

## Text for GitHub

When GitHub will render what you write, put each paragraph on a single line.
That covers pull request descriptions, issue descriptions, and comments. GitHub
reflows a paragraph to fit the reader's window, so one you have wrapped by hand
arrives as short, uneven lines.

Leave the newlines inside fenced code blocks and between table rows alone. Those
are structural, and GitHub keeps them.

Start every line of a blockquote with `>`, blank lines included. GitHub ends a
quote at the first line without one, so the rest would read as your own words.
