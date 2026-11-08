# Concepts

This page names the things dream deals with and says what the words mean.

Each entry uses only words defined before it. An entry ends with the words that
its concept replaces, where it replaces any, in a line that begins "Replaces:".
A replaced word is not used for its concept in the skills, the documents or the
issues.

## Definitions

### Coding agent

A **coding agent** is a language model that works on software by using tools in
a loop, such as reading files, running commands and editing code, and that
decides for itself which tool to use next.

### Context

A coding agent's **context** is the sequence of tokens from which its language
model generates its next output. It includes every earlier input to the model
and every output from it.

### Compaction

**Compaction** is an operation that replaces earlier parts of a coding agent's
context with a summary of them.

### Harness

A **harness** is a program that turns a language model into a coding agent. It
supplies the tools, runs the loop and manages the context. Claude Code and Codex
are harnesses.

Replaces: "host".

### Skill

A **skill** is a folder of instructions or information that a harness gives its
coding agent. Its one required file, `SKILL.md`, holds a name, a description and
a body. The name and description are in the agent's context from the start. The
body loads into the agent's context only when the skill is invoked, by a person
or by the agent itself. The folder can also bundle scripts and other files,
which the agent reads or runs only when the body points it at them.

### User

The **user** is the person who gives a coding agent its input, and on whose
behalf the agent works.

### Session

A **session** is one conversation between a user and a coding agent, run by a
harness, with a context of its own.

### Turn

A **turn** is a coding agent's whole response to one input, from when the input
arrives until the agent answers without asking for another tool. A session is a
sequence of turns.

### Subagent

A **subagent** is a coding agent that another coding agent starts inside its
session to do a delegated task. It has a context of its own, and its final
output returns to the agent that started it.

### Subagent file

A **subagent file** is a Markdown file that defines a kind of subagent. Its
frontmatter holds a name and a description, and its body holds the instructions
the subagent starts from.

Replaces: "agent prompt", "named agent".

### Plugin

A **plugin** is a bundle of skills, subagent files and other extensions that a
harness installs as one unit.

### dream

**dream** is a plugin of skills for building software with coding agents. Its
name is written in lower case, even at the start of a sentence.

### Repository

A **repository** is the git repository that a coding agent works in.

### Issue

An **issue** is a GitHub issue on the repository. It can record anything worth
tracking, such as a bug, a maintenance chore, a small enhancement or an epic
describing a major new feature.

### Sub-issue and parent issue

A **sub-issue** is an issue that GitHub links beneath another issue, its
**parent issue**. A parent issue can have many sub-issues, and a sub-issue can
be a parent issue in turn.

Replaces: "child", "child issue".

### Pull request

A **pull request** is a GitHub pull request on the repository: a proposal to
merge the changes on one branch into another, where the changes can be reviewed
and discussed before they merge.

### Implementation plan and implementation step

An **implementation plan** is an ordered list of **implementation steps** that
delivers a change in one pull request. Each implementation step is one idea and
one commit.

Replaces: "task", for an implementation step.

### Review and finding

A **review** is a reading of a change, or of code or documents, that reports
each way the work could be better as a **finding**. A finding is one claim about
the work read, with the evidence for it. For example, a finding can name a bug,
a simpler form, a fact kept in two places, something a reader is missing, or a
departure from the repository's instructions.

### Review lens

A **review lens** is one narrow question that a review asks of the work it
reads. For example, whether a change introduces races, or whether each fact has
one home.

### Specification and specification folder

A **specification** is a document in the repository that records thinking about
a piece of work before it is built. For example, a requirements brief, a reading
guide, a design or a roadmap. The specifications for one piece of work are kept
together in a **specification folder**.

Replaces: "spec", for a specification.

### Requirements brief

A **requirements brief** is a specification of what the user wants and why,
without a solution. It says what the user wants to be able to do, what is wrong
or missing today, what has to be true of anything they would accept, what
constraints any solution must work within, how they will know it worked, and
what is still open.

### Reading guide

A **reading guide** is a specification that leads a reader through the existing
code behind a piece of work. It recommends what to read and in what order, gives
the background that makes the code make sense, and names the code's awkward
parts.
