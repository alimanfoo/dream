Combine two dicts of settings, so that a key in `overlay` wins over the same key in `base`.

When a key holds a dict on both sides, the two dicts merge as well, and the merge goes on down through every level of nesting. Any other pair of values doesn't merge. The overlay value replaces the base value whole, and that includes a list, so a list in the overlay won't extend the list that it replaces.

Neither input changes. The result is a new dict, but only the top level is new: a nested value that comes through unmerged is the same object that `base` or `overlay` holds. If you change one of those nested values in place afterwards, you will change it in the input dict too. If you need the result to stand on its own, copy it deeply.

The merge recurses once per level of nesting, so a dict nested thousands of levels deep will hit Python's recursion limit.
