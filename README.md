# dream

A plugin for delivering great code and keeping the codebase coherent, with
minimal human input. It installs under Claude Code and Codex.

Choose the workflow that fits the task:

- `/dream:smith` plans a task, implements it, and reviews the result.
- `/dream:less` carries a small task straight through to a pull request.

`/dream:smith` and `/dream:less` also run unattended, from a repository's
labelled issues. Dreamcatcher does that, as a separate package, at
[alimanfoo/dreamcatcher](https://github.com/alimanfoo/dreamcatcher).

The plugin also includes standalone skills for requirements, code analysis,
design, roadmapping, planning, and review. Run the skills list in your host to
see them all.

## Prerequisites

Every skill runs under Claude Code. Codex support is partial: it includes
`dream:smith`, `dream:less`, `dream:spark`, `dream:state`, `dream:shape`,
`dream:seer`, `dream:code-review`, `dream:coherence-review`, and
`dream:precedent-review`. Put a `$` in front of a skill's name in a Codex
prompt:

```text
$dream:state
```

Install `gh` 2.94.0 or later and sign in when you want dream to work with GitHub
pull requests and issues. `dream:seer` uses the parent and blocked-by flags that
this version introduced.

## Installation

Under Claude Code:

```text
/plugin marketplace add alimanfoo/dream
/plugin install dream@dream
```

Under Codex:

```bash
codex plugin marketplace add alimanfoo/dream
codex plugin add dream@dream
```

## Roadmaps with /dream:seer

`/dream:seer` works with you to break a finished design into an ordered roadmap,
where each stage is one reviewable pull request. It puts the roadmap in the repo
as a markdown file on a pull request, and can create one blocked-by-chained
child issue per stage.

Run `/dream:seer GH123` under Claude Code or `$dream:seer GH123` under Codex,
where the issue carries the requirements, reading guide and design. Point it at
a spec folder instead when those sit in the repo as files. Seer leaves the child
issues unassigned and unlabelled, so you decide when implementation starts.

## Tasks with /dream:smith

`/dream:smith` carries a well-specified task through planning, implementation,
and review. It opens a draft pull request and marks it ready when the work is
complete.

Run `/dream:smith` under Claude Code or `$dream:smith` under Codex. Name the
task as an argument, such as `/dream:smith GH123`. Without one, Smith uses the
issue numbers in the current branch name, such as `GH83`. Without those, it asks
you for the task.

## Smaller tasks with /dream:less

`/dream:less` is a cut-back Smith for a small, self-contained change. It skips
planning and the separate coherence and precedent review passes.

Run `/dream:less` under Claude Code or `$dream:less` under Codex. It takes the
task the same way Smith does.

## Troubleshooting

A `/dream:smith` or `/dream:less` session prints the plugin version as it
starts. Quote that version when you report a problem.

### Permissions

If you have it on your plan, switch to `auto` permissions mode before you start
a session. This should handle most permissions automatically.

You may still hit occasional permissions blocks, for example when posting to
GitHub.

## License

MIT. See [LICENSE](LICENSE).
