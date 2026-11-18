---
name: agent-mechanics
description:
  Explains how coding agents work under Claude Code and Codex. Use only when
  explicitly invoked.
---

# dream:agent-mechanics

This guide describes the mechanics of a coding agent. It is written for software
engineers, including those new to agentic systems, who build systems that
contain agents, such as prompts, skills, subagent definitions and programs that
run agents. From these mechanics, an engineer can predict what the agents in
such a system will do.

This file describes the mechanics that Claude Code and Codex share. Two files
beside it, `claude-code.md` and `codex.md`, give the details specific to each
harness under the same headings. Read the file for each harness that the system
will run under, and both for a system meant to run under either. They are in the
folder that holds this file, which under Claude Code is `${CLAUDE_SKILL_DIR}`.

A coding agent has two components. The first is a language model, which predicts
the next token of a text from the tokens before it. The second is an agent
harness, such as Claude Code or Codex: the program around the model that
provides its tools, runs the loop that chains its actions, and manages the
context that the model sees. The model selects each action by emitting text, and
the harness performs it. A harness session is one conversation between a user
and a coding agent, run by an agent harness.

The model conditions only on the context of the request it receives. Every other
mechanism in this guide, from the instruction files loaded at session start to
tool results, skills, subagents and compaction, determines what that context
contains: what the harness adds to it, what it leaves outside it, and what it
removes from it.

## How the model generates text

A language model operates on tokens, the units into which text is encoded before
the model processes it. A token can correspond to a word, part of a word, a
character or a byte. The context is the sequence of tokens from which the model
generates its output, and its length is bounded by the model's context window,
the amount of text that the model can refer to when generating.

### Autoregressive generation

Language models such as Claude's are autoregressive. In the Transformer
architecture of Vaswani et al., an autoregressive model generates its output one
token at a time, consuming the tokens it has already generated as additional
input when it generates the next, and a softmax converts its output at each step
into probabilities for the next token. A token is then selected. The temperature
parameter controls how random the selection is, and even at temperature 0 the
output need not be fully deterministic. Generation stops when the selected token
is an end-of-sequence token, a special token in the model's vocabulary that
marks the end of its output, when the output matches a stop sequence that the
request specifies, or when the output reaches the request's token limit.

### Inference requests

The harness obtains each response by sending the model an inference request,
whose context holds what the harness has supplied: a system prompt, the
definitions of the available tools and the conversation so far. The model
retains nothing from one request to the next, so either the harness sends the
whole conversation with every request, or the provider's API keeps the
conversation and each request sends only the new messages. The provider's API
can also add content of its own to a request, such as instructions for using
tools.

### Consequences

Three consequences follow.

1. **The context is the model's only state.** The probabilities for each token
   are computed from the model's weights, which are fixed during inference, and
   from the tokens in the context. No other information carries over from one
   token to the next, or from one request to the next. Extended thinking, the
   reasoning that the model performs before responding, is made of thinking
   tokens that the model generates.
2. **Generation runs forward only.** In the Transformer, a mask, often called a
   causal mask, prevents each position from attending to the positions after it,
   so nothing computed for a token depends on the tokens generated after it. A
   generated token cannot be revised. Later tokens can only contradict or
   correct it.
3. **Output is not deterministic.** Identical inputs can produce different
   outputs from one request to the next, even at temperature 0.

## What the context holds

Everything the harness adds occupies the context window, from its system prompt
and instruction files to the conversation history. A request's tool definitions
give each tool's name, description and input schema, and count toward the
request's input tokens. Both harnesses can defer the definitions of MCP tools,
so that a tool's full definition enters the context only when the model looks it
up, as described under
[Built-in, MCP and server tools](#built-in-mcp-and-server-tools).

### At session start

At session start, the harness adds further content to the context, including
instruction files, a listing of the available skills and information about the
environment. The listing of skills is described under
[The skill listing](#the-skill-listing).

### Instruction files

Instruction files are Markdown files of instructions for a project or for the
user. The harness finds them by name in known locations, such as the working
directory and the directories above it, and adds them to the context.

### During the session

As the session runs, the harness appends each user message, each response that
the model generates, including its text and tool calls, and each tool result. It
also inserts messages of its own, such as text that a hook returns. A hook is a
handler, such as a shell command, that the harness runs at a fixed point in its
lifecycle, for example before a tool runs or at session start, as described
under [Hooks](#hooks).

### Across sessions

Each new harness session starts with a fresh context window, without the
conversation history of earlier sessions. Resuming a session reopens it and
appends new messages to its existing conversation. Otherwise, content from an
earlier session is in a new session's context only if something brings it in,
such as the user's input, a tool result, a hook's output, or a file that the
harness loads at session start, such as an instruction file.

## The turn

A turn is one complete response from the agent: it begins when the user sends a
message and ends when the agent finishes responding, with any number of tool
calls in between. A turn can also begin without a user message, as described
under [Asynchronous notifications](#asynchronous-notifications). The harness
appends the input to the conversation and sends an inference request. When the
response contains tool calls, the harness executes them, appends their results,
and sends the next request. When a response contains no tool call, the model has
finished, and that response is the turn's output. Between turns, the harness
starts no new turn until new input arrives, but it can still send a request, and
background work, such as a background subagent, can go on running.

### Other ends and continuations

A turn can also end, or continue, in other ways. A `Stop` hook can prevent a
turn from ending and continue the conversation, as described under
[Hooks](#hooks). The user can interrupt a turn at any point.

### Asynchronous notifications

Work that runs in the background, such as a background command or subagent, can
deliver content to the conversation after the turn that started it, and some
deliveries can start a turn without input from the user.

## Tool calls and permissions

A tool call is a structured block in the model's output that names a tool and
gives an input for it. The model only emits the block. The harness decides
whether to run the call and sends back a tool result, which holds either the
call's output or the reason it did not run. The model receives the result in its
next request. A tool can change state outside the context, such as files on disk
or a repository's history. The context gains only the call and its result, so
the model can condition on such a change only through what the result reports.

### Built-in, MCP and server tools

The model's tools are of three kinds: tools that the harness implements itself,
tools that MCP servers provide, and server tools, which run on the model
provider's infrastructure rather than in the harness. An MCP server is a program
that gives the model tools, prompts or resources over the Model Context
Protocol. Both harnesses name an MCP tool after its server, and both can defer
the definitions of MCP tools: the model then finds a tool by searching, and its
full definition enters the context only when the model looks it up.

### Permissions

Each harness decides whether a call may run from rules in its configuration,
from hooks, and from a mode or policy that applies to the whole session, and
some calls need a person's approval. When no one is present to approve a call,
the harness decides without asking, as its configuration directs.

## Hooks

A hook is a handler that the harness runs at a fixed point in its lifecycle,
such as before a tool runs or when the model finishes responding. Hooks are
deterministic: they fire at those points rather than at the model's discretion.
Their output can block an action, approve a tool call, keep a turn going or add
text to the context. Both harnesses run a hook that is a shell command or a call
to an MCP tool.

### Hook events

Both harnesses fire hooks at the start and end of a session (`SessionStart`,
`SessionEnd`), when the user submits a prompt (`UserPromptSubmit`), around a
tool call (`PreToolUse`, `PermissionRequest`, `PostToolUse`), around compaction
(`PreCompact`, `PostCompact`), when the main agent finishes responding (`Stop`),
and when a subagent starts or finishes (`SubagentStart`, `SubagentStop`). A
matcher restricts a hook to some occurrences of its event, such as calls to a
particular tool.

### Hook input and output

A command hook receives the event as JSON on standard input. Exit code 0 means
success, and the hook can print a JSON object whose fields carry its decisions.
Exit code 2 blocks the action on an event that can block. By default, a hook
that fails, for example by timing out, does not block, so on most events the
action goes ahead. A hook that runs asynchronously cannot block or decide
anything.

### What a hook can control

A `PreToolUse` hook can deny a tool call, and a `PermissionRequest` hook can
answer a request for approval with allow or deny.

A `Stop` hook can keep a turn going. When it returns a block decision with a
reason, or exits with code 2, the harness gives the reason to the model, which
then generates again instead of ending the turn. A `SubagentStop` hook does the
same for a subagent.

### Hook output in the context

A hook can add text to the context, which the harness inserts as a message of
its own. After compaction, `SessionStart` hooks that match compaction run again
and add their output afresh.

### Where hooks are defined

Hooks are defined in the harness's configuration, at levels that include managed
policy, the user and the project, and in plugins. Definitions from all these
sources add together rather than replacing one another, and hooks also run
inside subagents.

## Plugins

A plugin is a directory of components, such as skills, subagent definitions and
hooks, that an agent harness installs and loads as one unit. A plugin's name
usually comes from its manifest, a JSON file in the plugin.

### What a plugin contributes

A plugin can bundle skills, MCP servers and hooks, among other components, and
the harness loads them with the plugin.

### Plugin names

Both harnesses prefix a plugin's skills with the plugin's name, as in
`plugin:skill`.

### Which copy of a plugin loads

Both harnesses can load an installed plugin from a copy in a cache rather than
from its source, so an edit to the source does not necessarily reach a session.

## Skills

A skill is a folder that contains a required file, `SKILL.md`. The file's
frontmatter gives the skill's name and description, and its body holds the
skill's content.

### The skill listing

At session start, the harness adds a listing of the available skills to the
context, from which the model can decide to use one. The listing is bounded in
size.

### Invocation

A user can invoke a skill by naming it, and the model can invoke one itself.
Invoking a skill adds its content to the context, either as a message that the
harness appends or as the result of a tool call that reads the skill's file.

### Invoked content over time

Once added, a skill's content is part of the conversation and stays there across
later turns, subject to compaction.

### Supporting files and paths

Other files in a skill's folder enter the context only when the model reads
them, and a script that the model runs contributes only its output. The model
writes each path into its tool call, and a shell command runs in the shell's
current working directory. A relative path that the model copies from a skill
into a tool call therefore resolves against that working directory, not against
the skill's folder.

## Subagents

A subagent is a coding agent that the harness starts to carry out a delegated
task in a context of its own. The model can request one with a tool call. A
subagent starts either fresh, without the parent's conversation history, or as a
fork, with a copy of it.

### Initial context

A fresh subagent's context starts with instruction files that the parent loads
and the task it is given, and does not hold the parent's conversation history.

### Results and side effects

When a subagent finishes, the harness adds its final result to the parent's
context, and the subagent's own tool calls and results stay out of it. Changes
that a subagent's tool calls make outside the context, such as edits to files,
persist after it finishes.

### Subagent definitions

A subagent's instructions can come from a definition, which each harness finds
in its own places and formats.

## Compaction

Compaction removes content from the context. The harness compacts automatically
when the context nears the limit of the context window, and replaces earlier
parts of the conversation with a summary or an equivalent item. It then
re-inserts some content, such as instruction files, and content that existed
only in the conversation survives only as far as the summary records it.
`SessionStart` hooks that match compaction run again after it.

## Running an agent from a program

A program can run either harness with no person present. The program supplies
the input and reads the output, and the harness still builds the context and
runs the loop as the earlier sections describe. What differs is what the run
loads, how requests for the user's approval resolve, and how the output returns
to the program.
