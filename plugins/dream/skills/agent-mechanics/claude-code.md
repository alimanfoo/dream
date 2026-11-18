# Agent mechanics under Claude Code

This file gives the details of agent mechanics that are specific to Claude Code.
It follows the headings of `SKILL.md`, which describes the mechanics that Claude
Code and Codex share and should be read first, and adds to a section only what
is specific to Claude Code.

## What the context holds

Claude Code sends its system prompt ahead of the conversation on every request.

### At session start

Before the user types anything, Claude Code loads instruction files, auto
memory, the names of MCP tools, the listing of skills and information about the
environment.

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

### During the session

Claude Code inserts its own messages as system reminders, such as text that a
hook returns as `additionalContext`, or a note that a file the model edited
earlier has changed on disk.

### Across sessions

Claude Code also carries content across sessions in its auto memory index,
`MEMORY.md`, whose first 200 lines or 25 KB load at the start of every session.

## The turn

Each response from the Claude API ends with a stop reason. When the stop reason
is `tool_use`, the response contains one or more tool-use blocks, which Claude
Code executes before it sends the next request. When it is `end_turn`, the model
has finished, and that response is the turn's output. By default, in an
interactive session, Claude Code also sends a request between turns to compact a
conversation of at least 200,000 tokens that has been idle for about an hour.

### Other ends and continuations

A response can also stop because it reached `max_tokens`, matched a stop
sequence, reached the iteration limit of the server-tool loop, was a refusal, or
filled the context window, and Claude Code then determines what happens next.

### Asynchronous notifications

Work that runs in the background reports back through task notifications. The
model starts a background shell command by setting `run_in_background: true`,
and the command writes its output to a file that the model can read. A
background shell command and a background subagent send a notification when they
complete, fail or are stopped. By default, an MCP call in the main conversation
of an interactive session that is still running after two minutes moves to the
background and delivers its result in the same way. A Monitor watch usually runs
a script in the background and delivers each line that the script prints as it
arrives, and it can instead deliver each message from a WebSocket. Claude Code
prefixes each task notification, except a scheduled-trigger delivery, with a
notice that no human input has occurred. A notification that arrives while no
turn is running can start a turn without a user prompt.

## Tool calls and permissions

A tool call is a tool-use block in the model's output. Its input matches the
tool's schema exactly only when the tool's definition sets `strict: true`.

### Built-in, MCP and server tools

Built-in tools are implemented by Claude Code itself, which lists them in its
tools reference, and a skill runs through the built-in `Skill` tool rather than
adding a tool of its own. Server tools run on Anthropic's infrastructure, and
Claude Code's advisor tool is one.

Claude Code names an MCP tool `mcp__<server>__<tool>`, and a tool from a
plugin's server `mcp__plugin_<plugin>_<server>__<tool>`, and permission rules
refer to MCP tools by these names.

By default, Claude Code defers the definitions of MCP tools. At session start,
only the tools' names and the servers' instructions enter the context, and the
model loads a tool's full definition, when it decides to use the tool, with the
`ToolSearch` tool. Setting `ENABLE_TOOL_SEARCH` to `false` loads every
definition upfront, and a server marked `alwaysLoad` has its tools loaded
upfront regardless of `ENABLE_TOOL_SEARCH`.

By default, Claude Code saves a successful MCP result without images to a file
when it exceeds 25,000 tokens or, for a call that completes in the foreground,
50,000 characters, unless the tool declares its own limit. It replaces the
result in the context with a message that names the file.

### Permissions

Claude Code first runs any `PreToolUse` hooks. A hook can deny the call, force a
prompt, or let the call proceed without one, and a hook that exits with code 2
blocks the call before any permission rule is evaluated. Claude Code then
evaluates permission rules in order: a deny rule blocks the call, an ask rule
prompts the user to approve it, and an allow rule lets it run without approval.
An allow rule for an MCP tool takes no specifier. A call that no hook or rule
decides follows the defaults of the session's permission mode. In Manual mode,
file edits and shell commands outside a built-in set of read-only commands
require approval. If the user answers a prompt from the main conversation with
No and adds no comment, Claude Code stops the turn.

When no one is present to answer a prompt, the outcome depends on the run. In a
non-interactive run with no permission host, a call that would prompt is denied.
A permission host, such as an Agent SDK `canUseTool` callback or an MCP tool
named by `--permission-prompt-tool`, answers prompts on the user's behalf, and a
run with one waits for its answer. That changes when `--permission-prompts none`
or the `permissions.denyInsteadOfPrompting` setting is in effect: a call that
would prompt is then denied unless a `PermissionRequest` hook allows it, and the
model is told that nobody can approve the request and not to retry it.

## Hooks

Claude Code supports five types of handler: a shell command, an HTTP endpoint,
an MCP tool, a prompt that a Claude model evaluates, and an experimental
subagent.

### Hook events

Claude Code defines further events, for example for failed tool calls,
notifications, changes to configuration and files, and model switches.

### Hook input and output

An HTTP hook receives the event as the body of a POST request. The fields of
valid JSON output decide whatever the exit code. Any exit code other than 0 or 2
with plain or empty output, invalid JSON or a failure to start is a non-blocking
error, and a hook that times out is cancelled and its output discarded. On a
command or HTTP hook, `onFailure: "block"` makes a failure act as exit code 2
would on that event, except that it denies a `PermissionRequest`. It has no
effect on asynchronous hooks, or on `Stop`, `SubagentStop`, `TaskCompleted` and
`TeammateIdle` hooks.

### What a hook can control

A `PreToolUse` hook can deny a tool call, force a prompt, let the call skip the
prompt, with some exceptions, or, in a non-interactive run whose turn makes a
single tool call, defer it. When hooks disagree, deny takes precedence over
defer, defer over ask, and ask over allow, and an allow does not override a deny
or ask rule. A `PermissionRequest` hook's allow does not override a matching
deny rule.

By default, after stop hooks have continued a turn eight times in a row with no
tool call between, Claude Code overrides the next block and ends the turn, and
`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` raises that limit.

### Hook output in the context

A hook adds text to the context through its `additionalContext` field, or
through plain standard output on events such as `SessionStart` and
`UserPromptSubmit`. Claude Code wraps the text in a system reminder and inserts
it where the hook fired: at the start of the conversation for `SessionStart`,
beside the prompt for `UserPromptSubmit`, beside the tool result for the tool
events, and at the end of the turn for `Stop`. It caps each such string at
10,000 characters and replaces a longer one with a file path and a preview. The
text that mid-session events add is saved in the transcript and replayed when
the session is resumed, and `SessionStart` hooks run again instead. At
compaction the text is summarised with the rest of the conversation. A
synchronous hook's `systemMessage` is a warning shown to the user, and some
events discard it. An asynchronous hook's `systemMessage` goes to the model
instead.

### Where hooks are defined

Claude Code reads hooks from user, project and local settings, from managed
policy settings and from an enabled plugin's `hooks/hooks.json`. A skill's
frontmatter can also define hooks, which apply for the rest of the session once
the skill is invoked, and a subagent's frontmatter can define hooks that apply
while that subagent runs. A program using the Agent SDK can also pass hooks as
callbacks. An identical handler defined in several settings files runs once.
Hooks from settings, managed policy and plugins run inside subagents. In an
interactive session, hooks from settings files wait until the user accepts the
workspace-trust dialog. The managed setting `allowManagedHooksOnly` blocks user,
project, local and plugin hooks, except hooks from plugins that managed settings
force-enable.

## Plugins

The manifest is `.claude-plugin/plugin.json`, and `name` is its only required
field. The manifest is optional, and a plugin without one takes its name from
its marketplace entry, or from its directory when it is loaded with
`--plugin-dir`.

### What a plugin contributes

A plugin can bundle skills, commands, subagent definitions, hooks, MCP and LSP
servers, monitors, executables and several other kinds of component. While the
plugin is enabled, the name and description of each skill, subagent and command
that the model can invoke itself are in the context on every turn, within the
limits given under [The skill listing](#the-skill-listing), and the full text
loads only when it is used. A `CLAUDE.md` at the plugin's root is not loaded
into the context.

Other components act whether or not the model uses the plugin's skills. Claude
Code registers the plugin's hooks when the session loads the plugin, and they
fire on their events from then on. It starts the plugin's MCP servers at session
start. In an interactive session, a monitor runs a shell command in the
background, and what the command prints reaches the model as notifications.
Monitors do not start in a non-interactive run. The plugin's executables are on
the `PATH` of the shell that runs the model's shell commands.

### Plugin names

Claude Code namespaces every component of a plugin under the plugin's name, so a
subagent `reviewer` in a plugin `deploy-tools` is `deploy-tools:reviewer`. A
plugin's skill is invoked as `/<plugin>:<directory>`, and a `name` in the
skill's frontmatter replaces the directory in that name. A skill and a subagent
in the same plugin can therefore have the same scoped name. A plugin's skill
loads alongside a skill of the same name from elsewhere, because the prefix
keeps them apart, but when subagents share a name, a plugin's has the lowest
priority.

### Which copy of a plugin loads

Claude Code copies a plugin installed from a marketplace into a versioned cache
directory and loads that copy, with three exceptions that load in place: a
plugin loaded with `--plugin-dir`, a relative-path plugin in a marketplace added
from a local path, and a `command`-source plugin in link mode. Edits to a
relative-path plugin take effect at the next session start or after
`/reload-plugins`. A running session keeps the versions it loaded, even when a
plugin updates during it.

## Skills

Every frontmatter field is optional: the name defaults to the folder's name, and
the description to the first non-empty line of the body.

### The skill listing

By default, Claude Code lists every skill's name but drops descriptions to fit a
character budget of 1% of the context window, and caps each skill's combined
`description` and `when_to_use` text at 1,536 characters. It lists no
description for a skill whose frontmatter sets `disable-model-invocation: true`.

### Invocation

A skill runs when the user puts its name, as `/name`, at the start of a message,
unless its frontmatter sets `user-invocable: false`, or when the model invokes
it with the Skill tool. A name that follows other text only permits the model to
run the skill. Claude Code then renders `SKILL.md`. It substitutes arguments and
variables such as `${CLAUDE_SKILL_DIR}`, and runs each `` !`command` ``
placeholder as a shell command whose output replaces the placeholder. It appends
the rendered content to the conversation as a single message. Frontmatter can
extend what invocation does: `allowed-tools` grants permission to use tools
during the turn, `model` and `effort` override the model and effort level for
the rest of the turn, and `hooks` registers hooks for the rest of the session.
With `context: fork`, the skill runs in a new subagent instead, which receives
the rendered content as its prompt and does not see the conversation history.

### Invoked content over time

Claude Code does not re-read the skill file, so editing the file does not change
the content already in the context. If the skill is invoked again, Claude Code
adds a short note that it is already loaded when the rendered content is
unchanged, and appends the full content again when it has changed. After
compaction, Claude Code re-attaches the most recent invocation of each skill,
keeping at most the first 5,000 tokens of each and 25,000 tokens in all, and
drops the oldest invocations first.

### Supporting files and paths

A `` !`command` `` placeholder can also inject a file's content when the skill
is invoked. The shell's current working directory moves when the model runs
`cd`. Claude Code replaces `${CLAUDE_SKILL_DIR}` in a skill's content with the
folder that contains its `SKILL.md`.

## Subagents

The model requests a subagent with the Agent tool. The user can also start a
fork with `/subtask`, and a skill with `context: fork` runs in a subagent.

### Initial context

A fresh subagent's initial context holds its own system prompt with environment
details, the task message, the same `CLAUDE.md` files that the main conversation
loads, a snapshot of the repository's git status when there is one, and the full
content of any skills that its definition preloads. A definition that sets
`omitClaudeMd` loads at most the managed-policy files, and the built-in Explore
and Plan subagents omit the `CLAUDE.md` files and git status. A fresh subagent
does not see the main conversation's history, the skills already invoked in it,
or the files already read. A fork sees the same system prompt, tools, model and
message history as its parent, and the model can start one itself while fork
mode is on, as it is by default.

### Results and side effects

A subagent's summary comes back with a small metadata trailer, and a background
subagent's result reaches the parent as a completion notification in a later
turn. A fork started with `isolation: "worktree"` writes its file edits to a
separate git worktree instead of the user's checkout.

### Subagent definitions

Claude Code registers each Markdown file in a plugin's `agents/` directory,
searched recursively, as a subagent type with a scoped name such as
`my-plugin:review:security`, named as described under
[Plugin names](#plugin-names). It ignores the `hooks`, `mcpServers` and
`permissionMode` fields of a plugin's subagent definitions.

## Compaction

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
only as far as the summary records them.

## Running an agent from a program

### Programmatic interfaces

Claude Code runs non-interactively with the `-p` flag, which takes the prompt as
an argument, and also reads input piped to standard input. The Agent SDK, for
Python and TypeScript, is a library that runs the Claude Code binary. Its
`query()` function yields messages as the agent loop runs: an initial system
message, the model's responses and the tool calls between them, and finally a
result message that holds the final text, the token usage, the cost and the
session ID.

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

### Approvals and limits in a non-interactive run

From Claude Code v2.1.302, a `claude -p` or Agent SDK run with no permission
mode set starts in Manual mode. A call that needs approval is then denied unless
an allow rule, a hook, the SDK's `canUseTool` callback or a
`--permission-prompt-tool` approves it, as described under
[Permissions](#permissions). A program can bound the run with `--max-turns` and
`--max-budget-usd`, and request output that matches a JSON Schema with
`--json-schema`. The Agent SDK has equivalent turn and budget options, and when
a limit is reached, it returns a result with an error subtype such as
`error_max_turns`.

### Sessions across runs

A program continues the most recent Claude Code session with `--continue`, or a
specific one with `--resume` and the session ID from an earlier run's JSON
output. The resumed context holds the conversation history, with the last
compaction's summary in place of the messages that the compaction summarised,
but options such as `--mcp-config` and `--plugin-dir` must be passed again.
