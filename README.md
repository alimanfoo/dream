# dream

A plugin for Claude Code and Codex, for building software with agents.

The plugin provides skills. A skill is a named set of instructions you call from
the prompt, and it puts the agent to work in a particular way.

Some of the skills work on their own: give one a task and it carries the task to
a pull request while you do something else. Some work with you, one question at
a time, on the thinking that comes before code. The rest do one job each, such
as a review or a plan.

## Installation

Under Claude Code:

```text
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

Under Codex:

```bash
codex plugin marketplace add alimanfoo/dream
codex plugin add dream@dream
```

Every skill runs under Claude Code and under Codex. Call one by name, with a
leading slash under Claude Code and a `$` under Codex:

```text
/dream:smith
$dream:smith
```

Most of the skills work with GitHub issues and pull requests. For those, install
`gh` 2.94.0 or later and sign in.

## Autonomous coding skills

Give one of these skills a task and it carries the task to a pull request on its
own. It opens the pull request as a draft before it touches any code, and marks
it ready when the work is done. That pull request is where you can follow the
session, and where the skill asks you anything it can't decide for itself.

These skills can be used with
[alimanfoo/dreamcatcher](https://github.com/alimanfoo/dreamcatcher), a separate
package that watches a GitHub repository for labelled issues and dispatches
agents to implement them.

### /dream:smith

`/dream:smith` takes a well-specified task through planning, implementation and
review. It posts its plan for you to read, implements it one commit at a time,
then reviews the finished branch three ways: for coherence, for the bugs a set
of lenses chosen to fit the diff can find, and against the precedent in your own
past review comments. It posts each review, and what it did about each finding.

Name the task as an argument, such as `/dream:smith GH123` for an issue, or free
text for anything else. Without an argument, Smith uses the issue numbers in the
current branch name, such as `GH83`. Without those, it asks you for the task.

### /dream:less

`/dream:less` is a cut-back Smith for a small, self-contained change. It skips
the plan and runs one review rather than three. Name the task as an argument,
such as `/dream:less GH123`, or leave it out and Less reads the issue numbers in
the branch name.

## Collaborative product management skills

These skills work through the thinking that comes before code, and they work at
your pace: one question at a time, in chat, with room for you to redirect. Each
one ends in a written specification, which it offers to put in the repository as
a markdown file on a pull request. You can read it there and comment on any
line.

Run them in order on a large piece of work, or run whichever one you need. Each
takes an issue, a file or free text as an argument, so you can point one at what
the one before it wrote.

### /dream:spark

`/dream:spark` interviews you about a rough idea and turns it into a
requirements brief. It stays out of the solution, follows whichever thread you
are pulling on, and plays back what it heard before it writes anything down.
Bring an idea you haven't finished thinking about.

### /dream:state

`/dream:state` reads existing code with you, and leaves a reading guide to it.
Use it when you are about to design something in code you don't know well enough
yet. It explores while you watch, gives you the big picture first, then takes
you round the parts that matter.

### /dream:shape

`/dream:shape` works out a design with you. It keeps asking "what if" until the
shape stops moving, then asks what breaks until nothing more comes off, and
writes up the design you reach together. Bring a rough idea of what you want
built.

### /dream:seer

`/dream:seer` breaks a finished design into an ordered roadmap, where each stage
is one reviewable pull request. Once the roadmap has a home, it offers to create
one issue per stage, chained so each is blocked by the one before. It leaves
them unassigned and unlabelled, so you decide when implementation starts.

## Utility skills

The autonomous skills run most of these for you, and you can run any of them
yourself.

The review skills read the whole branch against `origin/main` by default, and
take a git range or a path as an argument.

### /dream:code-review

`/dream:code-review` reviews changed code through lenses picked to fit the diff.
A parser gets a malformed-input lens, concurrent code gets a races-and-ordering
lens. It verifies every finding against the code before it reports it, and ranks
what survives.

### /dream:coherence-review

`/dream:coherence-review` reviews changed code against the coherent coding
guide. It looks for the fix that stopped at the symptom, the edit that missed
one of its sites, the fact that now has two homes, and defensive code at the
wrong layer.

### /dream:precedent-review

`/dream:precedent-review` reviews changed code against the precedent in your own
past review comments on the repository, so it catches what you would catch. It
leaves out your comments on the pull request under review.

### /dream:coherent-coding

`/dream:coherent-coding` loads the coherent coding guide into the session. The
agent designs and writes to it from then on.

### /dream:plain-english

`/dream:plain-english` loads the Plain English guide into the session. Anything
the agent writes or says from then on is written to be understood, including by
a reader in a second language.

### /dream:plan

`/dream:plan` turns a focus into an implementation plan for a single pull
request, where each task is one idea and one commit.

## Troubleshooting

`/dream:smith` and `/dream:less` print the plugin version as they start. Quote
that version when you report a problem.

### Permissions

Start a session in an automatic permissions mode, so that most permissions are
handled for you.

Under Claude Code, when your plan includes `auto` mode:

```bash
claude --permission-mode auto
```

Under Codex:

```bash
codex --approve-for-me
```

If you hit permissions blocks, please raise an issue.

## License

MIT. See [LICENSE](LICENSE).
