Recursively merges two nested dictionaries, with `overlay` taking precedence. Keys that appear only in `base` survive at every level, so this is an additive update rather than a replacement.

The merge recurses into two values only when both are dictionaries. For any other pairing — including a dict in `base` against a scalar in `overlay`, or a scalar in `base` against a dict in `overlay` — the `overlay` value wins wholesale.

The merge treats lists as values, not as containers. It replaces a list outright, and never concatenates two lists or merges them element by element.

You cannot express a deletion. An `overlay` value of `None` sets the key to `None` rather than removing it.

The merge modifies neither input, but the result is not a deep copy. It shares the subtrees that `overlay` does not touch by reference with `base`, and it inserts values taken from `overlay` by reference too. So if you mutate the returned structure in place, you can see the change through either input, and if you mutate either input, you can see the change in the result. If you need isolation, copy explicitly.

The merge decides what to recurse into with `isinstance` checks against `dict`. It merges dict subclasses such as `OrderedDict` or `defaultdict`, but returns them as plain dicts, so they lose their type and any behavior that comes with it. It treats mapping types that do not subclass `dict` as opaque values, and replaces them.

Recursion depth follows the nesting depth of the inputs. Very deeply nested structures can exhaust the interpreter's recursion limit, and a self-referential dictionary will never let the merge terminate.
