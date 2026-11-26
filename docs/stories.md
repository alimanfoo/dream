# Stories

dream is a collection of skills for collaborative software engineering with
agents. Some skills guide an agent through autonomous coding work, such as
building or reviewing a change. Other skills guide an agent and the user through
interactive work, such as capturing requirements, exploring design options, or
triaging issues.

Most skills are designed to be run directly by the user within a harness session
in Claude Code or Codex. Some skills are designed to be used under dreamcatcher,
an application that allows coding agents to be steered via GitHub.

This page records what dream is meant to do, for the people and agents who
change it. Each story gives the user's goal, then the steps in order, each
saying who acts, then what the user has at the end. The stories use the words
that [dream's concepts page](concepts.md) and
[dreamcatcher's concepts page](https://alimanfoo.github.io/dreamcatcher/concepts/)
define, without defining them again.

## Decide what to build

### The user triages issues with an agent

The user has issues that have not been triaged. An issue's claims may no longer
hold for the current code, and an issue may duplicate another. The user wants to
decide the triage outcome of each one, and record each decision clearly enough
that an agent can later implement the issue without asking for more.

1. The user runs `/dream:sift`. The agent takes every issue that has no triage
   outcome.
2. The agent reads the repository's documentation to find guidance on
   engineering decisions and on what the product is meant to do, such as its
   `AGENTS.md`, decision principles, stories and concepts. It also loads the
   coherent coding guide, which sets the standard for the code an agent designs
   and writes.
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

### The user captures their requirements with an agent

The user has an idea for a change to the repository. They want an agent to
elicit their requirements by interviewing them, and to capture them in a
requirements specification, before anyone designs a solution.

1. The user runs `/dream:spark` with a seed, the material to start from: an
   issue, a file or some text.
2. The agent reads the repository's documentation and looks at how its code is
   laid out, so that its questions are informed by what the project is for. It
   reads any documented requirements the repository maintains, then reads the
   seed. It may question anything in the seed, since the interview may change
   any part of it.
3. The agent interviews the user, one question per turn. It asks about the
   problem or idea and the user's vision first, then about the stories, starting
   with happy paths before asking about user errors and faults. It follows
   threads from the user's answers, says what each answer changed in its
   understanding, and points out anything that doesn't add up. It keeps the
   conversation on what the user wants and why.
4. When it understands enough to write the specification, the agent says back
   what it understood in two or three sentences, and the user corrects it.
5. The agent writes the requirements specification in the first person, in the
   user's words. It records the motivation, the stories with happy paths first,
   the constraints and what is still open. It says which existing documented
   requirements the idea extends or changes, if any.
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

### The user explores the code for a change with an agent

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
3. The agent tells the user, a piece at a time, about the code relevant to the
   change: what its main parts are for, where they live and how they fit
   together.
4. The agent makes a list of the components and mechanisms the change will touch
   or depend on, and takes the user round each one, in an order that follows
   that account. At each one it says why the change brings them there, what it
   is for, where it lives, how it works and how it connects to the one before.
   It points out code that is hard to understand, or that looks over-built or
   patched round a problem.
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

### The user designs a change with an agent

The user has requirements for a change to the software, but no solution. They
want to explore solutions with an agent, which may know techniques they don't,
and to record the chosen solution in a design specification detailed enough to
plan its implementation.

1. The user runs `/dream:weave` with a seed: usually a requirements
   specification, or else an issue, a file or some text.
2. The agent reads the seed. It may question anything in it, because the seed is
   a starting point, and designing may change any part of it. Then it reads the
   code the change will live in, and the documentation that governs that code,
   before it says anything about the code.
3. The agent opens with the one thing it noticed in the code that the user
   probably hasn't, and the first thing it would want to settle. Then it puts up
   a few directions at once, a line each, so that both of them can see the range
   of options. One of them is the smallest thing that could possibly work.
4. The agent and the user explore the design with what-if questions, such as
   merging two parts or dropping a guarantee, one idea per turn. The agent
   follows each what-if two or three steps before it judges it. It says when
   part of the design is an instance of a known problem, and offers techniques
   and libraries the user may not know. It always has a next move ready, so that
   "ok" is a complete answer from the user.
5. Throughout, when the agent would remove something, it shows the design with
   that thing gone, and says what putting it back would cost. The user decides
   whether it is worth putting back.
6. When the what-ifs stop changing the design, the agent says so, and names any
   reservations it still has about the design. The user decides whether to move
   on or keep asking what-ifs.
7. The agent proposes which design models to use, and the user and the agent
   settle the choice together.
8. The agent sketches each chosen design model roughly, one per turn, and the
   user and the agent discuss each sketch before the next.
9. The user and the agent take the use case that motivates the work, or, where
   the requirements name none, an example use case they choose together. They
   walk it through the sketches step by step, from start to finish, making each
   step concrete with examples. At each step, they develop or revise the design
   models that the step involves.
10. The user and the agent fill in the details of the design models, and test
    them with further cases. The agent suggests cases, and they walk each one
    through the models together: first the other use cases, then the errors and
    faults that can occur in them, then, for each assumption the design rests
    on, a case in which it fails. Where a walk shows that the models fail a
    case, do more than the case needs, or hold a part that no case uses, they
    revise the models, and prefer removing a part to adding one. When further
    cases stop changing the models, the agent says so, and the user decides
    whether to stop.
11. The agent writes the design specification. It summarises the solution and
    presents the chosen design models, with a diagram where one makes a model
    clearer. It marks the models as a starting point that planning and
    implementation may revise. It writes out the walk of the motivating use case
    through the final models. It says which parts of the existing software the
    solution changes or removes, and the benefit of each removal. It says which
    alternatives were rejected and why, and which questions remain open.
12. The agent has two subagents read the design specification. One reads it
    beside the requirements, and reports which parts could be removed with the
    requirements still met, and what each removal would give up. The other reads
    the existing code that the solution changes or depends on. It reports
    whether the design specification is consistent with that code, and whether
    it contains enough detail to plan the solution's implementation. The agent
    fixes each point that needs only clearer wording, and brings the user each
    remaining point, one per turn. The user decides on each removal.
13. The agent shows the user the design specification.
14. The agent offers to put the design specification in a specification folder
    as `design.md` and open a pull request for it, and does so when the user
    agrees.

The user has a design specification detailed enough to plan the solution's
implementation, in which every part of the solution has a reason that justifies
building and maintaining it.

### The user breaks down a large piece of work with an agent

The user has a design specification for a piece of work too large to build in
one pull request. They want to explore with an agent how to divide the work into
stages and how to order them, and to record the stages in a roadmap that agents
can implement, one stage per session.

1. The user runs `/dream:quest` with a seed: usually a specification folder
   holding a requirements specification, a reading guide and a design
   specification, or an issue whose comments hold them.
2. The agent reads every specification the seed cites. It follows the reading
   guide through the code, then reads anything else the design touches, and the
   documentation that governs that code.
3. The agent suggests two or three ways to divide the work, such as by layer, a
   thin end-to-end path first, or the simple case before the awkward ones. It
   makes each the strongest version of itself, rather than setting weak options
   beside the one it prefers. It says which it prefers and why, and the user and
   the agent discuss them until they agree on one.
4. The agent and the user take one stage at a time. For each, they settle what
   it delivers, how they will know it is done, and what it leaves for later. The
   agent sketches which modules and functions the stage adds or changes, and
   which behaviour changes. That lets them judge whether the stage can stand
   alone and is small enough to review.
5. Throughout, when dividing the work exposes a missing design decision, the
   agent brings it to the user as one question, and corrects the design
   specification with what they settle.
6. The agent puts up the whole list of stages. The user and the agent split or
   merge stages until each one is small enough to review.
7. The agent puts the stages in dependency order. For each dependency it names
   what the later stage needs from the earlier one, and drops any dependency
   that has no such need. It looks for risky work that sits late, and discusses
   with the user whether to bring it earlier.
8. The agent writes the roadmap. For each stage, the roadmap says what the stage
   delivers, how to tell it is done, what it leaves for later, and which earlier
   stages it needs.
9. The agent has two subagents read the roadmap. One reads each stage as the
   agent that will implement it, and reports any stage that would force it to
   ask a question. The other checks that every dependency is real and in order,
   that every part of the design lands in a stage, and that no stage invents
   work. The agent fixes wording that was only unclear, brings the user each
   remaining point, one per turn, and revises the roadmap.
10. The agent shows the user the roadmap.
11. The agent offers to put the roadmap in the specification folder as
    `roadmap.md` and open a pull request for it, and does so when the user
    agrees.
12. The agent offers to create an issue for each stage, as a sub-issue of a
    parent issue. Each sub-issue is blocked by the sub-issues for the stages it
    needs. The agent does so when the user agrees, and adds no label and no
    assignee.

The user has a roadmap that divides the work into ordered stages, each one pull
request, and a sub-issue for each stage.

### The user takes a piece of work from idea to roadmap with agents

The user has an idea for a piece of work too large for one pull request. They
want to take it to a roadmap, through requirements, the existing code and a
design.

1. The user runs `/dream:spark` with the idea as its seed, and the agent puts a
   requirements specification in a new specification folder.
2. The user runs `/dream:trace` with the requirements specification as its seed,
   and the agent adds a reading guide to the folder.
3. The user runs `/dream:weave` with the requirements specification and the
   reading guide as its seed, and the agent adds a design specification to the
   folder.
4. The user runs `/dream:quest` with the specification folder as its seed, and
   the agent adds a roadmap to the folder and creates a sub-issue for each
   stage.
5. In steps 2 to 4, each agent corrects an earlier specification where its own
   work shows it to be wrong or incomplete.

The user has a specification folder that records the work from requirements to
roadmap, with each specification consistent with the others, and a sub-issue for
each stage.

The user can enter this sequence at any skill, with what they already have as
its seed.

## Implement a change

### An agent implements a large, well-specified change

The user has a well-specified issue that is large enough to need careful and
thorough engineering. They want a high-quality pull request for it.

1. The user runs `/dream:smith GH123`, where `GH123` names issue 123.
2. The agent reads the issue, its comments and the code the issue touches, and
   checks the issue against the code as it is now.
3. The agent opens a draft pull request and posts its plan there.
4. The agent implements the plan one step at a time, committing and pushing each
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
    finding included, except that it files at most two maintenance issues,
    choosing those that would cut the most maintenance burden. It lists the
    issues on the pull request.

The user has a reviewed pull request that does what the issue asked, and an
issue for each thing it left out of scope, with no more than two for
maintenance.

### An agent implements a clear, low-risk change

The user has an issue for a change that is clear and low-risk enough that a plan
and a second review would add nothing. They want a pull request for it quickly.

1. The user runs `/dream:less GH123`.
2. The agent reads the issue, its comments and the code the issue touches, and
   checks the issue against the code as it is now.
3. The agent opens a draft pull request.
4. The agent makes the change in small steps, committing and pushing each one.
   It follows a short summary of the engineering principles, rather than loading
   the full coherent coding guide as `dream:smith` does.
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

## Review a change

### Agents review a change for bugs and possible improvements

The user has a change on a branch, with an open pull request. They want it
reviewed for correctness bugs, and for the other opportunities for improvement
that matter most for what the change does.

1. The user runs `/dream:code-review`.
2. The agent reads the changes on the branch since it branched from the pull
   request's base branch, and the code it needs for context.
3. The agent picks review lenses that fit the change. One is always correctness
   bugs. It chooses the others for what the change does, such as races and
   ordering for concurrent code, or malformed input for a parser.
4. The agent has one subagent apply each lens.
5. The agent combines the subagents' findings, drops duplicates, reads the code
   each finding cites, and keeps only the findings it can confirm.
6. The agent lists the findings, most important first.

The user has a list of confirmed findings about the change, to act on as they
choose.

### Agents review a change for coherence and maintainability

The user has a change on a branch, with an open pull request. They want to know
where the change leaves the code less coherent or harder to maintain, with a fix
for each problem that takes out more code than it puts in.

1. The user runs `/dream:coherence-review`.
2. The agent reads the changes on the branch since it branched from the pull
   request's base branch, and the code it needs for context.
3. The agent has subagents review the change, each through a review lens drawn
   from the coherent coding guide, such as whether each fact and each concept
   has one home.
4. Each subagent proposes, for each finding, a fix that takes out more code than
   it puts in. It drops any finding it can't fix that way.
5. The agent combines the subagents' findings, and drops duplicates. It reads
   the code each finding cites, and keeps only the findings it can confirm whose
   fix holds: what the fix removes is there, removing it resolves the finding,
   and the result is less code.
6. The agent lists the findings, each with its fix, most important first.

The user has a list of confirmed findings about the change, each with a fix that
leaves less code, to act on as they choose.

### Agents review a change against principles from the user's past reviews

The user has a change on a branch, with an open pull request, and has reviewed
earlier pull requests on the repository. They want the change reviewed against
the principles they applied in those reviews.

1. The user runs `/dream:precedent-review`.
2. The agent reads the changes on the branch since it branched from the pull
   request's base branch, and the code it needs for context.
3. The agent has a subagent read the user's past review comments on the
   repository's pull requests. The subagent leaves out the user's comments on
   this change's own pull request, so that they don't steer the review. Before
   it reads the change, it writes down the principles the user keeps coming back
   to, citing the comments behind each.
4. The subagent reviews the change against those principles.
5. The agent reads the code each finding cites, and keeps only the findings it
   can confirm.
6. The agent lists the findings, most important first.

The user has a list of confirmed findings about the change, each a place where
the change departs from a principle behind their past reviews, to act on as they
choose.

## Run skills under dreamcatcher

### An agent implements an issue the user has labelled

The user has an issue that is ready to implement. They want an agent to
implement it on a pull request, and to steer the work from GitHub, without a
session of their own.

1. The user assigns the issue to themselves, and adds the dispatch label that
   their dreamcatcher configuration routes to smith or to less. That starts an
   agent assignment.
2. dreamcatcher opens a draft pull request for the issue, and starts an agent
   with that skill, as described by
   [dreamcatcher's stories](https://alimanfoo.github.io/dreamcatcher/stories/).
3. The agent adopts the draft pull request, and implements the issue as the
   story for [smith](#an-agent-implements-a-large-well-specified-change) or
   [less](#an-agent-implements-a-clear-low-risk-change) describes, up to marking
   the pull request ready for review.
4. The user reviews the pull request and comments on it.
5. dreamcatcher passes the user's comments to the agent.
6. The agent makes the changes asked for, and replies. Steps 4 to 6 repeat until
   the user is satisfied.
7. The user merges the pull request.
8. dreamcatcher gives the agent a last round, in which the agent finishes as
   that story describes.

The user has a merged pull request that does what the issue asked, without
having run a session or told the agent anything outside GitHub.

### An agent investigates an issue and answers the user's questions on it

The user has an issue they want investigated before anyone implements it, such
as a question about the code, a suspected bug or a doubt about a design. They
want answers from the code, on the issue, without starting a session of their
own.

1. The user assigns the issue to themselves, and adds the dispatch label that
   their dreamcatcher configuration routes to scout. That starts an issue
   conversation. The user asks their question in a comment on the issue.
2. dreamcatcher starts an agent with `/dream:scout GH123`, as described by
   [dreamcatcher's stories](https://alimanfoo.github.io/dreamcatcher/stories/).
3. The agent reads the issue and its comments, and traces the code that the
   question touches, with its callers, tests and docs. It checks every claim in
   the issue against the code, and runs the code where that settles the
   question.
4. The agent answers the latest question in a paragraph or two, as a maintainer
   would on an open-source issue. It cites the code its answer rests on by path
   and line, says where the answer rests on an inference, and recommends one
   answer where there are several.
5. dreamcatcher posts the answer on the issue.
6. The user replies with a follow-up question, and steps 3 to 5 repeat.

The user has answers on the issue, checked against the code, from which they can
decide what to do with it.

### An agent leads a campaign through a roadmap's stages

The user has a parent issue whose sub-issues are the stages of a roadmap, with
blocked-by links between them. They want an agent to carry every stage through
to a merged pull request, and to ask them only the questions the roadmap doesn't
settle.

1. The user assigns the parent issue to themselves, and adds the dispatch label
   that their dreamcatcher configuration routes to big. That starts a campaign.
2. dreamcatcher starts an agent, the lead, with `/dream:big GH123`, as described
   by
   [dreamcatcher's stories](https://alimanfoo.github.io/dreamcatcher/stories/).
3. The lead reads the parent issue, its comments, each sub-issue, and the
   specifications they link to. It learns each stage's goal, how to tell it is
   done, and which stages it depends on.
4. The lead starts each stage that is ready. It assigns the stage's sub-issue to
   the user's account, and adds the dispatch label of the route that suits the
   stage.
5. dreamcatcher starts an agent assignment for each labelled stage, once the
   sub-issues that block it have closed.
6. When a stage's pull request is ready, the lead reviews it. It checks whether
   the stage does what the roadmap says it delivers, by the roadmap's account of
   how to tell it is done. It also checks whether the stage stays coherent with
   the other stages, and gives later stages what they need. It leaves detailed
   code review to the skill the stage runs.
7. When something is missing or wrong, the lead says so in a comment on the pull
   request.
8. The stage's agent addresses the comment. Steps 6 to 8 repeat until the stage
   is done.
9. The lead passes to each later stage what this stage changed for it, then
   merges the pull request once its required checks pass.
10. Throughout, when neither the roadmap nor the user's earlier answers settle a
    question, the lead asks the user on the parent issue, and merges none of the
    stages the question bears on until they answer. If the lead cannot tell
    which stages it bears on, it merges no stage.
11. Steps 4 to 9 repeat until every sub-issue is closed. The lead says so on the
    parent issue.

The user has every stage of the roadmap merged, each reviewed against the
roadmap's account of how to tell it is done.

## Utility skills

`dream:smith` runs `dream:plan`, and `dream:smith` and `dream:sift` load
`dream:coherent-coding`. A user can run any of these skills directly, as these
stories describe.

### An agent writes an implementation plan for a change

The user has a change to make in one pull request. They want it divided into
implementation steps, each one idea and one commit, before anyone writes code.

1. The user runs `/dream:plan` with a description of the change they want.
2. The agent identifies from the description the intended result, how the code
   that the change touches works and is organised, and whether the change must
   keep behaviour the same or change it.
3. The agent drafts the implementation steps. Each step states its goal, a
   criterion that decides which work belongs in it, and examples of that work.
   Whoever implements the step applies the criterion, and finds every instance
   themselves.
4. Where the shape of the code that a step changes would make the step harder,
   the agent adds a step ahead of it that restructures that code without
   changing behaviour. It adds one only where that makes the later step clearly
   easier or safer.
5. The agent splits any step that holds more than one idea, and merges any step
   that leaves a change half-done into the step that completes it.
6. The agent orders the steps so that none depends on work a later step does.
   The tests and checks then pass at each commit.
7. The agent shows the user the implementation plan.

The user has an implementation plan whose steps can each be implemented and
committed in turn, with the tests and checks passing at each commit.

### An agent designs and writes code to the coherent coding guide

The user is about to have an agent design or write code. They want that code
coherent and easy to maintain.

1. The user runs `/dream:coherent-coding`.
2. The agent reads the coherent coding guide, and confirms in one line that it
   has loaded it.
3. The user asks the agent for the code they want.
4. The agent designs and writes the code with the guide in its context. The
   skill directs it to apply the guide as it scopes the change, as it writes,
   and as it reads back what it wrote.

The user has code that the agent designed and wrote with the coherent coding
guide in its context.

### An agent reasons about a system that has agents in it

The user is working with a coding agent to develop a system with LLM agents in
it, such as a prompt, a skill, a subagent file or a program that runs agents.
They want the coding agent to be able to reason about what the agents in that
system will do, and how the system can be engineered to achieve the desired
behaviour or functionality.

1. The user runs `/dream:agent-mechanics`.
2. A guide to agent mechanics is appended to the agent's context. It describes
   how a coding agent works: how the model generates text, what the context
   holds, the turn, tool calls and permissions, hooks, plugins, skills,
   subagents, compaction, and running an agent from a program.
3. The agent reads the details for Claude Code, for Codex, or for both,
   depending on which harnesses the system will run under.
4. The user asks the agent for the work they want.
5. The agent reasons about the system from the information about agent mechanics
   in its context. For example, it can tell that an instruction in a skill acts
   only through the tokens generated after it, or that a fresh subagent does not
   see its parent's conversation.

The user has work whose predictions about agents rest on how agents work.
