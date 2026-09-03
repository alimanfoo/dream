Merge two nested `dict`s, with `overlay` taking precedence over `base`.

The merge recurses only where *both* inputs hold a `dict`. It replaces any other value wholesale rather than merging it: it does not concatenate lists or union sets, and a scalar in `overlay` silently replaces an entire nested `dict` in `base` (and vice versa) instead of raising on the type mismatch.

The merge decides where to recurse with `isinstance(..., dict)`. That test admits `dict` subclasses such as `OrderedDict` and `defaultdict`, which recurse but come back as plain `dict`s, losing subclass behaviour such as a default factory; it rejects non-`dict` mappings, which the merge treats as ordinary values.

The merge applies every key present in `overlay`, so it offers no sentinel for deletion. An explicit `None` therefore overwrites a real value instead of deleting it, and dropping a key from the result requires leaving it out of `overlay` entirely.

Key order follows `base`, and the merge appends keys unique to `overlay` in their own order.

The merge leaves both inputs unmodified, but it does not deep-copy the result: any value it does not itself merge — a list, a `dict` present in only one input — stays shared with its source by reference, so mutating the result in place can show through `base` or `overlay`. If you will mutate the result, copy it explicitly.

Deep nesting can hit the interpreter's recursion limit, and an input containing a reference cycle makes the merge run forever.
