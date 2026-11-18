# Agent mechanics under Codex

This file gives the details of agent mechanics that are specific to Codex. It
follows the headings of `SKILL.md`, which describes the mechanics that Claude
Code and Codex share and should be read first, and adds to a section only what
is specific to Codex.

## What the context holds

### At session start

Codex builds an initial context from sections that include the instruction
files, the listing of skills and the environment.

### Instruction files

Codex loads `AGENTS.override.md` from its home directory, or `AGENTS.md` if the
override is missing or empty. In a trusted project, it then loads one file from
each directory from the project root down to the working directory,
`AGENTS.override.md` if one exists and otherwise `AGENTS.md`. The project root
is the nearest ancestor that contains a root marker, `.git` by default, and
without one Codex searches only the working directory. It loads at most 32 KiB
of project instruction files by default. Codex re-reads its instruction files at
request boundaries, and when their text changes, it sends the model a
replacement for the instructions it gave before.

## The turn

Codex sends another request when the model has called a tool, when the response
does not end the turn, or when the user has queued further input.

### Asynchronous notifications

`exec_command` returns a session ID for a command that is still running, and the
model receives the command's later output only by polling that session with
`write_stdin`. Codex does not tell the model when the command exits. A
subagent's completion reaches its parent as a message. While the parent's turn
is running and its model has not yet given a final answer, the parent sees the
message before its next request, and Codex sends that request because of it.
Otherwise the message waits for the parent's next turn. By default, an idle
parent starts a turn for a message only when the sender asks for one, as
`followup_task` does. Codex's goal extension, on by default, can also start a
turn when the thread is idle and a goal is active.

## Tool calls and permissions

### Built-in, MCP and server tools

Codex builds the model's tools for each step from its core tools, such as
`exec_command` and `apply_patch`, from MCP tools, from tools that its extensions
provide, from tools that a client supplies, and, where the provider supports it,
from a hosted web search tool.

Codex reads its MCP servers from the `mcp_servers` table of `config.toml`. By
default, it presents each server's tools to the model in a namespace named
`mcp__<server>`, and it adjusts names that the model's API would not accept, so
the name that the model sees can differ from the one the server gives.

By default, Codex defers MCP tools. It omits them from the definitions sent with
each request, and the model finds them by calling `tool_search`, which adds the
full definitions of the best matches to the history, up to eight by default. A
server's instructions become the description of its namespace.

Codex truncates an MCP result to the tool's configured output limit or, failing
that, to the model's truncation policy.

### Permissions

Codex decides according to its approval policy. Under the `never` policy, which
non-interactive `codex exec` runs use by default, Codex never asks the user. A
command that no execution-policy rule matches runs in the sandbox, unless Codex
flags it as dangerous, in which case it is rejected. A command that a rule marks
for approval is also rejected, while a command that allow rules match in full
can run outside the sandbox where the filesystem policy permits it. A rejection
or a failure inside the sandbox is returned to the model as the call's result.

By default, Codex decides from an MCP tool's annotations whether a call to it
needs approval: a tool annotated as read-only needs none, and any other tool
needs approval unless it is annotated as neither destructive nor open-world.
Under the `never` policy, an MCP call that needs approval is denied unless a
`PermissionRequest` hook or an automatic reviewer approves it. It is approved
without asking when Codex applies no sandbox of its own or grants full write
access to the disk.

## Hooks

Codex runs command and MCP-tool handlers, and skips prompt and agent handlers as
not yet supported.

### Hook events

Codex adds `Interrupt`, when a turn is interrupted, and `PreModelRequest` and
`PostModelRequest`, around each request to the model.

### Hook input and output

Exit code 2 blocks only when the hook also writes a message to standard error.
Any other exit code, a timeout or a failure to run is a non-blocking error.

### What a hook can control

A `PreToolUse` hook can deny a call but cannot approve one, and it can return
`allow` only to rewrite the call's input. A `PermissionRequest` hook can allow
or deny. Any deny wins, and an allow takes effect unless an execution-policy
rule requires a person to approve the command.

A `Stop` hook's reason reaches the model as a user message wrapped in a
`<hook_prompt>` element.

### Hook output in the context

Only `SessionStart`, `SubagentStart`, `UserPromptSubmit`, `PreToolUse` and
`PostToolUse` hooks can add text to the context, through `additionalContext` or,
on the first three, plain standard output. Codex records each piece of text as a
separate message with the developer role. It writes text over 2,500 tokens, by
default, to a file and keeps a preview that names the file. Neither local nor
remote compaction keeps these messages in the history.

### Where hooks are defined

Codex reads hooks from managed requirements, from enabled plugins, and from each
enabled configuration layer, where a `hooks.json` file in the layer's folder or
a `[hooks]` table in its `config.toml` can define them. A hook that is not
managed runs only when it is enabled and trusted. The user's trust is recorded
against a hash of the hook's definition and, for a plugin's hook, of the
plugin's contents, so a changed hook is not trusted until the user trusts it
again. The requirement `allow_managed_hooks_only` drops every hook that is not
managed.

## Plugins

Codex recognises a `plugin.json` at the plugin's root that declares an Agent
Plugins `$schema`, and otherwise reads, in order, `.codex-plugin/plugin.json`,
`.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` as a legacy
manifest.

### What a plugin contributes

A plugin can bundle skills, MCP servers, apps and hooks, and has no manifest
field for subagent definitions. Codex loads a plugin's hooks only from a legacy
manifest, not from an Agent Plugins one. It runs a plugin's hook only when the
hook is enabled and is either managed, trusted or exempt from trust checks. The
recorded trust covers a hash of the plugin's contents, so editing the plugin
withdraws that trust. When it installs a plugin with a legacy manifest, it
converts the plugin's commands into skills, skipping any it cannot convert.

### Plugin names

A user can mention a plugin's skill as `$plugin:skill`.

### Which copy of a plugin loads

Codex loads an installed plugin from a copy in its cache. Installing copies the
plugin's directories and regular files but not its symbolic links. Codex's
automatic refresh reinstalls a plugin only when its version changes, so an edit
to the plugin's source that keeps the same version does not reach the cached
copy.

## Skills

### The skill listing

By default, Codex lists each skill's name, description and path within a budget
of 2% of the context window, caps each description at 1,024 characters, and
omits any skill that does not allow implicit invocation.

### Invocation

A skill's body enters the context in one of two ways. When the user's input
mentions the skill as `$name`, Codex reads the whole of `SKILL.md`, frontmatter
included, and injects it into the conversation in a `<skill>` element. It
truncates an injected skill to 8,000 bytes if the skill comes from a plugin with
an Agent Plugins manifest, or from an executor or cloud source, and injects a
filesystem skill, including one from a plugin with a legacy manifest, in full.
Otherwise, the model reads `SKILL.md` itself, as the instructions it is given
direct: a filesystem skill with an ordinary file or shell tool call, and other
skills with the `skills.read` tool. The file then reaches the context as that
call's result.

### Supporting files and paths

Codex instructs the model to resolve a skill's relative paths against the folder
that holds its `SKILL.md`.

## Subagents

The model requests a subagent with `spawn_agent`.

### Initial context

Whether a subagent starts fresh or as a fork by default depends on Codex's
multi-agent version, which by default the model's metadata selects. Under
version 1, a subagent starts fresh unless the call asks for a fork. Under
version 2, it starts as a fork unless the call asks to start fresh. Nine of the
twelve models bundled at the pinned commit select version 2. By default, a
version 2 fork sees the parent's full history, while a version 1 fork's copy
omits tool calls, tool outputs, reasoning and non-final assistant messages. A
fresh subagent inherits the parent's instruction files, and then receives the
task message as its input.

### Results and side effects

The parent receives the subagent's final message as a message or notification,
and a version 2 subagent can also send the parent messages while it runs.

### Subagent definitions

Besides its built-in `default`, `explorer` and `worker` roles, Codex loads agent
roles only from its configuration layers, as `[agents.<name>]` tables in
`config.toml` and as TOML files in each configuration folder's `agents/`
directory. It does not read a plugin's `agents/` directory. A Markdown subagent
file therefore reaches a Codex subagent only through its context, as a path in
its task message that its model then reads, or as content inherited in a fork.

## Compaction

Codex compacts automatically when the context reaches 90% of the context window,
or a lower configured limit, and it can do so before a turn or between requests
within a turn. Depending on the model provider, it replaces earlier history with
a summary that the model writes or with an encrypted item that the provider's
server returns. It keeps the most recent user messages, up to a token budget,
and re-inserts the session's initial context.

## Running an agent from a program

### Programmatic interfaces

Codex runs non-interactively with `codex exec`, which takes the prompt as an
argument or from standard input. Given both, it appends standard input to the
prompt in a `<stdin>` block. With `--remote`, it runs against an existing
app-server instead of starting its own. A program can also run
`codex app-server`, an experimental server that accepts requests such as
`thread/start` and `turn/start` over standard I/O, a Unix socket or a WebSocket.
Its protocol is modelled on JSON-RPC 2.0 but omits the `"jsonrpc"` field.
Codex's TypeScript SDK runs `codex exec` as a child process, and its Python SDK
runs `codex app-server`.

### Output and exit status

By default, `codex exec` writes nothing to standard output but the final agent
message, and writes everything else to standard error. With `--json`, it writes
one JSON event per line to standard output instead, such as `thread.started`,
`item.completed` and `turn.completed`. `--output-last-message` also writes the
final message to a file. `codex exec` exits with status 1 when its turn fails,
is interrupted or reports an error that it will not retry.

### What a non-interactive run loads

`codex exec` loads its configuration as the interactive client does, and loads
`AGENTS.md` files, preferring `AGENTS.override.md`. It disables the
configuration of a project that is not trusted, including the project's MCP
servers, until the program trusts the project with `--trust`, which does not
override a project explicitly marked untrusted. Hooks also need recorded trust,
unless the program passes `--dangerously-bypass-hook-trust`.

### Approvals and limits in a non-interactive run

`codex exec` sets the approval policy to `never`, unless an automatic reviewer
is configured, and rejects any request for approval that reaches it. Its sandbox
defaults to workspace-write in a project with a trust decision and to read-only
otherwise. `--output-schema` constrains the final message to a JSON Schema.
`codex exec` has no flag that limits the number of turns or tokens.

### Sessions across runs

`codex exec resume` continues a session given its ID, or the most recent one
with `--last`. The ID arrives in the `thread.started` event. Codex rebuilds the
history from the stored session, and the current run's sandbox and approval
policy, and its model when one is set, apply to the resumed session.
