Combine two nested dictionaries, with `overlay` taking precedence over `base`. Both inputs are left unmodified, but the result is not a deep copy: any value not itself merged — a list, a nested dict present in only one input — is shared by reference with its source, so mutating the result in place can be visible through `base` or `overlay`. Copy explicitly if the result will be mutated.

Recursion happens only where *both* sides hold a `dict`. Any other type is replaced wholesale, never combined: lists are not concatenated, sets are not unioned, and a scalar in `overlay` silently replaces an entire nested subtree in `base` (and vice versa) rather than raising on the type mismatch. There is no sentinel for deletion — every key present in `overlay` is applied, so an explicit `None` overwrites a real value with `None`, and a key can only be dropped by leaving it out of `overlay` entirely.

Merging is decided by `isinstance(..., dict)`, so `dict` subclasses (`OrderedDict`, `defaultdict`) recurse but come back as plain `dict`, losing subclass behaviour such as a default factory; non-dict mappings are treated as opaque values. Key order follows `base`, with keys unique to `overlay` appended in their own order.

Nesting depth is bounded by the interpreter's recursion limit, and structures containing reference cycles will not terminate.
