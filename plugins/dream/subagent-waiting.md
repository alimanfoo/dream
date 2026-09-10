# Subagent waiting protocol

Use the results of the launch calls as the roster for the current batch. Match
each completion to a subagent on that roster by name or identifier. Do not infer
completion from the number of messages, since one wake-up may carry several
reports.

## Claude Code

If any subagent on the roster has not reported, end your turn. A completion
notification will resume the session. Match every report in the notification to
the roster, then end your turn again only when a rostered subagent has not
reported.

## Codex

Call `list_agents` and compare the roster with its results. If a subagent on the
roster is still running, call `wait_agent` once. When it returns, call
`list_agents` again. Continue only when every subagent on the roster has
completed. Never call `wait_agent` when no rostered subagent is running.

## While you wait

Do not sleep, run a filler command, or write that you are waiting. Do not poll
for progress: each Codex `list_agents` call must be the first check or follow a
`wait_agent` return.
