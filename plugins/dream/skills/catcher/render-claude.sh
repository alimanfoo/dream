#!/usr/bin/env bash
#
# Run a Claude Code round and write its output as text a person can read.
#
# Claude Code streams JSON events under --output-format stream-json. That gives
# the catcher a live view of a round, but no person can read it. This script
# renders each event as a line, so agent.log tells the story of the round: what
# the model said, what it did, and what failed. Codex already streams text like
# this, so only Claude Code needs the script.
#
# It drops the events that carry no story: the model's thinking, a tool result
# that succeeded, and Claude Code's own progress and housekeeping events. The
# full record survives either way. Claude Code writes every session's transcript
# under ~/.claude/projects, and the session line names the session to find it by.
#
# It runs the command rather than filtering a pipe, so it can exit with the
# command's own status. The caller logs that status.
#
# A line that is not a stream event passes through as it stands, so a warning
# from the harness still reaches the log.

set -uo pipefail

die() { printf 'render-claude: %s\n' "$*" >&2; exit 2; }

[ $# -gt 0 ] || die "usage: render-claude.sh <command> [argument ...]"
command -v jq >/dev/null 2>&1 || die "jq is not on the PATH"

# Render one event. Each kind of line starts with a label in brackets, so a
# reader can pick out the tool calls, and grep for one kind.
#
# A tool call reports the one input that says what the call is about. The
# fallback list runs from the most telling input to the least, and ends with the
# whole input, so a tool the list does not name still reports something.
#
# A subagent's lines are indented, so the main thread stays easy to follow.
#
# Paths under the worktree lose that prefix, which is most of a path's length
# and the same on every line.
"$@" | jq -Rr --unbuffered --arg cwd "$PWD" '
  def clip($n): if length > $n then .[0:$n] + " ..." else . end;

  def oneline: gsub("\\s+"; " ");

  def shorten: (. | tostring | ltrimstr($cwd + "/") | oneline | clip(200));

  def tool_summary:
    .input as $in
    | ($in.command // $in.file_path // $in.pattern // $in.url // $in.skill
       // $in.description // $in.prompt // $in)
    | shorten;

  def duration:
    (. / 1000 | floor) as $seconds
    | if $seconds >= 60 then "\($seconds / 60 | floor)m\($seconds % 60)s"
      else "\($seconds)s" end;

  def render_assistant:
    if .type == "text" then "\n" + .text
    elif .type == "tool_use" then "[\(.name)] \(tool_summary)"
    else empty end;

  def render_tool_result:
    if .type == "tool_result" and .is_error == true
    then "[failed] \(.content | shorten)"
    else empty end;

  def render_blocks(render_block):
    [.message.content[]? | render_block | select(. != "")]
    | select(length > 0)
    | join("\n");

  def render:
    if .type == "system" and .subtype == "init" then
      "[session] model \(.model), id \(.session_id)"
    elif .type == "assistant" then render_blocks(render_assistant)
    elif .type == "user" then render_blocks(render_tool_result)
    elif .type == "result" then
      "[result] \(.subtype), \(.num_turns) turn"
      + (if .num_turns == 1 then "" else "s" end)
      + ", \(.duration_ms | duration)"
      + ", session cost $\(.total_cost_usd * 100 | round / 100)"
    else empty end;

  def indent: split("\n") | map("  " + .) | join("\n");

  . as $line
  | (try fromjson catch null)
  | if type != "object" then $line
    else (.parent_tool_use_id != null) as $is_subagent
      | render
      | if $is_subagent then indent else . end
    end
'
exit "${PIPESTATUS[0]}"
