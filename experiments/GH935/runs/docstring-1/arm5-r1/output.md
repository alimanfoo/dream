```python
"""Call fn, and if it raises one of the exception types in retry_on, retry it.

Between attempts, this function sleeps. It starts from base_delay and doubles
the delay after every failed attempt, up to max_delay. It also multiplies each
delay by a random factor between 0.5 and 1.5, so that several clients retrying
at once don't all wake up together. It multiplies after it limits the delay to
max_delay, so any one sleep can run to 1.5 times max_delay.

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
    Exception: If every attempt raised one of the exception types in retry_on,
        the error from the last attempt. If fn raises any other error, that
        error comes straight back to the caller and no retry happens.
"""
```
