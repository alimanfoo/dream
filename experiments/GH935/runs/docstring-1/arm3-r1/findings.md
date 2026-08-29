Confirmed findings from the copy edit:

- "the call is retried after a delay" — passive with the actor dropped entirely; the reader never learns what retries the call.
- "Each wait is jittered by a random factor in [0.5, 1.5)" — passive naming the actor via "by X," the exact construction the guide rejects ("the file is read by the parser").
- "while the growth of the underlying delay is capped" — passive with the actor (what caps it) left out.
- "No delay is applied after the final attempt." — passive with no actor at all.
- "Anything not in `retry_on` is re-raised from the attempt that produced it." — passive; "is re-raised" never says what does the re-raising.
- "The exception from the final attempt, if every attempt failed with a retryable error." — the outcome comes before the condition that governs it, forcing the reader to hold the conclusion before learning whether it applies.
- "an individual sleep can exceed `max_delay`" — "sleep" is a synonym for "wait," used one sentence after "Each wait is jittered," for the same thing.
- "Note that a non-positive `attempts` never calls `fn` and raises `TypeError` instead." — "Note that" is a filler opener adding nothing the following clause doesn't already say.
