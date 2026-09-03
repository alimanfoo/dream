# Judgements

`key.json` says which arm is A and which is B in each comparison. It is
written before any comparison is shown, and read only once the comparison it
covers has been judged.

Each comparison names a pair of arms, a replicate, and the question the pair
answers. Three replicates per pair, since a single one is noise. A pair's
three comparisons never run the same way round, so a habit of picking the
left-hand version cannot pass for a preference between arms. `draws` records
the seed behind each batch, so a draw can be repeated.

`answers.md` holds the answers, one entry per comparison. An entry says A or
B and never says which arm that was, so giving an answer gives nothing away
about the comparisons still to come.

`../judge.py` serves the next unjudged comparison at
`http://127.0.0.1:8765`, and appends the answer. `../judge.py --report`
resolves the letters against the key, for the comparisons that already have an
answer.

`blind-judges-1.md` and `claude-call-1.md` hold what four blind Opus judges
and I made of comparison 1, all written before the owner gave their answer.
They stand as the evidence that a model judge does not stand in for the owner
here.
