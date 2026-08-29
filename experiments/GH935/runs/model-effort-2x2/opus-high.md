```
"""Call ``fn`` repeatedly until it succeeds, backing off between attempts.

Each attempt calls ``fn`` with no arguments. If it raises one of the
exception types in ``retry_on``, the error is recorded and the next attempt
is made after a sleep. Exceptions not listed in ``retry_on`` propagate
immediately.

The sleep before the next attempt is the current delay multiplied by a
random factor drawn uniformly from [0.5, 1.5), which spreads out retries
from concurrent callers. The delay itself starts at ``base_delay`` and
doubles after every failed attempt, capped at ``max_delay``. No sleep
happens after the final attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds used as the basis for the first backoff.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception raised by the final attempt, if every attempt
        failed with a retryable error. Any non-retryable exception raised
        by ``fn`` propagates unchanged.
    UnboundLocalError: If ``attempts`` is less than 1, since ``fn`` is never
        called and there is no error to re-raise.
"""
```
