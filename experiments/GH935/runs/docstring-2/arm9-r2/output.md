Recursively combines two nested dictionaries, with `overlay` taking precedence. It preserves keys present only in `base` at every level, so it updates `base` additively rather than replacing it.

It merges two values only when both are dictionaries. For any other pairing — including a dict in `base` against a scalar in `overlay`, or vice versa — it takes the `overlay` value wholesale.

To decide whether a value counts as a dictionary, it uses `isinstance` checks against `dict`. Dict subclasses such as `OrderedDict` or `defaultdict` therefore pass the check and merge, but they come back as plain dicts, losing their type and any associated behavior. Mapping types that do not subclass `dict` fail the check, so it treats them as opaque values and replaces them.

Lists count as values, not containers: it replaces them outright and never concatenates them or merges them element-wise.

An `overlay` cannot express a deletion: a value of `None` sets its key to `None` rather than removing it.

It modifies neither input; instead it builds and returns a new dictionary.

That new dictionary is not a deep copy. The result holds every subtree that `overlay` does not touch as a reference into `base`, and it holds values from `overlay` as references too. Mutating the result in place can therefore show through either input, and mutating either input can show in the result. Copy explicitly if you need isolation.

Recursion depth follows the nesting depth of the inputs; very deeply nested structures can exhaust the interpreter's recursion limit, and self-referential dictionaries will not terminate.
