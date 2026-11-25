---
title: dream
template: home.html
hide:
  - navigation
  - toc
headline: Better software from coding agents, with less input from you
lede:
  Hand off a task and get back a planned, built and reviewed pull request. Or
  work through requirements and design with the agent before any code. The
  skills aim to help agents be thoughtful engineers, not just write code.
---

## Install

```text title="Claude Code"
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

```bash title="Codex"
codex plugin marketplace add alimanfoo/dream
codex plugin add dream@dream
```

Call a skill by name, with a leading slash under Claude Code and a `$` under
Codex: `/dream:smith` or `$dream:smith`.

Most skills work with GitHub issues and pull requests. For those, install `gh`
2.94.0 or later and sign in.

## Hand off a task

Give one of these skills a task, and it carries the task to a pull request on
its own. The skill opens the pull request as a draft before it touches any code.
Follow the session there, and answer anything the skill asks you.

| Skill          | What it does                                                             |
| -------------- | ------------------------------------------------------------------------ |
| `/dream:smith` | Plans a well-specified task, builds it one commit at a time, reviews it. |
| `/dream:less`  | Builds a relatively easy change, with no plan and one review.            |

Name the task as an argument: an issue such as `GH123`, or free text. Without an
argument, the skill takes the issue numbers in the branch name.

## Run them from labelled issues

[dreamcatcher](https://alimanfoo.github.io/dreamcatcher/) runs these skills for
you, with no session to watch. Label a GitHub issue, and dreamcatcher starts an
agent on it in a worktree of its own, with several agents at a time. You talk to
each agent on GitHub. Reply on the pull request, and dreamcatcher passes your
reply to the agent. dreamcatcher also wakes the agent when the pull request
falls behind its base or conflicts with it, or when a check fails, so the agent
can fix it on its own. When you merge or close the pull request, dreamcatcher
gives the agent a last round to wrap up.

dreamcatcher runs a skill as an assignment, a conversation or a campaign. An
assignment carries an issue to a pull request. A conversation answers the
questions that you post as comments on an issue, and writes no code. A campaign
carries the sub-issues of a parent issue through their assignments to merge.

| Skill          | Under dreamcatcher   |
| -------------- | -------------------- |
| `/dream:smith` | Runs an assignment.  |
| `/dream:less`  | Runs an assignment.  |
| `/dream:scout` | Runs a conversation. |
| `/dream:big`   | Runs a campaign.     |

`dreamcatcher init` installs this plugin, and routes a label to each skill.
Follow the
[dreamcatcher tutorial](https://alimanfoo.github.io/dreamcatcher/tutorial/) for
a first run.

## Think it through together

These skills work with you on the thinking that comes before code, one decision
or question at a time. The triage skill records each decision on the issue. The
other skills end in a written specification, and offer to put it on a pull
request where you can comment on any line.

| Skill          | What it does                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------------- |
| `/dream:sift`  | Triages GitHub issues with you, records each decision, and can dispatch accepted work.                    |
| `/dream:spark` | Interviews you about a rough idea, and writes a requirements specification.                               |
| `/dream:trace` | Explores code relevant to your change with you, and writes a reading guide to it.                         |
| `/dream:weave` | Works out a solution with you, as design models tested against use cases.                                 |
| `/dream:quest` | Breaks a design specification into a roadmap of pull requests, with each issue blocked only by its needs. |

Run `/dream:sift` to work through a repository's issue queue. Run the
specification skills in order on a large piece of work, or run the one you need.
Each specification skill takes an issue, a file or free text, so you can point
it at what the one before it wrote.

## Review a change

Each review reads the branch against its open pull request's base, or against
the repository's default branch when there is no pull request. You can give it a
git range or a path instead. Smith runs the code and coherence reviews before it
marks a pull request ready, and you can run any of them yourself.

| Skill                     | What it looks for                                                      |
| ------------------------- | ---------------------------------------------------------------------- |
| `/dream:coherence-review` | Root causes, duplicated facts, weak boundaries, and unnecessary code.  |
| `/dream:code-review`      | Correctness bugs and other issues, through lenses chosen for the diff. |
| `/dream:precedent-review` | What you would catch, learned from your own past review comments.      |

## Plan and write

| Skill                    | What it does                                                                 |
| ------------------------ | ---------------------------------------------------------------------------- |
| `/dream:plan`            | Creates an implementation plan for one pull request, a commit per step.      |
| `/dream:coherent-coding` | Loads the coherent coding guide, for the agent to code to.                   |
| `/dream:agent-mechanics` | Loads a guide to how coding agents work, for building systems that use them. |

## If something goes wrong

Start each session in an automatic permissions mode, so that most permissions
are handled for you.

```bash title="Claude Code"
claude --permission-mode auto
```

```bash title="Codex"
codex --approve-for-me
```

Smith and Less print the plugin version as they start. Quote that version when
you [raise an issue](https://github.com/alimanfoo/dream/issues).
