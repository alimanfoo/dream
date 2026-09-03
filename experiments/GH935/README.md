# GH935: does copy-editing help?

Part 2 of alimanfoo/dream#935. Two questions, answered by the same runs:

- Does `dream:copy-edit` improve prose, or damage it?
- Can a different approach do better?

Every arm is a bare `claude -p` call from a directory outside this repo.
Nothing resolves a skill or installs a plugin, so the arms differ only in the
text of the prompt, and no arm can be affected by anything the plugin says
except what a prompt hands it deliberately.

`findings.md` says what the runs have shown so far. Read it after a comparison
has been judged rather than before, since it says which arm produced what.

## The arms

| Arm | What it is |
| --- | --- |
| 1 | seed prompt, vanilla |
| 2 | Plain English guide first, then the seed prompt |
| 3 | arm 1, then one copy-edit round |
| 4 | arm 3, then a second copy-edit round |
| 5 | arm 2, then one copy-edit round: what `dream:smith` does today |
| 6 | arm 1, then a rewrite as a conversation |
| 7 | arm 1, through a conversation and set out again as prose |
| 8 | arm 1, worked down from paragraphs to clauses |
| 9 | arm 8, plus a step for vocabulary and a step for active voice |
| 10 | arm 1, rewritten from the story underneath it |

Arms 1, 2, 3 and 5 form a 2x2: guide before writing or not, against
copy-editing afterwards or not. Arm 4 extends arm 3 to see whether a second
round makes things worse.

Arms 7 to 10 are candidate approaches. Arms 8 and 9 differ by the steps that
rewrite rather than move, so what such a step costs can be read off the pair.
Arm 9's steps run from the widest scope to the narrowest, which is why
vocabulary comes first: the passage is the only place that property lives.
Arm 10 takes a different route, recovering the story under the passage and
writing it again from that, so it repairs nothing and rebuilds everything.

Arm 6 is retired, because it invents knowledge the passage never gave it. Its
runs stand as the evidence for that, `make arm6` still builds it, and `make
all` leaves it alone.

Three replicates of arms 1 and 2. Every other arm runs once per replicate of
the arm it builds on, so each of them is paired to a specific piece of text.

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
- `judgements/` — the key saying which arm is A in each comparison, and the
  answers as they are given.
- `judge.py` — shows one comparison at a time and records the answer.
- `measure.py` — counts the prose features the arms are compared on.
- `findings.md` — what has been found, and the measurements behind it.

## The fixtures

`docstring-2` is the default. It documents a dict merge and asks for the prose
alone.

`docstring-1` documents a retry helper and includes the `Args`, `Returns` and
`Raises` template. That template turned out to carry most of the structure and
to confound every comparison, which is why `docstring-2` drops it. Both the
owner and an earlier session have read most of `docstring-1`, so it is spent
as judging material and stands as a record instead.

`runs/model-effort-2x2/` is a separate one-off: the same docstring request at
Sonnet and Opus, low and high effort. It asked whether writing quality depends
on the model and the effort. It does, but mostly through how well the model
read the code rather than how well it wrote.

## Running

    cd arms
    make                 say what running everything would do, and do none of it
    make all -j3         every arm, every replicate
    make arm8 -j3        one arm, and whatever it needs
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

An arm that writes the passage back to a file after each step records one
write per step in its events. Fewer writes than steps means the run collapsed
the steps, and did not test what it looks like it tested.

## Judging

    ./judge.py

That serves the next comparison that has no answer, at
`http://127.0.0.1:8765`. It shows two passages, named A and B, and one question
that never changes. It says nothing about which comparison this is, since the
question a pair answers would say what was done to one of the two and the
position in the sequence would say which pair it belongs to. The answer it
writes records the letter, so the key holds for every comparison still to come,
along with whether the reader would accept each version as it stands.

    ./judge.py --progress    how many are answered, and nothing about them
    ./judge.py --tally       what each pair came to
    ./judge.py --report      which arm won each comparison already answered

## Measuring

    ./measure.py docstring-1 docstring-2

That counts, for each run, the words, the times the function is named, the
times the reader is addressed, and the agentless passives. Every count is a
string match rather than a parse, and every one is a lower bound, so compare
an arm against another arm and read nothing into an absolute number.
