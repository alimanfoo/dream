```
<conversation>
> I've been handed the config merge helper to look after. What does it actually do?

Recursively combines two nested dictionaries, with `overlay` taking precedence. Keys present only in `base` are preserved at every level, so this is an additive update rather than a replacement.

> So when does it actually recurse rather than just overwrite?

Two values are merged only when both are dictionaries. Any other pairing — including a dict in `base` against a scalar in `overlay`, or vice versa — is resolved by taking the `overlay` value wholesale.

> What about lists? I half expected a list in the overlay to be appended to the base one.

Lists are values, not containers: they are replaced, never concatenated or merged element-wise.

> Can I use it to drop a key I don't want anymore?

There is no way to express a deletion; an `overlay` value of `None` sets the key to `None` rather than removing it.

> Is it safe to pass in dictionaries I'm still using elsewhere?

Neither input is modified, but the result is not a deep copy. Subtrees that `overlay` does not touch are shared by reference with `base`, and values taken from `overlay` are likewise inserted by reference.

> That sounds like it could bite me.

Mutating the returned structure in place can therefore be observed through either input, and vice versa; copy explicitly if you need isolation.

> We pass an `OrderedDict` in one place. Does that survive?

Merging is done with `isinstance` checks against `dict`, so dict subclasses such as `OrderedDict` or `defaultdict` are merged but come back as plain dicts, losing their type and any associated behavior.

> And things that behave like mappings but aren't `dict` subclasses?

Mapping types that do not subclass `dict` are treated as opaque values and replaced.

> Any limits on how deep the structures can go?

Recursion depth follows the nesting depth of the inputs; very deeply nested structures can exhaust the interpreter's recursion limit, and self-referential dictionaries will not terminate.
</conversation>
```

```
<passage>
Recursively combines two nested dictionaries, with `overlay` taking precedence. Keys present only in `base` are preserved at every level, so this is an additive update rather than a replacement.

Two values are merged only when both are dictionaries. Any other pairing — including a dict in `base` against a scalar in `overlay`, or vice versa — is resolved by taking the `overlay` value wholesale. Lists are values, not containers: they are replaced, never concatenated or merged element-wise. There is no way to express a deletion; an `overlay` value of `None` sets the key to `None` rather than removing it.

Neither input is modified, but the result is not a deep copy. Subtrees that `overlay` does not touch are shared by reference with `base`, and values taken from `overlay` are likewise inserted by reference. Mutating the returned structure in place can therefore be observed through either input, and vice versa; copy explicitly if you need isolation.

Merging is done with `isinstance` checks against `dict`, so dict subclasses such as `OrderedDict` or `defaultdict` are merged but come back as plain dicts, losing their type and any associated behavior. Mapping types that do not subclass `dict` are treated as opaque values and replaced.

Recursion depth follows the nesting depth of the inputs; very deeply nested structures can exhaust the interpreter's recursion limit, and self-referential dictionaries will not terminate.
</passage>
```
