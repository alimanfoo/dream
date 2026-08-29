#!/usr/bin/env bash
# Run one arm of the GH935 experiment.
#
#   ./run.sh <fixture> <arm> <replicate>
#
# Arms:
#   1  seed prompt, vanilla
#   2  guide first, then seed prompt
#   3  arm 1 output, one copy-edit round
#   4  arm 3 output, a second copy-edit round
#   5  arm 2 output, one copy-edit round   (what dream:smith does today)
#   A  arm 1 output, implementation A
#
# Every arm is a bare `claude -p` call. Nothing resolves a skill or installs a
# plugin, so the arms differ only in the text of the prompt.
set -euo pipefail

FIXTURE=${1:?fixture name, e.g. docstring}
ARM=${2:?arm, one of 1 2 3 4 5 A}
REP=${3:?replicate number}

E=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)                     # outside the repo, so nothing here reaches the model
trap 'rm -rf "$WORK"' EXIT

WRITER_MODEL=opus;   WRITER_EFFORT=high      # the session that writes and edits
EDITOR_MODEL=sonnet; EDITOR_EFFORT=medium    # pinned by copy-editor.md's frontmatter

OUT="$E/runs/$FIXTURE/arm$ARM-r$REP.md"
mkdir -p "$(dirname "$OUT")"

fill() { python3 -c '
import sys
text = open(sys.argv[1]).read()
for i in range(2, len(sys.argv), 2):
    text = text.replace(sys.argv[i], open(sys.argv[i + 1]).read().rstrip())
sys.stdout.write(text)
' "$@"; }

gen() {  # gen <prompt-file> <model> <effort> <output-file>
  ( cd "$WORK" && claude -p --model "$2" --effort "$3" --strict-mcp-config \
      "$(cat "$1")" < /dev/null ) > "$4"
}

GUIDE="$E/snapshot/plain-english.md"
SEED="$E/fixtures/$FIXTURE/seed-prompt.md"
READER="$E/fixtures/$FIXTURE/reader.md"

# The seed prompt carries {{CODE}} where a fixture has a source file.
cp "$SEED" "$WORK/seed.md"
if [ -f "$E/fixtures/$FIXTURE/source" ]; then
  fill "$WORK/seed.md" '{{CODE}}' "$E/fixtures/sources/$(cat "$E/fixtures/$FIXTURE/source")" > "$WORK/seed.filled"
  mv "$WORK/seed.filled" "$WORK/seed.md"
fi

# One copy-edit round: the editor finds, the author applies. The editor never
# edits, and the author never sees the rule-by-rule record. That separation is
# the mechanism, so it survives the flattening into bare prompts.
copyedit() {  # copyedit <input-text-file> <output-file>
  sed '1{/^---$/!q};1,/^---$/d' "$E/snapshot/copy-editor.md" > "$WORK/editor-instructions.md"
  fill "$E/arms/copyedit-editor.md" \
    '{{COPY_EDITOR_INSTRUCTIONS}}' "$WORK/editor-instructions.md" \
    '{{GUIDE}}' "$GUIDE" \
    '{{TEXT}}' "$1" \
    '{{READER}}' "$READER" > "$WORK/editor-prompt.md"
  gen "$WORK/editor-prompt.md" "$EDITOR_MODEL" "$EDITOR_EFFORT" "$WORK/findings.md"
  cp "$WORK/findings.md" "${2%.md}-findings.md"

  fill "$E/arms/copyedit-author.md" \
    '{{GUIDE}}' "$GUIDE" \
    '{{TEXT}}' "$1" \
    '{{FINDINGS}}' "$WORK/findings.md" > "$WORK/author-prompt.md"
  gen "$WORK/author-prompt.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$2"
}

need() {  # the output of an earlier arm this one builds on
  local f="$E/runs/$FIXTURE/arm$1-r$REP.md"
  [ -f "$f" ] || { echo "arm $ARM needs arm $1 replicate $REP; run that first" >&2; exit 1; }
  echo "$f"
}

case "$ARM" in
  1) gen "$WORK/seed.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$OUT" ;;
  2) fill "$E/arms/arm2-guide-first.md" '{{GUIDE}}' "$GUIDE" '{{SEED}}' "$WORK/seed.md" > "$WORK/p.md"
     gen "$WORK/p.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$OUT" ;;
  3) copyedit "$(need 1)" "$OUT" ;;
  4) copyedit "$(need 3)" "$OUT" ;;
  5) copyedit "$(need 2)" "$OUT" ;;
  A) fill "$E/implementations/A/prompt.md" '{{TEXT}}' "$(need 1)" > "$WORK/p.md"
     gen "$WORK/p.md" "$WRITER_MODEL" "$WRITER_EFFORT" "$OUT" ;;
  *) echo "unknown arm: $ARM" >&2; exit 1 ;;
esac

echo "wrote $OUT ($(wc -c < "$OUT") bytes)"
