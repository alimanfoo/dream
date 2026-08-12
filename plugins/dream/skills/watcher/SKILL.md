---
name: watcher
description:
  Watch a pull request for what the user posts. Surface each new post to the
  session. Use only when explicitly invoked.
argument-hint: "<pr> [interval]"
---

# Watcher

Watch a pull request for what the user posts on it. This is how a session
receives input from the user via GitHub rather than in the session itself.

The watch is one recurring background check for the whole session. It starts
when you invoke this skill. It runs until the pull request merges or closes, or
until you tear it down.

Each firing returns whatever the user has written since the last one. So you see
every post exactly once, whenever it arrives.

The machinery is a shell script, `watch.sh`, in this skill's directory. It reads
the pull request and tracks what you have already seen. This skill wraps it into
the recurring check and tells you how to act on each result.

## The footer precondition

Mark every comment that you post to the watched pull request with the Claude
Code footer:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

The watch drops comments that carry this footer, so your own replies do not come
back as fresh user posts.

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
`posts` per your session's rules. Return to idle when `posts` is empty, since
nothing is new.
```

Note the cron job ID in your turn output. Teardown needs it, and nothing else
records it.

Then go idle. The check runs on its own schedule and wakes you when it fires.
You do not poll it.

## On each firing

The cron prompt runs `watch.sh` and hands you the result. It returns the pull
request `state`, the `watermarkFile` path that teardown needs, and `posts`, what
the user newly wrote, oldest first.

Every post carries its `kind`, the `createdAt` it was written at, and the `body`
the user wrote. The `kind` says where it came from:

- A `comment` is on the conversation.
- A `review` also carries the user's `verdict`, so an approval reaches you even
  when the user left the body empty.
- An `inlineComment` is on a line of the diff, and carries the `path` and `line`
  the user wrote it on, plus the `id` of its thread. The `line` is the last one
  when the comment covers a range, and null when it is about the whole file.

The first firing returns everything on the pull request so far. Each later
firing returns only what is new since the one before. A post that arrives while
you are still handling an earlier batch surfaces on the next firing, never
dropped.

By default, treat each post as normal turn input and act accordingly.

Reply to an `inlineComment` in its own thread, so your words sit with the point
they address. Post to the pull request's `comments/<id>/replies` endpoint, using
that post's `id`, since a plain PR comment would start a new conversation
instead.

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
