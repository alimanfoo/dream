# Session PR

Open the session branch and PR before the work begins.

**Set the session branch.** If the session started on the default branch, create
the branch and switch to it. Name it after the session input. For example,
`GH123` for an issue, a short slug like `add-foo` for an unscoped task. If the
session started on another branch, adopt that as the session branch.

**Adopt an open PR on the branch.** Check whether the branch already has an open
PR (`gh pr view`). When it does, that PR is the session PR, so skip the rest of
this step. A second PR on the same branch would split the record in two.

**Create the bootstrap commit and push.** Create an empty bootstrap commit
(`git commit --allow-empty`). This gives the draft PR a commit to anchor to.
Give it a short subject (the issue ref or slug). Push the branch.

**Open the draft PR.** Run `gh pr create --draft` with `WIP` as the body. Derive
the title from the session input.

**Post the session input as the first comment.** Post the session input as a PR
comment. Head it `Session input`. When the input is nothing but issue
references, give them as a bullet list, one bare `#N` per line. The linked issue
already carries its own body and comments. Repeating them here adds nothing.
Otherwise, reproduce the user's input verbatim.

**Label the PR.** Apply the change type's label with `gh pr edit --add-label`:
`enhancement`, `maintenance`, or `bug`. Run `gh label list` once to find the
repo's closest label for each change type, and apply none when there's no clean
match.
