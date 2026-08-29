```python
"""Call fn, and retry it if it raises one of the errors in retry_on.

Between attempts, sleep for the current delay multiplied by a random
factor between 0.5 and 1.5. The random factor spreads out the retries of
several callers that failed at the same time. After each sleep, double
the delay, up to max_delay.

Any error that is not in retry_on propagates straight to the caller, and
so does the last error once the attempts run out.

Args:
    fn: The function to call. It takes no arguments.
    attempts: How many times to call fn, counting the first call. Pass
        at least 1.
    base_delay: How long to sleep before the second attempt, in seconds.
    max_delay: The longest the delay can grow to, in seconds.
    retry_on: The exception types that count as worth retrying.

Returns:
    Whatever fn returns on the first attempt that doesn't raise.

Raises:
    Exception: The error that the last attempt raised.
"""
```
