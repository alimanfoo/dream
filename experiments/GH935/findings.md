# What this experiment has found

Read this after a comparison has been judged, not before. It says which arm
produced what, and a judge who knows that is no longer judging the prose.

Each finding says where it comes from. A judged one rests on the repository
owner's blind answers, which `./judge.py --tally` reports. A counted one can be
checked by running `./measure.py`, which reports the tables at the foot of this
file. A read one comes from someone's reading, and the runs behind it are still
here to be read again.

Every pair ran three replicates, so a 2-1 is one answer away from a 1-2 and
settles nothing. Only a 3-0 is worth leaning on, and the cycle below shows what
happens to anyone who forgets it.

## What the judging says

Judged. All forty-two comparisons, answered blind, one at a time, with the page
carrying two passages and one question that never changed. The last nine also
asked whether each version would be accepted as it stands.

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
| 1v9 | does the ladder, structure then voice, help or hurt? | arm1 3 |
| 3v9 | which reads better, the copy editor's repair or the ladder? | arm3 2, arm9 1 |
| 8v9 | what do the rewriting steps add to the moves? | arm8 3 |

| arm | would accept | would not |
| --- | ---: | ---: |
| arm1 | 3 | 0 |
| arm3 | 3 | 0 |
| arm8 | 3 | 0 |
| arm9 | 3 | 6 |

## The arm that leads every count is the only one anyone rejected

Judged, and it is the result the rest of this file now turns on.

Arm 9 loses 3-0 to arm 1, 3-0 to arm 8 and 1-2 to arm 3. It is also the only
arm anyone declined: it was sent back six times in nine, where arm 1, arm 3 and
arm 8 were accepted every time they appeared.

Preference alone would have called this a bad arm. Acceptance says something
worse and more useful, because acceptance is not relative. Arm 9 does not lose
to better prose. It produces prose a reader will not take.

The notes name the fault as odd writing and quote it. "Values that are not
dictionaries include lists." "A list in `base` therefore gives way whole to the
list in `overlay`." "Any other `Mapping` ... it treats as an opaque value and
replaces whole." Every sentence quoted comes from an arm 9 run and from no
other arm.

## The measure was too narrow, and the arm walked through the gap

Counted, after the judging corrected it.

This file used to say arm 9 was the first arm to clear the repeated subject
while holding agentless passives at nought. That was wrong, and wrong in a way
worth keeping on the record.

`measure.py` counted the phrase "the function". Arm 9 calls the thing "the
merge", so the column read nought while arm9-r2 opened five sentences with "The
merge" in a row: "The merge recurses", "The merge decides", "The merge treats",
"The merge modifies", "the merge never terminates". The drumbeat was never
cleared. It was renamed, under a noun the measure did not look for.

The measure now takes each sentence's opening subject and reports the most
repeated one, whatever word it is. On that column arm 9 is the worst arm in the
experiment rather than the best.

Three things follow. A measure that names the token it is looking for measures
the token. An arm optimised against such a measure will satisfy it and keep the
fault. And the only thing that caught it was a reader, which is the argument
for judging that the counts cannot make on their own.

## Every arm that rewrites sentences loses

Judged. Six pairs came out 3-0, and they are the only results three replicates
can carry. Every one of them says the same thing.

Arm 7 loses to arm 1 and to arm 8. Arm 10 loses to arm 1 and to arm 3. Arm 9
loses to arm 1 and to arm 8. Those three are the arms that rewrite: one through
a conversation, one from a story spine, one by applying voice and given-new
order to sentences it holds. Every arm that beat them either repairs a span at
a time or only moves text about.

Arm 7 gave itself away through the blinding: "B is obviously the conversation
arm and unfortunately really doesn't work for this, too conversational", and on
another replicate "A is more enjoyable to read, but too informal for code
documentation". So its register survives the round trip and is wrong for the
genre, which is a fact about the register rather than about the passage.

Arm 10 gave no such tell. It reads acceptably and lost six times out of six.

## Three replicates cannot separate arms that are close

Judged. The close pairs make a cycle. Arm 1 beats arm 3 by 2-1, arm 3 beats
arm 8 by 2-1, and arm 8 beats arm 1 by 2-1. No consistent ranking holds all
three, so at least one is noise, and nothing in the numbers says which.

Five pairs of the fourteen came out 2-1, and a 2-1 over three replicates is
what a coin does more than a third of the time. Any claim resting on one of
them is a claim about three passages rather than about an arm. The sweeps are
safe from this, and so are the pairs that drew.

## Copy-editing is neutral, which is not what it was suspected of

Judged. #935 asked whether `dream:copy-edit` improves prose or damages it. Over
three pairs it does neither.

On vanilla text the pair goes 2-1 to the version that was not copy-edited,
which is within noise. On text written from the guide, which is what
`dream:smith` does, two of three replicates drew and the third went to the
version that was not copy-edited. A second round drew all three, with the owner
writing "nearly identical" on each.

So the step is not doing the damage #935 suspected of it, and it is not paying
for itself either. A round is two model calls, one of them holding a large
prompt open for about two minutes, and it buys no preference a reader can
detect.

Arm 3 does beat both arm 9 and arm 10, and was accepted every time it was
offered. Copy-edited prose is not bad prose. It is prose nobody prefers to what
it started as.

## The owner does not prefer the copy-edited version

Judged. This replaces an earlier finding that rested on one comparison.

On comparison 1 the owner chose the copy-edited version, saying the vanilla one
had "a greyness, a quality of being flat that makes it very hard to engage
with", and that the copy-edited one "felt more like there was a person behind
it". That was the only comparison anyone had at the time, and it was read as a
preference for what copy-editing does.

Both other replicates of the pair went the other way. Arm 1 takes it 2-1, which
settles nothing either way, but it does settle that comparison 1 was not a
general preference.

The finding about model judges weakens with it. Three of four blind Opus judges
chose arm 1 on comparison 1, and so did my own recorded call, every one of them
reaching for compactness. That was read as a model judge failing to stand in
for the owner. Over the whole pair the owner chose arm 1 twice, which is the
side those models preferred. So one comparison in three is all the disagreement
there ever was, and whether a model judge can stand in for the owner is open
again. Polling the models on the other forty-one would answer it.

`judgements/blind-judges-1.md` and `judgements/claude-call-1.md` hold the
verdicts, both written before the owner gave theirs.

## Reading the guide first beats repairing afterwards

Counted, and judged thinly. arm2-r2 is the only run in the experiment with no
repeated subject, no agentless passive, and no contortion a reader objected to.
It came from reading the guide and then writing, not from any repair.

Arm 2 also takes its pair against arm 1 by 2-1, and copy-editing on top of it
adds nothing, since 2v5 drew twice and went to arm 2 once.

Two of three replicates is thin. What makes it worth following is that no
repair arm reached the same place: every arm that took agentless passives to
nought did it by putting one subject at the head of sentence after sentence,
except the ones that addressed the reader instead.

## Arm 8 reaches structure and cannot reach voice

Judged and counted. Arm 8 beats arm 1 by 2-1, sweeps arm 7 3-0, loses to arm 3
by 1-2, and was accepted every time it was offered. It is the best of the
candidates, though its only sweep is against the arm that lost to everything.

The notes split it cleanly. It won where the owner wrote about structure: "A
breaks up the information into pieces well", and "once I've got the idea, I
know I can safely skim the rest of the paragraph. Rather, if a paragraph might
contain 2 or more ideas, I don't know when I can skim." It lost where they
wrote about voice: "writing is better in A", and "B feels like it's speaking to
me".

That is the arm doing what it is. It moves text and never rewrites a sentence,
so it reaches structure and cannot reach voice, and it leaves the agentless
passives exactly where it found them, at seven or eight against arm 1's six to
eight.

Arm 9 is this arm plus the steps that do reach voice, and arm 9 loses to it
3-0. So on this evidence the rewriting steps take away more than they add.

## The reader names one mechanism, and it is not the one under suspicion

Judged. Across the notes, the property the owner names by itself is one idea to
a paragraph, and the reason given is skimming: knowing where an idea ends is
knowing where it is safe to stop reading. It is named for arm 8 twice and for
arm 3 once, so it travels with the passage rather than with the treatment.

It has a far end. Against arm 5 the note reads "nearly identical, but B seems a
little fragmented", so breaking a passage up stops paying at some point and the
same reader sees it.

Nothing in the notes praises what the copy editor does span by span, and
nothing praises an actor being named. The one note where voice decides a
comparison praises a passage for "speaking to me", quoting an imperative.

## The trade, and the two ways out of it

Counted. Across the arms, agentless passives and a repeated subject trade
against each other. Arm 1 and arm 8 have no repeated subject and six to eight
agentless passives. Arm 3, arm 4 and arm 9 have nought or one agentless passive
and a subject repeated three to five times.

Two runs get out of the trade. arm2-r2 has neither, and uses "you" three times
without ever opening a sentence with it. arm5-r2 has neither, and opens two
sentences with "you", so its repeated subject is the reader rather than the
function.

The count understates the second way out. On comparison 15 the owner chose a
version because "it's speaking to me", quoting "Treat the result as read-only"
as advice. That is an imperative, which addresses the reader without the word
"you", and the run it came from counts one "you" in the whole passage. So a
prompt asking for the second person should be judged rather than counted.

## A second copy-edit round changes nothing

Counted and judged. Arm 4 is arm 3 with one more round. Their prose comes to
292, 274 and 222 words against arm 3's 292, 271 and 223, with the same repeated
subject and the same count in every replicate.

The second editor has little to report, because the first round already
satisfied the rules it checks. Its findings run 1116, 588 and 1106 bytes
against the first round's 2563, 1562 and 1528.

All three comparisons drew, and the owner wrote "nearly identical" on each
without being told the two were a round apart.

## The conversation round-trip makes prose longer and more personal

Counted. Arm 7 comes to 380, 352 and 359 words against arm 1's 218, 225 and
214, so passing a passage through a conversation and setting it out again adds
about two thirds again. It uses "you" five, eight and ten times, and keeps the
passives, at eleven, eight and five.

Judged, it loses 3-0 to arm 1 and 3-0 to arm 8. The extra length does not earn
its place, and the register is wrong for the genre.

## Quality tracks the model and the effort, through comprehension

Read. `runs/model-effort-2x2/` holds the same request at Sonnet and Opus, low
and high effort. The better runs say more true things because they read the
code better. Only Opus at high effort noticed that the function raises
`UnboundLocalError` when `attempts` is less than 1. No amount of rewriting
recovers a fact the writer never had.

## How the counts are made

`./measure.py docstring-1 docstring-2` prints the tables below.

Every count is a string match rather than a parse, and every one is a lower
bound. The repeated-subject column takes the first word of each sentence that
could be a subject, skipping determiners and the words that can stand in front
of one, and reports the most frequent. It will miss a subject named two ways
and count two subjects that share a word.

The "you" column is the weakest, since an imperative addresses the reader and
contains no pronoun to match.

The passive column knows a list of irregular participles and no more.

None of these is a reason to distrust a difference between two arms. All of
them are a reason to distrust an absolute number, and the section above on the
measure being too narrow is what happens when that reason is ignored.


## docstring-1

| run | words | repeated subject | you | agentless passive |
| --- | ---: | :--- | ---: | ---: |
| arm1-r1 | 92 | - | 0 | 4 |
| arm1-r2 | 50 | - | 0 | 0 |
| arm1-r3 | 100 | - | 0 | 3 |
| arm2-r1 | 75 | 2 × "it" | 0 | 0 |
| arm2-r2 | 59 | - | 0 | 0 |
| arm2-r3 | 78 | - | 0 | 0 |
| arm3-r1 | 98 | 2 × "function" | 0 | 0 |
| arm3-r2 | 58 | - | 0 | 0 |
| arm3-r3 | 115 | - | 0 | 0 |
| arm4-r1 | 96 | 2 × "function" | 0 | 0 |
| arm4-r2 | 60 | - | 0 | 0 |
| arm4-r3 | 115 | - | 0 | 0 |
| arm5-r1 | 79 | 3 × "it" | 0 | 0 |
| arm5-r2 | 63 | - | 0 | 0 |
| arm5-r3 | 78 | - | 0 | 0 |
| arm6-r1 | 883 | 4 × "you" | 29 | 3 |
| arm6-r2 | 1185 | 4 × "two" | 33 | 4 |
| arm6-r3 | 746 | 4 × "that'" | 11 | 5 |
| arm7-r1 | 92 | - | 0 | 4 |
| arm7-r2 | 50 | - | 0 | 0 |
| arm7-r3 | 100 | - | 0 | 3 |
| arm8-r1 | 97 | - | 0 | 3 |
| arm8-r2 | 68 | - | 0 | 0 |
| arm8-r3 | 105 | 2 × "call" | 0 | 5 |

## docstring-2

| run | words | repeated subject | you | agentless passive |
| --- | ---: | :--- | ---: | ---: |
| arm1-r1 | 218 | - | 0 | 7 |
| arm1-r2 | 225 | - | 1 | 8 |
| arm1-r3 | 214 | - | 0 | 6 |
| arm2-r1 | 190 | - | 2 | 5 |
| arm2-r2 | 162 | - | 3 | 0 |
| arm2-r3 | 212 | 2 × "base" | 3 | 5 |
| arm3-r1 | 292 | 4 × "function" | 3 | 0 |
| arm3-r2 | 271 | 4 × "it" | 6 | 0 |
| arm3-r3 | 223 | 3 × "function" | 1 | 0 |
| arm4-r1 | 292 | 4 × "function" | 3 | 0 |
| arm4-r2 | 274 | 4 × "it" | 6 | 0 |
| arm4-r3 | 222 | 3 × "function" | 1 | 0 |
| arm5-r1 | 195 | - | 2 | 4 |
| arm5-r2 | 163 | 2 × "you" | 3 | 0 |
| arm5-r3 | 211 | 3 × "it" | 5 | 1 |
| arm7-r1 | 380 | 2 × "there'" | 5 | 11 |
| arm7-r2 | 352 | 3 × "you" | 8 | 8 |
| arm7-r3 | 359 | - | 10 | 5 |
| arm8-r1 | 233 | - | 0 | 8 |
| arm8-r2 | 234 | - | 1 | 7 |
| arm8-r3 | 221 | 2 × "recursion" | 0 | 7 |
| arm9-r1 | 243 | 5 × "merge" | 1 | 0 |
| arm9-r2 | 336 | 5 × "merge" | 1 | 0 |
| arm9-r3 | 243 | 2 × "overlay" | 0 | 1 |
| arm10-r1 | 250 | 2 × "key" | 0 | 5 |
| arm10-r2 | 293 | 2 × "merge" | 1 | 8 |
| arm10-r3 | 266 | 2 × "two" | 0 | 7 |
