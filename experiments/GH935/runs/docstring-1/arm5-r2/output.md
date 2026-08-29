```python
"""Call ``fn`` and retry it if it raises one of the errors in ``retry_on``.

Between attempts, sleep for a delay that starts at ``base_delay`` seconds and
doubles each time. The delay never grows beyond ``max_delay`` seconds.

Then multiply the delay by a random factor between 0.5 and 1.5, so that
several callers retrying at once don't all come back at the same moment.

Args:
    fn: The function to call. It takes no arguments.
    attempts: How many times to call ``fn`` before giving up.
    base_delay: How long to sleep before the second attempt, in seconds.
    max_delay: The longest the delay can grow to, in seconds.
    retry_on: The exception types to retry on. Any other exception comes
        straight back to the caller.

Returns:
    Whatever ``fn`` returns on the first attempt that doesn't raise.

Raises:
    The error from the last attempt, if every attempt raised one of the
    types in ``retry_on``.
"""
```
