The function combines two nested mappings into a new `dict`, and where both mappings hold the same key, `overlay` wins. It recurses only where both sides hold a `dict` at that key; everywhere else, the overlay's value replaces the base's outright.

Replacement means the function never combines the two values. It does not concatenate lists or union sets, so an overlay list of one element beats a base list of ten. An overlay `None` is not a signal to leave the base entry alone either: it is a real value, and the function writes it over whatever the base holds. Nothing the caller can put in the overlay expresses deletion. And where the two sides disagree about type — a `dict` in the base, a scalar in the overlay, or the reverse — the function discards the whole subtree rather than merging part of it.

Recursion therefore turns on what the function counts as a `dict`, and it counts only genuine `dict` instances. A `Mapping` that isn't a `dict` subclass — `OrderedDict`'s cousins from other libraries among them — is not a `dict` to the function, which treats it as an opaque value and replaces it wholesale.

The recursion has no other bound. The function recurses as deep as the inputs nest, and a self-referential input sends it into a recursion that never ends.

The function modifies neither argument, but it copies shallowly: every value it does not merge as a `dict` is the same object in the result as in its source. If the caller mutates a nested list or a custom object afterwards, the change shows through both. A caller whose inputs outlive the call should treat the result as read-only, or deep-copy it.
