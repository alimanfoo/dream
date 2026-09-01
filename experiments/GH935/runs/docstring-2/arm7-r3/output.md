It takes two nested mappings and combines them into a new dict, with the overlay taking precedence. The key thing to understand is that it only recurses where both sides hold a `dict`; anywhere else, the overlay's value replaces the base's outright. So if your base has a list of ten defaults and the overlay has a list with one element, you get the one-element list. Lists are not concatenated, sets are not unioned. That trips up nearly everyone the first time — if you want the ten plus the one, you have to build that list yourself before you hand it over.

Nor can you use the overlay to blank something out. `None` is a real value there, and it overwrites; there's no special-casing of it as "leave the base entry alone." And you can't delete a key from the base at all — there is no way to express deletion with this function.

When the shapes don't line up — base has a nested dict at a key, overlay has a plain string there — the whole subtree is discarded rather than partially merged. It's the same in the other direction: overlay dict, base scalar, and the overlay just wins wholesale. Recursion only happens when both sides are dicts.

Neither argument is modified, so you won't surprise a caller that way. But the part worth internalizing is that the copying is shallow. Any value that wasn't itself merged as a `dict` is the *same object* in the result as it is in its source, so if you mutate a nested list afterwards you'll see that change through both — the result and the source share it. Either treat the result as read-only or deep-copy it; that matters especially if the inputs outlive the call.

Be careful with the `Mapping` types we pass around that aren't plain dicts, too. Only genuine `dict` instances trigger recursion. `Mapping` implementations that aren't `dict` subclasses — including `OrderedDict`'s cousins from other libraries — are treated as opaque values and replaced wholesale.

As for limits: recursion depth follows the nesting depth of the inputs, and be aware that self-referential structures will not terminate.
