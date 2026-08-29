```
<conversation>
> I've been asked to make our API client resilient to flaky upstreams. Someone pointed me at this `retry` helper. How do I actually call it?

You hand it a zero-argument callable. That trips people up on day one, because most of the time the thing you want to retry does take arguments. So you close over them:

    result = retry(lambda: client.get(url, timeout=5), attempts=5)

or use `functools.partial` if you prefer. Either way, `retry` never passes anything in — it just calls `fn()`. Whatever `fn` returns on the first successful call is what you get back.

> Got it. And `attempts=5` means it retries five times?

No, and this is the single most common misreading. `attempts` is the number of *calls*, not the number of retries. `attempts=5` means at most four retries. If you want "try once, then give up," that's `attempts=1`, not `0`.

> What does `attempts=0` do, then?

Nothing useful — and it fails in a way that will confuse you at 2am. With a non-positive `attempts`, `fn` is never called at all, and instead of returning `None` or raising something descriptive, you get a `TypeError`. So don't compute `attempts` from something that might come out zero or negative — a config value, a `len()`, a subtraction. Validate it at the boundary where the number comes from.

> Fair. Now the backoff — how long does it actually wait?

Start at `base_delay` seconds before the first retry, then double after each failed attempt: 1, 2, 4, 8, 16… until it hits `max_delay`, and it stops growing there. That cap applies to the underlying delay, which matters for the next question you're about to ask.

> Which is?

The jitter. Every wait gets multiplied by a random factor in `[0.5, 1.5)`. So if the underlying delay is sitting at the cap — say `max_delay=30` — an individual sleep can be anywhere from 15 to just under 45 seconds. The cap bounds the *growth*, not any single sleep.

> That seems like a bug. Why would you let it exceed the cap?

It's deliberate. Jitter exists to break up thundering herds. If your upstream has a blip and two hundred workers all back off on the same schedule, they retry in lockstep and hammer it again the instant it comes back. Randomizing the waits spreads them out. Making the jitter strictly one-sided would bias every delay downward, which is the wrong direction when the thing you're protecting is already struggling.

The practical consequence is for your timeouts, though. If you're budgeting worst-case latency for a request, compute it with `max_delay * 1.5`, not `max_delay`. I've seen an outer timeout tuned to the nominal numbers fire spuriously because of exactly this.

> Does it sleep after the last attempt too?

No — and that's the right call. There's no delay after the final attempt, because there's nothing left to wait for. If it did sleep there, every exhausted retry would burn an extra `max_delay`-ish chunk of wall clock before telling you it failed.

> What comes back if everything fails?

You get the exception from the final attempt. Not the first one, not an aggregate — the last. Worth knowing when you're reading a traceback: the error you're staring at is attempt N's, and attempts 1 through N-1 might have failed differently. If the distinction matters for debugging, log inside `fn`.

> And `retry_on` — that's just which exceptions it catches?

Which ones it *retries* on. A type or a tuple of types. Anything not in that tuple propagates immediately, straight through, no delay, no further attempts.

That asymmetry is the whole point of the parameter, and it's where I'd spend your thinking time. Retrying is only correct for transient failures. A connection reset, a 503, a timeout — sure, try again. A 401, a validation error, a malformed request — retrying that is pure waste: you'll fail four more times, slowly, and report the same error you already had.

> So keep `retry_on` narrow.

Narrow and specific. The failure mode I'd warn you about is passing something broad like `Exception` "to be safe." That turns a permanent bug into a slow permanent bug, and it swallows things you actively want to fail fast — like a `KeyboardInterrupt` subclass or a programming error in `fn` itself. Name the exceptions you actually mean.

> Anything else I should watch for on my first use?

Two things. First: only retry operations that are safe to repeat. `retry` will happily call your function five times, and if `fn` charges a card or appends a row, you've now done it five times. Idempotent reads are the easy case; writes need an idempotency key or a dedupe check on the server side.

Second: put the retry at the right layer. If `fn` itself contains a retry loop, and you wrap it in another, the attempt counts multiply — three inside times five outside is fifteen calls and a very long worst case. Pick one layer to own the retrying, and let the others fail fast.

> That's the part I would have gotten wrong. Thanks.

The nesting one bites almost everybody once. It's fine — just check what your HTTP client is already doing before you add a layer on top. A lot of them retry by default.
</conversation>
```
