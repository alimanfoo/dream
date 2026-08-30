Confirmed findings:

- **"Keys are merged recursively only where both sides hold a `dict`"** — Use active voice: passive with no actor named for who merges the keys.
- **"the whole subtree is discarded rather than partially merged"** — Use active voice: passive with no actor named for who discards the subtree.
- **"Neither argument is modified"** — Use active voice: passive with no actor named for who doesn't modify the arguments.
- **"are treated as opaque values and replaced wholesale"** — Use active voice: passive with no actor named for who treats and replaces the values.
- **"There is no way to express deletion."** — Use active voice: the guide specifically calls out "there is" as a construction that starts a sentence without naming anyone.
- **"Combines two nested mappings into a new dict"** — Use a small vocabulary: names the operation "combine" here but "merge"/"merged" everywhere else, swapping a synonym for the same meaning.
- **"Only genuine `dict` instances trigger recursion — `Mapping` implementations that aren't `dict` subclasses, including `OrderedDict`'s cousins from other libraries, are treated as opaque values and replaced wholesale."** — One idea per paragraph: this pivots to a new idea (which types trigger recursion) inside a paragraph that opened on shallow-copy/aliasing and then pivots again to recursion depth and termination.
- **"OrderedDict's cousins from other libraries"** — Write to communicate: "cousins" is a clever metaphor rather than a plain description.
