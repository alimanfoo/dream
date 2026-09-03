Given two nested mappings, this returns a new dict in which `overlay` wins. Wherever both the base and the overlay hold a `dict` at the same key, those two dicts are merged recursively; everywhere else, the overlay's value simply replaces the base's.

That single rule explains everything else. Lists are not concatenated and sets are not unioned, so an overlay list of one element beats a base list of ten. `None` in the overlay is an ordinary value like any other: it overwrites the base entry rather than signalling that the base should be left alone. Nothing expresses deletion. And if the two sides disagree about a key's type — a `dict` in the base, a scalar in the overlay, or the reverse — the whole subtree on the losing side is discarded rather than partially merged.

Recursion also depends on what counts as a `dict`, and only genuine `dict` instances do. A `Mapping` implementation that is not a `dict` subclass — a third-party ordered or frozen mapping, say — is treated as an opaque value and replaced wholesale, however dict-like it appears.

Neither argument is modified, but the copying is shallow. Any value that isn't itself merged as a `dict` appears in the result as the very same object it is in its source, so mutating a nested list or a custom object afterwards shows up through both. If the inputs outlive the call, treat the result as read-only or deep-copy it.

Two limits follow from the recursion itself: it descends as deep as the inputs nest, and it will not terminate on self-referential structures.
