#!/usr/bin/env bash
# Arm 10: arm 1's text, reconstructed from the story underneath it.
#
# One call. It works out what the passage is about, reduces that to a spine of
# concrete statements, and writes the passage again from the spine, so the
# result comes from the meaning rather than from the sentences that carried it.
#
# The original stays in the prompt while the passage is written again, which is
# what made arm 7 reproduce its input word for word until its second call was
# given the conversation and nothing else. So check a run against arm 1 before
# reading anything into it.
#
#   ./run.sh <fixture> <replicate>
ARM=10
source "$(dirname "$0")/../common.sh"
fill "$ARMS/10-story-spine/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
