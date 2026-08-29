#!/usr/bin/env bash
# Arm 1: the seed prompt, and nothing else.
#
#   ./run.sh <fixture> <replicate>
source "$(dirname "$0")/../common.sh"
gen "$(seed_prompt)" "$WRITER_MODEL" "$WRITER_EFFORT" "$RUNS/arm1-r$REP"
