```python
"""Call ``fn`` repeatedly until it succeeds or the retries run out.

``fn`` is invoked with no arguments. If it raises one of the exception
types in ``retry_on``, the call is retried after a delay; any other
exception propagates immediately.

Waiting starts at ``base_delay`` seconds and doubles after each failed
attempt, up to ``max_delay``. Each wait is jittered by a random factor in
[0.5, 1.5), so an individual sleep can exceed ``max_delay`` by up to half,
while the growth of the underlying delay is capped. No delay is applied
after the final attempt.

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
    Exception: The exception from the final attempt, if every attempt
        failed with a retryable error. Anything not in ``retry_on`` is
        re-raised from the attempt that produced it. Note that a
        non-positive ``attempts`` never calls ``fn`` and raises
        ``TypeError`` instead.
"""
```
