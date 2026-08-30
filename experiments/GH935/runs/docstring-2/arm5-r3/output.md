Combines two nested dictionaries into a new one, where a value from `overlay` wins over the value under the same key in `base`.

Two dictionaries under the same key merge, so a key that only `base` sets survives in the result. Anything else replaces outright. A list in `overlay` replaces the list in `base` rather than extending it, and you can't say "delete this key" — any key you leave out of `overlay` keeps its value from `base`. If `base` holds a dictionary under a key and `overlay` holds something else, the function drops the dictionary and everything under it.

The function doesn't change `base` or `overlay`. It copies only the dictionaries that it merges, so every other value in the result is the same object that came from `base` or `overlay`. If you change a list or a custom object in the result, you change it in the input too. If you might change one of those values, copy the result first.

The function recurses once for each level of nesting, so a dictionary that is nested thousands of levels deep will hit Python's recursion limit.

It also assumes that `overlay` is a mapping with an `items()` method.

It never looks at any key of `base` that `overlay` doesn't set.
