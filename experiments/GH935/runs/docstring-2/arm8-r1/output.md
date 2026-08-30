Combine two nested dictionaries, with `overlay` taking precedence over `base`.

Recursion happens only where *both* sides hold a `dict`. Any other pairing is replaced wholesale, never combined: lists are not concatenated, sets are not unioned, and a scalar in `overlay` silently replaces an entire nested subtree in `base` — or the reverse — rather than raising on the type mismatch.

Deletion has no sentinel: every key present in `overlay` is applied. An explicit `None` therefore overwrites a real value with `None`, and a key can be dropped only by leaving it out of `overlay` entirely.

Whether two sides merge is decided by `isinstance(..., dict)`. `dict` subclasses such as `OrderedDict` and `defaultdict` therefore recurse, but they come back as plain `dict`, losing subclass behaviour such as a default factory. Mappings that are not `dict` subclasses are treated as opaque values.

Key order in the result follows `base`, with keys unique to `overlay` appended in their own order.

Both inputs are left unmodified, but the result is not a deep copy: any value not itself merged — a list, or a nested dict present in only one input — is shared by reference with its source, so mutating the result in place can be visible through `base` or `overlay`. If the result will be mutated, copy it explicitly.

Nesting depth is bounded by the interpreter's recursion limit, and structures containing reference cycles will not terminate.
