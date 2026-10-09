---
hide:
  - navigation
  - toc
---

# dream

Skills for building software with agents, in Claude Code and Codex.

A skill is a named set of instructions that you call from the prompt. Each skill
puts the agent to work in a particular way.

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

### /dream:smith

For a well-specified task. Smith posts a plan, implements the plan one commit at
a time, then reviews the branch three ways and acts on every finding.

### /dream:less

For a small, self-contained change. Less skips the plan and runs one review.

Name the task as an argument: an issue such as `GH123`, or free text. Without an
argument, the skill takes the issue numbers in the branch name.

[dreamcatcher](https://alimanfoo.github.io/dreamcatcher/) watches a repository
for labelled issues, and starts an agent on each one.

## Think it through together

These skills work with you on the thinking that comes before code, one question
at a time. Each skill ends in a written specification, and offers to put it on a
pull request where you can comment on any line.

Run them in order on a large piece of work, or run the one you need. Each skill
takes an issue, a file or free text, so you can point it at what the one before
it wrote.

### /dream:spark

Interviews you about a rough idea, and turns it into a requirements brief.

### /dream:trace

Reads unfamiliar code with you, and leaves a reading guide to it.

### /dream:weave

Works out a design with you, and tests it by asking what breaks.

### /dream:quest

Breaks a design into an ordered roadmap, where each stage is one pull request.
It offers to create one issue per stage.

## Answer questions on an issue

### /dream:scout

Investigates an issue before any implementation work, and answers the questions
you post on it from the code. Set it as the `prompt` under dreamcatcher's
`[conversation]` block: `"/dream:scout GH{issue}"`.

## Do one job

The hand-off skills run these for you, and you can run any of them yourself.
Each review reads the branch against `origin/main`, or takes a git range or a
path.

### /dream:code-review

Reviews changed code through lenses chosen to fit the diff, and verifies every
finding before it reports it.

### /dream:coherence-review

Reviews changed code for the fix that stopped at the symptom, the edit that
missed a site, and the fact that now has two homes.

### /dream:precedent-review

Reviews changed code against your own past review comments, so it catches what
you would catch.

### /dream:plan

Turns a focus into a plan for one pull request, where each task is one commit.

### /dream:coherent-coding

Loads the coherent coding guide, so the agent designs and writes code to it.

### /dream:plain-english

Loads the Plain English guide, so the agent writes to be understood.

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
