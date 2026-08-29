Confirmed findings:

1. **Write as if speaking** — "Between attempts the caller sleeps for ``delay * (0.5 + random())`` -- i.e. a uniformly jittered 50%-150% of the current delay -- and ``delay`` is then doubled, starting at ``base_delay`` and capped at ``max_delay``." This packs a formula, an em-dash aside, and two trailing modifiers into one clause no one would say aloud.

2. **Introduce before you point** — "the caller" (in "Between attempts the caller sleeps for...") is referred to with "the" as if already known, but no caller has been introduced anywhere earlier.

3. **One idea per paragraph** — "No sleep happens after the final attempt." This is a separate idea (a termination boundary) tacked onto a paragraph whose opening sentence is about sleep duration and delay progression.

4. **Use active voice** — four passive/actor-less spans:
   - "it is called again after a delay" — doesn't say who calls it
   - "``delay`` is then doubled, starting at ``base_delay`` and capped at ``max_delay``" — "doubled" and "capped" have no actor
   - "Any non-retryable exception is re-raised as soon as it occurs." — doesn't say who re-raises it
   - "since no attempt is made and there is no error to re-raise" — "is made" is passive, and "there is" is the exact existential construction the rule calls out

5. **One reading per sentence** — "``delay`` is then doubled, starting at ``base_delay`` and capped at ``max_delay``." "Starting at ... and capped at ..." can read as modifying either the doubling operation or delay's value.

6. **Use a small vocabulary** — two synonym swaps:
   - "``fn`` is invoked with no arguments" mixes with "call"/"called" used for the same action elsewhere ("Call fn repeatedly", "it is called again", "successful call to fn")
   - "if every attempt failed with a retryable error" uses "error" where "exception" is used everywhere else, including the Raises heading itself

7. **Use verbs, not noun forms** — two spans:
   - "that trigger a retry" — noun form "a retry" propped up by the empty verb "trigger"
   - "No sleep happens after the final attempt." — noun form "sleep" propped up by the empty verb "happens"

8. **Skip the Latin** — "i.e. a uniformly jittered 50%-150% of the current delay" — the guide names "i.e." as the harder case to skip, since it stands for several different phrases.
