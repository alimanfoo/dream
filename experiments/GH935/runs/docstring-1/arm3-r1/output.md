```python
"""Call ``fn`` repeatedly until it succeeds or the retries run out.

The function calls ``fn`` with no arguments. If ``fn`` raises one of the
exception types in ``retry_on``, the function waits and then calls ``fn``
again; any other exception propagates immediately.

The delay starts at ``base_delay`` seconds and doubles after each failed
attempt, up to ``max_delay``. The function multiplies each delay by a
random factor in [0.5, 1.5), so an individual delay can exceed
``max_delay`` by up to half, while ``max_delay`` still caps the delay that
the function multiplies. After the final attempt the function does not
wait.

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
    Exception: If every attempt failed with a retryable error, the
        exception from the final attempt. The function re-raises anything
        not in ``retry_on`` from the attempt that produced it. If
        ``attempts`` is not positive, the function never calls ``fn`` and
        raises ``TypeError`` instead.
"""
```
