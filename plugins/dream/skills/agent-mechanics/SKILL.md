---
name: agent-mechanics
description:
  Explains how a coding agent works under Claude Code and Codex, covering the
  model, the context, the turn, tool calls and permissions, skills, subagents
  and compaction. Use when engineering a system that has LLM agents in it, such
  as a prompt, a skill, a subagent file or a program that runs agents, to reason
  about what the agents will do.
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

A coding agent has two components. The first is a language model, which maps a
sequence of tokens to a probability distribution over the next token and retains
nothing between requests. The second is an agent harness, such as Claude Code or
Codex: the program that sends inference requests to the model, executes the tool
calls that the model emits, and maintains the context that it sends with each
request ([Claude Code glossary][cc-glossary-harness]). The model selects each
action by emitting text, and the harness performs it. A harness session is one
conversation between a user and a coding agent, run by an agent harness.

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

Generation is autoregressive: the model generates one token at a time, and each
generated token becomes part of the input from which the next is generated
([Vaswani et al., 2017, §3][transformer]). At each step, the model computes a
probability distribution over its vocabulary ([Vaswani et al., 2017,
§3.4][transformer]), and a token is selected from that distribution. The
temperature parameter controls how random the selection is, and even at
temperature 0 the output is not fully deterministic ([Claude
glossary][api-glossary-temperature]). Generation continues until a stop
condition is met, for example when the model finishes its response, emits a tool
call or reaches a token limit ([Claude stop reasons][api-stop-reasons]).

The harness obtains each response by sending the model an inference request. The
Claude Messages API is stateless: each request carries the full conversation,
and the model retains nothing from one request to the next. The exception is
message threads, a beta feature with which the API keeps the conversation and
each request sends only new messages ([Messages API][api-messages]). Either way,
the context of a request is exactly what the harness has supplied: a system
prompt, the definitions of the available tools, and the conversation so far
([Claude tool use][api-tool-use]).

Three consequences follow.

1. **The context is the model's only state.** The distribution for each token is
   computed from the model's weights, which are fixed during inference, and from
   the tokens in the context. No other information carries over from one token
   to the next, or from one request to the next. Extended thinking, the
   reasoning that the model emits before its response, consists of generated
   tokens like any other output ([Claude Code glossary][cc-glossary-thinking]).
2. **Generation runs forward only.** A causal mask prevents each position from
   attending to positions after it ([Vaswani et al., 2017,
   §3.2.3][transformer]), so nothing computed for a token depends on the tokens
   generated after it. A generated token cannot be revised. Later tokens can
   only contradict or correct it.
3. **Output is sampled.** Because each token is selected from a distribution,
   the same context can produce different output on different requests ([Claude
   glossary][api-glossary-temperature]).

## What the context holds

Every request carries the harness's system prompt and the definitions of the
tools available to the model. Claude Code sends its system prompt ahead of the
conversation on every request ([Claude Code
glossary][cc-glossary-system-prompt]), and each tool definition gives the tool's
name, a description and a schema for its input ([Claude tool
use][api-tool-use]). Both occupy the context window, as do the instruction
files, skills and conversation history that the harness adds ([Claude Code
glossary][cc-glossary-context]).

At session start, the harness adds three further kinds of content: instruction
files, a listing of the available skills, and details of the environment, such
as the working directory and, under Claude Code, the output of `git status`
([Claude Code context window][cc-context-timeline], [Codex
`compact.rs`][cx-compact-retain]). The listing of skills is described under
[Skills](#skills).

Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from the working directory
and every directory above it, the user's `CLAUDE.md`, any managed-policy
`CLAUDE.md`, and each rule file in `.claude/rules/` that declares no path
pattern. It delivers them as system reminders, messages that it inserts into the
conversation, rather than as part of the system prompt ([Claude Code
memory][cc-memory-load], [Claude Code glossary][cc-glossary-reminder]). It loads
a `CLAUDE.md` in a subdirectory of the working directory, or a rule with a path
pattern, only when the model reads, writes or edits a matching file. By default,
it reads `AGENTS.md` only when no `CLAUDE.md` exists in the working directory or
above it ([Claude Code memory][cc-memory-load], [Claude Code
memory][cc-memory-agents]).

Codex loads `AGENTS.override.md`, or failing that `AGENTS.md`, from its home
directory, then the same from each directory from the project root down to the
working directory, where the project root is by default the nearest ancestor
that contains `.git` ([Codex `instructions/mod.rs`][cx-home-instructions],
[Codex `agents_md.rs`][cx-agents-md]). It loads at most 32 KiB of project
instruction files by default ([Codex `config_toml.rs`][cx-doc-max]).

As the session runs, the harness appends each user message, each response that
the model generates, including its text and tool-use blocks, and each tool
result ([Messages API][api-messages], [Claude tool use][api-tool-use]). It also
inserts system reminders of its own, such as the text that a hook returns or a
note that a file the model edited earlier has changed on disk. A hook is a
handler, such as a shell command, that the harness runs at a fixed point in its
lifecycle, for example before a tool runs or at session start ([Claude Code
glossary][cc-glossary-reminder], [Claude Code glossary][cc-glossary-hook]).

Each new harness session starts with a fresh context window, without the
conversation history of earlier sessions ([how Claude Code works][cc-sessions]).
Resuming a session reopens it and appends new messages to its existing
conversation ([how Claude Code works][cc-resume]). Otherwise, content from an
earlier session reaches a new one only through the user's input, through files
that the model reads with a tool call, or through files that the harness loads
at session start, such as instruction files and, under Claude Code, the first
200 lines or 25 KB of auto memory ([Claude Code memory][cc-memory-auto]).

## The turn

A turn is the agent's complete response to one input, usually a user message,
with any number of tool calls in between ([Claude Code
glossary][cc-glossary-turn]). The harness appends the input to the conversation
and sends an inference request. Each response ends with a stop reason. When the
stop reason is `tool_use`, the response contains one or more tool-use blocks,
and the harness executes them, appends their results, and sends the next
request. When it is `end_turn`, the model has finished, and that response is the
turn's output ([Claude stop reasons][api-stop-reasons], [Claude tool
use][api-tool-use]). Codex runs the same loop, sending another request while the
model has called a tool or the user has queued further input ([Codex
`turn.rs`][cx-turn]). Between turns the harness sends no requests, so the model
generates nothing.

A turn can also end, or continue, in other ways. A response can stop because it
reached `max_tokens`, matched a stop sequence, paused a long-running server-tool
loop, was a refusal, or filled the context window, and the harness then
determines what happens next ([Claude stop reasons][api-stop-reasons]). Server
tools, such as web search, run on Anthropic's infrastructure, and their results
arrive within the response without the harness executing anything ([Claude tool
use][api-tool-use]). Under both harnesses, a `Stop` hook can prevent a turn from
ending and continue the conversation ([Claude Code hooks][cc-hooks-stop], [Codex
`turn.rs`][cx-turn]). The user can also interrupt a turn at any point ([Claude
Code glossary][cc-glossary-loop]).

## Tool calls and permissions

A tool call is a tool-use block in the model's output: it names a tool and gives
an input that conforms to the tool's schema ([Claude tool use][api-tool-use]).
The model only emits the block. The harness decides whether to run the call and
appends a tool result, which holds either the call's output or the reason it did
not run. The model receives the result in its next request. A tool can change
state outside the context, such as files on disk or a repository's history. The
context gains only the call and its result, so the model can condition on such a
change only through what the result reports.

Claude Code first runs any `PreToolUse` hooks, and a hook that exits with code 2
blocks the call before any permission rule is evaluated ([Claude Code
permissions][cc-permissions-precedence]). It then evaluates permission rules in
order: a deny rule blocks the call, an ask rule prompts the user to approve it,
and an allow rule lets it run without approval ([Claude Code
permissions][cc-permissions-manage]). A call that no rule matches follows the
defaults of the session's permission mode. In Manual mode, file edits and shell
commands outside a built-in set of read-only commands require approval ([Claude
Code permissions][cc-permissions-system]). If the user answers a prompt with No
and adds no comment, Claude Code stops the turn ([Claude Code
permissions][cc-permissions-comment]).

When no one is present to answer a prompt, the outcome depends on the run. In a
non-interactive Claude Code run with no permission host, a call that would
prompt is denied. A run with a permission host, such as an Agent SDK
`canUseTool` callback, waits for the host's answer, unless
`--permission-prompts none` is set, in which case the call is denied and the
model is told that nobody can approve it ([Claude Code
headless][cc-headless-perm]).

Codex decides according to its approval policy ([Codex
`protocol.rs`][cx-approval]). Under the `never` policy, which non-interactive
`codex exec` runs use by default ([Codex `exec/src/lib.rs`][cx-exec-default]),
Codex never asks the user. A command that its execution policy permits runs in
the sandbox, and a command that the policy forbids, or that would require
approval, is rejected ([Codex `exec_policy.rs`][cx-exec-policy]). A rejection or
a failure inside the sandbox is returned to the model as the call's result
([Codex `protocol.rs`][cx-approval]).

## Skills

A skill is a folder whose one required file, `SKILL.md`, holds a name, a
description and a body. At session start, the harness adds a listing of the
available skills to the context, from which the model can decide to use one. The
listing is bounded in size. Claude Code lists every skill's name, but drops
descriptions to fit a budget of 1% of the context window, truncates each skill's
combined `description` and `when_to_use` text at 1,536 characters, and lists no
description for a skill whose frontmatter sets `disable-model-invocation: true`
([Claude Code skills][cc-skills-cut], [Claude Code skills][cc-skills-invoke]).
Codex lists each skill's name, description and path within a budget of 2% of the
context window by default, truncates each description at 1,024 characters, and
omits any skill that does not allow implicit invocation ([Codex
`render.rs`][cx-skills-budget], [Codex `host.rs`][cx-skills-hidden]).

Under Claude Code, a skill runs when the user puts its name, as `/name`, at the
start of a message, or when the model invokes it with the Skill tool. A name
that follows other text only permits the model to run the skill ([Claude Code
skills][cc-skills-where]). Claude Code then renders `SKILL.md`: it substitutes
arguments and variables such as `${CLAUDE_SKILL_DIR}`, and runs each
`` !`command` `` placeholder as a shell command whose output replaces the
placeholder. It appends the rendered content to the conversation as a single
message ([Claude Code skills][cc-skills-life], [Claude Code
skills][cc-skills-inject]). Frontmatter can extend what invocation does.
`allowed-tools` grants permission to use tools during the turn, `model` and
`effort` override the model and effort level for the rest of the turn, `hooks`
registers hooks for the rest of the session, and `context: fork` runs the skill
in a new subagent, with the rendered content as its prompt ([Claude Code
skills][cc-skills-frontmatter]).

Under Codex, a skill's body enters the context in one of two ways. When the
user's input mentions the skill as `$name`, the harness reads `SKILL.md`,
including its frontmatter, and injects it into the conversation in a `<skill>`
element ([Codex `selection.rs`][cx-skills-mention], [Codex
`fragments.rs`][cx-skills-inject]). For a plugin's skill, it truncates the file
at 8,000 bytes ([Codex `host_prompt.rs`][cx-skills-truncate]). Otherwise, the
model reads `SKILL.md` with an ordinary file or shell tool call, as Codex's
instructions direct it to, and the file reaches the context as that call's
result ([Codex `catalog_prompt.rs`][cx-catalog]).

Once appended, a skill's content is part of the conversation and stays there
across later turns. Claude Code does not re-read the skill file, so editing the
file does not change the content already in the context. If the skill is invoked
again, Claude Code adds a short note that it is already loaded when the rendered
content is unchanged, and appends the full content again when it has changed.
After compaction, Claude Code re-attaches the most recent invocation of each
skill, keeping at most the first 5,000 tokens of each and 25,000 tokens in all,
and drops the oldest invocations first ([Claude Code skills][cc-skills-life]).

Under Claude Code, which file a plugin's skill is rendered from depends on how
the plugin was installed. A plugin installed from a marketplace is copied into a
versioned cache directory, and Claude Code loads that copy. A plugin loaded with
`--plugin-dir` loads in place and is never copied, and a plugin in a marketplace
added from a local path loads from its path inside that marketplace, where edits
take effect at the next session start or after `/reload-plugins` ([Claude Code
plugins][cc-plugin-cache]).

Other files in a skill's folder enter the context only when the model reads
them, or, under Claude Code, when a `` !`command` `` placeholder injects their
content ([Claude Code skills][cc-skills-files]). The model writes each path into
its tool call, and a shell command runs in the session shell's current working
directory, which moves when the model runs `cd` ([Claude Code
skills][cc-skills-cwd]). A relative path that the model copies from a skill into
a tool call therefore resolves against that working directory, not against the
skill's folder. Claude Code replaces `${CLAUDE_SKILL_DIR}` in a skill's content
with the folder that contains its `SKILL.md` ([Claude Code
skills][cc-skills-subst]), and Codex instructs the model to resolve a skill's
relative paths against that folder ([Codex `models.json`][cx-models], [Codex
`catalog_prompt.rs`][cx-catalog]).

## Subagents

A subagent is a coding agent that the harness starts, at the model's request, to
carry out a delegated task in a context of its own. The model requests one with
a tool call: the Agent tool under Claude Code, or `spawn_agent` under Codex
([Claude Code subagents][cc-sub-fork], [Codex
`multi_agents_spec.rs`][cx-spawn-spec]). A subagent starts either fresh, without
the parent's conversation history, or as a fork, with a copy of that history.

Under Claude Code, a fresh subagent's initial context holds its own system
prompt with environment details, the task message, the same `CLAUDE.md` files
that the main conversation loads, the output of `git status`, and the full
content of any skills that its definition preloads. The built-in Explore and
Plan subagents omit the `CLAUDE.md` files and `git status`. A fresh subagent
does not see the main conversation's history, the skills already invoked in it,
or the files already read ([Claude Code subagents][cc-sub-startup]). A fork sees
the same system prompt, tools, model and message history as its parent, and the
model can start one itself while fork mode is on, as it is by default ([Claude
Code subagents][cc-sub-fork]).

Under Codex, the default depends on the multi-agent version. In version 1, a
subagent starts fresh unless the call sets `fork_context`. In version 2, it
inherits the parent's full history unless the call sets `fork_mode` to `none`
([Codex `multi_agents_spec.rs`][cx-spawn-modes], [Codex
`spawn.rs`][cx-spawn-v2]). The version comes from a feature flag or from the
model's metadata. At the pinned commit, the bundled models of the `gpt-6` and
`gpt-6.1` families, `gpt-5.6-sol` and `gpt-5.6-terra` select version 2 ([Codex
`config/mod.rs`][cx-multiagent-version], [Codex `models.json`][cx-models]). A
fresh Codex subagent starts with the initial context of a new thread, including
the parent's instruction files and the listing of skills, followed by the task
message ([Codex `thread_manager.rs`][cx-thread-instructions]).

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
files, persist after it finishes.

The two harnesses find subagent definitions in different places. Claude Code
registers each Markdown file in a plugin's `agents/` directory, searched
recursively, as a subagent type with a scoped name such as
`my-plugin:review:security` ([Claude Code subagents][cc-sub-scope]). That is the
same `plugin:name` form by which a plugin's skills are invoked, so a skill and a
subagent in the same plugin can have the same scoped name ([Claude Code
skills][cc-skills-names]). Codex loads agent roles only from its configuration
layers, as `[agents.<name>]` tables in `config.toml` and as TOML files in each
configuration folder's `agents/` directory. It does not read a plugin's
`agents/` directory ([Codex `loader.rs`][cx-roles-loader]). A Markdown subagent
file therefore reaches a Codex subagent only through its context, as a path in
its task message that its model then reads, or as content inherited in a fork.

## Compaction

Compaction removes content from the context. Claude Code compacts automatically
when the context window approaches its limit, or on demand with `/compact`, and
replaces the conversation history with a summary ([Claude Code
glossary][cc-glossary-compaction], [Claude Code context window][cc-compact]).
The system prompt still applies, and Claude Code re-injects the project-root
`CLAUDE.md`, rules without path patterns, auto memory, the listing of skills, a
fresh `git status`, up to five of the files the model most recently read or
edited, and recent skill invocations within the limits given under
[Skills](#skills). Nested `CLAUDE.md` files and path-scoped rules return only
when the model next works with files they cover. Instructions given only in the
conversation, and context that hooks added, survive only as far as the summary
records them ([Claude Code context window][cc-compact]).

Codex compacts automatically when the context reaches 90% of the context window,
or a lower configured limit, checking the limit before, during and after a turn
([Codex `openai_models.rs`][cx-compact-limit], [Codex
`turn.rs`][cx-compact-run]). By default, for OpenAI providers and Azure
Responses providers, it requests compaction from the server, which returns an
opaque compaction item. For other providers, it sends the model a summarisation
request and uses the summary ([Codex `capabilities.rs`][cx-compact-remote],
[Codex `compact.rs`][cx-compact-local]). In both cases, it keeps the most recent
user messages within a token budget and re-inserts the session's initial
context, including the instruction files and the listing of skills ([Codex
`compact.rs`][cx-compact-retain]).

## Sources

The Claude API and Claude Code sources are Anthropic's documentation as of
November 2026. The Codex sources are pinned to commit `49d657a` of
`openai/codex`, and their paths are relative to its `codex-rs` directory.

[api-glossary-context]:
  https://platform.claude.com/docs/en/about-claude/glossary#context-window
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
[transformer]: https://arxiv.org/abs/1706.03762
[cc-compact]:
  https://code.claude.com/docs/en/context-window#what-survives-compaction
[cc-context-timeline]:
  https://code.claude.com/docs/en/context-window#what-the-timeline-shows
[cc-glossary-compaction]: https://code.claude.com/docs/en/glossary#compaction
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
[cc-memory-agents]:
  https://code.claude.com/docs/en/memory#when-claude-code-reads-agents-md
[cc-memory-auto]:
  https://code.claude.com/docs/en/memory#claude-md-vs-auto-memory
[cc-memory-load]:
  https://code.claude.com/docs/en/memory#how-claude-md-files-load
[cc-permissions-comment]:
  https://code.claude.com/docs/en/permissions#add-a-comment-when-you-answer-a-permission-prompt
[cc-permissions-manage]:
  https://code.claude.com/docs/en/permissions#manage-permissions
[cc-permissions-precedence]:
  https://code.claude.com/docs/en/permissions#precedence-among-rules-hooks-and-mods
[cc-permissions-system]:
  https://code.claude.com/docs/en/permissions#permission-system
[cc-plugin-cache]:
  https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins
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
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control.rs#L524-L586
[cx-agents-md]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L1-L19
[cx-approval]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1207
[cx-catalog]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs
[cx-compact-limit]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/openai_models.rs#L583-L594
[cx-compact-local]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L123-L154
[cx-compact-remote]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/model-provider/src/capabilities.rs#L32-L41
[cx-compact-retain]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L672-L800
[cx-compact-run]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L1732-L1840
[cx-doc-max]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config/src/config_toml.rs#L76
[cx-exec-default]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L640-L642
[cx-exec-policy]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L899-L911
[cx-home-instructions]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-home/src/instructions/mod.rs#L40-L83
[cx-models]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager/models.json
[cx-multiagent-version]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1780-L1807
[cx-roles-loader]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs#L23-L117
[cx-skills-budget]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/render.rs#L23-L28
[cx-skills-hidden]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/provider/host.rs#L170-L172
[cx-skills-inject]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs#L72-L127
[cx-skills-mention]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/selection.rs#L33-L112
[cx-skills-truncate]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/host_prompt.rs#L82-L100
[cx-spawn-modes]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L629-L667
[cx-spawn-spec]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L805
[cx-spawn-v2]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs#L213-L239
[cx-thread-instructions]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/thread_manager.rs#L2262-L2301
[cx-turn]:
  https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L718-L934
