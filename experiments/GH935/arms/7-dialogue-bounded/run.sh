#!/usr/bin/env bash
# Arm 7: arm 1's text, passed through a conversation and set out again.
#
# Two calls. The first holds the conversation. The second sees that
# conversation and nothing else, so the passage has to be built from what was
# said rather than copied from the text it came from. A single call, with the
# original still in front of it, reproduced the original verbatim.
#
#   ./run.sh <fixture> <replicate>
ARM=7
source "$(dirname "$0")/../common.sh"

fill "$ARMS/7-dialogue-bounded/prompt-1.md" '{{TEXT}}' "$(need 1)" > "$WORK/prompt-1.md"
gen "$WORK/prompt-1.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" conversation

sed -n '/<conversation>/,/<\/conversation>/p' "$(run_dir)/conversation.md" \
  | sed '1d;$d' > "$WORK/conversation.md"
[ -s "$WORK/conversation.md" ] || { echo "no conversation in the first answer" >&2; exit 1; }

fill "$ARMS/7-dialogue-bounded/prompt-2.md" '{{CONVERSATION}}' "$WORK/conversation.md" > "$WORK/prompt-2.md"
gen "$WORK/prompt-2.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$(run_dir)" output
