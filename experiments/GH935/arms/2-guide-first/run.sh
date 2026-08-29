#!/usr/bin/env bash
# Arm 2: the Plain English guide, then the seed prompt.
#
#   ./run.sh <fixture> <replicate>
ARM=2
source "$(dirname "$0")/../common.sh"
fill "$ARMS/2-guide-first/prompt.md" \
  '{{GUIDE}}' "$GUIDE" \
  '{{SEED}}' "$(seed_prompt)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
