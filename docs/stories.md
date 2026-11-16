# Stories

dream is a collection of skills for collaborative software engineering with
agents. Some skills guide an agent through autonomous coding work, such as
building or reviewing a change. Other skills guide an agent and the user through
interactive work, such as capturing requirements, exploring design options, or
triaging issues.

Most skills are designed to be run directly by the user within an interactive
session with Claude Code or Codex. Some skills are designed to be used within
dreamcatcher, an application that allows coding agents to be steered via GitHub.

## Hand off a task

### The user hands an issue to smith

The user has a well-specified issue that is large enough to need careful and
thorough engineering. They want a high-quality pull request for it.

1. The user runs `/dream:smith GH123`.
2. Smith reads the issue, its comments and the code the issue touches, and
   checks the issue against the code as it is now.
3. Smith opens a draft pull request and posts its plan there.
4. Smith builds the plan one step at a time, committing and pushing each step.
5. Smith has the change reviewed twice, by reviewers outside its own session: a
   code review, then a coherence review. It applies each finding the evidence
   supports, defers each one that holds but needs a pull request of its own, and
   posts each review with its response to every finding.
6. Smith looks for code or complexity the change could remove by changing the
   design or the constraints in the issue, or by delivering less. It posts each
   opportunity with what it would give up, for the user to decide.
7. Smith writes the description and marks the pull request ready for review.
8. The user reviews the pull request, comments on it, and tells smith there are
   comments.
9. Smith makes the changes asked for, and replies. Steps 8 and 9 repeat until
   the user is satisfied.
10. The user merges the pull request, and tells smith.
11. Smith files an issue for each thing it left out of scope, each deferred
    finding included, and lists them on the pull request.

The user has a reviewed pull request that does what the issue asked, and an
issue for each thing it left.

### The user hands a small change to less

The user has an issue for a change that is clear and low-risk enough that a plan
and a second review would add nothing. They want a pull request for it quickly.

1. The user runs `/dream:less GH123`.
2. Less reads the issue, its comments and the code the issue touches.
3. Less opens a draft pull request.
4. Less makes the change in small steps, committing and pushing each one.
5. Less runs a code review in its own session, and applies each finding the
   evidence supports.
6. Less writes a short description and marks the pull request ready for review.
7. The user reviews the pull request, comments on it, and tells less there are
   comments.
8. Less makes the changes asked for, and replies. Steps 7 and 8 repeat until the
   user is satisfied.
9. The user merges the pull request.

The user has a pull request that does what the issue asked.
