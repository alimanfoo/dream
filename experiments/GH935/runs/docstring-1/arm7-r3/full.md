```
<conversation>
> I've been handed this retry helper to document. What does it actually do, in one line?

Call ``fn`` repeatedly until it succeeds, backing off between attempts. That's the whole idea — everything else is detail about how long it waits and when it gives up.

> How does it call `fn`? Do I pass it arguments somehow?

No. ``fn`` is invoked with no arguments. If you need arguments, you close over them or bind them before you hand the callable in.

> And "until it succeeds" — does it retry on any failure at all?

Not quite, and this is the part people get wrong. If it raises one of the exception types in ``retry_on``, it is called again after a delay; any other exception propagates immediately. So a typo in your function surfaces straight away rather than being swallowed and retried five times.

> Right. So what's the delay between attempts?

Between attempts the caller sleeps for ``delay * (0.5 + random())`` -- i.e. a uniformly jittered 50%-150% of the current delay -- and ``delay`` is then doubled, starting at ``base_delay`` and capped at ``max_delay``. The jitter is there so that a fleet of callers doesn't all wake up in lockstep.

> The cap is on the sleep, then?

That's the trap. Note that the cap applies to the pre-jitter delay, so an individual sleep may be up to 1.5 * ``max_delay`` seconds. If you're sizing a timeout around this, budget for that extra half.

> Does it sleep once more before giving up?

No sleep happens after the final attempt. There'd be nothing to wait for.

> Let me get the parameters straight. What's `fn` and what's `attempts`?

``fn`` is the zero-argument callable to invoke. ``attempts`` is the maximum number of calls to ``fn``. Must be at least 1 — it counts calls, not retries, so passing 3 means one initial call plus two retries.

> And the three timing-ish ones?

``base_delay`` is the delay in seconds before the first retry. ``max_delay`` is the upper bound in seconds on the (pre-jitter) delay. And ``retry_on`` is an exception type or tuple of types that trigger a retry.

> What comes back out of it?

The value returned by the first successful call to ``fn``. Nothing is aggregated or wrapped — you get the result as if you'd called it directly.

> And if every attempt fails?

You get the exception from the final attempt, if every attempt failed with a retryable error. Any non-retryable exception is re-raised as soon as it occurs, as we said — it doesn't wait for the attempts to run out.

> One last thing — what if I pass `attempts=0` by accident?

You get a ``TypeError``, if ``attempts`` is less than 1, since no attempt is made and there is no error to re-raise. There's simply no sensible thing to hand back, so it complains up front rather than returning `None` and letting you wonder.
</conversation>
```

```
<passage>
"""Call ``fn`` repeatedly until it succeeds, backing off between attempts.

``fn`` is invoked with no arguments. If it raises one of the exception
types in ``retry_on``, it is called again after a delay; any other
exception propagates immediately.

Between attempts the caller sleeps for ``delay * (0.5 + random())`` -- i.e.
a uniformly jittered 50%-150% of the current delay -- and ``delay`` is then
doubled, starting at ``base_delay`` and capped at ``max_delay``. Note that
the cap applies to the pre-jitter delay, so an individual sleep may be up
to 1.5 * ``max_delay`` seconds. No sleep happens after the final attempt.

Args:
    fn: Zero-argument callable to invoke.
    attempts: Maximum number of calls to ``fn``. Must be at least 1.
    base_delay: Delay in seconds before the first retry.
    max_delay: Upper bound in seconds on the (pre-jitter) delay.
    retry_on: Exception type or tuple of types that trigger a retry.

Returns:
    The value returned by the first successful call to ``fn``.

Raises:
    Exception: The exception from the final attempt, if every attempt
        failed with a retryable error. Any non-retryable exception is
        re-raised as soon as it occurs.
    TypeError: If ``attempts`` is less than 1, since no attempt is made
        and there is no error to re-raise.
"""
```
