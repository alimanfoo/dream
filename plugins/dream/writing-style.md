# Writing style guide

This guide sets the standard for written text. It covers prompts, documentation,
the messages between agents, the artefacts they write for GitHub, and what they
write to the user. Anyone who writes or reviews that text follows it, whether a
person or an automated tool.

## The stance

- Write to inform, not to impress.
- Your readers include people who do not speak English as a first language, and
  agents that act on every word. Write so neither can misread you.
- Aim for a reading age of about 11. Age 9 is better. Make it simpler when in
  doubt.

## One idea per paragraph

- Each paragraph carries one idea. Name it in the first sentence.
- Every sentence must earn its place. Cut any sentence that does not serve the
  paragraph's idea.
- Say it once. For example, "this holds only when X" already says "if not X, it
  does not". Do not add the inverse.
- If a paragraph holds two ideas, split it.

## One idea per sentence

- Put one idea in each sentence.
- Keep an instruction to 20 words or fewer. Keep a description to 25 or fewer.
  For example:
  - "If the request times out, log the error and retry once. A single retry
    usually clears a brief network glitch.", not "If the request times out, log
    the error and retry once, because a single retry usually clears a brief
    network glitch."
- Use active voice. For example:
  - "The parser reads the file before validation.", not "The file is read by the
    parser before validation."
- Name the actor. Say who or what does the action, not "the trap is" or "there
  is".
- Lead with what to do. Add what not to do only to support it.
- Put steps in a vertical list, not a run-on sentence.
- Keep one voice across a list. Do not switch part way.

## Instruction paragraphs

Build an instruction in four parts, in this order: the imperative, the why,
examples, exceptions.

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
need. But hold the order. A why before the verb, or an exception before the
rule, makes the reader decode before they can act.

## Words and marks

- Use a small, consistent vocabulary. One word per meaning, one meaning per
  word. Do not swap in a synonym for variety.
- Do not invent an umbrella term when you have already named the list.
- Prefer the common word. No jargon. No idioms. For example:
  - "X owns the schema", not "X is the operational source of truth"
  - "might go out of sync", not "has drift potential"
  - "now only handles country", not "has narrowed its role to country-only"
  - "use", not "leverage"
  - "essential", not "load-bearing"
  - "the API", not "the surface area"
- Use verbs, not noun forms of verbs. Write "decide", not "make a decision".
- Keep the small words. Do not drop "the", "a", or "that" to sound terse.
- Spell out an abbreviation the first time you use it. Skip the Latin. Write
  "for example", not "e.g.".
- Use simple punctuation. Full stops and commas. No dashes. No semicolons. To
  drop a dash, split the aside into its own sentence. For example:
  - "The script handled country and region. Now it handles country only.", not
    "The script — which handled country and region — handles country only."
- Skip the flourish. No filler opener. No three-part lists for effect. No neat
  opposites. No clever closing line. For example:
  - "The cache is the bottleneck.", not "Here's my honest take: the cache is the
    bottleneck."

## Text for GitHub

Write each paragraph on a single line when GitHub renders it: pull request and
issue descriptions, and comments. GitHub reflows each paragraph to the reader's
window, so a hard-wrapped paragraph breaks into short, uneven lines. Newlines
inside fenced code blocks and between table rows are structural. Leave those
alone.
