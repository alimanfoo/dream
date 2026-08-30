```
<conversation>
> I've been asked to use this `retry` helper, but I'm not sure what it actually does. Can you walk me through it?

Sure. At its core it calls a function repeatedly until it succeeds or the retries run out. You hand it `fn`, a zero-argument callable, and it invokes that. If the call works, you get its return value back — specifically the value returned by the first successful call.

> And if the call doesn't work?

Then it waits and tries again. The waiting is the interesting part: it's exponential backoff with jitter. The delay starts at `base_delay`, doubles after each failed attempt, and is capped at `max_delay`. Then each actual sleep gets scaled by a random factor in [0.5, 1.5) — that's the jitter.

> Why scale it randomly like that?

That's the jitter part of "exponential backoff with jitter" — it's what the random factor in [0.5, 1.5) is for. The delay you configure is the pre-jitter delay; `base_delay` is the delay in seconds before the first retry, prior to jitter, and `max_delay` is the upper bound in seconds on that pre-jitter delay. The number you actually sleep is that value times the random factor.

> So `attempts` is how many times it retries?

Careful — `attempts` is the maximum number of calls to `fn`, not the number of retries on top of the first call. So `attempts=3` means three calls total. It must be at least 1.

> Does it sleep after the last failure before giving up?

No. No sleep happens after the final attempt. There's nothing to wait for at that point, so it doesn't burn the time.

> What comes back to me if every attempt fails?

It raises the exception from the final attempt — that's the one that propagates, assuming every attempt failed with an error matching `retry_on`.

> What's `retry_on`?

An exception type, or a tuple of types, that trigger a retry. Anything raised that isn't one of those propagates immediately — no retry, no backoff, it just comes straight out.

> So if I only want to retry on network errors, I put those in `retry_on` and everything else fails fast?

That's exactly the shape of it. Retries happen for the types you named; any other exception propagates immediately.
</conversation>
```
