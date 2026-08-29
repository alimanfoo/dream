import random
import time


def retry(fn, attempts=5, base_delay=0.5, max_delay=30.0,
          retry_on=(TimeoutError, ConnectionError)):
    delay = base_delay
    last_error = None
    for attempt in range(attempts):
        try:
            return fn()
        except retry_on as error:
            last_error = error
            if attempt == attempts - 1:
                break
            time.sleep(delay * (0.5 + random.random()))
            delay = min(delay * 2, max_delay)
    raise last_error
