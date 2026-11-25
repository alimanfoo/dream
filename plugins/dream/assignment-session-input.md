# Session input

Take the argument the user gives as the session input. It names an issue, such
as `GH123`, or describes the task in free text.

Without an argument, scan the branch name for `gh<number>` tokens,
case-insensitive: `GH83`, `gh83-add-foo`, and `claude/gh341-defer-candidates`
each yield one. `fix-gh12-and-gh34` yields two. Every distinct issue number
found is part of the session input.

When the name holds no such token either, ask the user to provide the session
input.
