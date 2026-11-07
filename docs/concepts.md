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
