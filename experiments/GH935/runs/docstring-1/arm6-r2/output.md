```
<conversation>
> I keep seeing `retry(...)` wrapped around our network calls. What is it actually doing?

It's the plainest possible thing: it calls `fn`, and if `fn` blows up in a way we've said is retryable, it waits a bit and calls it again. It keeps doing that up to `attempts` times. If one of those calls returns, you get that value back and it stops immediately. If they all fail, you get the exception from the last one.

The whole reason it exists is that a lot of failures out there aren't really failures — they're "not right now." A connection reset, a 503, a rate limit. Calling again a second later often just works.

> Why not just loop and call it again straight away?

Because if the thing you're calling is struggling, hammering it is the worst possible response. That's what the `base_delay` / `max_delay` pair is for. The wait starts at `base_delay`, then doubles after every failed attempt — 1s, 2s, 4s, 8s — until it hits `max_delay` and stops growing.

Two things are happening there. The doubling gives a struggling service room to recover, and it gets you out of the way quickly if the problem is real. The cap stops the doubling from running away — without it, attempt ten is a fifteen-minute nap, and nobody wants that inside a request handler.

> And the jitter? The docstring says every sleep gets multiplied by a random number between 0.5 and 1.5.

That one's not obvious until you've watched it go wrong. Picture a hundred workers all talking to the same service, and the service hiccups. Every worker fails at roughly the same moment. With pure backoff they all sleep exactly one second, and then all hundred retry at exactly the same moment. You've just rebuilt the stampede that knocked the service over, and you'll rebuild it again at t+2, and t+4.

Jitter smears them out. Same average delay, but the retries arrive spread across a window instead of stacked on one instant. The 0.5–1.5 range is centred on 1.0 deliberately — on average you still wait about what the backoff says, you just don't wait *exactly* that.

> Makes sense. What's `retry_on` for — why not retry on everything?

Because most exceptions aren't going to fix themselves, and retrying them just wastes time and hides the bug.

If your request raises `ConnectionError`, sure, try again. If it raises `ValueError` because you built a malformed payload, calling the same broken code five more times gets you five more `ValueError`s and a delay before the traceback you were always going to get. Worse, it makes a deterministic bug look flaky — someone reads the logs, sees "retrying," and assumes it's the network.

So `retry_on` is a deliberate allowlist. Anything not in it propagates on the spot. Keep it tight. Name the specific exception types you actually believe are transient.

> The docstring mentions there's no sleep after the final attempt. Why call that out?

Because it's the thing everyone gets wrong when they hand-roll this.

The naive shape is `for each attempt: try, except: sleep`. On the last time through, it fails, sleeps the full delay, and *then* gives up. You've just added your longest wait to the end of a call that was doomed anyway. With a big `max_delay` that's dead time in a user-facing path for no benefit whatsoever.

Sleeping is something you do *between* attempts, not after them. Worth remembering when you're budgeting timeouts, too — three attempts means two sleeps, not three.

> How do I pick `attempts`?

Depends where you are in the stack. Something interactive with a person waiting? Two or three, with a small `base_delay`. A background job that can afford to be patient? More attempts and a higher cap are fine.

The number I'd actually reason about is the total worst-case time, not the attempt count. Add up the delays and the per-call timeouts and ask whether that's a duration you can live with. Five attempts sounds modest right up until you work out it's forty seconds inside something with a thirty-second timeout in front of it.

Also note `attempts` has to be at least 1, and `attempts=1` means it calls `fn` once and never retries. It's not "one retry."

> If every attempt fails, do I get all the errors or just the last one?

Just the last one. That's usually what you want — it's the freshest information — but be aware you're losing the earlier ones. If the first failure was a DNS error and the last was a timeout, that difference is diagnostically interesting and it's gone.

So log inside the retry loop or inside `fn`, don't rely on the final traceback to tell you the story. Otherwise you'll be looking at one timeout with no idea whether it was a clean run of four identical timeouts or something stranger.

> Anything I should be careful about before wrapping something in it?

The big one: **only retry things that are safe to do twice.**

`retry` can't tell the difference between "the request never arrived" and "the request worked fine but the response got lost on the way back." Both look identical from where it's standing. So if `fn` charges a card or sends an email, a retry may well do it a second time. Reads are almost always fine. Writes need either genuine idempotency or an idempotency key the other end honours.

Two smaller ones. First, `fn` takes no arguments, so you'll be reaching for `functools.partial(do_thing, order_id)` or a lambda — and if you're building those in a loop, remember a lambda closes over the variable, not its value at the time; `partial` binds the value and sidesteps that entirely.

Second, don't nest retries. If a helper retries three times and you wrap it in another three, you've quietly signed up for nine calls and a much longer worst case than anything in your code says. Pick one layer to own the retrying — usually the one closest to the network — and let the layers above it just fail.

> Last thing — is there anything it deliberately doesn't handle?

Yes, and it's worth knowing the shape of the gap. This retries a *single call in isolation*. It has no idea what any other call is doing.

That means it won't stop you retrying into a service that's comprehensively down. Every worker will keep politely backing off and trying again, forever, against something that isn't coming back for ten minutes. The tool for that is a circuit breaker: shared state that notices the failure rate, trips, and fails everything fast for a while without touching the network at all.

The two aren't alternatives, they're layers. Retry handles the blip. The breaker handles the outage. We've got retry everywhere and a breaker on the two or three dependencies where an outage actually hurts — that's the right ratio, I think. Reach for the breaker when you catch yourself wanting a really large `attempts` value. That instinct usually means you're trying to solve an outage with the wrong tool.
</conversation>
```
