<conversation>
> I've been handed this merge helper to use in the config loader. What does it actually do?

Combines two nested mappings into a new dict, with `overlay` taking precedence.

> Right, but "takes precedence" at what granularity? Whole top-level keys, or does it go deeper?

Keys are merged recursively only where both sides hold a `dict`; in every other case the overlay's value replaces the base's outright.

> So if I've got a list of default plugins in the base and I add one in the overlay, do I end up with both?

No. That means lists are not concatenated and sets are not unioned — an overlay list of one element wins over a base list of ten — and an overlay value of `None` is a real value that overwrites, not a signal to leave the base entry alone.

> Can I use `None` to knock a key out entirely, then?

No. There is no way to express deletion.

> What if the shapes disagree — base has a nested section where the overlay just has a string?

If the base has a `dict` at some key and the overlay has a scalar there (or vice versa), the whole subtree is discarded rather than partially merged.

> Is it safe to keep using the two inputs after I call it? I don't want the base config mutated under me.

Neither argument is modified, but the copying is shallow: any value not itself merged as a `dict` is the same object in the result as in its source, so mutating a nested list or a custom object afterwards is visible through both.

> That sounds like a good way to get a bug I'd never find. What's the rule of thumb?

Treat the result as read-only, or deep-copy it, if the inputs outlive the call.

> One more — we've got some config objects that are `Mapping`s but not plain dicts. Do those merge?

Only genuine `dict` instances trigger recursion — `Mapping` implementations that aren't `dict` subclasses, including `OrderedDict`'s cousins from other libraries, are treated as opaque values and replaced wholesale.

> Any limits on how deep it'll go?

Recursion depth follows the nesting depth of the inputs, and self-referential structures will not terminate.
</conversation>

<passage>
Combines two nested mappings into a new dict, with `overlay` taking precedence. Keys are merged recursively only where both sides hold a `dict`; in every other case the overlay's value replaces the base's outright. That means lists are not concatenated and sets are not unioned — an overlay list of one element wins over a base list of ten — and an overlay value of `None` is a real value that overwrites, not a signal to leave the base entry alone. There is no way to express deletion. If the base has a `dict` at some key and the overlay has a scalar there (or vice versa), the whole subtree is discarded rather than partially merged.

Neither argument is modified, but the copying is shallow: any value not itself merged as a `dict` is the same object in the result as in its source, so mutating a nested list or a custom object afterwards is visible through both. Treat the result as read-only, or deep-copy it, if the inputs outlive the call. Only genuine `dict` instances trigger recursion — `Mapping` implementations that aren't `dict` subclasses, including `OrderedDict`'s cousins from other libraries, are treated as opaque values and replaced wholesale. Recursion depth follows the nesting depth of the inputs, and self-referential structures will not terminate.
</passage>
