Confirmed findings:

1. **Strict narrative order** — "The error from the last attempt, if every attempt raised one of the types in retry_on." The result comes before the condition it depends on, so the reader has to hold "the error from the last attempt" with nothing to attach it to until the condition arrives.

2. **Giving instructions** (condition before verb) — "Call fn, and retry it if it raises one of the errors in retry_on." The condition governing the retry should come before the instruction, not after it.

3. **Use a small vocabulary** — "retry it if it raises one of the errors in retry_on" calls the members of `retry_on` "errors," while the Args entry calls them "exception types" and the Raises entry calls them "the types in retry_on" — three different words for the same thing.

4. **Use a small vocabulary** — "That factor applies after the cap, so any one sleep can run to 1.5 times max_delay." "The cap" is a new name for the bound already described as "up to max_delay," forcing the reader to work out that they're the same thing.
