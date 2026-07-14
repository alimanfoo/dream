---
name: review-scope
description: Review draft scope options and return the combined findings.
argument-hint: "<artifact>"
---

# Review scope

Review draft scope options across different lenses and return the combined
findings.

## Arguments

Read the argument the user gives. It names the artifact to review: the draft
scope options, as an absolute path.

## Review

Launch these review subagents in parallel, via the Agent tool, one per lens:

- `dream:review-scope-coherent`
- `dream:review-scope-anticipation`
- `dream:review-scope-root-cause`
- `dream:review-scope-property`

Brief each with the draft scope options under review and any other supporting
material the lenses need as context. Pass each as an absolute path. A subagent
can't resolve a path relative to its own prompt file. Don't retype the content
into the prompt.

Combine their findings into one list, dropping duplicates that point at the same
scope option part.
