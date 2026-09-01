This function recursively combines two nested dictionaries, a `base` and an `overlay`, into a new dictionary; where the two disagree, `overlay` wins.

The function merges two values only when both of them are dictionaries. For every other pairing — a dict in `base` against a scalar in `overlay`, or the reverse, or two scalars — it takes the `overlay` value wholesale.

Keys that appear only in `base` never meet an `overlay` value at all, and the function carries them through to the result at every level. A call is therefore an additive update rather than a replacement.

Lists count as values here, not as containers. The function replaces a `base` list with an `overlay` list wholesale, and it never concatenates the two or merges them element-wise.

An `overlay` value of `None` is likewise just a value: the function sets the key to `None` rather than removing it. The caller therefore has no way to express a deletion.

The function makes that test for a dictionary with an `isinstance` check against `dict`. Dict subclasses such as `OrderedDict` or `defaultdict` pass it and get merged, but the function builds the result out of plain dicts, so they come back stripped of their type and of any behavior that came with it. Mapping types that do not subclass `dict` fail it, and the function replaces them as opaque values.

The function modifies neither input, but the dictionary it returns is not a deep copy either. It shares the subtrees that `overlay` never touches with `base` by reference, and it inserts the values it takes from `overlay` by reference too. Code that mutates the returned structure in place can therefore change what either input holds, and code that mutates either input can change the result. If you need isolation, copy explicitly.

The function recurses as deeply as the inputs nest, and nothing bounds that depth. A deeply nested pair of dictionaries can therefore exhaust the interpreter's recursion limit, and a self-referential dictionary keeps the function recursing until it does.
