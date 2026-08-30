Merges two nested mappings into a new dict, with `overlay` taking precedence. The function merges keys recursively only where both sides hold a `dict`; in every other case the overlay's value replaces the base's outright. That means the function doesn't concatenate lists and doesn't union sets — an overlay list of one element wins over a base list of ten — and an overlay value of `None` is a real value that overwrites, not a signal to leave the base entry alone. You cannot express deletion. If the base has a `dict` at some key and the overlay has a scalar there, or the other way round, the function discards the whole subtree rather than merging part of it.

The function leaves both arguments unchanged, but it copies shallowly: any value it doesn't merge as a `dict` is the same object in the result as in its source, so mutating a nested list or a custom object afterwards is visible through both. Treat the result as read-only, or deep-copy it, if the inputs outlive the call.

Only genuine `dict` instances trigger recursion. The function treats `Mapping` implementations that aren't `dict` subclasses as opaque values and replaces them wholesale, including mapping types from other libraries that behave like `OrderedDict`.

Recursion depth follows the nesting depth of the inputs, and self-referential structures will not terminate.
