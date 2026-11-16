# Stories

dream is a collection of skills for collaborative software engineering with
agents. Some skills guide an agent through autonomous coding work, such as
building or reviewing a change. Other skills guide an agent and the user through
interactive work, such as capturing requirements, exploring design options, or
triaging issues.

Most skills are designed to be run directly by the user within a harness session
in Claude Code or Codex. Some skills are designed to be used within
dreamcatcher, an application that allows coding agents to be steered via GitHub.

This page records what dream is meant to do, for the people and agents who
change it. Each story gives the user's goal, then the steps in order, each with
one actor, then what the user has at the end.

## Hand off a task

### The user has an agent implement a well-specified issue

The user has a well-specified issue that is large enough to need careful and
thorough engineering. They want a high-quality pull request for it.

1. The user runs `/dream:smith GH123`.
2. The agent reads the issue, its comments and the code the issue touches, and
   checks the issue against the code as it is now.
3. The agent opens a draft pull request and posts its plan there.
4. The agent builds the plan one step at a time, committing and pushing each
   step.
5. The agent runs a code review and then a coherence review, each of which reads
   the change through subagents. The coherence review looks for fixes that miss
   the root cause, duplicated facts, weak boundaries and unnecessary code. The
   agent applies each finding the evidence supports, defers each one that holds
   but needs a pull request of its own, and posts each review with its response
   to every finding.
6. The agent looks for code or complexity the change could remove by changing
   the design or the constraints in the issue, or by delivering less. It posts
   each opportunity with what it would give up, for the user to accept or
   decline.
7. The agent writes the description and marks the pull request ready for review.
8. The user reviews the pull request, comments on it, and tells the agent there
   are comments.
9. The agent makes the changes asked for, and replies. Steps 8 and 9 repeat
   until the user is satisfied.
10. The user merges the pull request, and tells the agent.
11. The agent files an issue for each thing it left out of scope, each deferred
    finding included, and lists them on the pull request.

The user has a reviewed pull request that does what the issue asked, and an
issue for each thing it left out of scope.

### The user has an agent make a clear, low-risk change

The user has an issue for a change that is clear and low-risk enough that a plan
and a second review would add nothing. They want a pull request for it quickly.

1. The user runs `/dream:less GH123`.
2. The agent reads the issue, its comments and the code the issue touches.
3. The agent opens a draft pull request.
4. The agent makes the change in small steps, committing and pushing each one.
5. The agent runs a code review without subagents, and applies each finding the
   evidence supports.
6. The agent writes a short description and marks the pull request ready for
   review.
7. The user reviews the pull request, comments on it, and tells the agent there
   are comments.
8. The agent makes the changes asked for, and replies. Steps 7 and 8 repeat
   until the user is satisfied.
9. The user merges the pull request.

The user has a pull request that does what the issue asked.

## Think it through together

### The user triages issues with the assistance of an agent

The user has issues that have not been triaged. An issue's claims may no longer
hold for the current code, and an issue may duplicate another. The user wants to
decide the triage outcome of each one, and record each decision clearly enough
that an agent can later implement the issue without asking for more.

1. The user runs `/dream:sift`. The agent takes every issue that has no triage
   outcome.
2. The agent reads the repository's documentation to find guidance on
   engineering decisions and on what the product is meant to do for this
   project, such as its `AGENTS.md`, decision principles, stories and concepts.
   It also loads the coherent coding guide, which sets the standard for the code
   an agent designs and writes.
3. For one issue, the agent reads the issue and its comments, checks its claims
   against the code as it is now, and searches earlier issues and pull requests
   on the same subject.
4. The agent states the problem in a few sentences and offers three options: the
   strongest answer to the issue as it stands, the best real alternative, and a
   way to meet the need at its root. It recommends one and says why. When the
   issue raises several points, it takes them one at a time.
5. The user decides, or asks questions until they can.
6. The agent posts the decision on the issue. It writes the decision for the
   agent that will implement the issue, and names anything still missing or
   undecided.
7. The agent labels the issue with its change type. It records the triage
   outcome by labelling the issue as ready to implement, needing information,
   needing discussion, or waiting on something outside the repository, or by
   closing the issue with the reason.
8. Steps 3 to 7 repeat for each issue, until none are left.

The user has a decision and its reason on every issue they triaged. An agent can
implement each issue that is ready to implement without asking for more.

### The user captures their requirements with the assistance of an agent

The user has an idea for a change to the repository. They want an agent to
elicit their requirements by interviewing them, and to capture them in a
requirements specification, before anyone designs a solution.

1. The user runs `/dream:spark` with a seed, the material to start from: an
   issue, a file or some text.
2. The agent reads the repository's documentation and looks at how its code is
   laid out, so that its questions are informed by what the project is for. Then
   it reads the seed, and treats nothing in it as settled.
3. The agent asks the user where they would like to start, then interviews them,
   one question per turn. It follows threads from the user's answers, and says
   what each answer changed in its understanding. It points out anything that
   doesn't add up, such as two answers that conflict. It keeps the conversation
   on what the user wants and why, not on how to build it.
4. When it understands enough to write the specification, the agent says back
   what it understood in two or three sentences, and the user corrects it.
5. The agent writes the requirements specification in the first person, in the
   user's words. It says what the user wants to be able to do, what is wrong or
   missing today, what has to be true of anything they would accept, what limits
   a solution, how they will know it worked, and what is still open.
6. The agent has two subagents read the specification. One reads as the agent
   that will design a solution, and reports what else it would need to know. The
   other reports how the idea sits against what the repository is for, and where
   it overlaps or conflicts with what the repository already does. The agent
   drops what the specification already answers, and fixes wording that was only
   unclear. Then it brings the user each remaining point, one per turn, and
   revises the specification.
7. The agent shows the user the specification.
8. The agent offers to put the specification in a specification folder as
   `requirements.md` and open a pull request for it, and does so when the user
   agrees.

The user has a requirements specification, in their own words, that a design can
start from.

### The user learns the code relevant to an upcoming change, and has an agent write a reading guide to it

The user is about to design a change in collaboration with an agent. They want
to learn the existing code relevant to the change, so that they are better able
to collaborate on its design. They also want a reading guide to that code, so
that the agent that designs or implements the change can find and read all the
relevant code.

1. The user runs `/dream:trace` with a seed that sets the scope: usually a
   requirements specification, or else an issue, a file or some text.
2. The agent reads all the code relevant to that scope, and the documentation
   that governs it, before it tells the user anything about the code. As it
   goes, it says in a line what it opens and why.
3. The agent tells the user, a piece at a time, what the code is for, what its
   main parts are and where they live, and how they fit together.
4. The agent makes a list of the components and mechanisms worth understanding,
   and takes the user round each one, in an order that follows that account. At
   each one it says what it is for, where it lives, how it works and how it
   connects to the one before. It points out code that is hard to understand, or
   that looks over-built or patched round a problem.
5. Throughout, the agent tells the user only what it has read in the code, names
   the file and symbol for each thing it describes, and says where its evidence
   is thin.
6. The user asks questions, pushes back or redirects, and the agent answers from
   the code. The agent covers everything on its list.
7. The agent writes the reading guide. The guide has the big picture, a section
   for each component or mechanism, and the code's awkward parts. Each part says
   where to start reading and in what order. The agent draws on the whole
   conversation, the user's questions and corrections included.
8. The agent has a subagent check every claim in the reading guide against the
   code, and corrects each claim the subagent finds contradicted or unsupported.
   If the agent had told the user any of those claims during the tour, it tells
   them which.
9. The agent shows the user the reading guide.
10. The agent offers to put the reading guide in a specification folder as
    `reading-guide.md` and open a pull request for it, and does so when the user
    agrees.

The user knows the relevant code well enough to collaborate on the design, and
has a reading guide, checked against the code, that lets the next agent find and
read all of it.
