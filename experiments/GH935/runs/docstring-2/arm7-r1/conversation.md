```
<conversation>
> I've been asked to use this merge helper for our config loading. What does it actually do?

It combines two nested dictionaries, with `overlay` taking precedence over `base`. So you pass in your defaults as `base`, the user's overrides as `overlay`, and you get back the combination. Neither input gets modified.

> Great, so I can hand the result off and mutate it however I like?

Careful there — that's the first trap. Both inputs are left unmodified, but the result is *not* a deep copy. Any value that isn't itself merged — a list, say, or a nested dict that only exists in one of the two inputs — is shared by reference with whichever input it came from. So if you mutate the result in place, that change can be visible through `base` or `overlay`. If the result is going to be mutated, copy it explicitly first.

> Understood. And when it says "nested" — how deep does the merging go?

Recursion happens only where *both* sides hold a `dict`. That's the rule to memorise. Any other type is replaced wholesale, never combined.

> Meaning lists get merged element by element?

No — that's exactly what "never combined" rules out. Lists are not concatenated. Sets are not unioned. The overlay's value just replaces the base's value entirely.

> What if the types don't match on the two sides?

It doesn't care, and it won't raise. A scalar in `overlay` silently replaces an entire nested subtree in `base` — and it works the other way round too, a scalar in `base` gets replaced by a subtree from `overlay`. There's no type-mismatch error to catch; it just does the substitution quietly.

> Is there a way to say "remove this key" from the overlay?

There's no sentinel for deletion. Every key present in `overlay` is applied, full stop. So if you write an explicit `None` hoping to clear something out, what you actually get is a real value overwritten with `None`. The only way to drop a key is to leave it out of `overlay` entirely.

> We use `OrderedDict` and `defaultdict` in a couple of places. Do those work?

They'll recurse, because the merge decision is made with `isinstance(..., dict)` and those are `dict` subclasses. But what comes back is a plain `dict` — you lose the subclass behaviour, so a `defaultdict`'s default factory is gone after the merge. Worth knowing if downstream code is relying on it.

> And mappings that aren't dict subclasses at all?

Those are treated as opaque values. No recursion into them — they're replaced wholesale like a list or a scalar would be.

> What order do the keys come out in?

Key order follows `base`, and then keys unique to `overlay` are appended in their own order.

> Anything else that could bite me?

Two limits. Nesting depth is bounded by the interpreter's recursion limit, so pathologically deep structures will blow the stack. And structures containing reference cycles will not terminate — it'll just keep going. Don't feed it anything self-referential.
</conversation>
```
