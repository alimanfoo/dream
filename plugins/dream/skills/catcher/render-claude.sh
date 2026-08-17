#!/usr/bin/env bash
#
# Run a Claude Code round and write its output as text a person can read.
#
# Claude Code streams JSON events under --output-format stream-json. That gives
# the catcher a live view of a round, but no one can read it. This script
# renders each event as a line, so agent.log tells the story of the round: what
# the model said, what it did, and what failed.
#
# Codex already streams text like this. So only Claude Code needs the script.
#
# The script drops the events that carry no story: the model's thinking, a tool
# result that succeeded, and Claude Code's own progress and housekeeping events.
# The full transcript survives either way. Claude Code writes one for every
# session under ~/.claude/projects. The session line names the id, so a reader
# can find it.
#
# A subagent's report is the substance of the work it did, so the script gives it
# a line. It renders the completion event, which carries the report whether the
# subagent ran in the foreground or the background. A subagent's own words carry
# the report too, but they reach the stream only when its events stream inline.
#
# The script runs the command rather than filtering a pipe, so it can exit with
# the command's own status. The caller logs that status.
#
# The script passes a line through unchanged when it cannot render it: a warning
# from the harness, or an event whose shape breaks the rendering. So a broken
# render costs one line, not the round's log.

set -uo pipefail

die() { printf 'render-claude: %s\n' "$*" >&2; exit 2; }

[ $# -gt 0 ] || die "usage: render-claude.sh <command> [argument ...]"
command -v jq >/dev/null 2>&1 || die "jq is not on the PATH"

# Render one event. Each kind of line starts with a label in brackets. A reader
# can then pick out the tool calls, or grep for one kind.
#
# A tool call reports the one input that says what the call is about. The
# fallback list runs from the most telling input to the least. It ends with the
# whole input, so a tool that the list does not name still reports something.
#
# The script indents a subagent's lines, so the main thread stays easy to
# follow.
#
# A subagent reports its token usage when it finishes, and a background command
# does not. So the usage block tells the two completion events apart, and only
# the subagent's becomes a report.
#
# A path under the worktree loses that prefix. The prefix is the same on every
# line, and most of the path's length.
"$@" | jq -Rr --unbuffered --arg cwd "$PWD" '
  def clip($n): if length > $n then .[0:$n] + " ..." else . end;

  def oneline: gsub("\\s+"; " ");

  def shorten: (. | tostring | ltrimstr($cwd + "/") | oneline | clip(200));

  def tool_summary:
    .input as $in
    | ($in.command // $in.file_path // $in.pattern // $in.url // $in.skill
       // $in.description // $in.prompt // $in)
    | shorten;

  def is_subagent: .parent_tool_use_id != null;

  def is_report:
    .type == "system" and .subtype == "task_notification" and .usage != null;

  def render_assistant($is_subagent):
    if .type == "text" then (if $is_subagent then empty else "\n" + .text end)
    elif .type == "tool_use" then "[\(.name)] \(tool_summary)"
    else empty end;

  def render_tool_failure:
    if .type == "tool_result" and .is_error == true
    then "[failed] \(.content | shorten)"
    else empty end;

  def render_blocks(render_block):
    [.message.content[]? | render_block | select(. != "")]
    | select(length > 0)
    | join("\n");

  def indent: gsub("(?m)^"; "  ");

  def render:
    if .type == "system" and .subtype == "init" then
      "[session] model \(.model), id \(.session_id)"
    elif is_report then ("[report] \(.status)\n\(.summary)" | indent)
    elif .type == "assistant" then
      is_subagent as $is_subagent
      | render_blocks(render_assistant($is_subagent))
    elif .type == "user" then render_blocks(render_tool_failure)
    elif .type == "result" then "[result] \(.subtype)"
    else empty end;

  . as $line
  | try (fromjson
         | if type != "object" then $line
           else is_subagent as $is_subagent
             | render
             | if $is_subagent then indent else . end
           end)
    catch $line
'
exit "${PIPESTATUS[0]}"
