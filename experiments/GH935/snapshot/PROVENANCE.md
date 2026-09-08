Frozen copies, so the arms keep working when the plugin moves on.

`copy-editor.md` came from `plugins/dream/agents/copy-editor.md` at commit
177fb63. It keeps its frontmatter, which is not part of the prompt: it records
that the agent runs on Sonnet at medium effort, which is what the editor call
is pinned to.

`guides/` holds one copy of the Plain English guide per version an arm reads.
A file is named for the commit its content came from, so a name says where to
look and stops meaning anything else when the guide changes again.

- `plain-english-177fb63.md` came from `plugins/dream/plain-english.md` at
  commit 177fb63, before any of the changes below. It has the "Use active
  voice" section, the "Start with who does what" rule, and "Write as if
  speaking". Arm 2 reads it.

- `plain-english-be5d1d38.md` came from the same file at commit be5d1d38, which
  is the guide as it stands. Three sections went between the two: #938 removed
  "Use active voice", #940 removed "Write as if speaking", and be5d1d38 removed
  "Start with who does what", which was the last of the active voice rule.
  Arm 12 reads it.

- `plain-english-be5d1d38-plus-speech.md` is the file above with "Write as if
  speaking" put back where it was, ahead of "Write to communicate". No commit
  holds it. It exists so that #940 can be judged on its own, since the other
  two removals answer this experiment's own evidence and that one does not.
  Arm 11 reads it.
