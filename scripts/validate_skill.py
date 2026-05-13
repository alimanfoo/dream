#!/usr/bin/env python3
"""Validate the YAML frontmatter of a SKILL.md file.

Schema sourced from the Claude Code skill frontmatter reference at
https://code.claude.com/docs/en/skills.md (refreshed 2026-05-13). Refresh
the allowed-key list when the docs add or remove fields.

Initially adapted from `quick_validate.py` in the upstream `skill-creator`
skill (claude-plugins-official marketplace).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

ALLOWED_PROPERTIES = {
    "name",
    "description",
    "when_to_use",
    "argument-hint",
    "arguments",
    "disable-model-invocation",
    "user-invocable",
    "allowed-tools",
    "model",
    "effort",
    "context",
    "agent",
    "hooks",
    "paths",
    "shell",
}

DESCRIPTION_CAP = 1536  # combined description + when_to_use cap per docs


def validate_skill(skill_md: Path) -> tuple[bool, str]:
    if not skill_md.exists():
        return False, f"{skill_md}: file not found"

    content = skill_md.read_text()
    if not content.startswith("---"):
        return False, f"{skill_md}: no YAML frontmatter"

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, f"{skill_md}: invalid frontmatter format"

    try:
        frontmatter = yaml.safe_load(match.group(1))
    except yaml.YAMLError as e:
        return False, f"{skill_md}: invalid YAML in frontmatter: {e}"

    if not isinstance(frontmatter, dict):
        return False, f"{skill_md}: frontmatter must be a YAML dictionary"

    unexpected = set(frontmatter) - ALLOWED_PROPERTIES
    if unexpected:
        return False, (
            f"{skill_md}: unexpected key(s) in frontmatter: "
            f"{', '.join(sorted(unexpected))}. "
            f"Allowed: {', '.join(sorted(ALLOWED_PROPERTIES))}"
        )

    # `name` is optional per docs — falls back to directory name. Validate
    # only when present.
    name = frontmatter.get("name")
    if name is not None:
        if not isinstance(name, str):
            return False, (
                f"{skill_md}: name must be a string, got {type(name).__name__}"
            )
        name = name.strip()
        if not re.match(r"^[a-z0-9-]+$", name):
            return False, (
                f"{skill_md}: name '{name}' must be kebab-case "
                f"(lowercase letters, digits, hyphens)"
            )
        if name.startswith("-") or name.endswith("-") or "--" in name:
            return False, (
                f"{skill_md}: name '{name}' cannot start/end with hyphen "
                f"or contain consecutive hyphens"
            )
        if len(name) > 64:
            return False, (
                f"{skill_md}: name too long ({len(name)} chars, max 64)"
            )

    description = frontmatter.get("description")
    if description is not None and not isinstance(description, str):
        return False, (
            f"{skill_md}: description must be a string, "
            f"got {type(description).__name__}"
        )

    when_to_use = frontmatter.get("when_to_use")
    if when_to_use is not None and not isinstance(when_to_use, str):
        return False, (
            f"{skill_md}: when_to_use must be a string, "
            f"got {type(when_to_use).__name__}"
        )

    combined = len(description or "") + len(when_to_use or "")
    if combined > DESCRIPTION_CAP:
        return False, (
            f"{skill_md}: combined description + when_to_use too long "
            f"({combined} chars, max {DESCRIPTION_CAP})"
        )

    return True, f"{skill_md}: ok"


def main() -> int:
    if len(sys.argv) < 2:
        print(
            "Usage: validate_skill.py <SKILL.md> [<SKILL.md> ...]",
            file=sys.stderr,
        )
        return 2
    failed = False
    for arg in sys.argv[1:]:
        ok, message = validate_skill(Path(arg))
        print(message)
        if not ok:
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
