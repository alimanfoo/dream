# What this experiment has found

Read this after a comparison has been judged, not before. It says which arm
produced what, and a judge who knows that is no longer judging the prose.

Each finding says where it comes from. A judged one rests on the repository
owner's blind answers, which `./judge.py --tally` reports. A counted one can be
checked by running `./measure.py`, which reports the table at the foot of this
file. A read one comes from the session record and from someone's reading, and
the runs behind it are still here to be read again.

Every pair below ran three replicates, so a 2-1 is one answer away from a 1-2
and settles nothing. Only a 3-0 is worth leaning on, and the cycle two sections
down shows what happens to anyone who forgets it.

## What the judging says

Judged. All thirty-three comparisons, answered blind, one at a time, with the
page carrying two passages and one question that never changed.

| pair | question | result |
| --- | --- | --- |
| 1v3 | does copy-editing help or hurt? | arm1 2, arm3 1 |
| 3v4 | does a second copy-edit round help or hurt? | no preference 3 |
| 1v2 | does reading the guide before writing help or hurt? | arm2 2, arm1 1 |
| 2v5 | does copy-editing help or hurt text written from the guide? | arm2 1, no preference 2 |
| 3v8 | which repair reads better? | arm3 2, arm8 1 |
| 1v8 | does working down from paragraphs to clauses help or hurt? | arm8 2, arm1 1 |
| 1v7 | does a pass through a conversation help or hurt? | arm1 3 |
| 7v8 | which candidate reads better? | arm8 3 |
| 1v10 | does rebuilding the passage from its story help or hurt? | arm1 3 |
| 3v10 | which reads better? | arm3 3 |
| 9v10 | which candidate reads better? | arm10 1, arm9 1, no preference 1 |

## The four sweeps all say the same thing

Judged. Four pairs came out 3-0, and they are the only results here that three
replicates can carry.

Arm 7 loses to arm 1 and to arm 8. Arm 10 loses to arm 1 and to arm 3. Those
are the two arms that throw the sentences away and write the passage again,
one through a conversation and one from a story spine. Every arm that beat them
either repairs what it was given or only moves it.

The owner named arm 7 through the blinding: "B is obviously the conversation
arm and unfortunately really doesn't work for this, too conversational", and on
another replicate, "A is more enjoyable to read, but too informal for code
documentation". So the conversation register survives the round trip and is
wrong for the genre, which is a fact about the register rather than about the
passage.

Arm 10 loses without any such tell. It reads acceptably and still lost six
times out of six.

## Three replicates cannot separate arms that are close

Judged. The close pairs make a cycle. Arm 1 beats arm 3 by 2-1, arm 3 beats
arm 8 by 2-1, and arm 8 beats arm 1 by 2-1. All three cannot be true of a
consistent ranking, so at least one is noise, and nothing in the numbers says
which.

That is the sharpest thing this round produced. Four pairs of the eleven came
out 2-1, and a 2-1 over three replicates is what a coin does more than a third
of the time. Any claim resting on one of them is a claim about three passages,
not about an arm.

The four sweeps are safe from this, and so are the pairs that came out with no
preference at all.

## Copy-editing trades agentless prose for a named actor

Counted. On `docstring-2`, arm 1 writes six to eight agentless passives per
replicate and names the function nought times. One copy-edit round takes the
passives to nought and names the function nine, nought and five times. The
same trade happens on `docstring-1`.

The trade is what correctly applying "Use active voice" one span at a time
does. Each span, on its own, reads better with an actor in front of it. The
paragraph they add up to says "the function" at the head of almost every
sentence, which no single finding asked for.

## The owner does not prefer the copy-edited version

Judged. This replaces an earlier finding that rested on one comparison.

On comparison 1 the owner chose the copy-edited version, saying the vanilla one
had "a greyness, a quality of being flat that makes it very hard to engage
with", and that the copy-edited one "felt more like there was a person behind
it". That was the only comparison anyone had at the time, and it was read as
the owner preferring what copy-editing does.

Both other replicates of the pair went the other way. Arm 1 takes it 2-1, which
by the section above settles nothing either way, but it does settle that
comparison 1 was not a general preference.

The finding about model judges weakens with it. Three of four blind Opus judges
chose arm 1 on comparison 1, and so did my own recorded call, every one of them
reaching for compactness: "packs the same content into far less space",
"tighter prose", "less friction". That was read as a model judge failing to
stand in for the owner. Over the whole pair the owner chose arm 1 twice, which
is the side those models preferred. So one comparison in three is all the
disagreement there ever was, and whether a model judge can stand in for the
owner is open again. Polling the models on the other thirty-two would answer
it, and nothing else will.

`judgements/blind-judges-1.md` and `judgements/claude-call-1.md` hold the
verdicts, both written before the owner gave theirs.

## Copy-editing is neutral here, which is not what it was suspected of

Judged. #935 asked whether `dream:copy-edit` improves prose or damages it. Over
three pairs it does neither.

On vanilla text the pair goes 2-1 to the version that was not copy-edited,
which is within noise. On text written from the guide, which is what
`dream:smith` does, two of three replicates drew and the third went to the
version that was not copy-edited. A second round drew all three, with the owner
writing "nearly identical" on each.

So the step is not doing the damage #935 suspected of it. It is also not paying
for itself. A round is two model calls, one of them holding a large prompt open
for about two minutes, and it buys no preference a reader can detect.

Arm 3 does beat both rewriting candidates, 3-0 against arm 10 and 2-1 against
arm 8, so copy-edited prose is not bad prose. It is prose nobody prefers to
what it started as.

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
against the first round's 2563, 1562 and 1528.

Judged, and the reader agrees. All three replicates drew, and the owner wrote
"nearly identical" on each of them without being told the two were a round
apart.

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

It names the function nought, once and nought times, so it does not make the
drumbeat. It leaves the agentless passives at five, eight and seven, against
arm 1's seven, eight and six, so it does not repair voice either. It runs a
little longer, at 250, 293 and 266 words against 218, 225 and 214.

So arm 10 moves what these counts do not measure. What it moves, the owner did
not want. Judged, it lost 3-0 to arm 1 and 3-0 to arm 3, and split its pair
with arm 9 one each and a draw. Six comparisons against a baseline, six losses,
with no note saying why: unlike arm 7 it gives no tell, it simply never won.

It does not copy its input, which is the failure arm 7 hit, but it sits closer
to it than it did. The prompt used to open by telling the writer not to edit or
improve the existing sentences, which the rest of the prompt looked like it
already covered. Dropping that line raised the similarity to the input in all
three replicates, from 0.54, 0.35 and 0.33 to 0.61, 0.49 and 0.34, and the
longest shared run from thirteen, six and four words to fourteen, fourteen and
six. The replicates are paired, since each rewrites the same arm 1 text before
and after, so three moving the same way says more than three independent runs
would. It is still thin. The earlier runs are in the history at 90d3a44.

## Working down from paragraphs to clauses leaves the voice alone

Counted and read. Arm 8 moves text and does not rewrite it. It names the
function nought times and leaves the passives where it found them, seven or
eight per replicate against arm 1's six to eight. On `docstring-1` it made
real repairs, including splitting a `TypeError` out of an `Exception:` entry
that was hiding it.

So arm 8 costs nothing in voice. Judged, it is the best of the candidates: it
beats arm 1 by 2-1 and sweeps arm 7 3-0, and loses to arm 3 by 1-2. Both close
results are within noise, and the sweep is not. The arm that only moves text
outlasted both arms that rewrite it.

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

The count understates it. On comparison 15 the owner chose a version because
"it's speaking to me", quoting "Treat the result as read-only" as advice. That
is an imperative, which addresses the reader without the word "you", and the
run it came from counts one "you" in the whole passage. So the escape is wider
than the column measuring it, and a prompt asking for the second person should
be judged rather than counted.

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
rule. The "you" column is the weakest of them, since an imperative addresses
the reader and contains no pronoun to match. The session record says the copy editor named the function nine times on
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
| arm10-r1 | 250 | 0 | 0 | 5 |
| arm10-r2 | 293 | 1 | 1 | 8 |
| arm10-r3 | 266 | 0 | 0 | 7 |
