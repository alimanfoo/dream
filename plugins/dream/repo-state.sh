# shellcheck shell=bash
#
# Where a dream skill keeps state for one repository.
#
# The skill scripts that keep state for one repository hold this between them:
# `watch.sh` a watermark per pull request, and `dedup.sh` a record and a
# directory of issue bodies. They agree on where that state goes, and on what a
# repository name may look like before it becomes part of the path, so those two
# facts live here rather than in each script. Any further script that keeps such
# state sources this too.
#
# Nothing else the plugin's shell scripts repeat belongs here. Their `die`
# prefix, their tool preflight and their repository-resolution message are each
# the script's own. `catch.sh` shows what that looks like: a prefix of its own,
# five tools in its preflight rather than two, and a shorter resolution message.
# It keeps no state for a repository, so it sources nothing from here. Gathering
# those pieces here would tie together things meant to differ.
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
# The name half admits dots, so `owner/.` and `owner/..` satisfy the pattern. A
# relative path element is the one shape that must never become part of a state
# directory, so the two tests after the pattern reject those.
require_repo_name() {
  [[ "$1" =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ && "$1" != */. && "$1" != */.. ]] \
    || die "gh reported the repository as '$1', which is not the owner/name a path can be built from"
}

# Set `skill_state_dir` to the directory the named skill keeps this repository's
# state in, having checked the name and made the directory. So no caller holds
# a state directory that skipped the check. Nor does one find the directory
# missing when it writes.
#
# It sets a variable rather than printing one, so a failure here ends the
# calling script. Reading a printed path through a command substitution would
# put `die`'s exit in a subshell. The caller would then carry on with an empty
# path.
#
# The variable has the one name, rather than one the caller passes in. A
# caller's own name would arrive here as a string. Reading the value back would
# then mean expanding a variable whose name is itself held in a variable. And
# because shellcheck cannot follow an assignment made that way, the pre-commit
# hook fails every call site with SC2154 when it tries.
#
# The state sits under $HOME, so it survives between runs in separate processes.
# That also keeps it out of the repository being worked on.
#
# The repository name stays two real path segments, rather than being flattened,
# so two repositories never collide: acme-corp/api and acme/corp-api are
# distinct paths, not one shared key.
set_skill_state_dir() {
  require_repo_name "$2"
  skill_state_dir="$HOME/.dream/$1/$2"
  mkdir -p "$skill_state_dir" || die "cannot create the state directory $skill_state_dir"
}
