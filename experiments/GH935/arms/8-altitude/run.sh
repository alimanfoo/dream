#!/usr/bin/env bash
# Arm 8: arm 1's text, worked down from paragraphs to clauses.
#
# One agent, four steps, writing the passage back to a file after each. The
# file makes each step an act rather than a thought, and the events record
# whether all four happened.
#
#   ./run.sh <fixture> <replicate>
ARM=8
PERMISSION_MODE=acceptEdits   # the steps are edits to a scratch file outside the repo
source "$(dirname "$0")/../common.sh"
cp "$(need 1)" "$WORK/passage.md"
fill "$ARMS/8-altitude/prompt.md" '{{PATH}}' <(printf '%s' "$WORK/passage.md") > "$WORK/prompt.md"
gen_edit "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output "$WORK/passage.md"
