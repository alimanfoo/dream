"""Call ``fn`` repeatedly until it succeeds, backing off between attempts.

``fn`` is invoked with no arguments. If it raises one of the exception
types in ``retry_on``, it is called again after a delay; any other
exception propagates immediately.

Between attempts the caller sleeps for ``delay * (0.5 + random())`` -- i.e.
a uniformly jittered 50%-150% of the current delay -- and ``delay`` is then
doubled, starting at ``base_delay`` and capped at ``max_delay``. Note that
the cap applies to the pre-jitter delay, so an individual sleep may be up
to 1.5 * ``max_delay`` seconds. No sleep happens after the final attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with a retryable error. Any non-retryable exception is
        re-raised as soon as it occurs.
    TypeError: If ``attempts`` is less than 1, since no attempt is made
        and there is no error to re-raise.
"""
