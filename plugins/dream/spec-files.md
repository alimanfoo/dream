# Spec files

A specification goes into the repo as a markdown file, on a pull request. The
user reads it there, and can comment on any line of it. A later session corrects
it with a commit, so the specifications stay consistent with each other as the
work goes on.

## Where the files go

Keep every specification for one piece of work in the same folder, so a reader
finds the whole record in one place.

Default to `specs/YYYY-MM-dd-slug/` under the repo root, where the date is the
day the folder was made and the slug is a short name for the work. For example,
`specs/2026-03-14-offline-export/`.

Look at the repo before you use that default. When it already keeps its
specifications somewhere else, follow what it does. Ask the user to confirm the
folder either way, and use the folder they name.

When the work already has a folder, write into that one rather than starting
another. The seed usually names it. Otherwise look for it under `specs/`, and
ask the user when you can't tell which folder is the right one.

Each skill names its own file, so the folder ends up holding one file per
specification.

## The pull request

Once the user has agreed to the file, open a pull request for it:

- Create a branch off the current branch, named after the folder's slug.
- Copy the draft into the folder, under that name.
- Commit it. Read the `commitTrailer` value from
  [`agent-written-marks.json`](agent-written-marks.json), and end the commit
  message with that exact value.
- Push the branch, then run `gh pr create`. Title the pull request after the
  work. Give the body a line saying which specification the file holds and where
  the work came from. Read the `commentFooter` value from the same file, and end
  the body with that exact value as a blockquote, so a reader can tell an agent
  wrote it.

Put each paragraph of the body on a single line, since GitHub reflows it.

## Correcting an earlier specification

Writing a later specification turns up detail that an earlier one got wrong or
left out. Correct the earlier file where it sits, and commit the correction on
this session's own pull request. The correction then gets reviewed alongside the
work that found it.

Say what you corrected in the pull request description, so the reviewer knows to
look at it.
