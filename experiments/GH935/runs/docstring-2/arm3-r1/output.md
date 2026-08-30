Combine two nested dictionaries, with `overlay` taking precedence over `base`. The function returns a new dict as the result, and it leaves both inputs unmodified.

The result is not a deep copy. Wherever the function doesn't merge a value — a list, or a nested dict that only one input holds — the result holds the same object that its source input holds. So if you mutate the result in place, you can see the change through `base` or `overlay`. If you will mutate the result, copy it explicitly first.

The function recurses only where *both* sides hold a `dict`. For any other type it takes the value from `overlay` wholesale. It doesn't concatenate lists, and it doesn't union sets. If `overlay` holds a scalar where `base` holds a whole nested subtree, the function replaces the subtree with the scalar and doesn't raise on the type mismatch, and a subtree in `overlay` replaces a scalar in `base` the same way.

`overlay` has no sentinel that deletes a key. The function applies every key that `overlay` holds, so an explicit `None` overwrites a real value with `None`. To drop a key, leave it out of `overlay` entirely.

The function decides whether to merge with `isinstance(..., dict)`. So it recurses into `dict` subclasses such as `OrderedDict` and `defaultdict`, but it returns them as a plain `dict` that has lost the subclass behaviour, such as a default factory. It treats a mapping that isn't a `dict` as an opaque value.

Key order follows `base`, and the function appends the keys that only `overlay` holds in their own order.

The interpreter's recursion limit bounds the nesting depth that the function can handle, and the function will not terminate on a structure that contains a reference cycle.
