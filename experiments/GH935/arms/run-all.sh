#!/usr/bin/env bash
# Run every arm over one fixture.
#
#   ./run-all.sh <fixture> [replicates] [at-once]
#
# A run that already has an output.md is left alone, so a stage that failed
# part way can be filled in without paying for the runs that worked, and
# without repointing a later arm at text the record does not hold. Set FORCE=1
# to generate everything again.
#
# Arms that build on another arm's output have to wait for it, so the work goes
# in three stages.
#
#   stage 1   arms 1 and 2, which need nothing
#   stage 2   arms 3, 5 and 6, which read arm 1 or arm 2
#   stage 3   arm 4, which reads arm 3
#
# Only a few calls run at once. A copy-edit round takes a large prompt and
# writes a verdict for every rule in the guide, so it runs for around two
# minutes, and enough of those at once starts failing in the transport rather
# than in the model. A failed call is retried, since one transient failure
# would otherwise cost the whole stage.
set -uo pipefail

FIXTURE=${1:?fixture name, e.g. docstring-1}
REPS=${2:-3}
AT_ONCE=${3:-3}
ATTEMPTS=3
HERE=$(cd "$(dirname "$0")" && pwd)
E_RUNS=$(cd "$HERE/.." && pwd)/runs/$FIXTURE
failed=0

attempt() {
  local arm=$1 rep=$2 n
  local armno=${arm%%-*}
  if [ -z "${FORCE:-}" ] && [ -f "$E_RUNS/arm$armno-r$rep/output.md" ]; then
    echo "  $arm replicate $rep already done"
    return 0
  fi
  for n in $(seq 1 "$ATTEMPTS"); do
    if "$HERE/$arm/run.sh" "$FIXTURE" "$rep"; then return 0; fi
    echo "  $arm replicate $rep failed on attempt $n"
  done
  return 1
}

stage() {
  local name=$1; shift
  local pids=() arm rep
  echo "== $name =="
  for arm in "$@"; do
    for rep in $(seq 1 "$REPS"); do
      while [ "$(jobs -rp | wc -l)" -ge "$AT_ONCE" ]; do wait -n 2>/dev/null || true; done
      attempt "$arm" "$rep" &
      pids+=($!)
    done
  done
  for p in "${pids[@]}"; do wait "$p" || failed=$((failed + 1)); done
}

stage "stage 1: arms 1 and 2" 1-vanilla 2-guide-first
stage "stage 2: arms 3, 5 and 6" 3-copyedit 5-guide-then-copyedit 6-dialogue
stage "stage 3: arm 4" 4-copyedit-twice

echo
if [ "$failed" -gt 0 ]; then
  echo "$failed run(s) failed after $ATTEMPTS attempts; look for a folder without an output.md"
  exit 1
fi
echo "all arms done for $FIXTURE, $REPS replicates"
