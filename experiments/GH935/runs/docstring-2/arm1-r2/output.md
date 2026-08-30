Recursively combines two mappings, with `overlay` winning wherever the two disagree, and returns a new dictionary rather than modifying either argument.

The copying is shallow, which is the main thing to be careful about. Only dictionaries that appear on both sides get fresh copies; every other value in the result — lists, sets, custom objects, and whole subtrees present in just one of the inputs — is the same object held by `base` or `overlay`. Mutating one of those in the result mutates it in the original too, so treat the result as read-only unless you deep-copy first.

Merging happens only when both sides hold a `dict` (or a `dict` subclass) at the same key. Any other type is replaced wholesale: a list in `overlay` supersedes a list in `base` instead of extending it, and a scalar or `None` in `overlay` discards whatever structure `base` had there. There is no way to express "delete this key" or "leave this key alone" — a key absent from `overlay` is inherited, and a key present is applied. Mappings that are not `dict` subclasses are treated as opaque values and replaced.

Key order follows `base`, with keys unique to `overlay` appended in their own order. Recursion depth tracks the nesting depth of the shared structure, so deeply nested or self-referential input can exhaust the stack.
