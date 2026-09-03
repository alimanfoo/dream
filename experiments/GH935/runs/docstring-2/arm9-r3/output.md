Combines a base dict and an overlay dict into a new dict, with the overlay taking precedence. Where both hold a `dict` at the same key, it merges the two recursively; everywhere else, the overlay's value replaces the base's outright.

That replacement is wholesale: it neither concatenates lists nor unions sets, so an overlay list of one element replaces a base list of ten. An overlay `None` is a real value too, and it replaces the base's value rather than signalling that the base should be left alone. Mismatched types replace as well: if the base holds a `dict` at some key and the overlay holds a scalar there, or the reverse, the overlay's value replaces the whole base subtree rather than merging into part of it. An overlay can add or replace values, but it can never remove one.

That recursion reaches only genuine `dict` instances. Any other `Mapping` — `OrderedDict`'s cousins from other libraries, say — it treats as an opaque value and replaces whole.

It modifies neither input, but it copies shallowly: any value it does not merge as a `dict` is the same object in the result as in its input, so a later mutation of a nested list or a custom object shows up through both. If the inputs outlive the call, treat the result as read-only or deep-copy it.

Recursion depth follows the nesting depth of the inputs, and a self-referential input sends it into infinite recursion.
