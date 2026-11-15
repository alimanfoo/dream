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

The user has an issue that says what to build. They want it built on a pull
request without doing the work themselves.

1. The user runs `/dream:smith GH123`.
2. Smith reads the issue, its comments and the code the issue touches.
3. Smith opens a draft pull request and posts its plan there.
4. Smith builds the plan one step at a time, committing and pushing each step.
5. Smith runs a code review and then a coherence review. It applies each finding
   the evidence supports, and posts each review with its response to every
   finding.
6. Smith posts the ways the change could be smaller, writes the description, and
   marks the pull request ready for review.
7. The user reviews the pull request, comments on it, and tells smith there are
   comments.
8. Smith makes the changes asked for, and replies. Steps 7 and 8 repeat until
   the user is satisfied.
9. The user merges the pull request, and tells smith.
10. Smith files an issue for each thing it left out of scope, and lists them on
    the pull request.

The user has a reviewed pull request that does what the issue asked, and an
issue for each thing it left.
