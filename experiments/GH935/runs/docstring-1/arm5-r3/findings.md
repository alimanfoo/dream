Two confirmed findings, both under "Use a small vocabulary":

- **"retry_on: The exception types that count as worth retrying."** — breaks the small-vocabulary rule: the rest of the text calls this concept "error" throughout ("the errors in retry_on", "Any error that is not in retry_on", "the last error"), so "exception" here is a second word doing the same job.

- **"attempts: How many times to call fn, counting the first call."** — breaks the small-vocabulary rule: everywhere else a single invocation of `fn` is called an "attempt" ("before the second attempt", "the first attempt that doesn't raise", "the last attempt raised"), so "the first call" swaps in a second word for the same thing.
