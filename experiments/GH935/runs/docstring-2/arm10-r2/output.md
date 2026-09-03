Merges two nested dictionaries and returns the result. Where the same key appears in both, the value from `overlay` wins; keys that appear only in `base` survive, at every level of nesting. The merge is therefore an additive update to `base`, not a replacement of it.

The function recurses only where both sides hold dictionaries. Any other pairing — a dict in `base` against a scalar in `overlay`, or a scalar against a dict — is settled by taking the `overlay` value whole. Lists count as values here rather than containers, so an overlay list replaces a base list outright; nothing is concatenated or merged element by element. Nor can an overlay ask for a key to be removed: an overlay value of `None` sets the key to `None` rather than deleting it.

Neither input is modified, but the result is not a deep copy either. Wherever `overlay` leaves a subtree of `base` untouched, the result simply points at that subtree, and values taken from `overlay` are inserted by reference too. Mutating the returned structure in place can therefore be observed through either input, and mutating either input can be observed through the result. Copy explicitly if you need isolation.

What counts as a dictionary is decided by an `isinstance` check against `dict`. Subclasses such as `OrderedDict` and `defaultdict` pass that check and so are merged, but they come back as plain dicts, losing their type and any behavior that came with it. Mapping types that do not subclass `dict` fail the check and are treated as opaque values, replaced rather than merged.

The recursion runs as deep as the inputs are nested. A very deeply nested structure can exhaust the interpreter's recursion limit, and a self-referential dictionary will not terminate at all.
