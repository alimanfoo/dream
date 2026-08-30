# GH935: does copy-editing help?

Part 2 of alimanfoo/dream#935. Two questions, answered by the same runs:

- Does `dream:copy-edit` improve prose, or damage it?
- Can a different approach do better?

Every arm is a bare `claude -p` call from a directory outside this repo.
Nothing resolves a skill or installs a plugin, so the arms differ only in the
text of the prompt, and no arm can be affected by anything the plugin says
except what a prompt hands it deliberately.

## The arms

| Arm | What it is |
| --- | --- |
| 1 | seed prompt, vanilla |
| 2 | Plain English guide first, then the seed prompt |
| 3 | arm 1, then one copy-edit round |
| 4 | arm 3, then a second copy-edit round |
| 5 | arm 2, then one copy-edit round: what `dream:smith` does today |
| 6 | arm 1, then a rewrite as a conversation |

Arms 1, 2, 3 and 5 form a 2x2: guide before writing or not, against
copy-editing afterwards or not. Arm 4 extends arm 3 to see whether a second
round makes things worse.

Three replicates of arms 1 and 2. Arms 3, 4, 5 and 6 each run once per
replicate of the arm they build on, so each of them is paired to a specific
piece of text.

## Layout

- `snapshot/` — frozen copies of the guide and the copy editor's instructions,
  so the arms keep working when the plugin moves on.
- `fixtures/` — one folder per fixture, each with a seed prompt, the reader,
  and the source file it documents. `sources/` holds the code. A fixture is
  one instance of a kind of writing, so `docstring-1` is the first docstring
  and there will be others.
- `arms/` — the prompt templates and `run.sh`. Numbered arms are the baseline
  set. Lettered arms are candidate approaches, and there will be more of them.
- `runs/` — captured output, verbatim.

`runs/model-effort-2x2/` is a separate one-off: the same docstring request at
Sonnet and Opus, low and high effort. It asked whether writing quality depends
on the model and the effort. It does, but mostly through how well the model
read the code rather than how well it wrote.

## Running

    cd arms
    make                 say what running everything would do, and do none of it
    make all -j3         every arm, every replicate
    make arm6 -j3        one arm, and whatever it needs
    make all F=readme-1  a different fixture

An arm that reads another arm's output is a prerequisite of it, so make works
out the order and what is already done. Keep `-j` small: a copy-edit round
holds a large prompt open for about two minutes, and enough of those at once
fail in the transport rather than in the model.

A rebuild costs minutes and money, and gives different text rather than the
same text again, so plain `make` only reports. Nothing is spent until you ask
for it by name.

make decides from timestamps and git records none, so a clone or a branch
switch would stamp every file with the current time and leave most outputs
looking stale. `restore-mtimes.sh` gives each file back the time its content
last changed, and the Makefile runs it before looking at any target, so a
fresh clone needs nothing remembered.

An arm can also be run on its own, which is how to smoke-test a change
cheaply, since the models are overridable:

    WRITER_MODEL=haiku WRITER_EFFORT=low 1-vanilla/run.sh docstring-1 1

Each run gets a folder, `runs/<fixture>/arm<N>-r<replicate>/`, holding three
files per call the arm makes. The arm's result is always `output.md`. An arm
that takes more than one call names its earlier ones, so arm 3 leaves
`findings.md` beside its `output.md`.

- `<call>.md` is the text.
- `<call>.jsonl` is the call's events, which say which tools ran, how long it
  took, what it cost and whether it failed, so a call can be audited without
  being repeated. Token deltas are dropped, since they only restate the text.
- `<call>.meta.json` says where the text came from: fixture, arm, replicate,
  call, model, effort, when it ran, the repository commit, and a hash of the
  exact prompt. A file copied out for judging can still be traced back, and
  revising an arm's prompt makes its old output stop matching rather than pass
  for new. The prompt itself is not kept, since the arm, the snapshot and the
  fixture are all committed and rebuild it exactly.
