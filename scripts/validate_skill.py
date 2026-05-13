#!/usr/bin/env python3
"""Validate the YAML frontmatter of a SKILL.md file.

Adapted from `quick_validate.py` in the upstream `skill-creator` skill
(claude-plugins-official marketplace). Vendored here so the repo can lint
its own skills without depending on the user's local plugin install.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

ALLOWED_PROPERTIES = {
    "name",
    "description",
    "license",
    "allowed-tools",
    "metadata",
    "compatibility",
}


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

    if "name" not in frontmatter:
        return False, f"{skill_md}: missing 'name' in frontmatter"
    if "description" not in frontmatter:
        return False, f"{skill_md}: missing 'description' in frontmatter"

    name = frontmatter["name"]
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
        return False, f"{skill_md}: name too long ({len(name)} chars, max 64)"

    description = frontmatter["description"]
    if not isinstance(description, str):
        return False, (
            f"{skill_md}: description must be a string, "
            f"got {type(description).__name__}"
        )
    description = description.strip()
    if "<" in description or ">" in description:
        return False, f"{skill_md}: description cannot contain angle brackets"
    if len(description) > 1024:
        return False, (
            f"{skill_md}: description too long "
            f"({len(description)} chars, max 1024)"
        )

    compatibility = frontmatter.get("compatibility")
    if compatibility is not None:
        if not isinstance(compatibility, str):
            return False, f"{skill_md}: compatibility must be a string"
        if len(compatibility) > 500:
            return False, (
                f"{skill_md}: compatibility too long "
                f"({len(compatibility)} chars, max 500)"
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
