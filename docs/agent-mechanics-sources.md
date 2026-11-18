<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->

# Sources for dream:agent-mechanics

This file lists the sources that support each paragraph of the guide to agent
mechanics, whose files are in `plugins/dream/skills/agent-mechanics/`. It has a
part for each file of the guide, under that file's own headings. Each entry
gives the paragraph's opening words, then its sources. When a paragraph of the
guide changes, its entry here changes with it.

The Claude API, Claude Code and Hugging Face Transformers sources are their
documentation as of November 2026. The Codex sources are pinned to commit
`49d657a` of `openai/codex`, and their paths are relative to its `codex-rs`
directory, except paths that begin with `sdk/`, which are relative to the
repository's root.

## `SKILL.md`

- A coding agent has two components. The first…
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#pretraining),
  [how Claude Code works](https://code.claude.com/docs/en/how-claude-code-works#the-agentic-loop),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#agentic-harness)

### How the model generates text

- A language model operates on tokens, the units…
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#tokens),
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#context-window)

#### Autoregressive generation

- Language models such as Claude's are autoregressive. In…
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#pretraining),
  [§3](https://arxiv.org/abs/1706.03762),
  [§3.4](https://arxiv.org/abs/1706.03762),
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#temperature),
  [Hugging Face `EosTokenCriteria`](https://huggingface.co/docs/transformers/internal/generation_utils#transformers.EosTokenCriteria),
  [Hugging Face `StopStringCriteria`](https://huggingface.co/docs/transformers/internal/generation_utils#transformers.StopStringCriteria),
  [Hugging Face `MaxLengthCriteria`](https://huggingface.co/docs/transformers/internal/generation_utils#transformers.MaxLengthCriteria),
  [Claude stop reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons#stop-reason-values)

#### Inference requests

- The harness obtains each response by sending the…
  [Messages API](https://platform.claude.com/docs/en/build-with-claude/working-with-messages#multiple-conversational-turns),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#pricing)

#### Consequences

- **The context is the model's only state.** The…
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#extended-thinking)

- **Generation runs forward only.** In the Transformer, a…
  [Vaswani et al., 2017, §3.2.3](https://arxiv.org/abs/1706.03762)

- **Output is not deterministic.** Identical inputs can produce…
  [Claude glossary](https://platform.claude.com/docs/en/about-claude/glossary#temperature)

### What the context holds

- Everything the harness adds occupies the context window…
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#context-window),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#pricing)

#### At session start

- At session start, the harness adds further content…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-the-timeline-shows),
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L5142-L5149)

#### Instruction files

- Instruction files are Markdown files of instructions for…
  [Claude Code memory](https://code.claude.com/docs/en/memory#how-claude-md-files-load),
  [Codex `agents_md.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L199-L302)

#### During the session

- As the session runs, the harness appends each…
  [Messages API](https://platform.claude.com/docs/en/build-with-claude/working-with-messages#multiple-conversational-turns),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#system-reminder),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#hook),
  [Codex `hook_additional_context.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/hook_additional_context.rs#L19-L42)

#### Across sessions

- Each new harness session starts with a fresh…
  [how Claude Code works](https://code.claude.com/docs/en/how-claude-code-works#work-with-sessions),
  [how Claude Code works](https://code.claude.com/docs/en/how-claude-code-works#resume-or-fork-sessions),
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L1980-L2008)

### The turn

- A turn is one complete response from the…
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#turn),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Codex `stream_events_utils.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/stream_events_utils.rs#L360-L421),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L692-L866),
  [Claude Code settings](https://code.claude.com/docs/en/settings-reference#idlecompaction),
  [Codex `startup_prewarm.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/startup_prewarm.rs#L1),
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#tools-permissions-and-results-of-background-subagents)

#### Other ends and continuations

- A turn can also end, or continue, in…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#exit-code-2-behavior-per-event),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L692-L866),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#agentic-loop),
  [Codex `hook_runtime.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime.rs#L500-L546)

#### Asynchronous notifications

- Work that runs in the background, such as…
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/typescript#sdktasknotificationmessage),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/typescript#sdkmessageorigin),
  [Codex `completion.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control/completion.rs#L28-L152),
  [Codex `session/handlers.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/handlers.rs#L84-L104)

### Tool calls and permissions

- A tool call is a structured block in…
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Codex `protocol.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1207)

#### Built-in, MCP and server tools

- The model's tools are of three kinds: tools…
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Codex `spec_plan.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/spec_plan.rs#L122-L218),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#mcp-server),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#mcp),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#scale-with-mcp-tool-search),
  [Codex `handlers/mcp.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/mcp.rs#L611-L616),
  [Codex `tool_search_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/tool_search_spec.rs#L93-L95)

#### Permissions

- Each harness decides whether a call may run…
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#manage-permissions),
  [Codex `protocol.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1207),
  [Claude Code headless](https://code.claude.com/docs/en/headless#turn-off-permission-prompts-in-unattended-runs),
  [Codex `exec_policy.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L897-L911)

### Hooks

- A hook is a handler that the harness…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-lifecycle),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#hook),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-handler-fields),
  [Codex `protocol/hooks.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/hooks.rs#L140-L188)

#### Hook events

- Both harnesses fire hooks at the start and…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-lifecycle),
  [Codex `hooks/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/lib.rs#L29-L44),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#configuration),
  [Codex `matcher.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/matcher.rs#L11-L41)

#### Hook input and output

- A command hook receives the event as JSON…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#common-input-fields),
  [Codex `dispatcher.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/dispatcher.rs#L242-L251),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#exit-code-output),
  [Codex `pre_tool_use.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/pre_tool_use.rs#L268-L298),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#timeouts),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#run-hooks-in-the-background),
  [Codex `engine/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/mod.rs#L195-L210)

#### What a hook can control

- A `PreToolUse` hook can deny a tool call…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#pretooluse-decision-control),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#permissionrequest-decision-control),
  [Codex `output_parser.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/output_parser.rs#L441-L482),
  [Codex `permission_request.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/permission_request.rs#L153-L173)

- A `Stop` hook can keep a turn going…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#stop-decision-control),
  [Codex `stop.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/stop.rs#L299-L356),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L848-L866),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#subagentstop),
  [Codex `hook_runtime.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime.rs#L376-L453)

#### Hook output in the context

- A hook can add text to the context…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#add-context-for-claude),
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-survives-compaction),
  [Codex `hook_additional_context.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/hook_additional_context.rs#L19-L42),
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L5040-L5043)

#### Where hooks are defined

- Hooks are defined in the harness's configuration, at…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-locations),
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L156-L346),
  [Codex `hook_runtime.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime.rs#L1088-L1107)

### Plugins

- A plugin is a directory of components, such…
  [Claude Code plugins](https://code.claude.com/docs/en/plugins#understand-what-a-plugin-is),
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#manifest-file),
  [Codex `exec-server-protocol/protocol.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec-server-protocol/src/protocol.rs#L54-L59)

#### What a plugin contributes

- A plugin can bundle skills, MCP servers and…
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#standard-layout),
  [Codex `plugin/manifest.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/plugin/src/manifest.rs#L19-L25)

#### Plugin names

- Both harnesses prefix a plugin's skills with the…
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#skills),
  [Codex `namespace.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/loader/namespace.rs#L176-L181)

#### Which copy of a plugin loads

- Both harnesses can load an installed plugin from…
  [Claude Code plugins](https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins),
  [Codex `store.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L112-L120)

### Skills

- A skill is a folder that contains a…
  [Claude Code skills](https://code.claude.com/docs/en/skills#add-supporting-files),
  [Claude Code skills](https://code.claude.com/docs/en/skills#frontmatter-reference)

#### The skill listing

- At session start, the harness adds a listing…
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short),
  [Codex `render.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/render.rs#L23-L27)

#### Invocation

- A user can invoke a skill by naming…
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-content-lifecycle),
  [Codex `fragments.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs#L72-L127),
  [Codex `catalog_prompt.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs)

#### Invoked content over time

- Once added, a skill's content is part of…
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-content-lifecycle)

#### Supporting files and paths

- Other files in a skill's folder enter the…
  [Claude Code skills](https://code.claude.com/docs/en/skills#add-supporting-files),
  [Claude Code skills](https://code.claude.com/docs/en/skills#how-injected-commands-run)

### Subagents

- A subagent is a coding agent that the…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation),
  [Codex `multi_agents_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L88-L92)

#### Initial context

- A fresh subagent's context starts with instruction files…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#what-loads-at-startup),
  [Codex `thread_manager.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/thread_manager.rs#L2263-L2301),
  [Codex `agent/control/spawn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control/spawn.rs#L1000-L1002)

#### Results and side effects

- When a subagent finishes, the harness adds its…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-the-timeline-shows),
  [Codex `control.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control.rs#L524-L587)

#### Subagent definitions

- A subagent's instructions can come from a definition…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope),
  [Codex `loader.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs#L23-L117)

### Compaction

- Compaction removes content from the context. The harness…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#when-your-context-fills-up),
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-survives-compaction),
  [Codex `openai_models.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/openai_models.rs#L583-L594),
  [Codex `compact.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L682-L800),
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L5040-L5043)

### Running an agent from a program

## `claude-code.md`

### How the model generates text

#### Inference requests

- The Claude Messages API is stateless: the client…
  [Messages API](https://platform.claude.com/docs/en/build-with-claude/working-with-messages#multiple-conversational-turns),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#pricing)

### What the context holds

- Claude Code sends its system prompt ahead of…
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#system-prompt)

#### At session start

- Before the user types anything, Claude Code loads…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-the-timeline-shows)

#### Instruction files

- Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from the…
  [Claude Code memory](https://code.claude.com/docs/en/memory#how-claude-md-files-load),
  [Claude Code memory](https://code.claude.com/docs/en/memory#choose-where-to-put-claude-md-files),
  [Claude Code memory](https://code.claude.com/docs/en/memory#set-up-rules),
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#system-prompt),
  [Claude Code memory](https://code.claude.com/docs/en/memory#path-specific-rules),
  [Claude Code memory](https://code.claude.com/docs/en/memory#when-claude-code-reads-agents-md)

#### During the session

- Claude Code inserts its own messages as system…
  [Claude Code glossary](https://code.claude.com/docs/en/glossary#system-reminder)

#### Across sessions

- Claude Code also carries content across sessions in…
  [Claude Code memory](https://code.claude.com/docs/en/memory#how-it-works)

### The turn

- Each response from the Claude API ends with…
  [Claude stop reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons#stop-reason-values),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Claude Code settings](https://code.claude.com/docs/en/settings-reference#idlecompaction)

#### Other ends and continuations

- A response can also stop because it reached…
  [Claude stop reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons#stop-reason-values)

#### Asynchronous notifications

- Work that runs in the background reports back…
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference#background-commands),
  [Claude Code interactive mode](https://code.claude.com/docs/en/interactive-mode#how-backgrounding-works),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/typescript#sdktasknotificationmessage),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#automatic-backgrounding-of-long-tool-calls),
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference#monitor-tool),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/typescript#sdkmessageorigin),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#stop-an-mcp-task-or-get-its-result)

### Tool calls and permissions

- A tool call is a tool-use block in…
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#when-claude-uses-tools)

#### Built-in, MCP and server tools

- Built-in tools are implemented by Claude Code itself…
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference),
  [Claude tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview#how-tool-use-works),
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference#check-which-tools-are-available)

- Claude Code names an MCP tool `mcp__<server>__<tool>`, and…
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#mcp),
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#server-names-tool-names-and-reloads)

- By default, Claude Code defers the definitions of…
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#scale-with-mcp-tool-search),
  [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#configure-tool-search),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#exempt-a-server-from-deferral)

- By default, Claude Code saves a successful MCP…
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#mcp-output-limits-and-warnings)

#### Permissions

- Claude Code first runs any `PreToolUse` hooks. A…
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#extend-permissions-with-hooks),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#precedence-among-rules-hooks-and-mods),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#manage-permissions),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#mcp),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#permission-system),
  [Claude Code permissions](https://code.claude.com/docs/en/permissions#add-a-comment-when-you-answer-a-permission-prompt)

- When no one is present to answer a…
  [Claude Code headless](https://code.claude.com/docs/en/headless#turn-off-permission-prompts-in-unattended-runs)

### Hooks

- Claude Code supports five types of handler: a…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-handler-fields)

#### Hook events

- Claude Code defines further events, for example for…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-lifecycle)

#### Hook input and output

- An HTTP hook receives the event as the…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#common-input-fields),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#exit-code-output),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#timeouts),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#block-the-action-when-a-hook-fails)

#### What a hook can control

- A `PreToolUse` hook can deny a tool call…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#pretooluse-decision-control),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#permissionrequest-decision-control)

- By default, after stop hooks have continued a…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#stop-input)

#### Hook output in the context

- A hook adds text to the context through…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#add-context-for-claude),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#exit-code-0),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#json-output),
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-survives-compaction),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#how-async-hooks-execute)

#### Where hooks are defined

- Claude Code reads hooks from user, project and…
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-locations),
  [Agent SDK hooks](https://code.claude.com/docs/en/agent-sdk/hooks#configure-hooks),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#hook-handler-fields),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#workspace-trust)

### Plugins

- The manifest is `.claude-plugin/plugin.json`, and `name` is its…
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#manifest-file),
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#fields)

#### What a plugin contributes

- A plugin can bundle skills, commands, subagent definitions…
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#standard-layout),
  [Claude Code plugins](https://code.claude.com/docs/en/plugins#what-an-enabled-plugin-adds-to-your-sessions)

- Other components act whether or not the model…
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#when-plugin-hooks-fire),
  [Claude Code MCP](https://code.claude.com/docs/en/mcp#plugin-provided-mcp-servers),
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#monitors),
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#executables)

#### Plugin names

- Claude Code namespaces every component of a plugin…
  [Claude Code plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference#name),
  [Claude Code plugin components](https://code.claude.com/docs/en/plugins/components#skills),
  [Claude Code skills](https://code.claude.com/docs/en/skills#resolve-skills-that-share-a-name),
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope)

#### Which copy of a plugin loads

- Claude Code copies a plugin installed from a…
  [Claude Code plugins](https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins),
  [Claude Code plugins](https://code.claude.com/docs/en/plugins/loading#when-auto-update-runs)

### Skills

- Every frontmatter field is optional: the name defaults…
  [Claude Code skills](https://code.claude.com/docs/en/skills#frontmatter-reference)

#### The skill listing

- By default, Claude Code lists every skill's name…
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short),
  [Claude Code skills](https://code.claude.com/docs/en/skills#control-who-invokes-a-skill)

#### Invocation

- A skill runs when the user puts its…
  [Claude Code skills](https://code.claude.com/docs/en/skills#where-you-write-the-skills-name),
  [Claude Code skills](https://code.claude.com/docs/en/skills#restrict-claude%E2%80%99s-skill-access),
  [Claude Code skills](https://code.claude.com/docs/en/skills#available-string-substitutions),
  [Claude Code skills](https://code.claude.com/docs/en/skills#inject-dynamic-context),
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-content-lifecycle),
  [Claude Code skills](https://code.claude.com/docs/en/skills#frontmatter-reference),
  [Claude Code skills](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent)

#### Invoked content over time

- Claude Code does not re-read the skill file…
  [Claude Code skills](https://code.claude.com/docs/en/skills#skill-content-lifecycle)

#### Supporting files and paths

- A `` !`command` `` placeholder can also inject…
  [Claude Code skills](https://code.claude.com/docs/en/skills#inject-dynamic-context),
  [Claude Code skills](https://code.claude.com/docs/en/skills#how-injected-commands-run),
  [Claude Code skills](https://code.claude.com/docs/en/skills#available-string-substitutions)

### Subagents

- The model requests a subagent with the Agent…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation),
  [Claude Code skills](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent)

#### Initial context

- A fresh subagent's initial context holds its own…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#what-loads-at-startup),
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation)

#### Results and side effects

- A subagent's summary comes back with a small…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-the-timeline-shows),
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#tools-permissions-and-results-of-background-subagents),
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation)

#### Subagent definitions

- Claude Code registers each Markdown file in a…
  [Claude Code subagents](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope)

### Compaction

- Claude Code compacts automatically when the context window…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#when-your-context-fills-up),
  [Claude Code settings](https://code.claude.com/docs/en/settings-reference#idlecompaction),
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-survives-compaction)

- After compaction, the system prompt still applies, and…
  [Claude Code context window](https://code.claude.com/docs/en/context-window#what-survives-compaction)

### Running an agent from a program

#### Programmatic interfaces

- Claude Code runs non-interactively with the `-p` flag…
  [Claude Code headless](https://code.claude.com/docs/en/headless#basic-usage),
  [Claude Code headless](https://code.claude.com/docs/en/headless#pipe-data-through-claude),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview#compare-the-agent-sdk-to-other-claude-tools),
  [Agent SDK agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop#the-loop-at-a-glance)

#### Output and exit status

- By default, `claude -p` prints the final response…
  [Claude Code headless](https://code.claude.com/docs/en/headless#get-structured-output),
  [Claude Code headless](https://code.claude.com/docs/en/headless#stream-responses),
  [Claude Code headless](https://code.claude.com/docs/en/headless#basic-usage),
  [Claude Code headless](https://code.claude.com/docs/en/headless#background-tasks-at-exit)

#### What a non-interactive run loads

- By default, `claude -p` discovers and loads what…
  [Claude Code headless](https://code.claude.com/docs/en/headless#start-faster-with-bare-mode),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/claude-code-features#control-filesystem-settings-with-settingsources),
  [Agent SDK](https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts#how-system-prompts-work),
  [Claude Code hooks](https://code.claude.com/docs/en/hooks#workspace-trust)

#### Approvals and limits in a non-interactive run

- From Claude Code v2.1.302, a `claude -p` or…
  [Claude Code permission modes](https://code.claude.com/docs/en/permission-modes#which-mode-a-non-interactive-run-starts-in),
  [Claude Code CLI](https://code.claude.com/docs/en/cli-reference#cli-flags),
  [Agent SDK agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop#turns-and-budget)

#### Sessions across runs

- A program continues the most recent Claude Code…
  [Claude Code headless](https://code.claude.com/docs/en/headless#continue-conversations),
  [Claude Code sessions](https://code.claude.com/docs/en/sessions#what-a-resumed-session-restores),
  [Claude Code sessions](https://code.claude.com/docs/en/sessions#flags-to-pass-again-when-you-resume)

## `codex.md`

### What the context holds

#### At session start

- Codex builds an initial context from sections that…
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L5142-L5149),
  [Codex `world_state`](https://github.com/openai/codex/tree/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/world_state)

#### Instruction files

- Codex loads `AGENTS.override.md` from its home directory, or…
  [Codex `instructions/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-home/src/instructions/mod.rs#L40-L83),
  [Codex `agents_md.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md.rs#L199-L302),
  [Codex `config_toml.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config/src/config_toml.rs#L76),
  [Codex `agents_md_manager.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agents_md_manager.rs#L69-L135),
  [Codex `world_state/agents_md.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/world_state/agents_md.rs#L11-L13)

### The turn

- Codex sends another request when the model has…
  [Codex `stream_events_utils.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/stream_events_utils.rs#L360-L421),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L3677-L3679),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L692-L866)

#### Asynchronous notifications

- `exec_command` returns a session ID for a command…
  [Codex `shell_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/shell_spec.rs#L75-L138),
  [Codex `async_watcher.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/unified_exec/async_watcher.rs#L155-L243),
  [Codex `completion.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control/completion.rs#L28-L152),
  [Codex `agent/control.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control.rs#L582-L587),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L537-L560),
  [Codex `input_queue.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/input_queue.rs#L395-L416),
  [Codex `inject.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/inject.rs#L198-L225),
  [Codex `session/handlers.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/handlers.rs#L84-L104),
  [Codex `followup_task.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/followup_task.rs#L41-L47),
  [Codex `features/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/features/src/lib.rs#L2285-L2290),
  [Codex `ext/goal/extension.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/goal/src/extension.rs#L180-L201)

### Tool calls and permissions

#### Built-in, MCP and server tools

- Codex builds the model's tools for each step…
  [Codex `spec_plan.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/spec_plan.rs#L122-L218),
  [Codex `spec_plan.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/spec_plan.rs#L724-L754)

- Codex reads its MCP servers from the `mcp_servers`…
  [Codex `config_toml.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config/src/config_toml.rs#L306-L310),
  [Codex `codex-mcp/tools.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-mcp/src/tools.rs#L126-L303),
  [Codex `codex-mcp/mcp/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-mcp/src/mcp/mod.rs#L651-L666),
  [Codex `handlers/mcp.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/mcp.rs#L611-L616)

- By default, Codex defers MCP tools. It omits…
  [Codex `mcp_tool_exposure.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/mcp_tool_exposure.rs#L155-L159),
  [Codex `spec_plan.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/spec_plan.rs#L284-L319),
  [Codex `tool_search_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/tool_search_spec.rs#L93-L95),
  [Codex `tool_search.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/tool_search.rs#L237),
  [Codex `tools/context.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/context.rs#L290-L305),
  [Codex `rmcp_client.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-mcp/src/rmcp_client.rs#L1073-L1075)

- Codex truncates an MCP result to the tool's…
  [Codex `handlers/mcp.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/mcp.rs#L298-L301)

#### Permissions

- Codex decides according to its approval policy. Under…
  [Codex `protocol.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/protocol.rs#L1184-L1207),
  [Codex `exec/src/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L640-L642),
  [Codex `exec_policy.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L897-L911),
  [Codex `exec_policy.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L421-L509),
  [Codex `sandboxing.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/sandboxing.rs#L265-L283)

- By default, Codex decides from an MCP tool's…
  [Codex `mcp_tool_call.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/mcp_tool_call.rs#L2840-L2867),
  [Codex `mcp_tool_call.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/mcp_tool_call.rs#L1893-L1901),
  [Codex `approvals.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/approvals.rs#L600-L705),
  [Codex `codex-mcp/mcp/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/codex-mcp/src/mcp/mod.rs#L96-L115)

### Hooks

- Codex runs command and MCP-tool handlers, and skips…
  [Codex `protocol/hooks.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/hooks.rs#L140-L188),
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L782-L801)

#### Hook events

- Codex adds `Interrupt`, when a turn is interrupted…
  [Codex `hook_runtime.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime.rs#L500-L546),
  [Codex `hook_runtime/sampling.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime/sampling.rs#L57-L119)

#### Hook input and output

- Exit code 2 blocks only when the hook…
  [Codex `pre_tool_use.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/pre_tool_use.rs#L268-L298)

#### What a hook can control

- A `PreToolUse` hook can deny a call but…
  [Codex `output_parser.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/output_parser.rs#L441-L482),
  [Codex `permission_request.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/permission_request.rs#L153-L173),
  [Codex `approvals.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/approvals.rs#L600-L627),
  [Codex `exec_policy.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/exec_policy.rs#L470-L474)

- A `Stop` hook's reason reaches the model as…
  [Codex `items.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/items.rs#L132-L139),
  [Codex `items.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/items.rs#L756-L788)

#### Hook output in the context

- Only `SessionStart`, `SubagentStart`, `UserPromptSubmit`, `PreToolUse` and
  `PostToolUse` hooks…
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L686-L703),
  [Codex `session_start.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/events/session_start.rs#L305-L314),
  [Codex `hook_additional_context.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/context/hook_additional_context.rs#L19-L42),
  [Codex `hook_runtime.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/hook_runtime.rs#L911-L917),
  [Codex `output_spill.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/output_spill.rs#L12-L13),
  [Codex `compact.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L635-L651),
  [Codex `compact_remote_v2.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact_remote_v2.rs#L618-L679)

#### Where hooks are defined

- Codex reads hooks from managed requirements, from enabled…
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L156-L346),
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L836-L924),
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L112-L140)

### Plugins

- Codex recognises a `plugin.json` at the plugin's root…
  [Codex `plugin_namespace.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/plugins/src/plugin_namespace.rs#L12-L80),
  [Codex `exec-server-protocol/protocol.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec-server-protocol/src/protocol.rs#L54-L59)

#### What a plugin contributes

- A plugin can bundle skills, MCP servers, apps…
  [Codex `plugin/manifest.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/plugin/src/manifest.rs#L19-L25),
  [Codex `core-plugins/loader.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/loader.rs#L942-L952),
  [Codex `hooks/discovery.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/hooks/src/engine/discovery.rs#L836-L924),
  [Codex `store.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L639-L646)

#### Plugin names

- A user can mention a plugin's skill as…
  [Codex `mentions.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/skills/src/mentions.rs#L226-L228)

#### Which copy of a plugin loads

- Codex loads an installed plugin from a copy…
  [Codex `store.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L112-L120),
  [Codex `store.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/store.rs#L736-L760),
  [Codex `core-plugins/loader.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core-plugins/src/loader.rs#L667-L672)

### Skills

#### The skill listing

- By default, Codex lists each skill's name, description…
  [Codex `render.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/render.rs#L23-L27),
  [Codex `host.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/provider/host.rs#L170-L172)

#### Invocation

- A skill's body enters the context in one…
  [Codex `selection.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/selection.rs#L33-L112),
  [Codex `host_outcome.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/host_outcome.rs#L151-L177),
  [Codex `fragments.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/fragments.rs#L72-L127),
  [Codex `render.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/render.rs#L25),
  [Codex `host_prompt.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/host_prompt.rs#L84-L88),
  [Codex `extension.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/extension.rs#L350-L361),
  [Codex `world_state_catalogs.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/world_state_catalogs.rs#L441-L487),
  [Codex `extension.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/extension.rs#L446-L458),
  [Codex `models.json`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager/models.json),
  [Codex `catalog_prompt.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs)

#### Supporting files and paths

- Codex instructs the model to resolve a skill's…
  [Codex `models.json`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager/models.json),
  [Codex `catalog_prompt.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/ext/skills/src/catalog_prompt.rs)

### Subagents

- The model requests a subagent with `spawn_agent`…
  [Codex `multi_agents_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L88-L92)

#### Initial context

- Whether a subagent starts fresh or as a…
  [Codex `config/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1780-L1807),
  [Codex `multi_agents_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L626-L632),
  [Codex `multi_agents_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L664-L669),
  [Codex `spawn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs#L209-L239),
  [Codex `models.json`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/models-manager/models.json),
  [Codex `history.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/history.rs#L87-L134),
  [Codex `config/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/config/mod.rs#L1479),
  [Codex `thread_manager.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/thread_manager.rs#L2263-L2301),
  [Codex `agent/control/spawn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control/spawn.rs#L1000-L1002)

#### Results and side effects

- The parent receives the subagent's final message as…
  [Codex `control.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/control.rs#L524-L587),
  [Codex `multi_agents_spec.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L805)

#### Subagent definitions

- Besides its built-in `default`, `explorer` and `worker` roles…
  [Codex `role.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/agent/role.rs#L315-L350),
  [Codex `loader.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/agent-roles/src/loader.rs#L23-L117)

### Compaction

- Codex compacts automatically when the context reaches 90%…
  [Codex `openai_models.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/openai_models.rs#L583-L594),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L1597-L1626),
  [Codex `turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/turn.rs#L773-L830),
  [Codex `capabilities.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/model-provider/src/capabilities.rs#L34-L42),
  [Codex `protocol/models.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/protocol/src/models.rs#L1385-L1390),
  [Codex `compact.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L123-L154),
  [Codex `compact.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact.rs#L682-L800),
  [Codex `compact_remote_v2.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact_remote_v2.rs#L557-L602),
  [Codex `compact_remote_v2_installation.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/compact_remote_v2_installation.rs#L226-L242)

### Running an agent from a program

#### Programmatic interfaces

- Codex runs non-interactively with `codex exec`, which takes…
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L104-L108),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L1107-L1113),
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L20-L27),
  [Codex `cli/main.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/cli/src/main.rs#L178),
  [Codex `cli/main.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/cli/src/main.rs#L602-L613),
  [Codex `common.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/app-server-protocol/src/protocol/common.rs#L575-L592),
  [Codex `common.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/app-server-protocol/src/protocol/common.rs#L1113-L1136),
  [Codex `rpc.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/app-server-protocol/src/rpc.rs#L1-L2),
  [Codex `sdk/typescript/src/exec.ts`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/sdk/typescript/src/exec.ts#L94-L95),
  [Codex `sdk/python/src/openai_codex/client.py`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/sdk/python/src/openai_codex/client.py#L215-L256)

#### Output and exit status

- By default, `codex exec` writes nothing to standard…
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L1-L4),
  [Codex `exec_events.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/exec_events.rs#L9-L43),
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L95-L102),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L1474-L1491),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L1543-L1544)

#### What a non-interactive run loads

- `codex exec` loads its configuration as the interactive…
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L800-L827),
  [Codex `tui/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/tui/src/lib.rs#L667-L690),
  [Codex `exec/tests/suite/agents_md.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/tests/suite/agents_md.rs#L6-L74),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L684-L696),
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L58-L61),
  [Codex `shared_options.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/cli/src/shared_options.rs#L61-L64)

#### Approvals and limits in a non-interactive run

- `codex exec` sets the approval policy to `never`…
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L640-L642),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L854-L887),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L2289-L2421),
  [Codex `config_toml.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/config/src/config_toml.rs#L913-L922),
  [Codex `v2/turn.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/app-server-protocol/src/protocol/v2/turn.rs#L290-L293),
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L15-L109),
  [Codex `shared_options.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/utils/cli/src/shared_options.rs)

#### Sessions across runs

- `codex exec resume` continues a session given its…
  [Codex `exec/cli.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/cli.rs#L228-L296),
  [Codex `exec_events.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/exec_events.rs#L9-L43),
  [Codex `session/mod.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/core/src/session/mod.rs#L1980-L2008),
  [Codex `exec/lib.rs`](https://github.com/openai/codex/blob/49d657aad0e878fb7ab156b91126828c21a0005f/codex-rs/exec/src/lib.rs#L1607-L1633)
