#!/usr/bin/env bash
# Arm 3: arm 1's text, then one copy-edit round.
#
#   ./run.sh <fixture> <replicate>
ARM=3
source "$(dirname "$0")/../common.sh"
source "$(dirname "$0")/round.sh"
copyedit_round "$(need 1)" "$(run_dir)"
