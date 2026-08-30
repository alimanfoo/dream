#!/usr/bin/env bash
# Give every tracked file under the experiment the time its content last
# changed, rather than the time it happened to be written to disk.
#
# git records no mtimes, so cloning the repository or switching branch stamps
# every file with the current time, in the order git wrote them. make then
# reads those times as if they meant something. In this experiment they can
# mean that twelve outputs, each costing minutes and money, look stale because
# a directory sorts late in the alphabet.
#
# The commit that last touched a file is when its content last changed, which
# is what make needs. A file with uncommitted changes is left alone, since the
# working tree really is newer than anything git knows about.
set -euo pipefail

cd "$(dirname "$0")"
root=$(git rev-parse --show-toplevel)
scope=$(cd .. && git rev-parse --show-prefix)

# Files the working tree has changed keep the mtime they have.
dirty=$(git -C "$root" status --porcelain -- "$scope" | awk '{print $NF}')

git -C "$root" log --format='C%at' --name-only -- "$scope" | awk -v dirty="$dirty" '
  BEGIN { split(dirty, d, "\n"); for (i in d) skip[d[i]] = 1 }
  /^C[0-9]+$/ { stamp = substr($0, 2); next }
  NF && !($0 in seen) && !($0 in skip) { seen[$0] = 1; print stamp, $0 }
' | while read -r stamp path; do
  [ -e "$root/$path" ] && touch -d "@$stamp" "$root/$path"
done
