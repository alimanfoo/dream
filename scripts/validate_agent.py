#!/usr/bin/env python3
"""Validate the YAML frontmatter of a Claude Code agent file.

Schema sourced from the subagent frontmatter reference at
https://code.claude.com/docs/en/sub-agents.md (refreshed 2026-05-13).
Refresh the allowed-key list when the docs add or remove fields.

Only `name` and `description` are required per the docs. All other fields
are optional; this validator checks types and structure but does not
enforce value enums for fields whose accepted values may evolve (e.g.
`model`).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

ALLOWED_PROPERTIES = {
    "name",
    "description",
    "tools",
    "disallowedTools",
    "model",
    "permissionMode",
    "maxTurns",
    "skills",
    "mcpServers",
    "hooks",
    "memory",
    "background",
    "effort",
    "isolation",
    "color",
    "initialPrompt",
}


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

    description = frontmatter["description"]
    if not isinstance(description, str) or not description.strip():
        return False, f"{agent_md}: description must be a non-empty string"

    model = frontmatter.get("model")
    if model is not None and (not isinstance(model, str) or not model.strip()):
        return False, f"{agent_md}: model must be a non-empty string"

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
