Confirmed findings:

**Write as if speaking**
- "Both inputs are left unmodified, but the result is not a deep copy: any value not itself merged — a list, a nested dict present in only one input — is shared by reference with its source, so mutating the result in place can be visible through `base` or `overlay`." — this stacks a colon clause, an em-dash parenthetical, and a trailing "so" consequence into one unit no one would say aloud in one breath, rather than being built the way it would come out in speech.

**Introduce before you point**
- "the result is not a deep copy" — "the result" is used as an already-known entity, but nothing earlier names the function's output as "the result".

**One idea per paragraph**
- The paragraph beginning "Recursion happens only where *both* sides hold a `dict`." through "...leaving it out of `overlay` entirely." — covers two separate ideas (wholesale replacement of non-dict types, and how deletion/`None` is handled) instead of one.
- The paragraph beginning "Merging is decided by `isinstance(..., dict)`..." through "...appended in their own order." — covers two separate ideas (isinstance-based subclass handling, and key ordering) instead of one.

**Use active voice**
- "There is no sentinel for deletion" — opens with "There is", the exact construction the guide names as starting a sentence without naming anyone.
- "Any other type is replaced wholesale, never combined" — passive voice, leaves out what replaces the type.
- "lists are not concatenated, sets are not unioned" — both clauses passive, never name what would do the concatenating/unioning.
- "every key present in `overlay` is applied" — passive voice omits what applies the key.
- "non-dict mappings are treated as opaque values" — passive voice omits what treats them as opaque.
- "Merging is decided by `isinstance(..., dict)`" — passive, matching the guide's own rejected example ("the file is read by the parser") even with the actor named.
- "is shared by reference with its source" — passive voice never names what shares the value by reference.
- "Nesting depth is bounded by the interpreter's recursion limit" — passive construction naming the actor, matching the guide's rejected pattern.

**Use verbs, not noun forms**
- "Recursion happens only where *both* sides hold a `dict`." — "Recursion" is a noun form of "recur" propped up by the empty verb "happens".

**Giving instructions**
- "Copy explicitly if the result will be mutated." — the condition follows the imperative instead of preceding it.
