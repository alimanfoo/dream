```python
"""Call ``fn`` repeatedly until it succeeds or the retries run out.

``fn`` is invoked with no arguments. If it raises one of the exception
types in ``retry_on``, the call is retried after a delay; any other
exception propagates immediately.

Delays fall between attempts, so none follows the last one.

Waiting starts at ``base_delay`` seconds and doubles after each failed
attempt, up to ``max_delay``. Each wait is then jittered by a random
factor in [0.5, 1.5). The cap governs the underlying delay rather than
the jittered wait, so an individual sleep can exceed ``max_delay`` by up
to half.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``, retries included, so
        ``attempts=5`` allows at most four retries.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    Whatever ``fn`` returns on its first successful call.

Raises:
    Exception: If every attempt failed with a retryable error, the
        exception from the final attempt. Anything not in ``retry_on``
        is re-raised from the attempt that produced it.
    TypeError: If ``attempts`` is not positive, in which case ``fn`` is
        never called.
"""
```
