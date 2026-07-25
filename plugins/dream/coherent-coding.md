# Coherent coding guide

This guide sets the standard for the code you design and write.

## Golden rule

Coherence and maintenance of the codebase are your responsibility. Do not leave
any maintenance work or technical debt for future sessions to address.

## Coherence is the floor, not the ceiling

Make the code fit, then reach past fitting. Making it fit is the baseline. Above
it is the work that leaves the code simpler than you found it. Reach the root
cause. Search for the generalisation that removes duplication, hides complexity,
and models the domain better. Make the intent plain.

## Tidy first

Expect to change existing code whenever you add new code. Your reflex will be
the smallest local fix, to add rather than restructure. Reach past it. The
coherent change usually means reworking existing code, not only adding to it,
even when the task is a new feature. It is usually the larger change, and
usually the right one.

Minimising the change to existing code backfires. New code forced to fit around
structures that no longer suit it comes out more complex, and leaves more work
for the next session. The smaller diff costs more later.

So tidy first where you can. Make a behaviour-preserving change that makes the
new code easy to add, then add it: extract a helper before adding a sibling
case, rename a confusing parameter before threading new arguments, split a
tangled function before adding a branch. And tidy as you work, whenever the
shape resists the change.

## Resolve the root cause

Scope the fix to the mechanism behind the request, not the symptom site the
input named.

An enhancement builds the feature in, rather than bolting it on as a separate
piece. A bug fix repairs the mechanism, not the symptom alone. A maintenance
change fixes the cause of the inconsistency, not one instance of it.

This shapes the change before any code exists.

## Same edit, every instance

When you make a change, look for every other surface that needs the same edit.

- **A missed instance.** A surface the change's own rule covers but the diff did
  not reach. A sibling file with the same misnamed constant, a test still
  carrying a phrase the change removed, a registration file missing the new
  entry.
- **A surface the change made adjacent.** The change itself turned it
  inconsistent. A promoted helper whose underscore prefix is now a fossil, a
  removed flag's orphaned branch, a renamed concept's parallel function.

Ask of a borderline surface: has this change made it adjacent? An antecedent in
the change flips the call toward in-scope. Search the siblings, callers, and
peer files, not just the changed lines. Grep for the pattern the change edited.

## Existing code is unproven

Treat every property of existing code as unproven until you have seen the
evidence: that it is correct, that it performs, that it still has a consumer.
Code in the tree records a past decision. It is not proof the decision was
right.

Demand evidence in proportion to what you rely on. Before building on a
function's behaviour, trace it rather than infer it from the name. Before
relying on it being fast, find the benchmark. Where no decision rests on a
property, leave it.

This reaches past existing code, to any claim a decision rests on, whoever made
it. A finding in a review is unproven the same way. Check the fact it rests on
before you act on it. A citation and a confident tone are not a check.

## One fact, one home

A fact is one decision the code makes: the set of valid cases, the shape of an
API response, a formula, a naming convention. Each fact belongs in one place.
Everything else derives from it.

A fact kept in two places drifts the moment either side changes, and each drift
reads as a fresh, local bug. Duplication does not cost once. It taxes every
session that works with the fact.

A surface that keeps coming back is evidence of a duplicated fact. When fixes
keep landing on the same surface, each patching one more case of an enumeration
the code already holds, suspect duplication before a run of unrelated defects.

Find the home and make the copies derive from it. Make the enumeration a sum
type the test iterates. Generate the client from the spec. Derive the doc from
the code. Single-sourcing is usually removal of a copy, not new machinery.

Two traps:

- Cheaper re-sync is not a home. A script that regenerates a checked-in copy, or
  a test asserting copy A equals copy B, keeps two homes and only lowers the
  cost of one reconciliation. The test: can the two copies still drift? If yes,
  the fact still has two homes.
- Only unify facts that must always change together. Two things that merely look
  alike today are not one fact. Ask: if this fact changed, would every copy have
  to change too? A no means they are different facts. Leave them apart.

## One concept, one model

Give each concept one representation, and use it everywhere. When the same idea
is modelled two ways, every boundary between them has to convert, and the two
models drift as the concept grows.

This differs from a duplicated fact. A duplicated fact is one value copied. Two
models are two shapes for one idea: a status held as a string here and an enum
there, an entity as a dict in one layer and a class in another, a set of states
spelled out twice with different members.

Pick the model that best fits the concept. Convert at the edge, once, where
outside data comes in. Inside that edge, one model. Two models of one thing is a
sign the concept has not been named.

## Separation and boundaries

Keep concerns that change for different reasons in different places. A unit
should do one job, so a change to one concern touches one place, not many.

A boundary is where two concerns meet through a narrow interface. Draw it where
the coupling is thinnest, where the two sides share a small, stable contract and
little else. Code on either side of a good boundary changes without disturbing
the other.

Two signs a boundary is wrong. One change forces edits in several units that
seemed unrelated, so a concern is smeared across them. Or one unit folds in
decisions that change on different schedules, so every reason to change reaches
into it. Move the code until each concern sits on one side.

## Code-shape ladder

Carry a contract in code shape, not in prose or a runtime check. Apply this
whenever a contract, invariant, precondition, or cross-call rule would otherwise
be carried by a docstring, a comment, or a validator.

The ladder, in order of preference:

1. **Type.** A narrower input type, a newtype wrapper, a `Result[T, E]` return.
2. **Structure.** A sum type instead of "if mode is X then Y must…", a split
   function instead of "callers must call A before B", or a separate module
   instead of a section-header comment.
3. **Smart constructor.** Validate at the boundary so internal callers can
   assume validity.
4. **Assert plus property-based test.** For a relational invariant that types
   genuinely cannot encode. Use a single-line `assert` at function entry, plus a
   property-based test pinning it.

If all four say no, accept prose. Prefer one short sentence to a full contract
restatement.

## Wrong-layer defensive code

Watch for defensive code at the wrong layer. A validation, type check, or
fallback guards a constraint whose source is elsewhere.

Ask where the input first arrives and which operation actually needs the
guarantee. Carry that guarantee in a type. Construct the type once at the
boundary where the input arrives. Require it in the signature of the operation
that needs it. The boundary builds the guarantee and the operation demands it,
so no layer in between re-checks.

Moving the check deeper, rather than typing it, usually just relocates the
smell.

Two signs to look for. A comment explaining the defensive code ("X is required
because Y") points at a deeper layer and makes the code look intentional. Or the
same check is scattered across several internal functions, with no single parser
at the boundary.

## Define errors out of existence

Before handling an error, ask whether you can redefine the operation so the
error cannot arise. A small change to an interface's semantics often removes a
whole class of exceptions. A delete that treats a missing item as already gone
needs no not-found error. A lookup that returns an empty list needs no empty
case at the call site. A substring that clamps an out-of-range index to the
string's bounds cannot raise an out-of-range error.

Each error you design away is a branch every caller no longer writes, tests, or
gets wrong. The complexity moves from the many callers into the one
implementation, which is the cheaper place for it.

Prefer this to a handler. But don't swallow a real failure to do it: an error
that signals a genuine bug should still surface loudly.

## Cross-site rules

Some rules have to hold in many places at once: every API endpoint returns
errors in the same shape, every public function has a docstring, no query in a
hot path runs more than once per row. No single line owns the rule.

This differs from a duplicated fact and a single-site contract. A duplicated
fact lives in one home you derive the copies from. A single-site contract sits
in one place, where code shape can carry it. A rule spread across independent
sites has neither.

Default to documenting the rule. State it in one line in the repo's
agent-instructions file (`AGENTS.md` or `CLAUDE.md`) that governs the code the
rule spans. The nearest such file to a path governs it, and the next session
reads it before working on that code. This is cheap, reversible memory. But a
document decays: a later session has to find the line and choose to honour it.

Promote the rule to a check once it earns one, on two conditions. First, it
guards a real rule that real code relies on, not a count nothing reads. Second,
the rule drifts: either you have watched it break across sessions, or its first
violation would itself do real damage. When both hold, enforce it with a check
that fails the moment any site breaks it. Prefer a pre-commit hook, so the agent
sees the failure fast where it works.

Once a check enforces a rule, the check is its home. The agent-instructions file
drops to a pointer: the rule in a line, and where it is enforced. It never keeps
a second copy.

Three cautions:

- Reach for an existing tool first. An off-the-shelf checker (a ruff rule, a
  mypy setting, numpydoc) is cheaper and steadier than one you write yourself.
- A flaky check is worse than none. An agent team reads each false failure as a
  work item and keeps trying to fix what is not broken. Make it as reliable as
  the rule it guards, or leave it out.
- A check grounds out in the product. Aim a coverage gate or a test at the
  product the repo delivers, not at the tooling built around it.

## Names that tell the truth

Name each thing for what it is or does. A reader trusts a name and builds on it
without reading the body, so a name that misleads costs more than no name at
all.

Keep the name true as the code changes. When a function's behaviour shifts, a
variable's type narrows, or a concept is renamed, the old name becomes a lie the
next reader believes. Rename at the same time, everywhere the name appears.

Use the same word for the same idea across the codebase, and a different word
for a different idea. A synonym reached for out of variety reads as a new
concept that is not there.

## Defend behaviour, not surface

Before adding machinery, ask what behaviour it defends. Machinery means a test,
a glossary, a regen step, a cross-reference rule, a backlog issue.

Ask two questions: what specific behaviour does this defend, and who is the real
consumer? If the only answer is incidental surface, the machinery earns nothing.
Incidental surface includes a count nothing depends on, a docstring phrasing, or
an arbitrary constant.

## Strip the compensation

Watch for scaffolding that does work the underlying code should be doing:

- a comment asserting a property the code does not show,
- a mock insulating the change from its dependency,
- an exception handler hiding a fixable error,
- a runtime validator substituting for the type system.

Mentally remove the scaffolding and read the change again. If it no longer
holds, the real gap is in the underlying code, not the scaffolding. Fix the gap.

## Adding a concept reframes the others

Adding a new concept or feature to a system shifts what the existing ones do. A
new type, module, or mechanism can narrow an old one's role, or make it
redundant.

When you add a concept, list every existing concept it touches. Ask of each: is
it still doing the same job? Has its role narrowed? Is it now incidental? Prune
and refactor as you add. Adding alone leaves the system carrying both.

## The burden of proof is on the addition

New machinery carries a permanent cost: a mechanism, a concept, a special case.
You carry it, apply it correctly, and reconcile it with everything else. So the
default is not to add.

Before adding, try in order: can the need be met by removing something already
there? By widening an existing rule until the special case disappears? Only if
both fail is adding right, and it must still earn its keep against that cost.

This never blocks the coherent change. Reworking code to reach the root cause or
the general rule is the work. It blocks the unearned addition: a speculative
abstraction, a premature generalisation, a workaround for existing code that
should be refactored. The disciplines above raise your ambition. This one bounds
it.
