#!/usr/bin/env bash
# Arm 4: arm 3's text, then a second copy-edit round.
#
#   ./run.sh <fixture> <replicate>
source "$(dirname "$0")/../common.sh"
source "$(dirname "$0")/../3-copyedit/round.sh"
copyedit_round "$(need 3)" "$RUNS/arm4-r$REP"
