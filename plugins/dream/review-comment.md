# Review comment

Post a review's findings, and what you did about each one, as one pull request
comment. The reader uses it to see what the review raised and to judge each
decision you took.

## Start the comment when the review arrives

Write the comment into a temporary file outside the repo as soon as the review
arrives, before you weigh any finding or change any code. Put in the heading,
then each finding, copied across word for word, and leave the space under each
quote empty.

A review's words fade as you work. Starting the comment after the fixes are in
leaves you retelling each finding from memory, so the reader gets your words in
place of the review's.

If the review returned no findings, write the heading and one line saying so,
then post the file.

## Fill in each response

Write your response into the file under a finding's quote once you have acted on
that finding. The comment then reads:

```text
## {heading}

> {the finding, verbatim}

{your response}

> {the finding, verbatim}

{your response}

...and so on, one block per finding.
```

## Post the comment

Reread the file once every response is in. Replace any finding you have
summarised with the review's own words, so the reader can tell the review's
words from yours. Then post the file as a PR comment, with `--body-file`.
