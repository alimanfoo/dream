#!/usr/bin/env bash
# Arm 7: arm 1's text, rewritten as a conversation, bounded to what it says.
#
#   ./run.sh <fixture> <replicate>
ARM=7
source "$(dirname "$0")/../common.sh"
fill "$ARMS/7-dialogue-bounded/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
