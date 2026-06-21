#!/usr/bin/env python3
"""Flag the surface marks WRITING.md bans in Markdown prose.

WRITING.md is the repo's writing standard. It bans dashes, semicolons, and
Latin abbreviations. This check holds the floor for those marks. It does not
judge whether a sentence earns its place or reads plainly. That judgement is
the prose-rewriter agent's job. This check only catches the deterministic
tells, so a banned mark cannot slip back in unnoticed.

The check reads the source text, not the rendered output. It skips the parts
of a Markdown file that are not prose: fenced code blocks, inline code spans,
link targets, and HTML entities. A real em dash in a code example is fine. A
semicolon inside an HTML entity like &amp; is fine. Only banned marks in prose
are reported.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# Banned single characters, keyed by code point so this file holds no literal
# em dash or en dash and does not trip its own rule. A hyphen (U+002D) is fine:
# it joins compound words and marks list items.
BANNED_CHARS = {
    0x2014: "em dash (U+2014). WRITING.md bans dashes.",
    0x2013: "en dash (U+2013). WRITING.md bans dashes.",
    0x003B: "semicolon. WRITING.md bans semicolons.",
}

# Banned phrases. WRITING.md says skip the Latin and spell the words out.
# Matched case-insensitively at a word boundary.
BANNED_PHRASES = {
    "e.g.": 'Latin abbreviation. Write "for example".',
    "i.e.": 'Latin abbreviation. Write "that is".',
    "etc.": 'Latin abbreviation. Name the rest of the list instead.',
}

_INLINE_CODE = re.compile(r"(`+)(.+?)\1")
_INLINE_LINK = re.compile(r"(\]\()([^)]*)(\))")
_AUTOLINK = re.compile(r"(<)([a-z][a-z0-9+.-]*:[^>]*)(>)")
_REF_DEF = re.compile(r"^(\s*\[[^\]]+\]:\s+)(\S+)")
_HTML_ENTITY = re.compile(r"&#?[0-9a-zA-Z]+;")
_FENCE = re.compile(r"^\s*(```+|~~~+)")

# WRITING.md is the standard itself. It must name the banned forms to ban them,
# so it mentions "e.g." and the like on purpose. Exempt the whole file. This is
# the one home for that decision, so do not also exclude it at the hook level.
EXEMPT_NAMES = {"WRITING.md"}


def _mask(match: re.Match, keep_group: int) -> str:
    """Replace a match with spaces, keeping one group's text in place.

    Spaces preserve column positions so a finding reports the right column.
    The kept group is the visible part, such as a link's text.
    """
    text = match.group(0)
    if keep_group == 0:
        return " " * len(text)
    kept = match.group(keep_group)
    start = match.start(keep_group) - match.start(0)
    return " " * start + kept + " " * (len(text) - start - len(kept))


def mask_non_prose(line: str) -> str:
    """Blank out the parts of a line that are not prose.

    Replaces inline code, link targets, autolinks, and HTML entities with
    spaces. Keeps link text, since that is prose. Column positions are
    preserved so findings point at the right place.
    """
    line = _REF_DEF.sub(lambda m: m.group(1) + " " * len(m.group(2)), line)
    line = _INLINE_CODE.sub(lambda m: _mask(m, 0), line)
    line = _INLINE_LINK.sub(lambda m: _mask(m, 0), line)
    line = _AUTOLINK.sub(lambda m: _mask(m, 0), line)
    line = _HTML_ENTITY.sub(lambda m: _mask(m, 0), line)
    return line


def check_file(path: Path) -> list[str]:
    if path.name in EXEMPT_NAMES:
        return []
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return []

    findings = []
    in_fence = False
    fence_marker = ""
    for lineno, raw in enumerate(text.splitlines(), start=1):
        fence = _FENCE.match(raw)
        if fence:
            marker = fence.group(1)[0] * 3
            if not in_fence:
                in_fence, fence_marker = True, marker
            elif marker == fence_marker:
                in_fence, fence_marker = False, ""
            continue
        if in_fence:
            continue

        line = mask_non_prose(raw)
        for col, char in enumerate(line, start=1):
            reason = BANNED_CHARS.get(ord(char))
            if reason:
                findings.append(f"{path}:{lineno}:{col}: {reason}")
        lowered = line.lower()
        for phrase, reason in BANNED_PHRASES.items():
            start = 0
            while (idx := lowered.find(phrase, start)) != -1:
                findings.append(f"{path}:{lineno}:{idx + 1}: {reason}")
                start = idx + 1
    return findings


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: check_prose.py <file> [<file> ...]", file=sys.stderr)
        return 2
    findings = []
    for arg in sys.argv[1:]:
        findings.extend(check_file(Path(arg)))
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
