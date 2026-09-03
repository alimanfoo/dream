#!/usr/bin/env bash
# Arm 9: arm 8, with a step that applies the guide's active voice rule.
#
# Arm 8's steps only move things. This one adds a step that rewrites, so it
# carries the risk arm 8 was free of, and the two arms differ by that step
# alone.
#
# The step sits before the given-new step rather than after it. Voice decides
# what the subject of a sentence is, and the given-new step arranges a sentence
# around its subject, so voice has to settle first or the last step is
# arranging what the next one will move.
#
# The step says "use active voice", the guide's own words, rather than naming
# an actor for every action. An earlier wording, "say who or what does each
# thing", asked for an explicit actor in every sentence and got the same one
# every time. Its runs are in the history at cf9224d.
#
#   ./run.sh <fixture> <replicate>
ARM=9
PERMISSION_MODE=acceptEdits   # the steps are edits to a scratch file outside the repo
source "$(dirname "$0")/../common.sh"
cp "$(need 1)" "$WORK/passage.md"
fill "$ARMS/9-altitude-voice/prompt.md" '{{PATH}}' <(printf '%s' "$WORK/passage.md") > "$WORK/prompt.md"
gen_edit "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output "$WORK/passage.md"
