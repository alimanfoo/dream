# Tests and checks

Determine the tests, checks, build steps, and tooling built around the product
to produce, verify, and maintain it.

Find the project's test command. Look in the README, `AGENTS.md`, `CLAUDE.md`, a
Makefile, or `pyproject.toml`/`package.json` scripts. Run it yourself before
every commit. A commit hook rarely runs the test suite.

Find any codegen a commit hook doesn't run. Examples: a stub generator, an
OpenAPI client refresh, an index sync. Run it after an edit that needs it. This
makes the generated files match the source before you commit.
