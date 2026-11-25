# Cited material and code

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
