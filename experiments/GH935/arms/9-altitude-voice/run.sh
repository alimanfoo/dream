#!/usr/bin/env bash
# Arm 9: arm 8, with a step that says who does what.
#
# Arm 8's steps only move things. This one adds a step that rewrites, so it
# carries the risk arm 8 was free of, and the two arms differ by that step
# alone.
#
# The step sits before the given-new step rather than after it. Saying who
# does a thing decides what the subject of a sentence is, and the given-new
# step arranges a sentence around its subject, so voice has to settle first or
# the last step is arranging what the next one will move.
#
#   ./run.sh <fixture> <replicate>
ARM=9
PERMISSION_MODE=acceptEdits   # the steps are edits to a scratch file outside the repo
source "$(dirname "$0")/../common.sh"
cp "$(need 1)" "$WORK/passage.md"
fill "$ARMS/9-altitude-voice/prompt.md" '{{PATH}}' <(printf '%s' "$WORK/passage.md") > "$WORK/prompt.md"
gen_edit "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output "$WORK/passage.md"
