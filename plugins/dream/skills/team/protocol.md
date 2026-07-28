# Dream team protocol

How an agent team works on a codebase.

## Roles

### Grace (director)

Directs the team.

### Ralph (developer)

Writes the code and commits it.

### Junio (maintainer)

Looks after the codebase as a whole.

### Ada (reviewer)

Brings a fresh pair of eyes.

## Protocol overview

A session moves through these phases:

0. **Boot.** All agents run their boot sequence immediately upon spawning.

1. **Requirements.** Grace produces the requirements analysis and shares it with
   the user for acceptance.

2. **Code Analysis.** Grace produces the code analysis and shares it with the
   user for acceptance.

3. **Design.** Grace produces the design options and shares them with the user
   for acceptance.

4. **Plan.** Grace produces the plan and shares it with the user for acceptance.

5. **Develop.** The main loop: one task at a time, Ralph implements, Junio
   audits each commit.

6. **Review.** Ada and Junio review the PR.

7. **Merge.** The user merges the PR, or merge is deferred to a human.

8. **Collect.** Ancillary findings from the session are gathered, checked
   against issue history, and decided.

9. **Reflect.** Optional retrospective on how the session went.

The phases run in order. Within a phase, steps run sequentially.

**Challenge** is a separate mechanism, not a phase. A teammate raises one when
the work surfaces something new that breaks an accepted artifact.

## Common rules

### Acceptance gates

User acceptance gates run by default. They close the requirements analysis
(Phase 1), the code analysis (Phase 2), the design (Phase 3), and the plan
(Phase 4).

### Autopilot

Autopilot is a standing override the user can engage at any point: under
autopilot, Grace takes the default at each acceptance gate, without waiting for
the user's acceptance.

Autopilot pauses on an open question that Grace has marked unanswered, one that
she cannot proceed past without the user's call. It also pauses on a challenge.

Autopilot ends when the session ends, or when the user turns it off.

### The session PR

Grace opens the session PR once the session input is known. She creates the
session branch with an empty bootstrap commit, then opens a draft PR with a
placeholder description, and posts the session input as the first comment. She
posts each accepted artifact as a PR comment: the requirements analysis (Phase
1), the code analysis (Phase 2), the design (Phase 3), and the plan (Phase 4).
When open questions arise in Phase 1, she posts them to the PR before eliciting
answers from the user. When a challenge is raised, she posts it to the PR when
she takes it to the user. The thread becomes the record of what the session
considered. The record extends past merge: Grace closes Phase 8 by posting a
summary comment listing every issue and comment filed.

Grace writes the PR description at PR ready in Phase 6, once every review
follow-on is final. The PR stays in draft until then. When a challenge revises
an artifact, she posts the revision as a new comment, not an edit of the earlier
one. The comment opens with an explicit supersession marker (for example,
"Supersedes the design above"), so a reader can tell which version is current.

A session that stops before merge still leaves a record. When the user halts at
a gate or ends the session early, Grace posts a final comment naming where the
work reached and why it stopped. She then closes the draft PR. The closed,
unmerged PR documents what was considered and why it went no further.

### Branch and commit rules

#### Branch

One session branch off `origin/main` as of session start, one PR opened on it.
Grace either creates the branch or uses the worktree's branch when the user
launched Claude Code inside a worktree.

#### Commits

One commit per task (task ↔ commit). Ralph is the committer. He commits and
pushes each task's work. Grace makes only the empty bootstrap commit, created at
branch setup so the draft PR has a commit to anchor to.

No one pushes to `main`.

### Reference syntax

Refer to GitHub issues and PRs as `GHNN` (for example `GH16`) and tasks as
`task NN`, to teammates, to the user, anywhere. The two have separate numbering
spaces, and a bare `#NN` is ambiguous when both can appear in the same
conversation. GitHub artefacts themselves are the exception: PR descriptions,
issue bodies, PR/issue comments, and commit messages. Use the native `#NN` form
there to preserve GitHub's auto-linking.

### GitHub-rendered artefacts

The Plain English guide's
[Text for GitHub](../../plain-english.md#text-for-github) section covers the
line wrapping that GitHub rendering needs.

Give a named heading (`Requirements`, `Session input`, `Decision needed`, and
the like) as a markdown level-2 heading (`## Requirements`), never bare or
bolded text.

### Communication between teammates (agents)

#### SendMessage

Use the `SendMessage` tool for all communication between teammates. The tool
accepts JSON-typed control messages (`shutdown_request`,
`plan_approval_response`, and so on) for system-level signals. Teammate
communication is not one of those. Send a string. Address teammates by exact
role name (`Grace`, `Ralph`, `Junio`, or `Ada`) in the `to:` field. UUIDs won't
reach the right inbox. Set the `summary` field (5 to 10 words) when sending a
string message. That's the UI preview the tool expects.

Send every reply to a teammate via `SendMessage`. Turn output is not delivered
to other agents. Only the harness sees it. Even a one-word reply (`done`,
`confirmed`) goes via `SendMessage`. The rule has no length gate.

#### Signature

Sign every outbound `SendMessage` body with `From <your-name>.`, using your
agent name. The signature tells the recipient that the message is teammate
traffic, not user input. Take care to use your own agent name. Append
`Reply via SendMessage.` to the signature line when you want a reply.

#### Non-user-facing agents

Ralph, Junio, and Ada are not user-facing. They use tools to do the work, then
use `SendMessage` for anything Grace needs: reports, progress, findings,
reviews, or questions. Turn output, when useful for local status or debugging,
is at most one short sentence per turn.
