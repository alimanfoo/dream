```python
"""Call ``fn`` repeatedly until it succeeds, backing off between attempts.

``fn`` is invoked with no arguments.

A call that raises one of the exception types in ``retry_on`` is made again
after a delay; any other exception propagates immediately.

That delay starts at ``base_delay``, doubles after each attempt, and is
capped at ``max_delay``. The final attempt is not followed by a delay.

Each delay is jittered before it is used: the caller sleeps for
``delay * (0.5 + random())``, a uniform 50%-150% of the current delay.
Because the cap applies to the pre-jitter delay, an individual sleep may be
as long as 1.5 * ``max_delay`` seconds.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    TypeError: If ``attempts`` is less than 1. In that case no call is
        made, so there is no failure to re-raise.
    Exception: The exception from the final attempt, if every attempt
        failed with a retryable error. Any non-retryable exception is
        re-raised as soon as it occurs.
"""
```
