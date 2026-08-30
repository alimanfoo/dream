Findings:

- "Two values are merged only when both are dictionaries. Any other pairing — including a dict in `base` against a scalar in `overlay`, or vice versa — is resolved by taking the `overlay` value wholesale. Lists are values, not containers: they are replaced, never concatenated or merged element-wise. There is no way to express a deletion; an `overlay` value of `None` sets the key to `None` rather than removing it." — one idea per paragraph: this paragraph runs together three separate ideas (scalar/dict resolution, list behavior, and the lack of deletion) instead of stating one idea in its opening sentence.

- "There is no way to express a deletion" — active voice: opens with "There is", the construction the guide singles out as the worst case for hiding who does what.

- "Merging is done with `isinstance` checks against `dict`" — active voice: passive "is done" drops the actor, leaving unclear what performs the check.

- "Mapping types that do not subclass `dict` are treated as opaque values and replaced." — active voice: passive "are treated ... and replaced" never names what does the treating or replacing.

- "copy explicitly if you need isolation" — giving instructions: the condition trails the imperative, so a reader who doesn't need isolation has to read past the instruction before learning it doesn't apply to them.

- "Recursively combines two nested dictionaries" — small vocabulary: "combines" here versus "merged" used throughout the rest of the passage names the same operation with two different words.
