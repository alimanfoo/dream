# Boot sequence

Follow the steps below in order.

## A. Print the banner

Read the plugin's version from the `version` field of
`.codex-plugin/plugin.json`, in the folder that holds this file. Then print this
banner as your first user-visible output, with `<skill>` replaced by the name of
the skill you are running:

```text
# /dream:<skill> · dream v<version>
Booting...
```

Replace `<version>` with the version you read.

## B. Adopt the session rules

Follow these rules for the rest of the session.

### Autonomy

Work autonomously to the end. When you need to decide something, choose the
coherent option and explain your reasoning in the PR.

If you cannot decide something without the user, post a question as a comment on
the PR. Assume the user only follows the PR, not this session. Don't use
`AskUserQuestion` or the chat. The user won't see it, and the session stalls.
After you post the question, end your turn. A later round resumes when the user
replies on the PR.

### Communication style

Write each paragraph on a single line in a PR description or comment, since
GitHub reflows it (see [Text for GitHub](github-text.md)).

### Turn output

Keep your turn output brief, usually one sentence per turn, unless a step asks
you to write more. The user interacts via GitHub, so turn output is wasted
tokens.

### Mark your work

Read the `commentFooter` value, and the `commitTrailer` value for the harness
you run under (`claude` or `codex`), from
[`agent-written-marks.json`](agent-written-marks.json). End every commit with
that exact trailer. End every PR or issue body and every comment with the exact
`commentFooter` value as a blockquote. Replies on lines of the diff count as
comments.

This lets a reader tell quickly which items are agent-authored.

### Interrupted work

Once the session PR exists, post a comment there before you end a turn if
anything disrupts the work and prevents you from finishing it. Say what
disrupted the work and where you stopped. The user follows the PR, so turn
output alone is not enough.

## C. Orient to the repo

Determine what the repo is for as a whole. Read the repo's own docs
(`AGENTS.md`, `README`, `CLAUDE.md`) and explore its structure.

Determine the deliverable, what a consumer ultimately gets. For an application
or software library this is the code, but it could also be data, content,
configuration, or something else.

Determine how that product is organised into its major components.

## D. Find the tests and checks

Determine the tests, checks, build steps, and tooling built around the product
to produce, verify, and maintain it.

Find the project's test command. Look in the README, `AGENTS.md`, `CLAUDE.md`, a
Makefile, or `pyproject.toml`/`package.json` scripts. Run it yourself before
every commit. A commit hook rarely runs the test suite.

Find any codegen a commit hook doesn't run. Examples: a stub generator, an
OpenAPI client refresh, an index sync. Run it after an edit that needs it. This
makes the generated files match the source before you commit.

## E. Check the working tree

Check the working tree. If it has uncommitted changes, stop and tell the user,
in a comment on the branch's open PR if it has one.

Read the branch name (`git rev-parse --abbrev-ref HEAD`). Find the default
branch by following [Default branch](branch-bases.md#default-branch). If the
current branch is the default branch, pull the latest changes.

## F. Obtain session input

Take the argument the user gives as the session input. It names an issue, such
as `GH123`, or describes the task in free text.

Without an argument, scan the branch name for `gh<number>` tokens,
case-insensitive: `GH83`, `gh83-add-foo`, and `claude/gh341-defer-candidates`
each yield one. `fix-gh12-and-gh34` yields two. Every distinct issue number
found is part of the session input.

When the name holds no such token either, ask the user to provide the session
input.

## G. Read the cited material and the code

Read everything the user cites in their session input: issue bodies and their
comments, prior issues they reference, linked PRs, and named files or symbols.
For each cited issue, check whether it has sub-issues or a parent:

```bash
gh api repos/{owner}/{repo}/issues/<N>/sub_issues
gh api repos/{owner}/{repo}/issues/<N> --jq .parent_issue_url
```

Read the sub-issues and their comments too. They carry part of the same input.
Read the parent and its comments too, at the URL the second command prints. It
names the wider goal the cited issue serves. Only the cited issue is in scope,
not the parent's other sub-issues.

Then read the relevant code, callers, tests, and docs for the named surfaces.

Compare the session input against the code you read. The input may cite an issue
filed a while ago, or name code directly. Either way, the code may have changed
since. A symbol it names may be renamed, a file may have moved, or part of the
ask may already be done.

Reach for git history only to fill a real gap the reads left. For example, a
surface the input names that is no longer there. Trace where it went.

## H. Name the change type

Select the change type, which says what kind of change the work makes:

- **Enhancement.** New feature or capability that doesn't currently exist.
- **Maintenance.** Coherence, naming, structure. Behaviour already correct.
- **Bug fix.** Incorrect behaviour to repair.

## I. Open the session PR

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
