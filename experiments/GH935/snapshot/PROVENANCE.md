Frozen copies, so the arms keep working when the plugin moves on.

Taken from commit 177fb6398a9b4c7d784c94e400e3089f78f47622:

- plain-english.md  <- plugins/dream/plain-english.md
- copy-editor.md    <- plugins/dream/agents/copy-editor.md

copy-editor.md keeps its frontmatter. The frontmatter is not part of the
prompt; it records that the agent runs on Sonnet at medium effort, which is
what the editor call is pinned to.
