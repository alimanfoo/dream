Combines two nested dictionaries into a new one, with `overlay` winning wherever the two disagree.

Neither input is modified, but the result is not a deep copy. Wherever a value comes through untouched — a list, or a nested dict that only one of the inputs has — the result holds the very same object its source does, so mutating the result in place can become visible through `base` or `overlay`. Copy explicitly if the result will be mutated.

The merge descends only where *both* sides hold a `dict`. Everything else is replaced whole rather than combined: lists are not concatenated, sets are not unioned, and a scalar in `overlay` silently replaces an entire nested subtree in `base` — or the reverse — instead of raising on the type mismatch. Nor is there a sentinel meaning "delete": every key present in `overlay` is applied as given, so an explicit `None` overwrites a real value with `None`, and the only way to drop a key is to leave it out of `overlay` altogether.

"Both sides hold a dict" means `isinstance(..., dict)`. Subclasses of `dict` such as `OrderedDict` and `defaultdict` therefore do recurse, but they come back as plain `dict`s, losing whatever the subclass contributed — a default factory, for instance. Mappings that are not `dict` subclasses never recurse at all; they are treated as opaque values.

Keys come out in `base`'s order, with keys unique to `overlay` appended in theirs.

Because the descent is recursive, nesting depth is bounded by the interpreter's recursion limit, and a structure containing a reference cycle will not terminate.
