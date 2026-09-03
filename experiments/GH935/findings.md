# What this experiment has found

Read this after a comparison has been judged, not before. It says which arm
produced what, and a judge who knows that is no longer judging the prose.

Each finding says where it comes from. A counted one can be checked by running
`./measure.py`, which reports the table at the foot of this file. A read one
comes from the session record and from the repository owner's own reading, and
the runs behind it are still here to be read again.

## Copy-editing trades agentless prose for a named actor

Counted. On `docstring-2`, arm 1 writes six to eight agentless passives per
replicate and names the function nought times. One copy-edit round takes the
passives to nought and names the function nine, nought and five times. The
same trade happens on `docstring-1`.

The trade is what correctly applying "Use active voice" one span at a time
does. Each span, on its own, reads better with an actor in front of it. The
paragraph they add up to says "the function" at the head of almost every
sentence, which no single finding asked for.

## The owner prefers the copy-edited version, and a model judge does not

Read. On comparison 1 the owner chose the copy-edited version, saying the
vanilla one had "a greyness, a quality of being flat that makes it very hard
to engage with", and that the copy-edited one "felt more like there was a
person behind it".

Three of four blind Opus judges chose the other one, and so did my own
recorded call. Every model reached for compactness: "packs the same content
into far less space", "tighter prose", "less friction". That is the
compression ratchet #936 took out of the guide, arriving back through the
models doing the judging. `judgements/blind-judges-1.md` and
`judgements/claude-call-1.md` hold the verdicts, both written before the owner
gave theirs.

So a model judge does not stand in for the owner here, and the cheap way to
scale this evaluation is closed.

## The reader and the measurements agree on what differs

Counted and read. The vanilla version the owner called flat has seven
agentless passives and no "you", and its sentence subjects are "Both inputs
are left unmodified", "Any other type is replaced" and "There is no sentinel".
Nothing in it does anything. The two accounts of the difference match, even
though they disagree about which version is better.

## A second copy-edit round changes almost nothing

Counted. Arm 4 is arm 3 with one more round. Their prose comes to 292, 274 and
222 words against arm 3's 292, 271 and 223, and each names the function the
same number of times: nine, nought and five.

The second editor has little to report, because the first round already
satisfied the rules it checks. Its findings run 1116, 588 and 1106 bytes
against the first round's 2563, 1562 and 1528. Whether the small change it
does make helps or hurts is still a judgement, and comparison 3-against-4 is
still worth showing.

## Asking for an actor makes the drumbeat, and asking for a voice does not

Counted. Arm 9's voice step first read "say who or what does each thing". That
asks for an actor in every sentence, and the writer supplied the same actor
every time: it named the function seven, eleven and eight times across the
replicates, against arm 3's nine, nought and five. So holding a whole paragraph
was not the fix, even though a paragraph shows the repetition and a span does
not. Those runs are at commit cf9224d.

The step then took the guide's own wording, "use active voice". An active
sentence satisfies that whatever its subject is, so the subject can be the
delay, the result or the reader. That alone cleared it: arm 9 named the
function nought times in every replicate and held the agentless passives at
nought, the first arm to have both. Those runs are at commit d318d8f.

Until then, nought passives and a repeated subject travelled together in every
arm, and the trade looked like what repairing voice costs. It is what asking
for an actor costs.

The two wordings differ in nothing else, so wording decides it at paragraph
scope. Arm 3 differs from both in scope and in mechanism, so what the copy
editor's drumbeat comes from is still open: the span it works on, or the
guide's active voice rule telling it the reader must see who does what. An arm
that gives the copy editor a paragraph at a time would separate the two.

## The voice step clears the drumbeat most times, not every time

Counted. The voice step's three replicates at d318d8f named the function nought
times each, which is what "the first arm to have both" rested on. The same
prompt, run again unchanged for three more, named it nought, six and three
times. So four runs in six.

Arm 9 with the vocabulary step ahead of it names the function nought times in
all three committed replicates, and a further three run here named it nought,
nought and once. So five runs in six.

Neither second sample is committed, since an arm's folder holds one sample at a
time, and both are counts rather than texts. Together they say the step works
most times rather than every time, which three replicates could not have shown
either way. A claim about how often something happens needs more runs than a
claim about which of two texts reads better.

## A vocabulary step costs nothing

Counted. Arm 9 opens with "Across the whole passage, use a consistent
vocabulary", ahead of the five steps it had. It names the function nought times
in every replicate and leaves one agentless passive in one of them. All six
steps ran, one write each, which is the check that the run tested what it looks
like it tested.

The step was worth watching, because "call the same thing by the same name" and
the drumbeat are close relatives: the drumbeat is what consistency looks like
once the thing is the subject. Nothing of the kind happened.

Read. Counting by hand how many different words each replicate uses for a dict,
for replacing a value and for merging, the totals fall from seven, six and six
to five, five and five, which is the step doing what it was asked to do. That
count is a reader's, since it needs a list of which words mean the same thing
here and `measure.py` has none.

## Rewriting from the story leaves the voice where it found it

Counted. Arm 10 works out what the passage is about, reduces that to a spine of
concrete statements, and writes the passage again from the spine.

It does not copy its input, which is the failure arm 7 hit. Against the arm 1
text it was given, its longest shared run is thirteen, six and four words.

It names the function nought, one and nought times, so it does not produce the
drumbeat. It leaves the agentless passives at seven in every replicate, against
arm 1's seven, eight and six, so it does not repair voice either. It runs
longer, at 263, 375 and 287 words against 218, 225 and 214.

So arm 10 moves what these counts do not measure. Whether the prose reads as an
explanation rather than as a revision is what it is for, and only a reader
answers that.

## Working down from paragraphs to clauses leaves the voice alone

Counted and read. Arm 8 moves text and does not rewrite it. It names the
function nought times and leaves the passives where it found them, seven or
eight per replicate against arm 1's six to eight. On `docstring-1` it made
real repairs, including splitting a `TypeError` out of an `Exception:` entry
that was hiding it.

So arm 8 costs nothing in voice. Whether it gains anything is a judgement, and
1-against-8 has not been shown.

## Some runs escape the trade, and not all by addressing the reader

Counted. Six runs have neither the drumbeat nor an agentless passive.

Four of them address the reader. arm2-r2, arm3-r2, arm4-r2 and arm5-r2 use
"you" three to six times, and they come from two independent lines, since arm 5
builds on arm 2 and arm 4 builds on arm 3. So the second person is one way out
of the trade, and two lines found it without being asked.

The other two are arm9-r1 and arm9-r2, which use "you" once each, so their
sentences carry varied concrete subjects rather than a reader or a function.
That is the way out the voice step reaches for, and it reaches it more often
than not rather than every time.

What would test the second person is a prompt that asks for the reader to be
addressed, run against the same fixture.

## The conversation round-trip makes prose longer and more personal

Counted. Arm 7 comes to 380, 352 and 359 words against arm 1's 218, 225 and
214, so passing a passage through a conversation and setting it out again adds
about two thirds again. It uses "you" five, eight and ten times, and keeps the
passives, at eleven, eight and five.

Whether the extra length earns its place is a judgement, and 1-against-7 has
not been shown.

## Quality tracks the model and the effort, through comprehension

Read. `runs/model-effort-2x2/` holds the same request at Sonnet and Opus, low
and high effort. The better runs say more true things because they read the
code better. Only Opus at high effort noticed that the function raises
`UnboundLocalError` when `attempts` is less than 1. No amount of rewriting
recovers a fact the writer never had.

## How the counts are made

`./measure.py docstring-1 docstring-2` prints the table below.

Every count is a string match rather than a parse, and every one is a lower
bound. Counts made by reading run higher, and both are right under their own
rule. The session record says the copy editor named the function nine times on
`docstring-1`, counting a whole file. The table below says five for the same
run, counting the writer's prose and leaving out the `Args`, `Returns` and
`Raises` template, which is the fixture's structure rather than anything the
writer chose. So compare an arm against another arm, and do not read anything
into an absolute number.


## docstring-1

| run | words | actor named | you | agentless passive |
| --- | ---: | ---: | ---: | ---: |
| arm1-r1 | 92 | 0 | 0 | 4 |
| arm1-r2 | 50 | 0 | 0 | 0 |
| arm1-r3 | 100 | 0 | 0 | 3 |
| arm2-r1 | 75 | 1 | 0 | 0 |
| arm2-r2 | 59 | 0 | 0 | 0 |
| arm2-r3 | 78 | 0 | 0 | 0 |
| arm3-r1 | 98 | 5 | 0 | 0 |
| arm3-r2 | 58 | 0 | 0 | 0 |
| arm3-r3 | 115 | 5 | 0 | 0 |
| arm4-r1 | 96 | 4 | 0 | 0 |
| arm4-r2 | 60 | 0 | 0 | 0 |
| arm4-r3 | 115 | 5 | 0 | 0 |
| arm5-r1 | 79 | 1 | 0 | 0 |
| arm5-r2 | 63 | 0 | 0 | 0 |
| arm5-r3 | 78 | 0 | 0 | 0 |
| arm6-r1 | 883 | 0 | 29 | 3 |
| arm6-r2 | 1185 | 0 | 33 | 4 |
| arm6-r3 | 746 | 1 | 11 | 5 |
| arm7-r1 | 92 | 0 | 0 | 4 |
| arm7-r2 | 50 | 0 | 0 | 0 |
| arm7-r3 | 100 | 0 | 0 | 3 |
| arm8-r1 | 97 | 0 | 0 | 3 |
| arm8-r2 | 68 | 0 | 0 | 0 |
| arm8-r3 | 105 | 0 | 0 | 5 |

## docstring-2

| run | words | actor named | you | agentless passive |
| --- | ---: | ---: | ---: | ---: |
| arm1-r1 | 218 | 0 | 0 | 7 |
| arm1-r2 | 225 | 0 | 1 | 8 |
| arm1-r3 | 214 | 0 | 0 | 6 |
| arm2-r1 | 190 | 0 | 2 | 5 |
| arm2-r2 | 162 | 0 | 3 | 0 |
| arm2-r3 | 212 | 1 | 3 | 5 |
| arm3-r1 | 292 | 9 | 3 | 0 |
| arm3-r2 | 271 | 0 | 6 | 0 |
| arm3-r3 | 223 | 5 | 1 | 0 |
| arm4-r1 | 292 | 9 | 3 | 0 |
| arm4-r2 | 274 | 0 | 6 | 0 |
| arm4-r3 | 222 | 5 | 1 | 0 |
| arm5-r1 | 195 | 0 | 2 | 4 |
| arm5-r2 | 163 | 0 | 3 | 0 |
| arm5-r3 | 211 | 3 | 5 | 1 |
| arm7-r1 | 380 | 0 | 5 | 11 |
| arm7-r2 | 352 | 0 | 8 | 8 |
| arm7-r3 | 359 | 1 | 10 | 5 |
| arm8-r1 | 233 | 0 | 0 | 8 |
| arm8-r2 | 234 | 0 | 1 | 7 |
| arm8-r3 | 221 | 0 | 0 | 7 |
| arm9-r1 | 243 | 0 | 1 | 0 |
| arm9-r2 | 336 | 0 | 1 | 0 |
| arm9-r3 | 243 | 0 | 0 | 1 |
| arm10-r1 | 263 | 0 | 0 | 7 |
| arm10-r2 | 375 | 1 | 1 | 7 |
| arm10-r3 | 287 | 0 | 0 | 7 |
