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
engineer can predict what the agents in such a system will do. Each statement
holds for the versions given under [Sources](#sources), and where Claude Code
and Codex differ in a way that changes an agent's behaviour, the guide describes
both.

A coding agent has two components. The first is a language model, which predicts
the next token of a text from the tokens before it ([Claude
glossary][api-glossary-pretraining]). The second is an agent harness, such as
Claude Code or Codex: the program around the model that provides its tools, runs
the loop that chains its actions, and manages the context that the model sees
([how Claude Code works][cc-loop], [Claude Code glossary][cc-glossary-harness]).
The model selects each action by emitting text, and the harness performs it. A
harness session is one conversation between a user and a coding agent, run by an
agent harness.

The model conditions only on the context of the request it receives. Every other
mechanism in this guide, from the instruction files loaded at session start to
tool results, skills, subagents and compaction, determines what that context
contains: what the harness adds to it, what it leaves outside it, and what it
removes from it.

## How the model generates text

A language model operates on tokens, the units into which text is encoded before
the model processes it. A token can correspond to a word, part of a word, a
character or a byte ([Claude glossary][api-glossary-tokens]). The context is the
sequence of tokens from which the model generates its output, and its length is
bounded by the model's context window, the amount of text that the model can
refer to when generating ([Claude glossary][api-glossary-context]).

### Autoregressive generation

Claude's underlying model is autoregressive ([Claude
glossary][api-glossary-pretraining]). In the Transformer architecture of Vaswani
et al., an autoregressive model generates its output one token at a time,
consuming the tokens it has already generated as additional input when it
generates the next ([§3][transformer]), and a softmax converts its output at
each step into probabilities for the next token ([§3.4][transformer]). A token
is then selected. The temperature parameter controls how random the selection
is, and even at temperature 0 the output is not fully deterministic ([Claude
glossary][api-glossary-temperature]). Generation continues until a stop
condition is met, for example when the model finishes its response, emits a tool
call or reaches a token limit ([Claude stop reasons][api-stop-reasons]).

### Inference requests

The harness obtains each response by sending the model an inference request. The
Claude Messages API is stateless: the client sends the full conversation with
every request. With message threads, a beta feature, the API keeps the
conversation instead, and each request sends only the new messages ([Messages
API][api-messages]). Either way, the context of a request holds what the harness
has supplied, namely a system prompt, the definitions of the available tools and
the conversation so far, together with a tool-use system prompt that the API
adds whenever tools are defined ([Claude tool use][api-tool-use-pricing]).

### Consequences

Three consequences follow.

1. **The context is the model's only state.** The probabilities for each token
   are computed from the model's weights, which are fixed during inference, and
   from the tokens in the context. No other information carries over from one
   token to the next, or from one request to the next. Extended thinking, the
   reasoning that the model performs before responding, is made of thinking
   tokens that the model generates ([Claude Code
   glossary][cc-glossary-thinking]).
2. **Generation runs forward only.** In the Transformer, a mask, often called a
   causal mask, prevents each position from attending to the positions after it
   ([Vaswani et al., 2017, §3.2.3][transformer]), so nothing computed for a
   token depends on the tokens generated after it. A generated token cannot be
   revised. Later tokens can only contradict or correct it.
3. **Output is not deterministic.** Identical inputs can produce different
   outputs from one request to the next, even at temperature 0 ([Claude
   glossary][api-glossary-temperature]).

## What the context holds

Every request carries the harness's system prompt and its tool definitions, each
of which gives a tool's name, description and input schema ([Claude tool
use][api-tool-use-pricing]). Claude Code sends its system prompt ahead of the
conversation on every request ([Claude Code
glossary][cc-glossary-system-prompt]). By default it defers the definitions of
MCP tools, the tools that external servers provide through the Model Context
Protocol: until the model uses one, only the tools' names and their servers'
instructions occupy the context ([how Claude Code works][cc-context-fills]).
Everything else the harness adds, from instruction files to conversation
history, occupies the context window too ([Claude Code
glossary][cc-glossary-context]).

### At session start

At session start, the harness adds further content. Before the user types
anything, Claude Code loads instruction files, auto memory, the names of MCP
tools, the listing of skills and information about the environment ([Claude Code
context window][cc-context-timeline]). Codex builds an initial context from
sections that include the instruction files, the listing of skills and the
environment ([Codex `session/mod.rs`][cx-initial-context], [Codex
`world_state`][cx-world-state]). The listing of skills is described under
[The skill listing](#the-skill-listing).

### Instruction files

Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from the working directory
and every directory above it ([Claude Code memory][cc-memory-load]), the
project's `.claude/CLAUDE.md`, the user's `CLAUDE.md` and any managed-policy
`CLAUDE.md` ([Claude Code memory][cc-memory-where]), and each project or user
rule file that declares no path pattern ([Claude Code memory][cc-memory-rules]).
It delivers them as system reminders, messages that it inserts into the
conversation, rather than as part of the system prompt ([Claude Code
glossary][cc-glossary-system-prompt]). It loads a `CLAUDE.md` in a subdirectory
of the working directory only when the model reads, writes or edits a file in
that subdirectory ([Claude Code memory][cc-memory-load]), and a rule with a path
pattern only when the model reads, writes or edits a matching file, including
reading it with a shell command such as `cat` ([Claude Code
memory][cc-memory-path-rules]). By default, it reads `AGENTS.md` only when no
`CLAUDE.md` exists in the working directory or above it ([Claude Code
memory][cc-memory-agents]).

Codex loads `AGENTS.override.md` from its home directory, or `AGENTS.md` if the
override is missing or empty ([Codex
`instructions/mod.rs`][cx-home-instructions]). In a trusted project, it then
loads one file from each directory from the project root down to the working
directory, `AGENTS.override.md` if one exists and otherwise `AGENTS.md`. The
project root is the nearest ancestor that contains a root marker, `.git` by
default, and without one Codex searches only the working directory ([Codex
`agents_md.rs`][cx-agents-md]). It loads at most 32 KiB of project instruction
files by default ([Codex `config_toml.rs`][cx-doc-max]). Codex re-reads its
instruction files at request boundaries, and when their text changes, it sends
the model a replacement for the instructions it gave before ([Codex
`agents_md_manager.rs`][cx-agents-md-refresh], [Codex
`world_state/agents_md.rs`][cx-agents-md-replace]).

### During the session

As the session runs, the harness appends each user message, each response that
the model generates, including its text and tool-use blocks, and each tool
result ([Messages API][api-messages], [Claude tool use][api-tool-use]). It also
inserts system reminders of its own, such as text that a hook returns as
`additionalContext`, or a note that a file the model edited earlier has changed
on disk. A hook is a handler, such as a shell command, that the harness runs at
a fixed point in its lifecycle, for example before a tool runs or at session
start ([Claude Code glossary][cc-glossary-reminder], [Claude Code
glossary][cc-glossary-hook]).

### Across sessions

Each new harness session starts with a fresh context window, without the
conversation history of earlier sessions ([how Claude Code works][cc-sessions]).
Resuming a session reopens it and appends new messages to its existing
conversation ([how Claude Code works][cc-resume]). Otherwise, content from an
earlier session is in a new session's context only if something brings it in,
such as the user's input, a tool result, a hook's output, or a file that the
harness loads at session start. Such files include the instruction files and,
under Claude Code, the auto memory index, `MEMORY.md`, whose first 200 lines or
25 KB load at the start of every session ([Claude Code memory][cc-memory-auto]).

## The turn

A turn is one complete response from the agent: it begins when the user sends a
message and ends when the agent finishes responding, with any number of tool
calls in between ([Claude Code glossary][cc-glossary-turn]). The harness appends
the message to the conversation and sends an inference request. Each response
ends with a stop reason. When the stop reason is `tool_use`, the response
contains one or more tool-use blocks, and the harness executes them, appends
their results, and sends the next request. When it is `end_turn`, the model has
finished, and that response is the turn's output ([Claude stop
reasons][api-stop-reasons], [Claude tool use][api-tool-use]). Codex runs the
same loop: it sends another request when the model has called a tool, when the
response does not end the turn, or when the user has queued further input
([Codex `stream_events_utils.rs`][cx-tool-follow], [Codex `turn.rs`][cx-turn]).
Between turns, Claude Code sends no request for the main conversation, except to
compact a long conversation that has been left idle ([Claude Code
settings][cc-idle-compaction]), but background subagents can go on running
([Claude Code subagents][cc-sub-background]).

### Other ends and continuations

A turn can also end, or continue, in other ways. A response can stop because it
reached `max_tokens`, matched a stop sequence, reached the iteration limit of
the server-tool loop, was a refusal, or filled the context window, and the
harness then determines what happens next ([Claude stop
reasons][api-stop-reasons]). Server tools, such as web search, run on
Anthropic's infrastructure, and their results arrive within the response without
the harness executing anything. The exception is a server tool called in the
same group of parallel calls as a client tool: the API then returns without
running it, so that the harness can run the client tools first ([Claude tool
use][api-tool-use], [Claude stop reasons][api-stop-reasons]). Under both
harnesses, a `Stop` hook can prevent a turn from ending and continue the
conversation ([Claude Code hooks][cc-hooks-stop], [Codex `turn.rs`][cx-turn]).
The user can also interrupt a turn at any point ([Claude Code
glossary][cc-glossary-loop]).

## Tool calls and permissions

A tool call is a tool-use block in the model's output: it names a tool and gives
an input for it. The input matches the tool's schema exactly only when the
tool's definition sets `strict: true` ([Claude tool use][api-tool-use-when]).
The model only emits the block. The harness decides whether to run the call and
sends back a tool result ([Claude tool use][api-tool-use]), which holds either
the call's output or the reason it did not run. The model receives the result in
its next request. A tool can change state outside the context, such as files on
disk or a repository's history. The context gains only the call and its result,
so the model can condition on such a change only through what the result
reports.

### Permissions under Claude Code

Claude Code first runs any `PreToolUse` hooks. A hook can deny the call, force a
prompt, or let the call proceed without one ([Claude Code
permissions][cc-permissions-hooks]), and a hook that exits with code 2 blocks
the call before any permission rule is evaluated ([Claude Code
permissions][cc-permissions-precedence]). Claude Code then evaluates permission
rules in order: a deny rule blocks the call, an ask rule prompts the user to
approve it, and an allow rule lets it run without approval ([Claude Code
permissions][cc-permissions-manage]). A call that no hook or rule decides
follows the defaults of the session's permission mode. In Manual mode, file
edits and shell commands outside a built-in set of read-only commands require
approval ([Claude Code permissions][cc-permissions-system]). If the user answers
a prompt from the main conversation with No and adds no comment, Claude Code
stops the turn ([Claude Code permissions][cc-permissions-comment]).

When no one is present to answer a prompt, the outcome depends on the run. In a
non-interactive Claude Code run with no permission host, a call that would
prompt is denied. A permission host, such as an Agent SDK `canUseTool` callback
or an MCP tool named by `--permission-prompt-tool`, answers prompts on the
user's behalf, and a run with one waits for its answer. That changes when
`--permission-prompts none` or the `permissions.denyInsteadOfPrompting` setting
is in effect: a call that would prompt is then denied unless a
`PermissionRequest` hook allows it, and the model is told that nobody can
approve the request and not to retry it ([Claude Code
headless][cc-headless-perm]).

### Approval under Codex

Codex decides according to its approval policy ([Codex
`protocol.rs`][cx-approval]). Under the `never` policy, which non-interactive
`codex exec` runs use by default ([Codex `exec/src/lib.rs`][cx-exec-default]),
Codex never asks the user. A command that no execution-policy rule matches runs
in the sandbox, unless Codex flags it as dangerous, in which case it is rejected
([Codex `exec_policy.rs`][cx-exec-policy]). A command that a rule marks for
approval is also rejected, while a command that allow rules match in full can
run outside the sandbox where the filesystem policy permits it ([Codex
`exec_policy.rs`][cx-exec-policy-rules], [Codex
`sandboxing.rs`][cx-sandbox-bypass]). A rejection or a failure inside the
sandbox is returned to the model as the call's result ([Codex
`protocol.rs`][cx-approval]).

## Plugins

A plugin is a directory of components, such as skills, subagent definitions and
hooks, that an agent harness installs and loads as one unit ([Claude Code
plugins][cc-plugins]). A plugin's name usually comes from its manifest. Under
Claude Code, the manifest is `.claude-plugin/plugin.json` and `name` is its only
required field. The manifest is optional, and a plugin without one takes its
name from its marketplace entry, or from its directory when it is loaded with
`--plugin-dir` ([Claude Code plugin manifest][cc-plugin-manifest-file], [Claude
Code plugin manifest][cc-plugin-manifest-fields]). Codex recognises a
`plugin.json` at the plugin's root that declares an Agent Plugins `$schema`, and
otherwise reads, in order, `.codex-plugin/plugin.json`,
`.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` as a legacy
manifest ([Codex `plugin_namespace.rs`][cx-agent-plugin-manifest], [Codex
`exec-server-protocol/protocol.rs`][cx-legacy-manifests]).

### What a plugin contributes

A Claude Code plugin can bundle skills, commands, subagent definitions, hooks,
MCP and LSP servers, monitors, executables and several other kinds of component
([Claude Code plugin manifest][cc-plugin-layout]). While the plugin is enabled,
the name and description of each skill, subagent and command that the model can
invoke itself are in the context on every turn, within the limits given under
[The skill listing](#the-skill-listing), and the full text loads only when it is
used ([Claude Code plugins][cc-plugin-adds]). A `CLAUDE.md` at the plugin's root
is not loaded into the context ([Claude Code plugin
manifest][cc-plugin-layout]).

Other components act whether or not the model uses the plugin's skills. Claude
Code registers the plugin's hooks when the session loads the plugin, and they
fire on their events from then on ([Claude Code plugin
components][cc-plugin-hooks]). It starts the plugin's MCP servers at session
start ([Claude Code MCP][cc-mcp-plugin]). In an interactive session, a monitor
runs a shell command in the background, and what the command prints reaches the
model as notifications. Monitors do not start in a non-interactive run ([Claude
Code plugin components][cc-plugin-monitors]). The plugin's executables are on
the `PATH` of the shell that runs the model's shell commands ([Claude Code
plugin components][cc-plugin-executables]).

A Codex plugin can bundle skills, MCP servers, apps and hooks, and has no
manifest field for subagent definitions ([Codex
`plugin/manifest.rs`][cx-plugin-components]). Codex loads a plugin's hooks only
from a legacy manifest, not from an Agent Plugins one ([Codex
`core-plugins/loader.rs`][cx-plugin-hooks]). It runs a plugin's hook only when
the hook is enabled and is either managed, trusted or exempt from trust checks.
The recorded trust covers a hash of the plugin's contents, so editing the plugin
withdraws that trust ([Codex `hooks/discovery.rs`][cx-plugin-hook-trust]). When
it installs a plugin with a legacy manifest, it converts the plugin's commands
into skills, skipping any it cannot convert ([Codex
`store.rs`][cx-command-migration]).

### Plugin names

Claude Code namespaces every component of a plugin under the plugin's name, so a
subagent `reviewer` in a plugin `deploy-tools` is `deploy-tools:reviewer`
([Claude Code plugin manifest][cc-plugin-name]). A plugin's skill is invoked as
`/<plugin>:<directory>`, and a `name` in the skill's frontmatter replaces the
directory in that name ([Claude Code plugin components][cc-plugin-skills]). A
skill and a subagent in the same plugin can therefore have the same scoped name.
A plugin's skill loads alongside a skill of the same name from elsewhere,
because the prefix keeps them apart ([Claude Code skills][cc-skills-names]), but
when subagents share a name, a plugin's has the lowest priority ([Claude Code
subagents][cc-sub-scope]). Codex lists a plugin's skills with the plugin's name
as a prefix, as in `plugin:skill`, and a user can mention one as `$plugin:skill`
([Codex `namespace.rs`][cx-skill-namespace], [Codex
`mentions.rs`][cx-skill-mention-chars]).

### Which copy of a plugin loads

Claude Code copies a plugin installed from a marketplace into a versioned cache
directory and loads that copy, with three exceptions that load in place: a
plugin loaded with `--plugin-dir`, a relative-path plugin in a marketplace added
from a local path, and a `command`-source plugin in link mode. Edits to a
relative-path plugin take effect at the next session start or after
`/reload-plugins` ([Claude Code plugins][cc-plugin-cache]). A running session
keeps the versions it loaded, even when a plugin updates during it ([Claude Code
plugins][cc-plugin-update]).

Codex loads an installed plugin from a copy in its cache, at
`plugins/cache/<marketplace>/<plugin>/<version>` under its home directory
([Codex `store.rs`][cx-plugin-cache]). Installing copies the plugin's
directories and regular files but not its symbolic links ([Codex
`store.rs`][cx-plugin-copy]). Codex's automatic refresh reinstalls a plugin only
when its version changes, so an edit to the plugin's source that keeps the same
version does not reach the cached copy ([Codex
`core-plugins/loader.rs`][cx-plugin-refresh]).

## Skills

A skill is a folder that contains a required file, `SKILL.md` ([Claude Code
skills][cc-skills-files]). The file's frontmatter gives the skill's name and
description, and its body holds the skill's content. Under Claude Code every
frontmatter field is optional: the name defaults to the folder's name, and the
description to the first non-empty line of the body ([Claude Code
skills][cc-skills-frontmatter]).

### The skill listing

At session start, the harness adds a listing of the available skills to the
context, from which the model can decide to use one. The listing is bounded in
size. By default, Claude Code lists every skill's name but drops descriptions to
fit a character budget of 1% of the context window, and caps each skill's
combined `description` and `when_to_use` text at 1,536 characters. It lists no
description for a skill whose frontmatter sets `disable-model-invocation: true`
([Claude Code skills][cc-skills-cut], [Claude Code skills][cc-skills-invoke]).
By default, Codex lists each skill's name, description and path within a budget
of 2% of the context window, caps each description at 1,024 characters, and
omits any skill that does not allow implicit invocation ([Codex
`render.rs`][cx-skills-budget], [Codex `host.rs`][cx-skills-hidden]).

### Invocation under Claude Code

Under Claude Code, a skill runs when the user puts its name, as `/name`, at the
start of a message, unless its frontmatter sets `user-invocable: false`, or when
the model invokes it with the Skill tool. A name that follows other text only
permits the model to run the skill ([Claude Code skills][cc-skills-where],
[Claude Code skills][cc-skills-restrict]). Claude Code then renders `SKILL.md`.
It substitutes arguments and variables such as `${CLAUDE_SKILL_DIR}` ([Claude
Code skills][cc-skills-subst]), and runs each `` !`command` `` placeholder as a
shell command whose output replaces the placeholder ([Claude Code
skills][cc-skills-inject]). It appends the rendered content to the conversation
as a single message ([Claude Code skills][cc-skills-life]). Frontmatter can
extend what invocation does: `allowed-tools` grants permission to use tools
during the turn, `model` and `effort` override the model and effort level for
the rest of the turn, and `hooks` registers hooks for the rest of the session
([Claude Code skills][cc-skills-frontmatter]). With `context: fork`, the skill
runs in a new subagent instead, which receives the rendered content as its
prompt and does not see the conversation history ([Claude Code
skills][cc-skills-subagent]).

### Invocation under Codex

Under Codex, a skill's body enters the context in one of two ways. When the
user's input mentions the skill as `$name`, the harness reads the whole of
`SKILL.md`, frontmatter included, and injects it into the conversation in a
`<skill>` element ([Codex `selection.rs`][cx-skills-mention], [Codex
`host_outcome.rs`][cx-skills-read-file], [Codex
`fragments.rs`][cx-skills-inject]). Codex injects skills by one of two paths,
which truncate differently at 8,000 bytes: its skills extension truncates every
skill that it injects, and its core path truncates only a skill from a plugin
with an Agent Plugins manifest ([Codex `extension.rs`][cx-skills-ext-truncate],
[Codex `host_prompt.rs`][cx-skills-truncate]). Otherwise, the model reads
`SKILL.md` itself, as the instructions it is given direct: a filesystem skill
with an ordinary file or shell tool call, and other skills with the
`skills.read` tool. The file then reaches the context as that call's result
([Codex `models.json`][cx-models], [Codex `catalog_prompt.rs`][cx-catalog]).

### Invoked content over time

Once appended, a skill's content is part of the conversation and stays there
across later turns. Claude Code does not re-read the skill file, so editing the
file does not change the content already in the context. If the skill is invoked
again, Claude Code adds a short note that it is already loaded when the rendered
content is unchanged, and appends the full content again when it has changed.
After compaction, Claude Code re-attaches the most recent invocation of each
skill, keeping at most the first 5,000 tokens of each and 25,000 tokens in all,
and drops the oldest invocations first ([Claude Code skills][cc-skills-life]).

### Supporting files and paths

Other files in a skill's folder enter the context only when the model reads
them, or, under Claude Code, when a `` !`command` `` placeholder injects their
content. A script that the model runs contributes only its output ([Claude Code
skills][cc-skills-files], [Claude Code skills][cc-skills-inject]). The model
writes each path into its tool call, and a shell command runs in the session
shell's current working directory, which moves when the model runs `cd` ([Claude
Code skills][cc-skills-cwd]). A relative path that the model copies from a skill
into a tool call therefore resolves against that working directory, not against
the skill's folder. Claude Code replaces `${CLAUDE_SKILL_DIR}` in a skill's
content with the folder that contains its `SKILL.md` ([Claude Code
skills][cc-skills-subst]), and Codex instructs the model to resolve a skill's
relative paths against that folder ([Codex `models.json`][cx-models], [Codex
`catalog_prompt.rs`][cx-catalog]).

## Subagents

A subagent is a coding agent that the harness starts to carry out a delegated
task in a context of its own. The model can request one with a tool call: the
Agent tool under Claude Code ([Claude Code subagents][cc-sub-fork]), or
`spawn_agent` under Codex ([Codex `multi_agents_spec.rs`][cx-spawn-name]). Under
Claude Code, the user can also start a fork with `/subtask` ([Claude Code
subagents][cc-sub-fork]), and a skill with `context: fork` runs in a subagent
([Claude Code skills][cc-skills-subagent]). A subagent starts either fresh,
without the parent's conversation history, or as a fork, with a copy of it.

### Initial context under Claude Code

Under Claude Code, a fresh subagent's initial context holds its own system
prompt with environment details, the task message, the same `CLAUDE.md` files
that the main conversation loads, a snapshot of the repository's git status when
there is one, and the full content of any skills that its definition preloads. A
definition that sets `omitClaudeMd` loads at most the managed-policy files, and
the built-in Explore and Plan subagents omit the `CLAUDE.md` files and git
status. A fresh subagent does not see the main conversation's history, the
skills already invoked in it, or the files already read ([Claude Code
subagents][cc-sub-startup]). A fork sees the same system prompt, tools, model
and message history as its parent, and the model can start one itself while fork
mode is on, as it is by default ([Claude Code subagents][cc-sub-fork]).

### Initial context under Codex

Under Codex, the default depends on the multi-agent version. In version 1, a
subagent starts fresh unless the call sets `fork_context` ([Codex
`multi_agents_spec.rs`][cx-spawn-v1-schema]). In version 2, it inherits the
parent's history unless the call sets `fork_turns` to `none` ([Codex
`multi_agents_spec.rs`][cx-spawn-v2-schema], [Codex `spawn.rs`][cx-spawn-v2]). A
version 1 fork's copy omits tool calls, tool outputs, reasoning and non-final
assistant messages. A version 2 fork's copy keeps them, unless
`preserve_fork_prefix`, which is on by default, is turned off ([Codex
`history.rs`][cx-fork-history], [Codex `config/mod.rs`][cx-preserve-fork]). The
version comes from a feature flag or from the model's metadata ([Codex
`config/mod.rs`][cx-multiagent-version]). At the pinned commit, the bundled
models `gpt-6-astra`, `gpt-6-sol`, `gpt-6-luna`, `gpt-6.1-sol`, `gpt-6.1-terra`,
`gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-daybreak-blue-latest` and
`gpt-daybreak-red-latest` select version 2 ([Codex `models.json`][cx-models]). A
fresh Codex subagent inherits the parent's instruction files and any items that
the parent always retains, and then receives the task message as its input
([Codex `thread_manager.rs`][cx-thread-instructions], [Codex
`history.rs`][cx-fresh-retained], [Codex
`agent/control/spawn.rs`][cx-spawn-input]).

### Results and side effects

When a subagent finishes, the harness adds its final result to the parent's
context, and the subagent's own tool calls and results stay out of it. Under
Claude Code, a subagent's summary comes back with a small metadata trailer
([Claude Code context window][cc-context-timeline]), and a background subagent's
result reaches the parent as a completion notification in a later turn ([Claude
Code subagents][cc-sub-background]). Under Codex, the parent receives the
subagent's final message as a message or notification, and a version 2 subagent
can also send the parent messages while it runs ([Codex
`control.rs`][cx-agent-control], [Codex `multi_agents_spec.rs`][cx-spawn-spec]).
Changes that a subagent's tool calls make outside the context, such as edits to
files, persist after it finishes. Under Claude Code, a fork started with
`isolation: "worktree"` writes its file edits to a separate git worktree instead
of the user's checkout ([Claude Code subagents][cc-sub-fork]).

### Subagent definitions

The two harnesses find subagent definitions in different places. Claude Code
registers each Markdown file in a plugin's `agents/` directory, searched
recursively, as a subagent type with a scoped name such as
`my-plugin:review:security`, named as described under
[Plugin names](#plugin-names). It ignores the `hooks`, `mcpServers` and
`permissionMode` fields of a plugin's subagent definitions ([Claude Code
subagents][cc-sub-scope]). Besides its built-in `default`, `explorer` and
`worker` roles ([Codex `role.rs`][cx-roles-builtin]), Codex loads agent roles
only from its configuration layers, as `[agents.<name>]` tables in `config.toml`
and as TOML files in each configuration folder's `agents/` directory. It does
not read a plugin's `agents/` directory ([Codex `loader.rs`][cx-roles-loader]).
A Markdown subagent file therefore reaches a Codex subagent only through its
context, as a path in its task message that its model then reads, or as content
inherited in a fork.

## Compaction

Compaction removes content from the context.

### Compaction under Claude Code

Claude Code compacts automatically when the context window approaches its limit,
and by default also when a long conversation has been left idle. The user can
compact on demand with `/compact`. Compaction replaces the conversation history
with a summary ([Claude Code context window][cc-context-full], [Claude Code
settings][cc-idle-compaction], [Claude Code context window][cc-compact]).

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
match compaction run again and add their output ([Claude Code context
window][cc-compact]).

### Compaction under Codex

Codex compacts automatically when the context reaches 90% of the context window,
or a lower configured limit ([Codex `openai_models.rs`][cx-compact-limit]). It
checks the limit before each turn and before each follow-up request within a
turn ([Codex `turn.rs`][cx-compact-pre], [Codex `turn.rs`][cx-compact-mid]). It
checks after a turn only if a post-turn threshold is configured, and by default
none is ([Codex `config/mod.rs`][cx-compact-post]). By default, for OpenAI
providers and Azure Responses providers, it requests compaction from the server,
which returns an encrypted compaction item ([Codex
`capabilities.rs`][cx-compact-remote], [Codex
`protocol/models.rs`][cx-compaction-item]). For other providers, it sends the
model a summarisation request and uses the summary ([Codex
`compact.rs`][cx-compact-local]). It then keeps the most recent user messages
within a token budget, 20,000 tokens for local compaction and 64,000 for remote,
and re-inserts the session's initial context ([Codex
`compact.rs`][cx-compact-retain], [Codex
`compact_remote_v2.rs`][cx-compact-remote-retain], [Codex
`compact_remote_v2_installation.rs`][cx-compact-remote-install]).

## Sources

The Claude API and Claude Code sources are Anthropic's documentation as of
November 2026. The Codex sources are pinned to commit `49d657a` of
`openai/codex`, and their paths are relative to its `codex-rs` directory.

[api-glossary-context]:
  https://platform.claude.com/docs/en/about-claude/glossary#context-window
[api-glossary-pretraining]:
  https://platform.claude.com/docs/en/about-claude/glossary#pretraining
[api-glossary-temperature]:
  https://platform.claude.com/docs/en/about-claude/glossary#temperature
[api-glossary-tokens]:
  https://platform.claude.com/docs/en/about-claude/glossary#tokens
[api-messages]:
  https://platform.claude.com/docs/en/build-with-claude/working-with-messages#multiple-conversational-turns
[api-stop-reasons]:
  https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons#stop-reason-values
[api-tool-use]:
  https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works
[api-tool-use-pricing]:
  https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#pricing
[api-tool-use-when]:
  https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#when-claude-uses-tools
[cc-compact]:
  https://code.claude.com/docs/en/context-window#what-survives-compaction
[cc-context-fills]:
  https://code.claude.com/docs/en/how-claude-code-works#when-context-fills-up
[cc-context-full]:
  https://code.claude.com/docs/en/context-window#when-your-context-fills-up
[cc-context-timeline]:
  https://code.claude.com/docs/en/context-window#what-the-timeline-shows
[cc-glossary-context]: https://code.claude.com/docs/en/glossary#context-window
[cc-glossary-harness]: https://code.claude.com/docs/en/glossary#agentic-harness
[cc-glossary-hook]: https://code.claude.com/docs/en/glossary#hook
[cc-glossary-loop]: https://code.claude.com/docs/en/glossary#agentic-loop
[cc-glossary-reminder]: https://code.claude.com/docs/en/glossary#system-reminder
[cc-glossary-system-prompt]:
  https://code.claude.com/docs/en/glossary#system-prompt
[cc-glossary-thinking]:
  https://code.claude.com/docs/en/glossary#extended-thinking
[cc-glossary-turn]: https://code.claude.com/docs/en/glossary#turn
[cc-headless-perm]:
  https://code.claude.com/docs/en/headless#turn-off-permission-prompts-in-unattended-runs
[cc-hooks-stop]:
  https://code.claude.com/docs/en/hooks#exit-code-2-behavior-per-event
[cc-idle-compaction]:
  https://code.claude.com/docs/en/settings-reference#idlecompaction
[cc-loop]:
  https://code.claude.com/docs/en/how-claude-code-works#the-agentic-loop
[cc-mcp-plugin]: https://code.claude.com/docs/en/mcp#plugin-provided-mcp-servers
[cc-memory-agents]:
  https://code.claude.com/docs/en/memory#when-claude-code-reads-agents-md
[cc-memory-auto]: https://code.claude.com/docs/en/memory#how-it-works
[cc-memory-load]:
  https://code.claude.com/docs/en/memory#how-claude-md-files-load
[cc-memory-path-rules]:
  https://code.claude.com/docs/en/memory#path-specific-rules
[cc-memory-rules]: https://code.claude.com/docs/en/memory#set-up-rules
[cc-memory-where]:
  https://code.claude.com/docs/en/memory#choose-where-to-put-claude-md-files
[cc-permissions-comment]:
  https://code.claude.com/docs/en/permissions#add-a-comment-when-you-answer-a-permission-prompt
[cc-permissions-hooks]:
  https://code.claude.com/docs/en/permissions#extend-permissions-with-hooks
[cc-permissions-manage]:
  https://code.claude.com/docs/en/permissions#manage-permissions
[cc-permissions-precedence]:
  https://code.claude.com/docs/en/permissions#precedence-among-rules-hooks-and-mods
[cc-permissions-system]:
  https://code.claude.com/docs/en/permissions#permission-system
[cc-plugin-adds]:
  https://code.claude.com/docs/en/plugins#what-an-enabled-plugin-adds-to-your-sessions
[cc-plugin-cache]:
  https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins
[cc-plugin-executables]:
  https://code.claude.com/docs/en/plugins/components#executables
[cc-plugin-hooks]:
  https://code.claude.com/docs/en/plugins/components#when-plugin-hooks-fire
[cc-plugin-layout]:
  https://code.claude.com/docs/en/plugins/manifest-reference#standard-layout
[cc-plugin-manifest-fields]:
  https://code.claude.com/docs/en/plugins/manifest-reference#fields
[cc-plugin-manifest-file]:
  https://code.claude.com/docs/en/plugins/manifest-reference#manifest-file
[cc-plugin-monitors]:
  https://code.claude.com/docs/en/plugins/components#monitors
[cc-plugin-name]:
  https://code.claude.com/docs/en/plugins/manifest-reference#name
[cc-plugin-skills]: https://code.claude.com/docs/en/plugins/components#skills
[cc-plugin-update]:
  https://code.claude.com/docs/en/plugins/loading#when-auto-update-runs
[cc-plugins]:
  https://code.claude.com/docs/en/plugins#understand-what-a-plugin-is
[cc-resume]:
  https://code.claude.com/docs/en/how-claude-code-works#resume-or-fork-sessions
[cc-sessions]:
  https://code.claude.com/docs/en/how-claude-code-works#work-with-sessions
[cc-skills-cut]:
  https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short
[cc-skills-cwd]:
  https://code.claude.com/docs/en/skills#how-injected-commands-run
[cc-skills-files]: https://code.claude.com/docs/en/skills#add-supporting-files
[cc-skills-frontmatter]:
  https://code.claude.com/docs/en/skills#frontmatter-reference
[cc-skills-inject]:
  https://code.claude.com/docs/en/skills#inject-dynamic-context
[cc-skills-invoke]:
  https://code.claude.com/docs/en/skills#control-who-invokes-a-skill
[cc-skills-life]: https://code.claude.com/docs/en/skills#skill-content-lifecycle
[cc-skills-names]:
  https://code.claude.com/docs/en/skills#resolve-skills-that-share-a-name
[cc-skills-restrict]:
  https://code.claude.com/docs/en/skills#restrict-claude%E2%80%99s-skill-access
[cc-skills-subagent]:
  https://code.claude.com/docs/en/skills#run-skills-in-a-subagent
[cc-skills-subst]:
  https://code.claude.com/docs/en/skills#available-string-substitutions
[cc-skills-where]:
  https://code.claude.com/docs/en/skills#where-you-write-the-skills-name
[cc-sub-background]:
  https://code.claude.com/docs/en/sub-agents#tools-permissions-and-results-of-background-subagents
[cc-sub-fork]:
  https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation
[cc-sub-scope]:
  https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope
[cc-sub-startup]:
  https://code.claude.com/docs/en/sub-agents#what-loads-at-startup
[cx-agent-control]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control.rs#L524-L587
[cx-agent-plugin-manifest]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/plugins/src/plugin_namespace.rs#L12-L80
[cx-agents-md]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L199-L302
[cx-agents-md-refresh]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md_manager.rs#L69-L135
[cx-agents-md-replace]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/world_state/agents_md.rs#L11-L13
[cx-approval]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1207
[cx-catalog]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs
[cx-command-migration]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L639-L646
[cx-compact-limit]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/openai_models.rs#L583-L594
[cx-compact-local]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L123-L154
[cx-compact-mid]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L773-L830
[cx-compact-post]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L4670-L4672
[cx-compact-pre]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L1597-L1626
[cx-compact-remote]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/model-provider/src/capabilities.rs#L34-L42
[cx-compact-remote-install]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact_remote_v2_installation.rs#L226-L242
[cx-compact-remote-retain]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact_remote_v2.rs#L557-L602
[cx-compact-retain]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L682-L800
[cx-compaction-item]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/models.rs#L1385-L1390
[cx-doc-max]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config/src/config_toml.rs#L76
[cx-exec-default]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L640-L642
[cx-exec-policy]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L897-L911
[cx-exec-policy-rules]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L421-L509
[cx-fork-history]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/history.rs#L87-L134
[cx-fresh-retained]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/history.rs#L46-L84
[cx-home-instructions]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-home/src/instructions/mod.rs#L40-L83
[cx-initial-context]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L5142-L5149
[cx-legacy-manifests]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec-server-protocol/src/protocol.rs#L54-L59
[cx-models]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager/models.json
[cx-multiagent-version]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1780-L1807
[cx-plugin-cache]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L112-L120
[cx-plugin-components]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/plugin/src/manifest.rs#L19-L25
[cx-plugin-copy]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L736-L760
[cx-plugin-hook-trust]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L836-L924
[cx-plugin-hooks]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/loader.rs#L942-L952
[cx-plugin-refresh]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/loader.rs#L667-L672
[cx-preserve-fork]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1479
[cx-roles-builtin]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/role.rs#L315-L350
[cx-roles-loader]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs#L23-L117
[cx-sandbox-bypass]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/sandboxing.rs#L265-L283
[cx-skill-mention-chars]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/skills/src/mentions.rs#L226-L228
[cx-skill-namespace]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/loader/namespace.rs#L176-L181
[cx-skills-budget]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/render.rs#L23-L27
[cx-skills-ext-truncate]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/extension.rs#L446-L458
[cx-skills-hidden]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/provider/host.rs#L170-L172
[cx-skills-inject]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs#L72-L127
[cx-skills-mention]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/selection.rs#L33-L112
[cx-skills-read-file]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/host_outcome.rs#L151-L177
[cx-skills-truncate]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/host_prompt.rs#L84-L88
[cx-spawn-input]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control/spawn.rs#L1000-L1002
[cx-spawn-name]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L88-L92
[cx-spawn-spec]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L805
[cx-spawn-v1-schema]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L626-L632
[cx-spawn-v2]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs#L209-L239
[cx-spawn-v2-schema]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L664-L669
[cx-thread-instructions]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/thread_manager.rs#L2263-L2301
[cx-tool-follow]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/stream_events_utils.rs#L360-L421
[cx-turn]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L692-L866
[cx-world-state]:
  https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/world_state
[transformer]: https://arxiv.org/abs/1706.03762
