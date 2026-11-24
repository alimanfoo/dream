# Text for GitHub

When GitHub will render what you write, put each paragraph on a single line.
That covers pull request descriptions, issue descriptions, and comments. GitHub
reflows a paragraph to fit the reader's window, so one you have wrapped by hand
arrives as short, uneven lines.

Leave the newlines inside fenced code blocks and between table rows alone. Those
are structural, and GitHub keeps them.

Pass a multi-line body through a file (`--body-file`) or a quoted heredoc, not
as `\n` escapes inside a quoted string, so GitHub receives real newlines.

Start every line of a blockquote with `>`, blank lines included. GitHub ends a
quote at the first line without one, so the rest would read as your own words.
