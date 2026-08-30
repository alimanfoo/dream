Combines two nested mappings into a new dict, with `overlay` taking precedence. Keys are merged recursively only where both sides hold a `dict`; in every other case the overlay's value replaces the base's outright.

Because that replacement is wholesale, lists are not concatenated and sets are not unioned — an overlay list of one element wins over a base list of ten. An overlay value of `None` is a real value that overwrites, not a signal to leave the base entry alone. Nothing in the overlay, therefore, can express deletion. If the base holds a `dict` at some key and the overlay holds a scalar there (or vice versa), the whole subtree is discarded rather than partially merged.

Recursion is triggered only by genuine `dict` instances. `Mapping` implementations that aren't `dict` subclasses, including `OrderedDict`'s cousins from other libraries, are treated as opaque values and replaced wholesale.

Recursion also goes as deep as the inputs nest, so a structure that refers to itself will not terminate.

Neither argument is modified, but the copying is shallow: any value not itself merged as a `dict` is the same object in the result as in its source. Mutating a nested list or a custom object afterwards is therefore visible through both. If the inputs outlive the call, treat the result as read-only or deep-copy it.
