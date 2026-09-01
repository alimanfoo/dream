What it does is combine two nested dictionaries, with `overlay` winning wherever the two disagree: you pass your defaults in as `base`, the user's overrides as `overlay`, and you get the combination back. Neither input is touched.

The first trap is assuming that makes the result yours to do what you like with. The inputs are unmodified, yes, but the result is not a deep copy. Anything that wasn't itself merged — a list, or a nested dict that existed on only one side — comes back shared by reference with whichever input it came from, so mutating the result in place can show up through `base` or `overlay`. If the result is going to be mutated, copy it explicitly first.

The rule to memorise about "nested" is that recursion happens only where *both* sides hold a `dict`. Everything else is replaced wholesale, never combined. Lists are not concatenated, sets are not unioned; the overlay's value simply takes the base's place. Mismatched types don't bother it and won't raise: a scalar in `overlay` silently replaces a whole nested subtree in `base`, and equally a scalar in `base` gets replaced by a subtree from `overlay`. There's no type-mismatch error to catch — the substitution just happens quietly.

There's also no sentinel for deletion. Every key present in `overlay` gets applied, full stop, so writing an explicit `None` to clear something out doesn't clear it — it overwrites a real value with `None`. The only way to drop a key is to leave it out of `overlay` altogether.

`OrderedDict` and `defaultdict` will recurse, since the decision is made with `isinstance(..., dict)` and those are subclasses, but what comes back is a plain `dict` — the subclass behaviour is lost, so a `defaultdict`'s default factory is gone after the merge. Worth knowing if downstream code leans on it. Mappings that aren't `dict` subclasses at all are treated as opaque values: no recursion into them, replaced wholesale like a list or a scalar.

Key order follows `base`, with keys unique to `overlay` appended in their own order.

Two limits beyond that. Nesting depth is bounded by the interpreter's recursion limit, so pathologically deep structures will blow the stack; and structures containing reference cycles won't terminate, it'll just keep going. Don't feed it anything self-referential.
