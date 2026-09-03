Recursively merges two nested dictionaries, giving `overlay` precedence. Keys that appear only in `base` survive at every level, so the merge adds to `base` rather than replacing it.

The merge recurses into a pair of values only when both of them are dictionaries. For any other pairing — a dictionary in `base` against a scalar in `overlay`, or a scalar against a dictionary — it takes the `overlay` value wholesale.

Values that are not dictionaries include lists. A list in `base` therefore gives way whole to the list in `overlay`; the merge never concatenates the two or merges them element by element.

The merge decides what counts as a dictionary with an `isinstance` check against `dict`. Subclasses such as `OrderedDict` and `defaultdict` pass that check, so the merge recurses into them — and then returns them as plain dicts, losing their type and any behavior that went with it.

Mappings that do not subclass `dict` fail the same check. The merge treats them as ordinary values and replaces them.

The `overlay` value always wins, but it can only set a key, never remove one. An `overlay` value of `None` therefore sets the key to `None`, and the merge offers no way to express a deletion.

The merge modifies neither input, but the result it returns is not a deep copy. That result points at the same objects as its inputs: the subtrees `overlay` never touches come straight from `base`, and the values `overlay` does supply come straight from `overlay`. Sharing objects that way makes mutation visible in both directions — code that mutates the result in place can see the change through either input, and code that mutates an input can see it through the result. If you need isolation, copy the result explicitly.

Because the merge recurses, its stack depth follows the nesting depth of the inputs. Deeply nested inputs can therefore exhaust the interpreter's recursion limit.

The recursion has no bottom to reach in a self-referential dictionary, so the merge never terminates on one.
