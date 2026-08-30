<conversation>
> Hey, I've been asked to use this retry helper in my code and I want to make sure I understand it. What does it actually do?

It calls a function repeatedly until it succeeds, backing off between attempts. You hand it `fn`, and it invokes it with no arguments. If `fn` raises one of the exception types you listed in `retry_on`, it waits a bit and calls it again. Anything else propagates straight away.

> So it only swallows the exceptions I nominate?

Right. `retry_on` takes an exception type or a tuple of types, and those are the ones that trigger a retry. Any other exception is re-raised as soon as it occurs — no waiting, no further attempts.

> What does the backing-off part mean in practice? How long does it wait?

Between attempts the caller sleeps for `delay * (0.5 + random())`. That's a uniformly jittered 50%–150% of the current delay. After each sleep, `delay` is doubled. It starts at `base_delay` and is capped at `max_delay`.

> So no sleep is longer than `max_delay`?

That's the trap, actually. The cap applies to the *pre-jitter* delay. Since the jitter can go up to 150%, an individual sleep may be up to `1.5 * max_delay` seconds. Worth remembering if you're sizing a timeout budget around it.

> Does it sleep after the last try too?

No. There's no sleep after the final attempt — it's only ever between attempts.

> How do I control how many times it tries?

That's the `attempts` argument: the maximum number of calls to `fn`. It has to be at least 1.

> And if I pass something less than 1?

You get a `TypeError`. The reasoning is that no attempt is made at all, so there's no error to re-raise — it has to raise something of its own.

> What comes back if it works?

The value returned by the first successful call to `fn`.

> And if every attempt fails?

Then you get the exception from the final attempt — assuming every attempt failed with a retryable error. As I said, a non-retryable one wouldn't have got that far; it's re-raised the moment it occurs.

> Just to check I've got the arguments straight — that's `fn`, `attempts`, `base_delay`, `max_delay`, and `retry_on`?

That's the lot. `fn` is the zero-argument callable to invoke, `attempts` is the maximum number of calls, `base_delay` is the delay in seconds before the first retry, `max_delay` is the upper bound in seconds on the pre-jitter delay, and `retry_on` is the exception type or tuple of types that trigger a retry.
</conversation>
