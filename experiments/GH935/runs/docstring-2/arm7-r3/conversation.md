<conversation>
> Hey, I was told to use the deep merge helper for our config layering. What does it actually do?

It takes two nested mappings and combines them into a new dict, with the overlay taking precedence. The key thing to understand is that it only recurses where both sides hold a `dict`. Anywhere else, the overlay's value replaces the base's outright.

> "Outright" meaning what, exactly? If my base has a list of ten defaults and the overlay has a list with one element in it...

Then you get the one-element list. Lists are not concatenated, sets are not unioned. That trips up nearly everyone the first time. If you want the ten plus the one, you have to build that list yourself before you hand it over.

> What if I want to explicitly blank out a value in the overlay? Can I set it to `None` and have it fall through to the base?

No — `None` is a real value there, and it overwrites. There's no special-casing of it as "leave the base entry alone."

> So how do I delete a key from the base?

You can't. There is no way to express deletion with this function.

> Okay. What about when the shapes don't line up — base has a nested dict at a key, overlay has a plain string there?

Then the whole subtree is discarded rather than partially merged. Same in the other direction: overlay dict, base scalar — the overlay just wins wholesale. Recursion only happens when both sides are dicts.

> Does it mutate what I pass in? I'd rather not surprise a caller.

Neither argument is modified. But — and this is the part worth internalizing — the copying is shallow. Any value that wasn't itself merged as a `dict` is the *same object* in the result as it is in its source.

> Meaning if I mutate a nested list afterwards...

You'll see that change through both. The result and the source share it. So either treat the result as read-only, or deep-copy it — that matters especially if the inputs outlive the call.

> We pass around a few `Mapping` types that aren't plain dicts. Are those handled?

Only genuine `dict` instances trigger recursion. `Mapping` implementations that aren't `dict` subclasses — including `OrderedDict`'s cousins from other libraries — are treated as opaque values and replaced wholesale.

> Any limits on how deep it'll go?

Recursion depth follows the nesting depth of the inputs. And be aware: self-referential structures will not terminate.
</conversation>
