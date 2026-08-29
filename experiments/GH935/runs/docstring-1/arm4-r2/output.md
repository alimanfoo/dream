```
"""Call ``fn`` repeatedly until it succeeds or runs out of attempts.

Each retry waits before it calls ``fn`` again, using exponential backoff
with jitter. The delay starts at ``base_delay`` and doubles after each
failed attempt, up to ``max_delay``. Jitter then scales each actual sleep
by a random factor in [0.5, 1.5). After the final attempt, ``fn`` doesn't
sleep at all.

Args:
    fn: Callable that takes no arguments.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry, before jitter
        scales it.
    max_delay: Upper bound in seconds on the delay, before jitter scales
        it.
    retry_on: Exception type or tuple of types that trigger a retry.
        Any other exception propagates immediately.

Returns:
    The value that the first successful attempt returned.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with an error matching ``retry_on``.
"""
```
