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
