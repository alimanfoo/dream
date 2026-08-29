```python
"""Call fn, and retry it if it raises one of the errors in retry_on.

Between attempts, this function sleeps. It starts from base_delay and doubles
the delay after every failed attempt, up to max_delay. It also multiplies each
delay by a random factor between 0.5 and 1.5, so that several clients retrying
at once don't all wake up together. That factor applies after the cap, so any
one sleep can run to 1.5 times max_delay.

Args:
    fn: The function to call. It takes no arguments.
    attempts: How many times to call fn, counting the first call. Pass at
        least 1.
    base_delay: How long to sleep before the second attempt, in seconds.
    max_delay: The longest delay to grow to, in seconds.
    retry_on: The exception types that count as a retryable failure.

Returns:
    Whatever fn returns, from the first attempt that doesn't raise.

Raises:
    Exception: The error from the last attempt, if every attempt raised one of
        the types in retry_on. If fn raises any other error, that error comes
        straight back to the caller and no retry happens.
"""
```
