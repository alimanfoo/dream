# shellcheck shell=bash
#
# Where a dream skill keeps state for one repository.
#
# Two skill scripts keep per-repository state: `watch.sh` a watermark per pull
# request, and `dedup.sh` a record and a directory of issue bodies. They agree
# on where that state goes and on what a repository name may look like before it
# becomes part of the path, so those two facts live here rather than in each
# script. A third script that keeps per-repository state sources this too.
#
# Nothing else the scripts repeat belongs here. Their `die` prefix, their tool
# preflight and their repository-resolution message are each their own, and
# that message has already drifted between them, which is what being each
# script's own looks like. Gathering those here would tie together things meant
# to differ.
#
# Failures report through `die`, so the message carries the calling skill's own
# prefix. That is why this file has to be sourced after `die` is defined, and
# why it checks.

declare -F die >/dev/null \
  || { printf 'dream: repo-state.sh was sourced before a die helper was defined\n' >&2; exit 2; }

# Die unless the value is a repository name of the shape `gh` returns: an owner
# of letters, digits and hyphens, then a name that may also hold a dot or an
# underscore, and no second slash.
#
# The name half admits dots, so `owner/.` and `owner/..` satisfy the pattern.
# The two tests after it are what reject those, because a relative path element
# is the one shape that must never become part of a state directory.
require_repo_name() {
  [[ "$1" =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ && "$1" != */. && "$1" != */.. ]] \
    || die "gh reported the repository as '$1', which is not the owner/name a path can be built from"
}

# Print the directory the named skill keeps this repository's state in, having
# checked the name and made the directory. So a caller cannot hold a path here
# that skipped the check, and cannot find the directory missing when it writes.
#
# Call it as `dir=$(make_skill_state_dir <skill> <repo>) || exit 2`. A failure
# dies inside the command substitution, which ends the subshell and not the
# script, so the status is what stops the caller. The message is already out.
#
# The state sits under $HOME, so it survives between runs in separate processes
# and is never committed to the repository being worked on. The repository name
# stays two real path segments, rather than being flattened, so two repositories
# never collide: acme-corp/api and acme/corp-api are distinct paths, not one
# shared key.
make_skill_state_dir() {
  require_repo_name "$2"
  local dir="$HOME/.dream/$1/$2"
  mkdir -p "$dir" || die "cannot create the state directory $dir"
  printf '%s' "$dir"
}
