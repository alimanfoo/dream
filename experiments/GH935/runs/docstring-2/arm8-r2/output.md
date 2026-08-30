Recursively combines two nested dictionaries, `base` and `overlay`, with `overlay` taking precedence. Keys present only in `base` are preserved at every level, so this is an additive update rather than a replacement.

Two values are merged only when both are dictionaries. Any other pairing — including a dict in `base` against a scalar in `overlay`, or vice versa — is resolved by taking the `overlay` value wholesale.

Lists are values, not containers: they are replaced, never concatenated or merged element-wise.

Whether two values count as dictionaries is decided by `isinstance` checks against `dict`, so dict subclasses such as `OrderedDict` or `defaultdict` are merged but come back as plain dicts, losing their type and any associated behavior. Mapping types that do not subclass `dict` are treated as opaque values and replaced.

The `overlay` has no way to express a deletion: a value of `None` sets the key to `None` rather than removing it.

Neither input is modified, but the result is not a deep copy. Subtrees that `overlay` does not touch are shared by reference with `base`, and values taken from `overlay` are likewise inserted by reference. Mutating the returned structure in place can therefore be observed through either input, and vice versa. Copy explicitly if you need isolation.

Recursion depth follows the nesting depth of the inputs. Very deeply nested structures can therefore exhaust the interpreter's recursion limit, and self-referential dictionaries will not terminate.
