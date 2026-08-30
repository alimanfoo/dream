```
"""Call ``fn`` repeatedly until it succeeds or the attempts run out.

Between one attempt and the next, the call sleeps. After the final
attempt, it does not.

Each of those sleeps follows exponential backoff with jitter. The delay
starts at ``base_delay`` and doubles after each failed attempt, up to a
ceiling of ``max_delay``. The sleep actually taken is that delay scaled
by a random factor in [0.5, 1.5).

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
```
