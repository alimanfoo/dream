#!/usr/bin/env python3
"""Flag invisible characters that break rendering or hide in source.

These code points are visually indistinguishable from a normal space or
from nothing at all, yet they change how Markdown and tooling parse a
file. A non-breaking space after a closing code fence, for instance,
stops the fence from closing and swallows every heading after it. Such
characters are almost never intended in this repo's text, so flag them.

Visible non-ASCII (en dashes, smart quotes, accented letters) is left
alone — only the invisible offenders below are reported.
"""

from __future__ import annotations

import sys
from pathlib import Path

# Code point -> human-readable name. Kept to characters with no legitimate
# use in this repo's text: zero-width marks, non-breaking spaces, bidi
# controls, and the byte-order mark. Keyed by integer code point so this
# file holds no literal invisibles and does not trip its own check.
DISALLOWED = {
    0x00A0: "no-break space (U+00A0)",
    0x200B: "zero-width space (U+200B)",
    0x200C: "zero-width non-joiner (U+200C)",
    0x200D: "zero-width joiner (U+200D)",
    0x2028: "line separator (U+2028)",
    0x2029: "paragraph separator (U+2029)",
    0x202A: "left-to-right embedding (U+202A)",
    0x202B: "right-to-left embedding (U+202B)",
    0x202C: "pop directional formatting (U+202C)",
    0x202D: "left-to-right override (U+202D)",
    0x202E: "right-to-left override (U+202E)",
    0x2060: "word joiner (U+2060)",
    0xFEFF: "byte-order mark / zero-width no-break space (U+FEFF)",
}


def check_file(path: Path) -> list[str]:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as err:
        # A file we cannot decode is the likeliest place for a stray byte to
        # hide, so flag it rather than report it clean. Point at the offending
        # byte, since line and column mean nothing in a file we could not read.
        return [
            f"{path}: not valid UTF-8 at byte {err.start}, "
            "cannot scan for invisible characters"
        ]
    except OSError:
        return [f"{path}: could not be read"]

    # Split on "\n" only. str.splitlines() also breaks on U+2028 and U+2029
    # (among others) and drops them, hiding those two from this scan.
    findings = []
    for lineno, line in enumerate(text.split("\n"), start=1):
        for col, char in enumerate(line, start=1):
            name = DISALLOWED.get(ord(char))
            if name:
                findings.append(f"{path}:{lineno}:{col}: {name}")
    return findings


def main() -> int:
    if len(sys.argv) < 2:
        print(
            "Usage: check_invisible_chars.py <file> [<file> ...]",
            file=sys.stderr,
        )
        return 2
    findings = []
    for arg in sys.argv[1:]:
        findings.extend(check_file(Path(arg)))
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
