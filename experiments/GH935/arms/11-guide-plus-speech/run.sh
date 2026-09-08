#!/usr/bin/env bash
# Arm 11: the guide as it stands, with "Write as if speaking" put back, then
# the seed prompt.
#
# Arm 12 reads the same guide without that section. The two differ by it alone,
# so the pair says what #940 cost or saved. #940 took the section out on the
# grounds that given-new ordering covers it, and arm 9 carried the given-new
# step while producing every sentence the reader sent back.
#
#   ./run.sh <fixture> <replicate>
ARM=11
GUIDE_NAME=plain-english-be5d1d38-plus-speech.md
source "$(dirname "$0")/../common.sh"
GUIDE="$E/snapshot/guides/$GUIDE_NAME"
fill "$ARMS/2-guide-first/prompt.md" \
  '{{GUIDE}}' "$GUIDE" \
  '{{SEED}}' "$(seed_prompt)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
