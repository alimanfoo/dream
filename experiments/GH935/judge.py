#!/usr/bin/env python3
"""Show one comparison at a time, and record which version the reader chose.

    ./judge.py [fixture]   serve the next unjudged comparison
    ./judge.py --progress  say how many are answered and how many are left
    ./judge.py --tally     say what each pair came to, and what was acceptable
    ./judge.py --report    say which arm won each comparison already judged

The page names the two versions A and B and says nothing else about them, and
nothing about which comparison it is. The question a pair answers would say
what was done to one of the two versions, and the position in the sequence
would say which pair this is, so the page carries neither and asks the same
question every time. The key stays on disk and the reader never sees it, so a
preference for an arm cannot follow from knowing which arm it is.

The record this writes says A or B and never an arm, so writing an answer
gives nothing away about the comparisons still to come. `--report` resolves
the letters, and resolves only the comparisons that already have an answer,
so the tool cannot leak an assignment that is still doing its job.
"""
import html
import http.server
import json
import pathlib
import re
import sys
import urllib.parse
from datetime import datetime, timezone

HERE = pathlib.Path(__file__).parent
JUDGEMENTS = HERE / "judgements"
PORT = 8765
KEY = ANSWERS = None   # set by use(), below
HEADING = re.compile(r"^## comparison (\d+)\b", re.M)

PAGE = """<!doctype html>
<meta charset="utf-8">
<title>{title}</title>
<style>
  body {{ font: 16px/1.6 Georgia, serif; max-width: 60rem; margin: 2rem auto;
         padding: 0 1.5rem; color: #1a1a1a; background: #fdfdfc; }}
  h1 {{ font-size: 1.1rem; font-weight: normal; color: #666; margin-bottom: 0; }}
  h2 {{ font-size: 1.3rem; margin: 0 0 1.5rem; }}
  .pair {{ display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; }}
  .version {{ border: 1px solid #ddd; padding: 1.25rem 1.5rem; background: #fff; }}
  .version h3 {{ margin-top: 0; font-size: .8rem; letter-spacing: .1em;
                text-transform: uppercase; color: #888; }}
  pre {{ font: 14px/1.5 ui-monospace, monospace; white-space: pre-wrap; }}
  form {{ margin-top: 2rem; }}
  textarea {{ width: 100%; font: inherit; padding: .6rem; border: 1px solid #ccc; }}
  button {{ font: inherit; padding: .6rem 1.6rem; margin-right: .75rem;
           cursor: pointer; border: 1px solid #444; background: #fff; }}
  fieldset {{ border: 1px solid #ddd; margin: 0 0 1.25rem; padding: .75rem 1rem; }}
  legend {{ color: #666; padding: 0 .4rem; }}
  fieldset label {{ margin-right: 1.5rem; }}
  button:hover {{ background: #f0f0ee; }}
  .done {{ color: #666; }}
  @media (max-width: 60rem) {{ .pair {{ grid-template-columns: 1fr; }} }}
</style>
{body}
"""


def use(fixture=None):
    """Point at one fixture's key and answers.

    With no fixture named, take the one that still has comparisons without an
    answer, so the common case needs no argument and an ambiguous one says so
    rather than guessing.
    """
    global KEY, ANSWERS
    available = sorted(d.name for d in JUDGEMENTS.iterdir()
                       if (d / "key.json").exists())
    if fixture is None:
        unfinished = []
        for name in available:
            KEY = JUDGEMENTS / name / "key.json"
            ANSWERS = JUDGEMENTS / name / "answers.md"
            if len(judged()) < len(load_key()["comparisons"]):
                unfinished.append(name)
        if len(unfinished) != 1:
            sys.exit(f"name a fixture: {', '.join(available)}"
                     + (f" (unanswered: {', '.join(unfinished)})" if unfinished
                        else " (all answered)"))
        fixture = unfinished[0]
    if fixture not in available:
        sys.exit(f"no key for {fixture}: {', '.join(available)}")
    KEY = JUDGEMENTS / fixture / "key.json"
    ANSWERS = JUDGEMENTS / fixture / "answers.md"
    return fixture


def load_key():
    return json.loads(KEY.read_text())


def judged():
    """The ids that already have an answer."""
    if not ANSWERS.exists():
        return set()
    return {int(n) for n in HEADING.findall(ANSWERS.read_text())}


def text_of(fixture, arm, replicate):
    path = HERE / "runs" / fixture / f"{arm}-r{replicate}" / "output.md"
    return path.read_text()


def render(text):
    """Show prose as prose, and leave a code block as it was written."""
    out, block = [], []
    fenced = False
    for line in text.splitlines():
        if line.strip().startswith("```"):
            if fenced:
                out.append("<pre>%s</pre>" % html.escape("\n".join(block)))
                block = []
            fenced = not fenced
        elif fenced:
            block.append(line)
        else:
            out.append(line)
    if block:
        out.append("<pre>%s</pre>" % html.escape("\n".join(block)))
    body, paragraph = [], []
    for chunk in out:
        if chunk.startswith("<pre>"):
            body.append(chunk)
        elif chunk.strip():
            paragraph.append(html.escape(chunk.strip()))
        elif paragraph:
            body.append("<p>%s</p>" % " ".join(paragraph))
            paragraph = []
    if paragraph:
        body.append("<p>%s</p>" % " ".join(paragraph))
    return "\n".join(body)


def next_page(key):
    done = judged()
    todo = [c for c in key["comparisons"] if c["id"] not in done]
    if not todo:
        return PAGE.format(
            title="All judged",
            body='<h2 class="done">Every comparison has an answer. '
            "Run <code>./judge.py --report</code> to see which arm won each "
            "one.</h2>",
        )
    c = todo[0]
    fixture = key["fixture"]
    versions = "".join(
        '<div class="version"><h3>Version %s</h3>%s</div>'
        % (letter, render(text_of(fixture, c[letter], c["replicate"])))
        for letter in ("A", "B")
    )
    body = """
<h2>Which of these reads better?</h2>
<div class="pair">{versions}</div>
<form method="post" action="/vote">
  <input type="hidden" name="id" value="{id}">
  <fieldset>
    <legend>Would you accept each of these as it stands?</legend>
    <label>A: <input type="radio" name="accept_A" value="yes"> yes
              <input type="radio" name="accept_A" value="no"> no</label>
    <label>B: <input type="radio" name="accept_B" value="yes"> yes
              <input type="radio" name="accept_B" value="no"> no</label>
  </fieldset>
  <p><label>Why, in your own words (optional)<br>
     <textarea name="notes" rows="4"></textarea></label></p>
  <button name="choice" value="A">A is better</button>
  <button name="choice" value="B">B is better</button>
  <button name="choice" value="neither">No preference</button>
</form>
""".format(id=c["id"], versions=versions)
    return PAGE.format(title="Judging", body=body)


def record(comparison_id, choice, notes, accepted):
    """Append the answer. The letter goes in and the arm stays out.

    A preference and an acceptance are different questions, and one does not
    give the other. A reader can prefer one of two passages and still send
    both back, which is worth knowing about an arm that keeps winning.
    """
    when = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    entry = [
        "\n## comparison %d\n\n" % comparison_id,
        "Chose %s. %s\n" % (choice, when),
    ]
    said = [
        "Would %saccept %s." % ("" if accepted[letter] == "yes" else "not ", letter)
        for letter in ("A", "B")
        if accepted.get(letter)
    ]
    if said:
        entry.append("\n" + " ".join(said) + "\n")
    if notes.strip():
        entry.append("\n" + "\n".join("> " + l for l in notes.strip().splitlines()) + "\n")
    with ANSWERS.open("a") as f:
        f.write("".join(entry))


class Handler(http.server.BaseHTTPRequestHandler):
    def reply(self, status, body="", headers=()):
        self.send_response(status)
        for name, value in headers:
            self.send_header(name, value)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self):
        self.reply(200, next_page(load_key()))

    def do_POST(self):
        size = int(self.headers.get("Content-Length", 0))
        form = urllib.parse.parse_qs(self.rfile.read(size).decode())
        record(
            int(form["id"][0]),
            form["choice"][0],
            form.get("notes", [""])[0],
            {letter: (form.get("accept_" + letter) or [None])[0] for letter in "AB"},
        )
        self.reply(303, headers=[("Location", "/")])

    def log_message(self, *args):
        pass


def progress():
    """How far through, without saying anything about any comparison."""
    key, done = load_key(), judged()
    total = len(key["comparisons"])
    print(f"{len(done)} of {total} answered, {total - len(done)} to go")


def acceptance():
    """How often each arm would have been accepted as it stands.

    A preference is relative and always names a winner. An acceptance is not,
    so an arm can win a pair and still be prose the reader would send back.
    """
    key = load_key()
    by_id = {c["id"]: c for c in key["comparisons"]}
    blocks = re.split(r"^## comparison (\d+)\s*$", ANSWERS.read_text(), flags=re.M)[1:]
    counts = {}
    for cid, body in zip(blocks[::2], blocks[1::2]):
        for negated, letter in re.findall(r"Would (not )?accept ([AB])\.", body):
            arm = by_id[int(cid)][letter]
            yes, no = counts.get(arm, (0, 0))
            counts[arm] = (yes + (not negated), no + bool(negated))
    if not counts:
        return
    print("\n| arm | would accept | would not |")
    print("| --- | ---: | ---: |")
    for arm in sorted(counts, key=lambda a: int(a[3:])):
        yes, no = counts[arm]
        print(f"| {arm} | {yes} | {no} |")


def tally():
    """What each pair came to, once its comparisons have answers."""
    key = load_key()
    answers = dict(
        re.findall(r"^## comparison (\d+)\n\nChose (\w+)\.", ANSWERS.read_text(), re.M)
    )
    seen = []
    for c in key["comparisons"]:
        if c["pair"] not in seen:
            seen.append(c["pair"])
    print("| pair | question | result |")
    print("| --- | --- | --- |")
    for pair in seen:
        group = [c for c in key["comparisons"] if c["pair"] == pair]
        wins, undecided, unanswered = {}, 0, 0
        for c in group:
            choice = answers.get(str(c["id"]))
            if choice is None:
                unanswered += 1
            elif choice in ("A", "B"):
                wins[c[choice]] = wins.get(c[choice], 0) + 1
            else:
                undecided += 1
        parts = [f"{arm} {n}" for arm, n in
                 sorted(wins.items(), key=lambda kv: (-kv[1], kv[0]))]
        if undecided:
            parts.append(f"no preference {undecided}")
        if unanswered:
            parts.append(f"unanswered {unanswered}")
        print(f"| {pair} | {group[0]['question']} | {', '.join(parts)} |")
    acceptance()


def report():
    key, done = load_key(), judged()
    if not done:
        sys.exit("no answers yet")
    answers = dict(
        re.findall(r"^## comparison (\d+)\n\nChose (\w+)\.", ANSWERS.read_text(), re.M)
    )
    for c in key["comparisons"]:
        choice = answers.get(str(c["id"]))
        if choice:
            won = c.get(choice, choice)
            print(f"comparison {c['id']} ({c['pair']}, replicate {c['replicate']}): "
                  f"chose {choice} = {won}")


if __name__ == "__main__":
    named = [a for a in sys.argv[1:] if not a.startswith("-")]
    fixture = use(named[0] if named else None)
    if "--report" in sys.argv:
        report()
    elif "--progress" in sys.argv:
        progress()
    elif "--tally" in sys.argv:
        tally()
    else:
        print(f"judging {fixture} at http://127.0.0.1:{PORT}")
        http.server.HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
