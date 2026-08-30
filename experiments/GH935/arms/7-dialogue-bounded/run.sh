#!/usr/bin/env bash
# Arm 7: arm 1's text, passed through a conversation and set out again.
#
# The conversation and the passage come from one call, in that order, so the
# passage is written inside the register the conversation has already
# established. full.md keeps both; output.md is the passage alone, which is
# what the other arms produce and so what can be compared with them.
#
#   ./run.sh <fixture> <replicate>
ARM=7
source "$(dirname "$0")/../common.sh"
fill "$ARMS/7-dialogue-bounded/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt.md"
gen "$WORK/prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" full
sed -n '/<passage>/,/<\/passage>/p' "$(run_dir)/full.md" \
  | sed '1d;$d' > "$(run_dir)/output.md"
[ -s "$(run_dir)/output.md" ] || { echo "no passage in the answer" >&2; exit 1; }
echo "wrote $(run_dir)/output.md ($(wc -c < "$(run_dir)/output.md") bytes)"
