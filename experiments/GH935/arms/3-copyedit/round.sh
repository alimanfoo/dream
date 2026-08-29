# One copy-edit round. Arms 4 and 5 source this too.
#
# The editor finds and the author applies. The editor never edits, and the
# author never sees the rule-by-rule record. That separation is the mechanism
# under test, so it survives the flattening into bare prompts.
#
# copyedit_round <input-text-file> <run-dir>
copyedit_round() {
  local input=$1 dir=$2
  sed '1{/^---$/!q};1,/^---$/d' "$E/snapshot/copy-editor.md" > "$WORK/editor-instructions.md"
  fill "$ARMS/3-copyedit/editor.md" \
    '{{COPY_EDITOR_INSTRUCTIONS}}' "$WORK/editor-instructions.md" \
    '{{GUIDE}}' "$GUIDE" \
    '{{TEXT}}' "$input" \
    '{{READER}}' "$READER" > "$WORK/editor-prompt.md"
  gen "$WORK/editor-prompt.md" "$EDITOR_MODEL" "$EDITOR_EFFORT" "$dir" findings

  fill "$ARMS/3-copyedit/author.md" \
    '{{GUIDE}}' "$GUIDE" \
    '{{TEXT}}' "$input" \
    '{{FINDINGS}}' "$dir/findings.md" > "$WORK/author-prompt.md"
  gen "$WORK/author-prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$dir" output
}
