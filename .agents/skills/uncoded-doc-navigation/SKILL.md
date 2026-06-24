---
name: uncoded-doc-navigation
description: Use before searching or reading a codebase's Markdown documentation indexed by uncoded — locating which file and section cover a topic, or orienting to what documentation exists.
---

# Documentation Navigation

This codebase uses [uncoded](https://github.com/alimanfoo/uncoded) to maintain
a documentation index.

**Step 1 — Orient. Read the docs map first.** Before answering the
user, before any other tool call:

```text
Read .uncoded/docs.yaml
```

`.uncoded/docs.yaml` is an orientation outline: it lists every Markdown file
and its heading hierarchy. Read it in full, now.

**Step 2 — Navigate.** Headings in the map are literal text. Use `Read` or
`grep` to navigate to a specific section identified in the map.
