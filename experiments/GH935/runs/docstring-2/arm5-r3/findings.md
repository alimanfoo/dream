Confirmed findings:

- **Write as if speaking** — "Only the dictionaries that get merged are copied, though, so every other value in the result is the same object that came from `base` or `overlay`." Stacking "though, so" isn't how this contrast-then-consequence would come out in speech.

- **Introduce before you point** — "Copy the result yourself if the caller might do that." "The caller" is referred to with "the" without ever being introduced as an entity.

- **One idea per paragraph** — "The function recurses once for each level of nesting, so a dictionary that is nested thousands of levels deep will hit Python's recursion limit. It also assumes that `overlay` is a mapping with an `items()` method, and it never looks at any key of `base` that `overlay` doesn't set." This bundles three separate implementation notes — recursion depth, the mapping/`items()` assumption, and never inspecting unset base keys.

- **Use active voice** — "there is no way to say \"delete this key\"" — the "there is" construction the guide names as the worse case of actor-dropping.

- **Use active voice** — "the dictionary and everything under it is dropped" — passive, no actor named.

- **Use active voice** — "Only the dictionaries that get merged are copied" — passive, no actor named.

- **Giving instructions** — "Copy the result yourself if the caller might do that." The condition should come before the imperative, per the guide's "If the file is read-only, skip it" pattern.

- **Use a small vocabulary** — "Neither `base` nor `overlay` is modified" alongside "you mutate it in the input too" and "Copy the result yourself if the caller might do that" — "modified" and "mutate" name the same action with two different words.

- **Say how many you mean** — "a key you leave out of `overlay` keeps its value from `base`" — reads as one unspecified key rather than "any key," the same ambiguity as the guide's "A user can delete a record" example.
