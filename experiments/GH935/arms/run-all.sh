#!/usr/bin/env bash
# Run every arm over one fixture.
#
#   ./run-all.sh <fixture> [replicates]
#
# Arms that build on another arm's output have to wait for it, so the work goes
# in three stages. Within a stage everything runs at once.
#
#   stage 1   arms 1 and 2, which need nothing
#   stage 2   arms 3, 5 and 6, which read arm 1 or arm 2
#   stage 3   arm 4, which reads arm 3
set -uo pipefail

FIXTURE=${1:?fixture name, e.g. docstring-1}
REPS=${2:-3}
HERE=$(cd "$(dirname "$0")" && pwd)
failed=0

stage() {
  local name=$1; shift
  local pids=() spec arm rep
  echo "== $name =="
  for spec in "$@"; do
    arm=${spec%:*}
    for rep in $(seq 1 "$REPS"); do
      "$HERE"/"$arm"/run.sh "$FIXTURE" "$rep" &
      pids+=($!)
    done
  done
  for p in "${pids[@]}"; do wait "$p" || failed=$((failed + 1)); done
}

stage "stage 1: arms 1 and 2" 1-vanilla: 2-guide-first:
stage "stage 2: arms 3, 5 and 6" 3-copyedit: 5-guide-then-copyedit: 6-dialogue:
stage "stage 3: arm 4" 4-copyedit-twice:

echo
if [ "$failed" -gt 0 ]; then
  echo "$failed call(s) failed; look for a jsonl without an md beside it"
  exit 1
fi
echo "all arms done for $FIXTURE, $REPS replicates"
