#!/usr/bin/env bash
# Arm A: arm 1's text, rewritten as a conversation between an experienced
# colleague and a new one.
#
#   ./run.sh <fixture> <replicate>
source "$(dirname "$0")/../common.sh"
fill "$ARMS/A-dialogue/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$RUNS/armA-r$REP"
