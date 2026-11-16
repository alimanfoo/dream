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

## Think it through together

### The user triages issues with the assistance of an agent

The user has issues that have not been triaged. Any of them may be wrong,
already fixed, out of date, or a duplicate. The user wants to decide the triage
outcome of each one, and record it clearly enough for another agent to implement
it later.

1. The user runs `/dream:sift`, optionally naming the issues to take. Otherwise
   the agent takes every issue that has no triage outcome.
2. The agent reads the repository's documentation to find guidance on
   engineering decisions and on what the product is meant to do for this
   project, such as its `AGENTS.md`, decision principles, stories and concepts.
   It also loads the coherent coding guide.
3. For one issue, the agent reads the issue and its comments, checks its claims
   against the code as it is now, and searches earlier issues and pull requests
   on the same subject.
4. The agent states the problem in a few sentences and offers three options: the
   strongest answer to the issue as it stands, the best real alternative, and a
   way to meet the need at its root. It recommends one and says why. When the
   issue raises several points, it takes them one at a time.
5. The user decides, or asks questions until they can.
6. The agent posts the decision on the issue, written for the agent that will
   implement it. It gives the issue its change type and records the triage
   outcome. It labels the issue as ready to implement, needing information,
   needing discussion, or waiting on something outside the repository, or it
   closes the issue and says why.
7. Steps 3 to 6 repeat for each issue, until none are left or the user stops.

The user has a decision and its reason on every issue they triaged. The issues
that are ready can go to an agent as they are.
