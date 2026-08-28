# GH935 fixtures

`retry.py` is the code the fixtures document. `generate-prompt.md` is the
template used to generate them, with `{{CODE}}` replaced by the whole of
`retry.py`.

Each `vanilla-retry-<model>-<effort>.md` is one run, captured verbatim:

```
cd <a directory outside this repo>
claude -p --model <model> --effort <effort> --strict-mcp-config "<the filled template>"
```

The runs happen outside the repo so nothing the dream plugin says reaches them.
There is no user-level CLAUDE.md and the plugin is not installed globally, so
the output has never met the Plain English guide.
