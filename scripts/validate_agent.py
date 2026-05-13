#!/usr/bin/env python3
"""Validate the YAML frontmatter of a Claude Code agent file.

Agent frontmatter is documented at
https://code.claude.com/docs/en/sub-agents — required keys are `name` and
`description`; optional keys are `model`, `tools`, `disallowedTools`, and
`color`. This script enforces the documented shape and checks that the
agent name matches the filename stem.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

ALLOWED_PROPERTIES = {
    "name",
    "description",
    "model",
    "tools",
    "disallowedTools",
    "color",
}
ALLOWED_MODELS = {"opus", "sonnet", "haiku", "inherit"}


def validate_agent(agent_md: Path) -> tuple[bool, str]:
    if not agent_md.exists():
        return False, f"{agent_md}: file not found"

    content = agent_md.read_text()
    if not content.startswith("---"):
        return False, f"{agent_md}: no YAML frontmatter"

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, f"{agent_md}: invalid frontmatter format"

    try:
        frontmatter = yaml.safe_load(match.group(1))
    except yaml.YAMLError as e:
        return False, f"{agent_md}: invalid YAML in frontmatter: {e}"

    if not isinstance(frontmatter, dict):
        return False, f"{agent_md}: frontmatter must be a YAML dictionary"

    unexpected = set(frontmatter) - ALLOWED_PROPERTIES
    if unexpected:
        return False, (
            f"{agent_md}: unexpected key(s) in frontmatter: "
            f"{', '.join(sorted(unexpected))}. "
            f"Allowed: {', '.join(sorted(ALLOWED_PROPERTIES))}"
        )

    if "name" not in frontmatter:
        return False, f"{agent_md}: missing 'name' in frontmatter"
    if "description" not in frontmatter:
        return False, f"{agent_md}: missing 'description' in frontmatter"

    name = frontmatter["name"]
    if not isinstance(name, str) or not name.strip():
        return False, f"{agent_md}: name must be a non-empty string"
    if name != agent_md.stem:
        return False, (
            f"{agent_md}: name '{name}' must match filename stem "
            f"'{agent_md.stem}'"
        )

    description = frontmatter["description"]
    if not isinstance(description, str) or not description.strip():
        return False, f"{agent_md}: description must be a non-empty string"

    model = frontmatter.get("model")
    if model is not None and model not in ALLOWED_MODELS:
        return False, (
            f"{agent_md}: model '{model}' not in allowed set "
            f"{sorted(ALLOWED_MODELS)}"
        )

    for key in ("tools", "disallowedTools"):
        value = frontmatter.get(key)
        if value is not None and not isinstance(value, str):
            return False, (
                f"{agent_md}: {key} must be a comma-separated string"
            )

    return True, f"{agent_md}: ok"


def main() -> int:
    if len(sys.argv) < 2:
        print(
            "Usage: validate_agent.py <agent.md> [<agent.md> ...]",
            file=sys.stderr,
        )
        return 2
    failed = False
    for arg in sys.argv[1:]:
        ok, message = validate_agent(Path(arg))
        print(message)
        if not ok:
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
