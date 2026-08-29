```python
"""Call ``fn`` repeatedly until it succeeds, waiting longer before each retry.

This function calls ``fn`` with no arguments. If ``fn`` raises one of the
exception types in ``retry_on``, this function calls ``fn`` again after a
delay. Any other exception propagates immediately.

The delay starts at ``base_delay`` seconds, and this function doubles it
after every attempt, up to a maximum of ``max_delay``.

Before each retry, this function sleeps for ``delay * (0.5 + random())``,
which is anywhere from 50% to 150% of the current delay. The cap applies
to the delay before jitter, so a single sleep can last as long as
1.5 * ``max_delay`` seconds.

After the final attempt, this function does not sleep again.

Args:
    fn: Zero-argument callable to call.
    attempts: Maximum number of times this function calls ``fn``. Must be
        at least 1.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the delay before jitter.
    retry_on: Exception type or tuple of types that make this function
        retry.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception from the final attempt, if every attempt
        raised a retryable exception. This function re-raises any
        non-retryable exception as soon as ``fn`` raises it.
    TypeError: If ``attempts`` is less than 1, because this function then
        never calls ``fn`` and so has no exception to re-raise.
"""
```
