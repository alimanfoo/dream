```
"""Call ``fn``, retrying with exponential backoff and jitter.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to make (not counting retries
        separately); must be at least 1.
    base_delay: Delay in seconds used before the first retry.
    max_delay: Upper bound in seconds for the backoff delay, applied
        before jitter.
    retry_on: Exception type or tuple of types that trigger a retry.
        Anything else propagates immediately.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The last exception raised by ``fn`` if every attempt
        fails. Exceptions not matching ``retry_on`` are re-raised
        without retrying.

The delay doubles after each failed attempt, capped at ``max_delay``,
and each sleep is multiplied by a random factor in [0.5, 1.5) to
spread out retries from concurrent callers. No sleep occurs after the
final attempt.
"""
```
