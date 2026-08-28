```
"""Call fn, retrying with exponential backoff if it raises a retryable error.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of attempts before giving up.
    base_delay: Initial delay in seconds before the first retry.
    max_delay: Upper bound on the delay between retries.
    retry_on: Exception type(s) that trigger a retry.

Returns:
    The return value of fn() on success.

Raises:
    The last caught exception if all attempts are exhausted.
"""
```
