# Special cases

This page is the ledger of special cases: text in the plugin that applies to one
particular situation rather than stating a general rule. Each entry records
where the text is, what differs between the situations it covers, and which
constraint outside the project causes it. The standard's
[Rules not cases](standard.md#rules-not-cases) criterion requires every special
case to have an entry, and sets the requirement for its cause.

## Agent harnesses

Each of these special cases exists because Claude Code and Codex behave
differently.

| Where                                                                                                                | What differs                                                                                                                                                                                                         | Cause                                                                                                                                                                                                                            |
| -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `dream:code-review` and `dream:coherence-review`, "Launch the lenses"; `dream:precedent-review`, "Launch the review" | Under Claude Code, the skill launches the subagent type that the plugin's subagent file defines. Under Codex, it launches a plain subagent, gives it the subagent file's path, and tells it to skip the frontmatter. | Claude Code registers each file in a plugin's `agents/` directory as a subagent type. Codex does not read a plugin's `agents/` directory, so a subagent file reaches a Codex subagent only as a path that the subagent reads.    |
| `subagent-waiting.md`                                                                                                | Under Claude Code, the agent ends its turn while a subagent has not reported, and the subagent's completion notification starts a new turn. Under Codex, it calls `list_agents` and `wait_agent` within its turn.    | Under Claude Code, a subagent's completion notification can start a turn in an idle parent. Under Codex, by default, a subagent's completion waits for the parent's next turn, so a parent that ended its turn would not resume. |
| `commitTrailer` in `agent-written-marks.json`, read by `dream:smith`, `dream:less` and `specification-files.md`      | The commit trailer names a different co-author under each agent harness: Claude under Claude Code, Codex under Codex.                                                                                                | The trailer credits the coding agent that wrote the commit, and each agent harness runs a different vendor's coding agent.                                                                                                       |
