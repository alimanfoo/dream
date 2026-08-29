```
<conversation>
> I've been asked to use this `retry` helper for the upload calls. Before I do — what's the deal with `retry_on`?

It's the filter that decides what counts as a transient failure. Pass a single exception type or a tuple of them. If `fn` raises something in that set, the helper sleeps and calls it again. Anything else propagates immediately, on the spot — no sleep, no further attempts.

> So an unexpected bug inside `fn` isn't going to get retried five times?

Right, and that's deliberate. Retrying a `KeyError` or a `TypeError` just wastes wall-clock and makes the traceback show up thirty seconds later than it should. Keep `retry_on` narrow — the specific network or throttling exceptions you actually expect — and everything else fails fast.

> Got it. And `fn` takes no arguments?

None. It's invoked bare. So in practice you close over what you need, or wrap it — `lambda: client.upload(path, blob)`, or `functools.partial`. The helper returns whatever the first successful call returns, so you don't lose the result.

> What does the waiting actually look like? Is it a fixed delay?

No, it's exponential with jitter. The delay starts at `base_delay`, and after each attempt it doubles, capped at `max_delay`. But the sleep isn't the delay itself — it's `delay * (0.5 + random())`, which is a uniform 50%–150% of the current value.

> Why randomize it at all? Seems like it just makes the timing harder to reason about.

Because of what happens when a service goes down and comes back. If a hundred workers all fail at the same instant and all back off by exactly one second, they all retry at the same instant too — and knock the service straight back over. The jitter spreads them out. You give up a little predictability in a single process to avoid a synchronized stampede across all of them.

> Makes sense. So with `max_delay=10`, my worst-case sleep is ten seconds?

That's the trap, and it's worth internalizing. The cap applies to the *pre-jitter* delay. So `delay` never exceeds 10, but the jitter multiplier still goes up to 1.5 on top of that — an individual sleep can be up to 15 seconds.

> That could matter if something upstream has a timeout.

Exactly why I'm flagging it. If you're inside a request handler with a hard deadline, budget against `1.5 * max_delay` per sleep, not `max_delay`. I've seen someone size a timeout off the cap and then spend an afternoon confused about intermittent deadline breaches.

> Fair. And `attempts` — is that the number of retries, or total calls?

Total calls. `attempts=3` means `fn` runs at most three times: the original plus two retries. Off-by-one there is a classic, so read it as "calls," not "retries."

> What happens if they all fail?

The exception from the *final* attempt propagates. Not the first one, not a wrapper type — the last failure, as-is. So whatever your caller catches is the most recent evidence of what's wrong, which is usually what you want in the logs.

> And the sleeping — does it sleep after that last one too?

No, and that's a small nicety. There's no sleep after the final attempt. If you've run out of attempts there's nothing left to wait for, so the failure surfaces immediately instead of after one last pointless pause.

> One more: what if I pass `attempts=0`? Does it just return `None`?

It raises `TypeError`. And the reasoning is worth understanding, because it's not an arbitrary validation rule. With zero attempts, `fn` is never called, so there's no result to return and no exception to re-raise — the function has no honest way to fulfill its contract. Rather than invent a return value or swallow the situation silently, it treats it as a programming error, which is what it is.

> That's a nice line to draw.

It generalizes. Whenever a function is asked to do something where every possible answer would be a lie, raising is the right move. Returning `None` there would just push the bug downstream to whoever forgot to check.

> Okay. So for the upload path — narrow `retry_on`, a handful of attempts, and size the timeout off one-and-a-half times the cap.

That's the whole thing. Start with `attempts=3` or so and a small `base_delay`; you can always widen it once you've seen how the service actually misbehaves. Tuning it up front without data is guessing.
</conversation>
```
