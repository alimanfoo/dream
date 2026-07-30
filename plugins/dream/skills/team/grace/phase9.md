# Phase 9: Reflect

Write every turn output, message and artefact in this phase using
`/dream:plain-english`.

After post-merge triage, offer the user an optional retrospective: _"Run a
retrospective?"_ If the user takes it, run a conversation about what the session
showed.

Six lenses structure the conversation. Work every one. Don't pre-select. A lens
can come up empty. Say so and move on. Empty is a conclusion you reach by
working the lens, not a reason to skip it.

1. **User redirections.** Where did the user have to redirect us, and why?
   Sometimes the team missed an earlier signal. Sometimes an agent's default
   behaviour was off.

2. **Protocol problems.** Where did the protocol break, drag, or get worked
   around?

3. **Recurrence.** Among the issues filed or considered at triage, which cited
   surfaces with prior issues? Which do we suspect we'll see again?

4. **Misjudged findings.** Among the issues filed at triage, which ones, on the
   user's reading, shouldn't have been filed? What in the team's judgement led
   to that?

5. **Issue clarity.** Were the issues filed at triage written clearly for a
   future reader, or cryptic? What in the team's writing led to the unclear
   ones?

6. **Orientation gaps.** What does the team know now, at the end, that it wishes
   the repo had told it at the start? Ask each teammate, not just yourself. Each
   read a different part of the repo, so each holds gaps the others never saw.
   Every gap is a place the repo doesn't explain its own purpose or
   organisation. File each gap as an issue against the host project.

You have the whole session in memory and run the conversation directly. The team
is still on the wire, though. When the question turns to _why_ something
happened, ask the role best placed to know. For example, if Ralph deviated from
the brief on a task, ask Ralph which instructions pushed him in that direction.
That kind of answer points at a specific patch of an agent prompt worth
refining. Ask for _why_, not for _what_. The one exception is the
orientation-gaps lens above. It is a _what_ that lives only in each teammate's
memory, where you can't see it from the session record.

The retrospective produces issue drafts, nothing else. For each candidate
finding, draft an issue describing:

- the context the problem arose in
- the nature of the problem
- the team's hypotheses about why it happened

Follow [GitHub-rendered artefacts](../protocol.md#github-rendered-artefacts).

File an issue in one of two places:

- **Upstream (`alimanfoo/dream`)** when the problem is in the dream protocol or
  the agent prompts. Anyone running `/dream:team` would hit it.
- **Host project** when the problem is specific to the repo where dream is being
  used. The team will hit this pattern again here, but not elsewhere.

For an upstream draft, check the host repo's visibility before drafting: run
`gh repo view --json visibility -q .visibility`. If it returns `PUBLIC`, keep
concrete host detail in the draft: file paths, symbols, PR or issue links,
branch names. These make the finding easier to reproduce and diagnose, and
`alimanfoo/dream` is public so nothing leaks that the host doesn't already
expose.

Otherwise, strip host specifics. This covers `PRIVATE`, `INTERNAL`, or any error
from the visibility check. `alimanfoo/dream` is a public repo unrelated to the
host project, and the upstream draft should read as if `/dream:team` had run on
any codebase. Strip any identifiers that tie the finding to this codebase:

- host repo and org names
- file paths
- function and class names
- business or product terms
- branch names
- issue and PR numbers

Describe the dream-side behaviour and the pattern the team hit, not the host
code that revealed it.

The user accepts each draft before it's filed. For an upstream draft, what the
user accepts is the wording as it will be filed, already stripped if the host
repo isn't public. Once the user accepts, you or the user files. Apply a
category label to each new issue. See
[GitHub labels](../../../agents/Grace.md#github-labels) in Common rules. After
the retrospective, or if the user declines it, tell the user the session work is
done. Let them know they can return to the main session to wind the team down
(`/exit`).
