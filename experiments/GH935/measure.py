#!/usr/bin/env python3
"""Count the prose features the arms are being compared on.

    ./measure.py docstring-2
    ./measure.py docstring-1 docstring-2

A judgement is a reader's, and no count replaces one. These counts exist so
that a claim about a run can be checked against the run rather than taken on
trust, and so that a claim made once stays checkable after the session that
made it has gone.

Every count is a string match rather than a parse, and every one of them is a
lower bound. A passive built on a participle the list below does not name, or
an actor named some other way, goes uncounted. So a difference between two
arms carries weight and an absolute number carries little.

Code blocks never count. An output wrapped in a single fence is the docstring
itself rather than an example, so the wrapper comes off first. The Args,
Returns and Raises template never counts either, since it is the fixture's
structure rather than the writer's prose, and it carried most of the
repetition on docstring-1 before docstring-2 dropped it.
"""
import pathlib
import re
import sys

# The actor these fixtures are about is the function being documented, so
# naming it is what the drumbeat sounds like.
ACTOR = re.compile(r"\b(?:this|the)\s+(?:\w+\s+)?function\b", re.I)
SECOND_PERSON = re.compile(r"\byou(?:r|rs)?\b", re.I)

BE = r"(?:is|are|was|were|be|been|being|gets?|got)"
# A word that introduces a noun cannot begin a participle, so "is a nested
# dict" stays out of the passive count.
DET = (
    r"(?:a|an|the|its|their|your|our|my|his|her|this|that|these|those"
    r"|any|some|no|each|every|both|either|neither)"
)
# Participles a suffix does not catch. The list is common irregulars, not a
# complete one, which is why the count is a lower bound.
IRREGULAR = (
    r"(?:left|made|given|taken|kept|held|set|put|built|done|seen|known"
    r"|found|lost|sent|meant|read|cut|split|brought|thrown|shown|drawn"
    r"|chosen|hidden|broken|driven|written|dealt|meant|bound|sold|told)"
)
PARTICIPLE = rf"(?:\w+(?:ed|en)|{IRREGULAR})"
# A be-verb, then a participle within two words, and no "by" after it. So
# "is replaced" counts and "is replaced by the overlay" does not, since that
# one says who does it.
PASSIVE = re.compile(
    rf"\b{BE}\b(?:\s+(?!{DET}\b)\w+){{0,2}}?\s+{PARTICIPLE}\b(?!\s+by\b)", re.I
)

FENCE = re.compile(r"^\s*```")
TEMPLATE = re.compile(r"^\s*(?:Args|Arguments|Returns|Raises|Yields):\s*$")


def unwrap(lines):
    """Drop a fence that wraps the whole output rather than an example."""
    body = [i for i, line in enumerate(lines) if line.strip()]
    if body and FENCE.match(lines[body[0]]) and FENCE.match(lines[body[-1]]):
        return lines[body[0] + 1 : body[-1]]
    return lines


def prose(text):
    """The writer's own sentences: no code blocks, no docstring template."""
    kept, in_code = [], False
    for line in unwrap(text.splitlines()):
        if FENCE.match(line):
            in_code = not in_code
        elif TEMPLATE.match(line):
            break
        elif not in_code:
            kept.append(line)
    return "\n".join(kept)


def measure(path):
    text = prose(path.read_text())
    return {
        "words": len(text.split()),
        "actor": len(ACTOR.findall(text)),
        "you": len(SECOND_PERSON.findall(text)),
        "passive": len(PASSIVE.findall(text)),
    }


def main(fixtures):
    root = pathlib.Path(__file__).parent / "runs"
    for fixture in fixtures:
        runs = sorted(
            (root / fixture).glob("arm*/output.md"),
            key=lambda p: [int(n) for n in re.findall(r"\d+", p.parent.name)],
        )
        if not runs:
            sys.exit(f"no runs under runs/{fixture}")
        print(f"\n## {fixture}\n")
        print("| run | words | actor named | you | agentless passive |")
        print("| --- | ---: | ---: | ---: | ---: |")
        for path in runs:
            m = measure(path)
            print(
                f"| {path.parent.name} | {m['words']} | {m['actor']} "
                f"| {m['you']} | {m['passive']} |"
            )


if __name__ == "__main__":
    main(sys.argv[1:] or ["docstring-2"])
