---
name: agent-mechanics
description:
  Explains how coding agents work under Claude Code and Codex. Use only when
  explicitly invoked.
---

# dream:agent-mechanics

This guide describes the mechanics of a coding agent under Claude Code and
Codex. It is written for software engineers, including those new to agentic
systems, who build systems that contain agents, such as prompts, skills,
subagent definitions and programs that run agents. From these mechanics, an
engineer can predict what the agents in such a system will do. Where Claude Code
and Codex differ in a way that changes an agent's behaviour, the guide describes
both. Each statement holds for the versions given in [`sources.md`](sources.md),
which lists the sources that support each paragraph.

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

Claude's underlying model is autoregressive. In the Transformer architecture of
Vaswani et al., an autoregressive model generates its output one token at a
time, consuming the tokens it has already generated as additional input when it
generates the next, and a softmax converts its output at each step into
probabilities for the next token. A token is then selected. The temperature
parameter controls how random the selection is, and even at temperature 0 the
output is not fully deterministic. Generation continues until a stop condition
is met, for example when the model finishes its response, emits a tool call or
reaches a token limit.

### Inference requests

The harness obtains each response by sending the model an inference request. The
Claude Messages API is stateless: the client sends the full conversation with
every request. With message threads, a beta feature, the API keeps the
conversation instead, and each request sends only the new messages. Either way,
the context of a request holds what the harness has supplied, namely a system
prompt, the definitions of the available tools and the conversation so far,
together with a tool-use system prompt that the API adds whenever tools are
defined.

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

Claude Code sends its system prompt ahead of the conversation on every request.
A request's tool definitions give each tool's name, description and input
schema, and count toward the request's input tokens. Both harnesses can defer
the definitions of MCP tools, so that a tool's full definition enters the
context only when the model looks it up, as described under
[Built-in, MCP and server tools](#built-in-mcp-and-server-tools). Everything
else the harness adds, from instruction files to conversation history, occupies
the context window too.

### At session start

At session start, the harness adds further content. Before the user types
anything, Claude Code loads instruction files, auto memory, the names of MCP
tools, the listing of skills and information about the environment. Codex builds
an initial context from sections that include the instruction files, the listing
of skills and the environment. The listing of skills is described under
[The skill listing](#the-skill-listing).

### Instruction files

Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from the working directory
and every directory above it, the project's `.claude/CLAUDE.md`, the user's
`CLAUDE.md` and any managed-policy `CLAUDE.md`, and each project or user rule
file that declares no path pattern. It delivers them as system reminders,
messages that it inserts into the conversation, rather than as part of the
system prompt. It loads a `CLAUDE.md` in a subdirectory of the working directory
only when the model reads, writes or edits a file in that subdirectory, and a
rule with a path pattern only when the model reads, writes or edits a matching
file, including reading it with a shell command such as `cat`. By default, it
reads `AGENTS.md` only when no `CLAUDE.md` exists in the working directory or
above it.

Codex loads `AGENTS.override.md` from its home directory, or `AGENTS.md` if the
override is missing or empty. In a trusted project, it then loads one file from
each directory from the project root down to the working directory,
`AGENTS.override.md` if one exists and otherwise `AGENTS.md`. The project root
is the nearest ancestor that contains a root marker, `.git` by default, and
without one Codex searches only the working directory. It loads at most 32 KiB
of project instruction files by default. Codex re-reads its instruction files at
request boundaries, and when their text changes, it sends the model a
replacement for the instructions it gave before.

### During the session

As the session runs, the harness appends each user message, each response that
the model generates, including its text and tool-use blocks, and each tool
result. It also inserts system reminders of its own, such as text that a hook
returns as `additionalContext`, or a note that a file the model edited earlier
has changed on disk. A hook is a handler, such as a shell command, that the
harness runs at a fixed point in its lifecycle, for example before a tool runs
or at session start, as described under [Hooks](#hooks).

### Across sessions

Each new harness session starts with a fresh context window, without the
conversation history of earlier sessions. Resuming a session reopens it and
appends new messages to its existing conversation. Otherwise, content from an
earlier session is in a new session's context only if something brings it in,
such as the user's input, a tool result, a hook's output, or a file that the
harness loads at session start. Such files include the instruction files and,
under Claude Code, the auto memory index, `MEMORY.md`, whose first 200 lines or
25 KB load at the start of every session.

## The turn

A turn is one complete response from the agent: it begins when the user sends a
message and ends when the agent finishes responding, with any number of tool
calls in between. A turn can also begin without a user message, as described
under [Asynchronous notifications](#asynchronous-notifications). The harness
appends the input to the conversation and sends an inference request. Each
response ends with a stop reason. When the stop reason is `tool_use`, the
response contains one or more tool-use blocks, and the harness executes them,
appends their results, and sends the next request. When it is `end_turn`, the
model has finished, and that response is the turn's output. Codex runs the same
loop: it sends another request when the model has called a tool, when the
response does not end the turn, or when the user has queued further input.
Between turns, the harness starts no new turn until new input arrives, but it
can still send a request. By default, in an interactive session, Claude Code
compacts a conversation of at least 200,000 tokens that has been idle for about
an hour. With a provider that supports WebSockets, Codex sends a warm-up
request, which generates no output, when a session starts or an idle thread
resumes. Background work, such as a background subagent, can go on running
between turns.

### Other ends and continuations

A turn can also end, or continue, in other ways. A response can stop because it
reached `max_tokens`, matched a stop sequence, reached the iteration limit of
the server-tool loop, was a refusal, or filled the context window, and the
harness then determines what happens next. Server tools, such as web search, run
on Anthropic's infrastructure, and their results arrive within the response
without the harness executing anything. The exception is a server tool called in
the same group of parallel calls as a client tool: the API then returns without
running it, so that the harness can run the client tools first. Under both
harnesses, a `Stop` hook can prevent a turn from ending and continue the
conversation. The user can also interrupt a turn at any point.

### Asynchronous notifications

Under Claude Code, work that runs in the background reports back through task
notifications. The model starts a background shell command by setting
`run_in_background: true`, and the command writes its output to a file that the
model can read. A background shell command and a background subagent send a
notification when they complete, fail or are stopped. By default, an MCP call in
the main conversation of an interactive session that is still running after two
minutes moves to the background and delivers its result in the same way. A
Monitor watch usually runs a script in the background and delivers each line
that the script prints as it arrives, and it can instead deliver each message
from a WebSocket. Claude Code prefixes each task notification, except a
scheduled-trigger delivery, with a notice that no human input has occurred. A
notification that arrives while no turn is running can start a turn without a
user prompt.

Under Codex, `exec_command` returns a session ID for a command that is still
running, and the model receives the command's later output only by polling that
session with `write_stdin`. When the command exits, Codex sends an event to its
client but adds nothing to the conversation. A version 2 subagent's completion
reaches its parent as a message in the parent's mailbox, and a version 1
subagent's completion is injected into the parent as a notification without
starting a turn. While the parent's turn is running and its model has not yet
given a final answer, Codex adds a mailbox message to the history before the
next request, and sends that request because of it. Otherwise the message waits
for the next turn. An idle parent starts a turn for a message only when the
sender asked for one, as `followup_task` does, or when the
`wake_on_agent_messages` feature, off by default, is on. Codex's goal extension,
on by default, can also start a turn when the thread is idle and a goal is
active.

## Tool calls and permissions

A tool call is a tool-use block in the model's output: it names a tool and gives
an input for it. The input matches the tool's schema exactly only when the
tool's definition sets `strict: true`. The model only emits the block. The
harness decides whether to run the call and sends back a tool result, which
holds either the call's output or the reason it did not run. The model receives
the result in its next request. A tool can change state outside the context,
such as files on disk or a repository's history. The context gains only the call
and its result, so the model can condition on such a change only through what
the result reports.

### Built-in, MCP and server tools

Under Claude Code, the model's tools are of three kinds. Built-in tools are
implemented by Claude Code itself, which lists them in its tools reference, and
a skill runs through the built-in `Skill` tool rather than adding a tool of its
own. MCP tools are provided by MCP servers, as described below. Server tools run
on Anthropic's infrastructure rather than in the harness, and Claude Code's
advisor tool is one. Codex builds the model's tools for each step from its core
tools, such as `exec_command` and `apply_patch`, from MCP tools, from tools that
its extensions provide, from tools that a client supplies, and, where the
provider supports it, from a hosted web search tool.

An MCP server is a program that gives the model tools, prompts or resources over
the Model Context Protocol. Claude Code names an MCP tool
`mcp__<server>__<tool>`, and a tool from a plugin's server
`mcp__plugin_<plugin>_<server>__<tool>`, and permission rules refer to MCP tools
by these names. Codex reads its MCP servers from the `mcp_servers` table of
`config.toml`. By default, it presents each server's tools to the model in a
namespace named `mcp__<server>`. It replaces any character other than an ASCII
letter, a digit or an underscore with an underscore, and adjusts names where
necessary so that each is unique and at most 128 bytes long.

By default, Claude Code defers the definitions of MCP tools. At session start,
only the tools' names and the servers' instructions enter the context, and the
model loads a tool's full definition, when it decides to use the tool, with the
`ToolSearch` tool. Setting `ENABLE_TOOL_SEARCH` to `false` loads every
definition upfront, and a server marked `alwaysLoad` has its tools loaded
upfront regardless of `ENABLE_TOOL_SEARCH`. Codex defers MCP tools when the
model supports tool search, as every model bundled at the pinned commit does,
unless a server's configuration keeps its tools direct. It omits deferred tools
from the definitions sent with each request, and the model finds them by calling
`tool_search`, which ranks them with BM25 and adds the full definitions of the
best matches to the history: up to eight by default, or as many as the call's
`limit` asks for. A Codex server's instructions become the description of its
namespace.

By default, Claude Code saves a successful MCP result without images to a file
when it exceeds 25,000 tokens or, for a call that completes in the foreground,
50,000 characters, unless the tool declares its own limit. It replaces the
result in the context with a message that names the file. An allow rule for an
MCP tool takes no specifier. Codex truncates an MCP result to the tool's
configured output limit or, failing that, to the model's truncation policy. By
default, Codex decides from a tool's annotations whether a call to it needs
approval: a tool annotated as read-only needs none, and any other tool needs
approval unless it is annotated as neither destructive nor open-world. Under the
`never` policy, a call that needs approval is denied unless a
`PermissionRequest` hook or an automatic reviewer approves it. It is approved
without asking when Codex applies no sandbox of its own or grants full write
access to the disk.

### Permissions under Claude Code

Claude Code first runs any `PreToolUse` hooks. A hook can deny the call, force a
prompt, or let the call proceed without one, and a hook that exits with code 2
blocks the call before any permission rule is evaluated. Claude Code then
evaluates permission rules in order: a deny rule blocks the call, an ask rule
prompts the user to approve it, and an allow rule lets it run without approval.
A call that no hook or rule decides follows the defaults of the session's
permission mode. In Manual mode, file edits and shell commands outside a
built-in set of read-only commands require approval. If the user answers a
prompt from the main conversation with No and adds no comment, Claude Code stops
the turn.

When no one is present to answer a prompt, the outcome depends on the run. In a
non-interactive Claude Code run with no permission host, a call that would
prompt is denied. A permission host, such as an Agent SDK `canUseTool` callback
or an MCP tool named by `--permission-prompt-tool`, answers prompts on the
user's behalf, and a run with one waits for its answer. That changes when
`--permission-prompts none` or the `permissions.denyInsteadOfPrompting` setting
is in effect: a call that would prompt is then denied unless a
`PermissionRequest` hook allows it, and the model is told that nobody can
approve the request and not to retry it.

### Approval under Codex

Codex decides according to its approval policy. Under the `never` policy, which
non-interactive `codex exec` runs use by default, Codex never asks the user. A
command that no execution-policy rule matches runs in the sandbox, unless Codex
flags it as dangerous, in which case it is rejected. A command that a rule marks
for approval is also rejected, while a command that allow rules match in full
can run outside the sandbox where the filesystem policy permits it. A rejection
or a failure inside the sandbox is returned to the model as the call's result.

## Hooks

A hook is a handler that the harness runs at a fixed point in its lifecycle,
such as before a tool runs or when the model finishes responding. Hooks are
deterministic: they fire at those points rather than at the model's discretion.
Their output can block an action, approve a tool call, keep a turn going or add
text to the context. Claude Code supports five types of handler: a shell
command, an HTTP endpoint, an MCP tool, a prompt that a Claude model evaluates,
and an experimental subagent. Codex runs command and MCP-tool handlers, and
skips prompt and agent handlers as not yet supported.

### Hook events

Both harnesses fire hooks at the start and end of a session (`SessionStart`,
`SessionEnd`), when the user submits a prompt (`UserPromptSubmit`), around a
tool call (`PreToolUse`, `PermissionRequest`, `PostToolUse`), around compaction
(`PreCompact`, `PostCompact`), when the main agent finishes responding (`Stop`),
and when a subagent starts or finishes (`SubagentStart`, `SubagentStop`). Claude
Code defines further events, for example for failed tool calls, notifications,
changes to configuration and files, and model switches. Codex adds `Interrupt`,
when a turn is interrupted, and `PreModelRequest` and `PostModelRequest`, around
each request to the model. A matcher restricts a hook to some occurrences of its
event, such as calls to a particular tool.

### Hook input and output

A command hook receives the event as JSON on standard input, under both
harnesses, and a Claude Code HTTP hook receives it as the body of a POST
request. Exit code 0 means success, and the hook can print a JSON object whose
fields carry its decisions. Exit code 2 blocks the action on an event that can
block, and under Codex it also requires a message on standard error.

Under Claude Code, the fields of valid JSON output decide whatever the exit
code. Any other exit code with plain or empty output, invalid JSON or a failure
to start is a non-blocking error, and a hook that times out is cancelled and its
output discarded. Under Codex, any other exit code, a timeout or a failure to
run is a non-blocking error. Under either harness, on most events the action
then goes ahead. On a Claude Code command or HTTP hook, `onFailure: "block"`
makes a failure act as exit code 2 would on that event, except that it denies a
`PermissionRequest`. It has no effect on asynchronous hooks, or on `Stop`,
`SubagentStop`, `TaskCompleted` and `TeammateIdle` hooks. A hook that runs
asynchronously cannot block or decide anything under either harness.

### What a hook can control

Under Claude Code, a `PreToolUse` hook can deny a tool call, force a prompt, let
the call skip the prompt, with some exceptions, or, in a non-interactive run
whose turn makes a single tool call, defer it. When hooks disagree, deny takes
precedence over defer, defer over ask, and ask over allow, and an allow does not
override a deny or ask rule. A `PermissionRequest` hook answers a permission
prompt with allow or deny, and its allow does not override a matching deny rule.
Under Codex, a `PreToolUse` hook can deny a call but cannot approve one, and it
can return `allow` only to rewrite the call's input. A Codex `PermissionRequest`
hook can allow or deny. Any deny wins, and an allow takes effect unless an
execution-policy rule requires a person to approve the command.

A `Stop` hook can keep a turn going. When it returns a block decision with a
reason, or exits with code 2, the harness gives the reason to the model, which
then generates again instead of ending the turn. By default, after stop hooks
have continued a turn eight times in a row with no tool call between, Claude
Code overrides the next block and ends the turn, and
`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` raises that limit. Codex delivers the reason
as a user message wrapped in a `<hook_prompt>` element. A `SubagentStop` hook
does the same for a subagent.

### Hook output in the context

Under Claude Code, a hook adds text to the context through its
`additionalContext` field, or through plain standard output on events such as
`SessionStart` and `UserPromptSubmit`. Claude Code wraps the text in a system
reminder and inserts it where the hook fired: at the start of the conversation
for `SessionStart`, beside the prompt for `UserPromptSubmit`, beside the tool
result for the tool events, and at the end of the turn for `Stop`. It caps each
such string at 10,000 characters and replaces a longer one with a file path and
a preview. The text that mid-session events add is saved in the transcript and
replayed when the session is resumed, and `SessionStart` hooks run again
instead. At compaction the text is summarised with the rest of the conversation,
but `SessionStart` hooks that match compaction run again and add their output
afresh. A synchronous hook's `systemMessage` is a warning shown to the user, and
some events discard it. An asynchronous hook's `systemMessage` goes to the model
instead.

Under Codex, only `SessionStart`, `SubagentStart`, `UserPromptSubmit`,
`PreToolUse` and `PostToolUse` hooks can add text to the context, through
`additionalContext` or, on the first three, plain standard output. Codex records
each piece of text as a separate message with the developer role. It writes text
over 2,500 tokens, by default, to a file and keeps a preview that names the
file. Neither local nor remote compaction keeps these messages in the history,
and after compaction, `SessionStart` hooks run again with the source `compact`.

### Where hooks are defined

Claude Code reads hooks from user, project and local settings, from managed
policy settings and from an enabled plugin's `hooks/hooks.json`. A skill's
frontmatter can also define hooks, which apply for the rest of the session once
the skill is invoked, and a subagent's frontmatter can define hooks that apply
while that subagent runs. A program using the Agent SDK can also pass hooks as
callbacks. Definitions from different places add together rather than replacing
one another, though an identical handler defined in several settings files runs
once. Hooks from settings, managed policy and plugins also run inside subagents.
In an interactive session, hooks from settings files wait until the user accepts
the workspace-trust dialog. The managed setting `allowManagedHooksOnly` blocks
user, project, local and plugin hooks, except hooks from plugins that managed
settings force-enable.

Codex reads hooks from managed requirements, from enabled plugins, and from each
enabled configuration layer, where a `hooks.json` file in the layer's folder or
a `[hooks]` table in its `config.toml` can define them. Definitions from all
these sources add together. A hook that is not managed runs only when it is
enabled and trusted. The user's trust is recorded against a hash of the hook's
definition and, for a plugin's hook, of the plugin's contents, so a changed hook
is not trusted until the user trusts it again. The requirement
`allow_managed_hooks_only` drops every hook that is not managed. Hooks also run
inside subagents, whose ID their input carries.

## Plugins

A plugin is a directory of components, such as skills, subagent definitions and
hooks, that an agent harness installs and loads as one unit. A plugin's name
usually comes from its manifest. Under Claude Code, the manifest is
`.claude-plugin/plugin.json` and `name` is its only required field. The manifest
is optional, and a plugin without one takes its name from its marketplace entry,
or from its directory when it is loaded with `--plugin-dir`. Codex recognises a
`plugin.json` at the plugin's root that declares an Agent Plugins `$schema`, and
otherwise reads, in order, `.codex-plugin/plugin.json`,
`.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` as a legacy
manifest.

### What a plugin contributes

A Claude Code plugin can bundle skills, commands, subagent definitions, hooks,
MCP and LSP servers, monitors, executables and several other kinds of component.
While the plugin is enabled, the name and description of each skill, subagent
and command that the model can invoke itself are in the context on every turn,
within the limits given under [The skill listing](#the-skill-listing), and the
full text loads only when it is used. A `CLAUDE.md` at the plugin's root is not
loaded into the context.

Other components act whether or not the model uses the plugin's skills. Claude
Code registers the plugin's hooks when the session loads the plugin, and they
fire on their events from then on. It starts the plugin's MCP servers at session
start. In an interactive session, a monitor runs a shell command in the
background, and what the command prints reaches the model as notifications.
Monitors do not start in a non-interactive run. The plugin's executables are on
the `PATH` of the shell that runs the model's shell commands.

A Codex plugin can bundle skills, MCP servers, apps and hooks, and has no
manifest field for subagent definitions. Codex loads a plugin's hooks only from
a legacy manifest, not from an Agent Plugins one. It runs a plugin's hook only
when the hook is enabled and is either managed, trusted or exempt from trust
checks. The recorded trust covers a hash of the plugin's contents, so editing
the plugin withdraws that trust. When it installs a plugin with a legacy
manifest, it converts the plugin's commands into skills, skipping any it cannot
convert.

### Plugin names

Claude Code namespaces every component of a plugin under the plugin's name, so a
subagent `reviewer` in a plugin `deploy-tools` is `deploy-tools:reviewer`. A
plugin's skill is invoked as `/<plugin>:<directory>`, and a `name` in the
skill's frontmatter replaces the directory in that name. A skill and a subagent
in the same plugin can therefore have the same scoped name. A plugin's skill
loads alongside a skill of the same name from elsewhere, because the prefix
keeps them apart, but when subagents share a name, a plugin's has the lowest
priority. Codex lists a plugin's skills with the plugin's name as a prefix, as
in `plugin:skill`, and a user can mention one as `$plugin:skill`.

### Which copy of a plugin loads

Claude Code copies a plugin installed from a marketplace into a versioned cache
directory and loads that copy, with three exceptions that load in place: a
plugin loaded with `--plugin-dir`, a relative-path plugin in a marketplace added
from a local path, and a `command`-source plugin in link mode. Edits to a
relative-path plugin take effect at the next session start or after
`/reload-plugins`. A running session keeps the versions it loaded, even when a
plugin updates during it.

Codex loads an installed plugin from a copy in its cache, at
`plugins/cache/<marketplace>/<plugin>/<version>` under its home directory.
Installing copies the plugin's directories and regular files but not its
symbolic links. Codex's automatic refresh reinstalls a plugin only when its
version changes, so an edit to the plugin's source that keeps the same version
does not reach the cached copy.

## Skills

A skill is a folder that contains a required file, `SKILL.md`. The file's
frontmatter gives the skill's name and description, and its body holds the
skill's content. Under Claude Code every frontmatter field is optional: the name
defaults to the folder's name, and the description to the first non-empty line
of the body.

### The skill listing

At session start, the harness adds a listing of the available skills to the
context, from which the model can decide to use one. The listing is bounded in
size. By default, Claude Code lists every skill's name but drops descriptions to
fit a character budget of 1% of the context window, and caps each skill's
combined `description` and `when_to_use` text at 1,536 characters. It lists no
description for a skill whose frontmatter sets `disable-model-invocation: true`.
By default, Codex lists each skill's name, description and path within a budget
of 2% of the context window, caps each description at 1,024 characters, and
omits any skill that does not allow implicit invocation.

### Invocation under Claude Code

Under Claude Code, a skill runs when the user puts its name, as `/name`, at the
start of a message, unless its frontmatter sets `user-invocable: false`, or when
the model invokes it with the Skill tool. A name that follows other text only
permits the model to run the skill. Claude Code then renders `SKILL.md`. It
substitutes arguments and variables such as `${CLAUDE_SKILL_DIR}`, and runs each
`` !`command` `` placeholder as a shell command whose output replaces the
placeholder. It appends the rendered content to the conversation as a single
message. Frontmatter can extend what invocation does: `allowed-tools` grants
permission to use tools during the turn, `model` and `effort` override the model
and effort level for the rest of the turn, and `hooks` registers hooks for the
rest of the session. With `context: fork`, the skill runs in a new subagent
instead, which receives the rendered content as its prompt and does not see the
conversation history.

### Invocation under Codex

Under Codex, a skill's body enters the context in one of two ways. When the
user's input mentions the skill as `$name`, the harness reads the whole of
`SKILL.md`, frontmatter included, and injects it into the conversation in a
`<skill>` element. Codex injects skills by one of two paths, which truncate
differently at 8,000 bytes: its skills extension truncates every skill that it
injects, and its core path truncates only a skill from a plugin with an Agent
Plugins manifest. Otherwise, the model reads `SKILL.md` itself, as the
instructions it is given direct: a filesystem skill with an ordinary file or
shell tool call, and other skills with the `skills.read` tool. The file then
reaches the context as that call's result.

### Invoked content over time

Once appended, a skill's content is part of the conversation and stays there
across later turns. Claude Code does not re-read the skill file, so editing the
file does not change the content already in the context. If the skill is invoked
again, Claude Code adds a short note that it is already loaded when the rendered
content is unchanged, and appends the full content again when it has changed.
After compaction, Claude Code re-attaches the most recent invocation of each
skill, keeping at most the first 5,000 tokens of each and 25,000 tokens in all,
and drops the oldest invocations first.

### Supporting files and paths

Other files in a skill's folder enter the context only when the model reads
them, or, under Claude Code, when a `` !`command` `` placeholder injects their
content. A script that the model runs contributes only its output. The model
writes each path into its tool call, and a shell command runs in the session
shell's current working directory, which moves when the model runs `cd`. A
relative path that the model copies from a skill into a tool call therefore
resolves against that working directory, not against the skill's folder. Claude
Code replaces `${CLAUDE_SKILL_DIR}` in a skill's content with the folder that
contains its `SKILL.md`, and Codex instructs the model to resolve a skill's
relative paths against that folder.

## Subagents

A subagent is a coding agent that the harness starts to carry out a delegated
task in a context of its own. The model can request one with a tool call: the
Agent tool under Claude Code, or `spawn_agent` under Codex. Under Claude Code,
the user can also start a fork with `/subtask`, and a skill with `context: fork`
runs in a subagent. A subagent starts either fresh, without the parent's
conversation history, or as a fork, with a copy of it.

### Initial context under Claude Code

Under Claude Code, a fresh subagent's initial context holds its own system
prompt with environment details, the task message, the same `CLAUDE.md` files
that the main conversation loads, a snapshot of the repository's git status when
there is one, and the full content of any skills that its definition preloads. A
definition that sets `omitClaudeMd` loads at most the managed-policy files, and
the built-in Explore and Plan subagents omit the `CLAUDE.md` files and git
status. A fresh subagent does not see the main conversation's history, the
skills already invoked in it, or the files already read. A fork sees the same
system prompt, tools, model and message history as its parent, and the model can
start one itself while fork mode is on, as it is by default.

### Initial context under Codex

Under Codex, the default depends on the multi-agent version. In version 1, a
subagent starts fresh unless the call sets `fork_context`. In version 2, it
inherits the parent's history unless the call sets `fork_turns` to `none`. A
version 1 fork's copy omits tool calls, tool outputs, reasoning and non-final
assistant messages. A version 2 fork's copy keeps them, unless
`preserve_fork_prefix`, which is on by default, is turned off. The version comes
from a feature flag or from the model's metadata. At the pinned commit, the
bundled models `gpt-6-astra`, `gpt-6-sol`, `gpt-6-luna`, `gpt-6.1-sol`,
`gpt-6.1-terra`, `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-daybreak-blue-latest` and
`gpt-daybreak-red-latest` select version 2. A fresh Codex subagent inherits the
parent's instruction files and any items that the parent always retains, and
then receives the task message as its input.

### Results and side effects

When a subagent finishes, the harness adds its final result to the parent's
context, and the subagent's own tool calls and results stay out of it. Under
Claude Code, a subagent's summary comes back with a small metadata trailer, and
a background subagent's result reaches the parent as a completion notification
in a later turn. Under Codex, the parent receives the subagent's final message
as a message or notification, and a version 2 subagent can also send the parent
messages while it runs. Changes that a subagent's tool calls make outside the
context, such as edits to files, persist after it finishes. Under Claude Code, a
fork started with `isolation: "worktree"` writes its file edits to a separate
git worktree instead of the user's checkout.

### Subagent definitions

The two harnesses find subagent definitions in different places. Claude Code
registers each Markdown file in a plugin's `agents/` directory, searched
recursively, as a subagent type with a scoped name such as
`my-plugin:review:security`, named as described under
[Plugin names](#plugin-names). It ignores the `hooks`, `mcpServers` and
`permissionMode` fields of a plugin's subagent definitions. Besides its built-in
`default`, `explorer` and `worker` roles, Codex loads agent roles only from its
configuration layers, as `[agents.<name>]` tables in `config.toml` and as TOML
files in each configuration folder's `agents/` directory. It does not read a
plugin's `agents/` directory. A Markdown subagent file therefore reaches a Codex
subagent only through its context, as a path in its task message that its model
then reads, or as content inherited in a fork.

## Compaction

Compaction removes content from the context.

### Compaction under Claude Code

Claude Code compacts automatically when the context window approaches its limit,
and by default also when a long conversation has been left idle. The user can
compact on demand with `/compact`. Compaction replaces the conversation history
with a summary.

After compaction, the system prompt still applies, and Claude Code re-injects
the project-root `CLAUDE.md`, rules without path patterns, auto memory, and the
listing of skills. It also re-injects a fresh git status if the session started
with one, up to five of the files that the model read or edited, most recently
modified first, and recent skill invocations within the limits given under
[Invoked content over time](#invoked-content-over-time). A re-read file over
5,000 tokens returns only as a path. Nested `CLAUDE.md` files and path-scoped
rules return only when the model next works with files they cover. Instructions
given only in the conversation, and context that hooks added earlier, survive
only as far as the summary records them, although `SessionStart` hooks that
match compaction run again and add their output.

### Compaction under Codex

Codex compacts automatically when the context reaches 90% of the context window,
or a lower configured limit. It checks the limit before each turn and before
each follow-up request within a turn. It checks after a turn only if a post-turn
threshold is configured, and by default none is. By default, for OpenAI
providers and Azure Responses providers, it requests compaction from the server,
which returns an encrypted compaction item. For other providers, it sends the
model a summarisation request and uses the summary. It then keeps the most
recent user messages within a token budget, 20,000 tokens for local compaction
and 64,000 for remote, and re-inserts the session's initial context.

## Running an agent from a program

A program can run either harness with no person present. The program supplies
the input and reads the output, and the harness still builds the context and
runs the loop as the earlier sections describe. What differs is what the run
loads, how requests for the user's approval resolve, and how the output returns
to the program.

### Programmatic interfaces

Claude Code runs non-interactively with the `-p` flag, which takes the prompt as
an argument, and also reads input piped to standard input. The Agent SDK, for
Python and TypeScript, is a library that runs the Claude Code binary. Its
`query()` function yields messages as the agent loop runs: an initial system
message, the model's responses and the tool calls between them, and finally a
result message that holds the final text, the token usage, the cost and the
session ID.

Codex runs non-interactively with `codex exec`, which takes the prompt as an
argument or from standard input. Given both, it appends standard input to the
prompt in a `<stdin>` block. By default, `codex exec` drives an app-server that
it starts in its own process, and with `--remote`, it connects to an existing
one. A program can also run `codex app-server`, an experimental server that
accepts requests such as `thread/start` and `turn/start` over standard I/O, a
Unix socket or a WebSocket. Its protocol is modelled on JSON-RPC 2.0 but omits
the `"jsonrpc"` field. Codex's TypeScript SDK runs `codex exec` as a child
process, and its Python SDK runs `codex app-server`.

### Output and exit status

By default, `claude -p` prints the final response as plain text. With
`--output-format json`, it prints a JSON object that holds the result, the
session ID and metadata, and with `stream-json`, it prints newline-delimited
JSON events as the run proceeds, ending with a `result` message. It exits with
code 0 on success and a non-zero code on failure, and it prints a failure inside
the run, such as missing authentication, as the result on standard output. A run
can stay open after its turn to wait for background work that the model started.
It waits for a background command that the main conversation started until the
command exits or reaches its time limit. It waits for other background work,
such as subagents and Monitor watches, until the work finishes or, by default,
10 minutes of idle waiting pass.

By default, `codex exec` writes nothing to standard output but the final agent
message, and writes everything else to standard error. With `--json`, it writes
one JSON event per line to standard output instead, such as `thread.started`,
`item.completed` and `turn.completed`. `--output-last-message` also writes the
final message to a file. `codex exec` exits with status 1 when its turn fails,
is interrupted or reports an error that it will not retry.

### What a non-interactive run loads

By default, `claude -p` discovers and loads what an interactive session would,
including hooks, skills, plugins, MCP servers and `CLAUDE.md` files. With
`--bare`, it skips that discovery: the model has the Bash, file read and file
edit tools, and the run loads only what the program passes with flags such as
`--mcp-config` and `--settings`, except that hooks never run in bare mode. The
Agent SDK reads the same user, project and local settings, `CLAUDE.md` files and
skills unless the program narrows its `settingSources`. Unless the program sets
a system prompt, the SDK uses a minimal one that covers tool calling, whereas
`claude -p` uses Claude Code's full system prompt. A non-interactive run shows
no workspace-trust dialog and treats the folder as trusted.

`codex exec` starts an in-process app-server as the interactive client does, and
loads `AGENTS.md` files, preferring `AGENTS.override.md`. It disables the
configuration of a project that is not trusted, including the project's MCP
servers, until the program trusts the project with `--trust`, which does not
override a project explicitly marked untrusted. Hooks also need recorded trust,
unless the program passes `--dangerously-bypass-hook-trust`.

### Approvals and limits in a non-interactive run

From Claude Code v2.1.302, a `claude -p` or Agent SDK run with no permission
mode set starts in Manual mode. A call that needs approval is then denied unless
an allow rule, a hook, the SDK's `canUseTool` callback or a
`--permission-prompt-tool` approves it, as described under
[Permissions under Claude Code](#permissions-under-claude-code). A program can
bound the run with `--max-turns` and `--max-budget-usd`, and request output that
matches a JSON Schema with `--json-schema`. The Agent SDK has equivalent turn
and budget options, and when a limit is reached, it returns a result with an
error subtype such as `error_max_turns`.

`codex exec` sets the approval policy to `never`, unless an automatic reviewer
is configured, and rejects any request for approval that reaches it. Its sandbox
defaults to workspace-write in a project with a trust decision and to read-only
otherwise. `--output-schema` constrains the final message to a JSON Schema.
`codex exec` has no flag that limits the number of turns or tokens.

### Sessions across runs

A program continues the most recent Claude Code session with `--continue`, or a
specific one with `--resume` and the session ID from an earlier run's JSON
output. The resumed context holds the conversation history, with the last
compaction's summary in place of the messages that the compaction summarised,
but options such as `--mcp-config` and `--plugin-dir` must be passed again.

`codex exec resume` continues a session given its ID, or the most recent one
with `--last`. The ID arrives in the `thread.started` event. Codex rebuilds the
history from the stored session, and the current run's sandbox and approval
policy, and its model when one is set, apply to the resumed session.
