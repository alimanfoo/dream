```
<conversation>
> I've been asked to document this retry helper. What does it actually do, at the top level?

Call `fn` repeatedly until it succeeds or the retries run out.

> And how does it space out those repeated calls? Does it just hammer away immediately?

Retries use exponential backoff with jitter: the delay starts at `base_delay`, doubles after each failed attempt up to `max_delay`, and each actual sleep is scaled by a random factor in [0.5, 1.5).

> So if the last attempt fails, does it still wait before giving up?

No sleep happens after the final attempt.

> Let me go through the arguments. What's `fn` expected to be?

Zero-argument callable to invoke.

> And `attempts`?

Maximum number of calls to `fn`. Must be at least 1.

> What exactly does `base_delay` control?

Delay in seconds before the first retry, prior to jitter.

> And `max_delay` — is that a cap on the sleep itself?

Upper bound in seconds on the pre-jitter delay.

> Last one: `retry_on`. What goes in there?

Exception type or tuple of types that trigger a retry. Any other exception propagates immediately.

> Good. What comes back out of the function when things go well?

The value returned by the first successful call to `fn`.

> And when they don't go well — what does the caller see?

The exception from the final attempt, if every attempt failed with an error matching `retry_on`.
</conversation>
```

```
<passage>
"""Call ``fn`` repeatedly until it succeeds or the retries run out.

Retries use exponential backoff with jitter: the delay starts at
``base_delay``, doubles after each failed attempt up to ``max_delay``,
and each actual sleep is scaled by a random factor in [0.5, 1.5).
No sleep happens after the final attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry, prior to jitter.
    max_delay: Upper bound in seconds on the pre-jitter delay.
    retry_on: Exception type or tuple of types that trigger a retry.
        Any other exception propagates immediately.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with an error matching ``retry_on``.
"""
</passage>
```
