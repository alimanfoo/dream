# Branch bases

## Default branch

Run `git fetch origin`, then `git remote set-head origin --auto`. Read
`git symbolic-ref --short refs/remotes/origin/HEAD` and remove `origin/`.

## Review base

Use `gh pr view --json baseRefName --jq .baseRefName`. If no pull request is
open, use the default branch. Run `git fetch origin <base>`.
