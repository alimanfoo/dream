# Shared plumbing for the arms. Each arm's run.sh sources this.
#
# Every arm is a bare `claude -p` call from a directory outside this repo.
# Nothing resolves a skill or installs a plugin, so the arms differ only in the
# text of the prompt.
set -euo pipefail

ARM=${ARM:?each arm sets ARM before sourcing this}
FIXTURE=${1:?fixture name, e.g. docstring}
REP=${2:?replicate number}

E=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # common.sh sits in arms/, so this is the experiment root
ARMS="$E/arms"
WORK=$(mktemp -d)                 # outside the repo, so nothing here reaches a model
trap 'rm -rf "$WORK"' EXIT

WRITER_MODEL=${WRITER_MODEL:-opus};     WRITER_EFFORT=${WRITER_EFFORT:-high}     # the session that writes and edits
EDITOR_MODEL=${EDITOR_MODEL:-sonnet}; EDITOR_EFFORT=${EDITOR_EFFORT:-medium}   # what copy-editor.md's frontmatter pins

GUIDE="$E/snapshot/plain-english.md"
READER="$E/fixtures/$FIXTURE/reader.md"
RUNS="$E/runs/$FIXTURE"
mkdir -p "$RUNS"

# Replace each {{PLACEHOLDER}} with the contents of a file.
fill() { python3 -c '
import sys
text = open(sys.argv[1]).read()
for i in range(2, len(sys.argv), 2):
    text = text.replace(sys.argv[i], open(sys.argv[i + 1]).read().rstrip())
sys.stdout.write(text)
' "$@"; }

# gen <prompt-file> <model> <effort> <output-stem>
# Writes three files. <stem>.md holds the text. <stem>.jsonl holds the run's
# events, which say which tools ran, how long it took, what it cost and whether
# it failed, so a run can be audited without being repeated; token deltas are
# dropped, since they only restate the text. <stem>.meta.json says where the
# text came from, so a file that has been moved or copied for judging can still
# be traced back.
gen() {
  local prompt=$1 model=$2 effort=$3 stem=$4
  ( cd "$WORK" && claude -p --model "$model" --effort "$effort" \
      --strict-mcp-config --output-format stream-json --verbose \
      "$(cat "$prompt")" < /dev/null ) \
    | jq -c 'select(.type != "stream_event")' > "$stem.jsonl"
  jq -e 'select(.type=="result") | .is_error | not' "$stem.jsonl" > /dev/null \
    || { echo "run failed, see $stem.jsonl" >&2; return 1; }
  jq -r 'select(.type=="result") | .result' "$stem.jsonl" > "$stem.md"

  # The prompt hash pins which version of an arm produced this. Revise an arm's
  # prompt and its old output stops matching, rather than being mistaken for new.
  jq -n \
    --arg fixture "$FIXTURE" --arg arm "$ARM" --arg replicate "$REP" \
    --arg model "$model" --arg effort "$effort" \
    --arg prompt_sha256 "$(sha256sum < "$prompt" | cut -d" " -f1)" \
    --arg snapshot_commit "$(git -C "$E" rev-parse HEAD)" \
    --arg generated_at "$(date -u +%FT%TZ)" \
    '$ARGS.named' > "$stem.meta.json"
  echo "wrote $stem.md ($(wc -c < "$stem.md") bytes)"
}

# The seed prompt, with {{CODE}} replaced by the source file the fixture names.
seed_prompt() {
  cp "$E/fixtures/$FIXTURE/seed-prompt.md" "$WORK/seed.md"
  if [ -f "$E/fixtures/$FIXTURE/source" ]; then
    fill "$WORK/seed.md" '{{CODE}}' \
      "$E/fixtures/sources/$(cat "$E/fixtures/$FIXTURE/source")" > "$WORK/seed.filled"
    mv "$WORK/seed.filled" "$WORK/seed.md"
  fi
  echo "$WORK/seed.md"
}

# The output of an earlier arm this one builds on.
need() {
  local f="$RUNS/arm$1-r$REP.md"
  [ -f "$f" ] || { echo "needs arm $1 replicate $REP; run that first" >&2; exit 1; }
  echo "$f"
}
