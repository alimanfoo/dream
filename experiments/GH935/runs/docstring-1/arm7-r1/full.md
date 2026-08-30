<conversation>
> I've been asked to use this `retry` helper in the ingest job, but I want to make sure I understand it first. What does it actually do?

At the top level it's simple: call `fn` repeatedly until it succeeds or the retries run out. That's the whole contract — everything else is about *how* it waits between those calls and *which* failures it's willing to wait on.

> How does it call `fn`? Do I pass arguments through?

No, `fn` is invoked with no arguments. If you need arguments, wrap it in a lambda or a `functools.partial` before you hand it over. In the docs it's described as: `fn`: Zero-argument callable to invoke.

> And it retries on any failure?

Not any failure — that's the important part. If it raises one of the exception types in `retry_on`, the call is retried after a delay; any other exception propagates immediately. So `retry_on` is your allowlist of "this is probably transient." It takes an exception type or tuple of types that trigger a retry.

> Makes sense. What does the waiting look like?

It's exponential backoff. Waiting starts at `base_delay` seconds and doubles after each failed attempt, up to `max_delay`. So `base_delay` is the delay in seconds before the first retry, and `max_delay` is the upper bound in seconds on the (pre-jitter) delay.

> You said "pre-jitter" — what's the jitter doing?

Each wait is jittered by a random factor in [0.5, 1.5), so an individual sleep can exceed `max_delay` by up to half, while the growth of the underlying delay is capped. That's worth internalising: `max_delay` bounds the delay the algorithm computes, not the actual sleep you'll observe. If you set `max_delay` to 30, you can still see a sleep of nearly 45 seconds.

> Right, I'd have assumed 30 was a hard ceiling. Does it sleep after the last attempt too?

No. No delay is applied after the final attempt. There'd be nothing to wait for.

> How do I control how many times it tries?

That's `attempts`. It's the maximum number of calls to `fn` (not counting retries separately), so `attempts=5` means at most four retries. People get that off by one constantly — it's total calls, not extra calls.

> What comes back if it works?

Whatever `fn` returns on its first successful call. Nothing is wrapped or transformed.

> And if it never works?

Then you get the exception from the final attempt, if every attempt failed with a retryable error. You're not handed a summary or a custom wrapper type — it's the real exception from the last try. And as we said, anything not in `retry_on` is re-raised from the attempt that produced it, immediately, without waiting.

> Any edge cases I should watch out for before I wire this in?

One. Note that a non-positive `attempts` never calls `fn` and raises `TypeError` instead. So if `attempts` is coming from config or a computed value, guard it — passing zero doesn't quietly do nothing, it blows up with an error that won't obviously point back at the config.
</conversation>

```
<passage>
"""Call ``fn`` repeatedly until it succeeds or the retries run out.

``fn`` is invoked with no arguments. If it raises one of the exception
types in ``retry_on``, the call is retried after a delay; any other
exception propagates immediately.

Waiting starts at ``base_delay`` seconds and doubles after each failed
attempt, up to ``max_delay``. Each wait is jittered by a random factor in
[0.5, 1.5), so an individual sleep can exceed ``max_delay`` by up to half,
while the growth of the underlying delay is capped. No delay is applied
after the final attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn`` (not counting retries
        separately), so ``attempts=5`` means at most four retries.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    Whatever ``fn`` returns on its first successful call.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with a retryable error. Anything not in ``retry_on`` is
        re-raised from the attempt that produced it. Note that a
        non-positive ``attempts`` never calls ``fn`` and raises
        ``TypeError`` instead.
"""
</passage>
```
