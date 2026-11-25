# Working tree

Check the working tree. If it has uncommitted changes, stop and tell the user,
in a comment on the branch's open PR if it has one.

Read the branch name (`git rev-parse --abbrev-ref HEAD`). Find the default
branch by following [Default branch](branch-bases.md#default-branch). If the
current branch is the default branch, pull the latest changes.
