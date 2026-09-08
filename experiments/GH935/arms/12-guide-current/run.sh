#!/usr/bin/env bash
# Arm 12: the guide as it stands, then the seed prompt.
#
# Against arm 2 this says what the three removals came to together, and against
# arm 1 it says whether the guide beats no guide at all.
#
#   ./run.sh <fixture> <replicate>
ARM=12
GUIDE_NAME=plain-english-be5d1d38.md
source "$(dirname "$0")/../common.sh"
GUIDE="$E/snapshot/guides/$GUIDE_NAME"
fill "$ARMS/2-guide-first/prompt.md" \
  '{{GUIDE}}' "$GUIDE" \
  '{{SEED}}' "$(seed_prompt)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
