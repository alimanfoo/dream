Combine two nested dictionaries, with `overlay` taking precedence over `base`.

The merge recurses only where *both* sides hold a `dict`. Anywhere else it replaces one value with the other outright. It never concatenates lists or unions sets, and a scalar in `overlay` silently overwrites an entire nested subtree in `base` — or the reverse — rather than raising a type error.

The merge decides what counts as a `dict` with `isinstance(..., dict)`. That test lets `dict` subclasses (`OrderedDict`, `defaultdict`) recurse, but they come back as plain `dict`, losing subclass behaviour such as a default factory. It treats non-dict mappings as opaque values.

The merge applies every key present in `overlay`, whatever its value. Nothing in `overlay` can therefore signal a deletion: an explicit `None` overwrites a real value with `None`, and a key disappears only if you leave it out of `overlay` entirely.

Key order follows `base`, and keys unique to `overlay` follow in their own order.

The merge leaves both inputs unmodified, but its result is not a deep copy. The result holds every value the merge did not build itself — a list, a nested dict present in only one input — as a reference to the original in `base` or `overlay`. Mutating one of those values in place therefore changes what the inputs see too. If you plan to mutate the result, copy it explicitly first.

Nesting depth runs up against the interpreter's recursion limit, and the merge never terminates on a structure containing a reference cycle.
