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

# The guide an arm reads. Arms differ in which version they get, so an arm
# sets GUIDE before sourcing this and the original stands as the default.
GUIDE=${GUIDE:-"$E/snapshot/guides/plain-english-177fb63.md"}
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

# Run one call, and record what it did. Writes <call>.jsonl with the run's
# events, which say which tools ran, how long it took, what it cost and whether
# it failed, so a call can be audited without being repeated; token deltas are
# dropped, since they only restate the text. Writes <call>.meta.json to say
# where the text came from, so a file copied out for judging can still be
# traced back.
call() {
  local prompt=$1 model=$2 effort=$3 dir=$4 name=$5
  mkdir -p "$dir"
  local stem="$dir/$name"
  # An arm that edits a file needs PERMISSION_MODE, or the write is declined
  # and the call reports work it was never allowed to do.
  # Capture to the work directory and move the finished file into place, so a
  # call that is killed part way leaves nothing behind. A half-written capture
  # would otherwise sit in the run folder looking like a record of the call.
  ( cd "$WORK" && claude -p --model "$model" --effort "$effort" \
      ${PERMISSION_MODE:+--permission-mode "$PERMISSION_MODE"} \
      --strict-mcp-config --output-format stream-json --verbose \
      "$(cat "$prompt")" < /dev/null ) \
    | jq -c 'select(.type != "stream_event")' > "$WORK/$name.jsonl"
  mv "$WORK/$name.jsonl" "$stem.jsonl"
  jq -e 'select(.type=="result") | .is_error | not' "$stem.jsonl" > /dev/null \
    || { echo "call failed, see $stem.jsonl" >&2; return 1; }

  # The prompt hash pins which version of an arm produced this. Revise an arm's
  # prompt and its old output stops matching, rather than being mistaken for new.
  # The prompt itself is not kept, since the arm, the snapshot and the fixture
  # are all committed and rebuild it exactly.
  #
  # The work directory is stamped out before hashing. It is a fresh mktemp path
  # every run, so an arm that names a file in its prompt would otherwise hash
  # differently every time, and the hash would say a prompt had changed when
  # only the temporary directory had.
  jq -n \
    --arg fixture "$FIXTURE" --arg arm "$ARM" --arg replicate "$REP" \
    --arg call "$name" --arg model "$model" --arg effort "$effort" \
    --arg prompt_sha256 "$(sed "s|$WORK|{{WORK}}|g" "$prompt" | sha256sum | cut -d" " -f1)" \
    --arg snapshot_commit "$(git -C "$E" rev-parse HEAD)" \
    --arg generated_at "$(date -u +%FT%TZ)" \
    '$ARGS.named' > "$stem.meta.json"
}

# gen <prompt-file> <model> <effort> <run-dir> <call-name>
# For a call whose answer is what it says. An arm's result is always output.md,
# and an arm that takes more than one call names its earlier ones, so arm 3
# leaves findings.md beside its output.md.
gen() {
  call "$@"
  local stem="$4/$5"
  jq -r 'select(.type=="result") | .result' "$stem.jsonl" > "$stem.md"
  echo "wrote $stem.md ($(wc -c < "$stem.md") bytes)"
}

# gen_edit <prompt-file> <model> <effort> <run-dir> <call-name> <edited-file>
# For a call whose answer is a file it edited rather than anything it said.
gen_edit() {
  call "$1" "$2" "$3" "$4" "$5"
  local stem="$4/$5"
  cp "$6" "$stem.md"
  echo "wrote $stem.md ($(wc -c < "$stem.md") bytes)"
}

# Where this run's files go.
run_dir() { echo "$RUNS/arm$ARM-r$REP"; }

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
  local f="$RUNS/arm$1-r$REP/output.md"
  [ -f "$f" ] || { echo "needs arm $1 replicate $REP; run that first" >&2; exit 1; }
  echo "$f"
}
