# Concepts

This page names the things dream deals with and says what the words mean.

Each entry uses only words defined before it. An entry ends with the words that
its concept replaces, where it replaces any, in a line that begins "Replaces:".
A replaced word is not used for its concept in the skills, the documents or the
issues.

## Definitions

### dream

**dream** is a plugin of skills for building software with coding agents. Its
name is written in lower case, even at the start of a sentence.

### Coding agent

A **coding agent** is a language model that works on software by calling tools,
such as reading files, running commands and editing code, in a loop.

### Harness

A **harness** is a program that runs a coding agent, such as Claude Code or
Codex.

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
