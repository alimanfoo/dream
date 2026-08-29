#!/usr/bin/env bash
# Arm 5: arm 2's text, then one copy-edit round. This is what dream:smith
# does today.
#
#   ./run.sh <fixture> <replicate>
ARM=5
source "$(dirname "$0")/../common.sh"
source "$(dirname "$0")/../3-copyedit/round.sh"
copyedit_round "$(need 2)" "$(run_dir)"
