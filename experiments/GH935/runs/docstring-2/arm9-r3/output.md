Combines two nested mappings into a new dict, with `overlay` taking precedence. It recurses into a key only where both sides hold a `dict`; everywhere else, the overlay's value replaces the base's outright.

That replacement is total: it never concatenates lists and never unions sets, so an overlay list of one element wins over a base list of ten. An overlay value of `None` overwrites too — it is a real value, not a signal to leave the base entry alone. No overlay can therefore express deletion. And where the base holds a `dict` at some key but the overlay holds a scalar there, or the other way round, the merge discards the whole subtree rather than merging it in part.

The recursion turns on what counts as a `dict`, and only genuine `dict` instances count. A `Mapping` implementation that isn't a `dict` subclass — `OrderedDict`'s cousins from other libraries among them — counts as an opaque value, and the overlay replaces it wholesale.

Recursion depth follows the nesting depth of the inputs, and a self-referential structure never terminates at all.

Neither argument changes, but the copying goes only one level deep: every value the merge does not itself recurse into is the same object in the result as in its source. Mutate a nested list or a custom object afterwards, and both the result and the source show the change. If the inputs outlive the call, treat the result as read-only or deep-copy it.
