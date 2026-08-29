#!/usr/bin/env bash
# Arm 6: arm 1's text, rewritten as a conversation between an experienced
# colleague and a new one.
#
#   ./run.sh <fixture> <replicate>
ARM=6
source "$(dirname "$0")/../common.sh"
fill "$ARMS/6-dialogue/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$RUNS/arm6-r$REP"
