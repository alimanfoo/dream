Three findings survive:

- **"Between attempts, sleep for a delay that starts at ``base_delay`` seconds and doubles each time, up to ``max_delay``. Each sleep is multiplied by a random factor between 0.5 and 1.5, so that several callers retrying at once don't all come back at the same moment."** — breaks *one idea per paragraph*: it mixes how the delay grows and caps with why it's also randomized, and the first sentence doesn't signal the second idea is coming.

- **"Each sleep is multiplied by a random factor between 0.5 and 1.5"** — breaks *use active voice*: passive construction drops the actor doing the multiplying.

- **"sleep for a delay that starts at ``base_delay`` seconds and doubles each time, up to ``max_delay``"** — breaks *one reading per sentence*: "up to ``max_delay``" could cap the delay's value or the number of doublings, and only the Args section resolves it.
