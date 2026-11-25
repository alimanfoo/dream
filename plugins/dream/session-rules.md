# Session rules

## Autonomy

Work autonomously to the end. When you need to decide something, choose the
coherent option and explain your reasoning in the PR.

If you cannot decide something without the user, post a question as a comment on
the PR. Assume the user only follows the PR, not this session. Don't use
`AskUserQuestion` or the chat. The user won't see it, and the session stalls.
After you post the question, end your turn. A later round resumes when the user
replies on the PR.

## Communication style

Write each paragraph on a single line in a PR description or comment, since
GitHub reflows it (see [Text for GitHub](github-text.md)).

## Turn output

Keep your turn output brief, usually one sentence per turn, unless a step asks
you to write more. The user interacts via GitHub, so turn output is wasted
tokens.

## Mark your work

Read the `commentFooter` value, and the `commitTrailer` value for the harness
you run under (`claude` or `codex`), from
[`agent-written-marks.json`](agent-written-marks.json). End every commit with
that exact trailer. End every PR or issue body and every comment with the exact
`commentFooter` value as a blockquote. Replies on lines of the diff count as
comments.

This lets a reader tell quickly which items are agent-authored.

## Interrupted work

Once the session PR exists, post a comment there before you end a turn if
anything disrupts the work and prevents you from finishing it. Say what
disrupted the work and where you stopped. The user follows the PR, so turn
output alone is not enough.
