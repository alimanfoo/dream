Combine two nested dictionaries, with `overlay` taking precedence over `base`.

The function recurses only where *both* sides hold a `dict`. Anywhere else it replaces the value in `base` with the value in `overlay` wholesale, never combining the two: it does not concatenate lists or union sets, and it lets a scalar in `overlay` silently replace an entire nested subtree in `base` (and vice versa) rather than raising on the type mismatch.

The function applies every key present in `overlay`. It recognises no sentinel for deletion, so an explicit `None` overwrites a real value with `None`, and the only way to drop a key is to leave it out of `overlay` entirely.

The function decides what to merge with `isinstance(..., dict)`. It therefore recurses into `dict` subclasses such as `OrderedDict` and `defaultdict`, but rebuilds them as plain `dict`, dropping subclass behaviour such as a default factory. The same test makes any mapping that is not a `dict` opaque, so the function replaces it wholesale.

The result keeps the key order of `base`, and keys unique to `overlay` follow in their own order.

The function modifies neither input, but the result it returns is not a deep copy: values the function did not itself merge — a list, a nested dict present in only one input — stay shared by reference with the input they came from, so mutating the result in place can show through `base` or `overlay`. If you will mutate the result, copy it explicitly.

The function can nest only as deeply as the interpreter's recursion limit allows, and on structures containing reference cycles it will not terminate at all.
