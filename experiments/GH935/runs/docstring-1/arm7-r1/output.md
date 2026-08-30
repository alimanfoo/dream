<conversation>
> Hey, I've been asked to use this retry helper in my code. What does it actually do?

It calls a function repeatedly until it succeeds or the retries run out. You hand it `fn`, and it invokes it with no arguments. If `fn` raises one of the exception types you listed in `retry_on`, it waits a bit and tries again. Any other exception propagates immediately — no retry, it just comes straight back out at you.

> How many times does it try?

That's `attempts` — the maximum number of calls to `fn`. Note that's calls, not retries counted separately. So `attempts=5` means at most four retries.

> And the waiting between tries — is that a fixed delay?

No, it backs off. The wait starts at `base_delay` seconds and doubles after each failed attempt, up to `max_delay`. And there's no delay applied after the final attempt — no point sleeping if you're not going to try again.

> Does everything hit the same delay at the same moment then? I've been bitten by thundering herds before.

That's what the jitter is for. Each wait gets multiplied by a random factor in [0.5, 1.5). Worth knowing what that means for the cap: an individual sleep can exceed `max_delay` by up to half. The cap applies to the growth of the underlying delay, not to the jittered sleep you actually get.

> Got it. What comes back if it works?

Whatever `fn` returns on its first successful call.

> And if it never succeeds?

If every attempt failed with a retryable error, you get the exception from the final attempt. For anything not in `retry_on`, it's re-raised from the attempt that produced it.

> One more — what if I pass `attempts=0`, say from a config value that ends up zero?

Then `fn` is never called at all, and you get a `TypeError` instead. So a non-positive `attempts` isn't a quiet no-op — it raises.

> Anything else on `retry_on`?

Just that it takes either a single exception type or a tuple of types. Those are the ones that trigger a retry.
</conversation>
