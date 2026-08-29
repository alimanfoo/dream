```
    Retry a callable with exponential backoff and jitter.

    Calls `fn()` repeatedly until it succeeds or `attempts` calls have
    been made, sleeping between attempts for a randomly jittered delay
    that doubles each time (starting at `base_delay`, capped at
    `max_delay`). Only exceptions matching `retry_on` are caught and
    retried; any other exception propagates immediately.

    Args:
        fn: Zero-argument callable to invoke.
        attempts: Maximum number of calls to attempt.
        base_delay: Initial delay in seconds before backoff/jitter.
        max_delay: Upper bound on the delay in seconds.
        retry_on: Exception type or tuple of types that trigger a retry.

    Returns:
        The return value of `fn()` on the first successful call.

    Raises:
        The last exception raised by `fn()` if all attempts fail.
    """
```
