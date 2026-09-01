`deep_merge` recursively combines two nested dictionaries, with `overlay` taking precedence. The important part is that keys present only in `base` are preserved at every level — so it's an additive update, not a replacement. You're layering changes on top, not swapping a subtree out.

It only merges where both sides are dictionaries. That's the rule to remember: two values are merged only when both are dicts. Any other pairing gets resolved by taking the `overlay` value wholesale — including a dict in `base` against a scalar in `overlay`, or a scalar in `base` against a dict in `overlay`. Lists are values, not containers. They get replaced — never concatenated, never merged element-wise. If your overlay has a one-element list where base had five, you end up with the one element.

There's no way to express a deletion. An `overlay` value of `None` sets the key to `None` — it doesn't remove it. You'll still have the key, just pointing at `None`.

Neither input is modified. But — and this is the bit that catches people — the result is not a deep copy. Subtrees that `overlay` doesn't touch are shared by reference with `base`, and values taken from `overlay` are inserted by reference too. So if you mutate the returned structure in place, that mutation can be observed through either input. And the reverse holds as well — mutate an input and you may see it in the result. If you need isolation, copy explicitly.

`OrderedDict`s and the like will merge, but they won't survive. The merging is done with `isinstance` checks against `dict`, so dict subclasses like `OrderedDict` or `defaultdict` get merged but come back as plain dicts. You lose the type and any behavior that went with it. Mapping types that aren't dict subclasses at all are treated as opaque values and just replaced — no recursion into them.

As for limits, recursion depth follows the nesting depth of the inputs, so very deeply nested structures can exhaust the interpreter's recursion limit. And self-referential dictionaries won't terminate at all — don't hand it a structure that points back into itself.
