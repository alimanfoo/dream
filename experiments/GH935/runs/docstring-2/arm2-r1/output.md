Merges `overlay` into `base` and returns a new dictionary. Neither
argument is modified, so it is safe to pass in dictionaries that
other code still holds.

Where a key holds a dictionary in both `base` and `overlay`, the two
dictionaries are merged, and the same rule applies at every level
below. For any other key, the value from `overlay` replaces the value
from `base`. That includes the case where one side holds a dictionary
and the other does not, so a plain value in `overlay` will drop a whole
dictionary from `base`. It also includes lists, which are replaced
rather than joined, and `None`, which counts as a value and overwrites
whatever `base` had.

A key that appears only in `base` keeps its value, and a key that
appears only in `overlay` is added.

The result is not a deep copy. Any value that was not merged is the
same object that `base` or `overlay` holds, so if you mutate a list or
a dictionary inside the result, the change shows up in the input as
well. Copy the result deeply first if you need to change it in place.
