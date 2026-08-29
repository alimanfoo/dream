```
"""Call ``fn`` repeatedly until it succeeds or runs out of attempts.

Each retry waits before it calls ``fn`` again, using exponential backoff
with jitter. The delay starts at ``base_delay`` and doubles after each
failed attempt, up to ``max_delay``. Jitter then scales each actual sleep
by a random factor in [0.5, 1.5). No sleep happens after the final
attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry, measured before
        jitter.
    max_delay: Upper bound in seconds on the delay, measured before
        jitter.
    retry_on: Exception type or tuple of types that trigger a retry.
        Any other exception propagates immediately.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with an error matching ``retry_on``.
"""
```
