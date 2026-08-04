---
name: watcher
description:
  Watch a pull request for the user's replies. Surface each new one to the
  session. Use only when explicitly invoked.
argument-hint: "<pr> [interval]"
---

# Watcher

Watch a pull request for the user's replies. This is how a session receives
input from the user via GitHub rather than in the session itself.

The watch is one recurring background check for the whole session. It starts
when you invoke this skill. It runs until the pull request merges or closes, or
until you tear it down.

Each firing returns whatever the user has written since the last one. So you see
every reply exactly once, whenever it arrives.

The machinery is a shell script, `watch.sh`, in this skill's directory. It reads
the pull request and tracks what you have already seen. This skill wraps it into
the recurring check and tells you how to act on each result.

## The footer precondition

Mark every comment that you post to the watched pull request with the Claude
Code footer:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

The watch tells your own comments from the user's by that footer, and drops any
comment that carries it. Without it, your own words read back as the user's
input, and the watch surfaces them to you as fresh instructions to act on. This
covers a reply to an inline comment on the diff as much as a comment on the
conversation.

## Set up the watch

Create a recurring cron job (`CronCreate`) that fires every `interval` minutes,
the argument, defaulting to 10 when the caller gives none. Give it this prompt,
with the pull request number and the absolute path to `watch.sh` in this skill's
directory filled in:

```text
Watch check for pull request #<pr>. Run:

  bash <absolute path>/watch.sh <pr>

Read the whole JSON result. If `state` is `MERGED` or `CLOSED`, the watch is
done: tear it down and finish per your session's rules. Otherwise act on
`replies` per your session's rules. Return to idle when `replies` is empty, since
nothing is new.
```

Note the cron job ID in your turn output. Teardown needs it, and nothing else
records it.

Then go idle. The check runs on its own schedule and wakes you when it fires.
You do not poll it.

## On each firing

The cron prompt runs `watch.sh` and hands you the result. It returns the pull
request `state`, the `watermarkFile` path that teardown needs, and `replies`,
what the user newly wrote, oldest first.

Every reply carries its `kind`, the `createdAt` it was written at, and the
`body` the user wrote. The `kind` says where it came from:

- A `comment` is on the conversation.
- A `review` also carries the user's `verdict`, so an approval reaches you even
  when the user left the body empty.
- An `inlineComment` is on a line of the diff. It carries the `path` and `line`
  the user wrote it on, which later commits may since have moved, and the `id`
  of its thread.

The first firing returns everything on the pull request so far. Each later
firing returns only what is new since the one before. A reply that arrives while
you are still handling an earlier batch surfaces on the next firing, never
dropped.

By default, treat each reply as normal turn input and act accordingly.

Reply to an `inlineComment` in its own thread, by its `id`, so your words sit
with the point they address.

## Teardown

Tear the watch down at any terminal outcome: the pull request merged or closed,
a merge that you deferred, or the session done watching for another reason. To
tear it down:

- Delete the cron job (`CronDelete`) by the ID that you recorded at setup.
- Delete the watermark file: `rm -f` the `watermarkFile` path that the script
  reports.

## Limits

- A recurring cron job expires after seven days. A watch on a slow reviewer
  could outlive it and stop. Most reviews land sooner.
- A 10-minute cron can fire up to five minutes late. This makes no real
  difference for a periodic check.
