# Review comment

Post a review's findings, and what you did about each one, as one pull request
comment. The reader uses it to see what the review raised and to judge each
decision you took.

## Start the comment when the review arrives

Write the comment into a temporary file outside the repo as soon as the review
arrives, before you weigh any finding or change any code. Put in the heading,
then each finding, copied across word for word, and leave the space under each
quote empty. Name the file after the comment's heading, so one review's file
never overwrites another's.

If the review returned no findings, the comment is the heading and one line
saying so.

## Fill in each response

Write your response into the file under a finding's quote once you have decided
what to do about that finding. The comment then reads:

```text
## {heading}

> {the finding, verbatim}

{your response}

> {the finding, verbatim}

{your response}

...and so on, one block per finding.
```

## Post the comment

After all findings are addressed and responses written to the comment file, post
the file as a PR comment.
