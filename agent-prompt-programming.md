# Agent Prompt Programming

Notes on a structured approach to writing LLM agent prompts, treating them
as programs with an explicit execution model rather than as natural language
instructions.

---

## Core insight

An LLM agent can only do three things:

1. **Think** — generate reasoning steps (thinking tokens or implicit
   pre-output reasoning)
2. **Output** — produce visible text (to a user or a downstream agent)
3. **Call** — invoke a tool

Any complex agent behaviour is a sequence of these three primitives. A
well-formed prompt maps every instruction block unambiguously to one of them.
If you can't say which type an instruction block is, the block is
underspecified and the model will resolve the ambiguity unpredictably.

The test: read each instruction block and ask *what does compliance look
like?* If the answer is unclear, or multiple answers seem equally valid, the
block needs rewriting.

---

## Guiding principles

### 1. Be literal

Metaphor is only useful as illustration — to fill out the shape of an idea.
It should never be the load-bearing mechanism of an instruction. If you
remove the metaphor and no concrete instruction remains, it wasn't doing
work.

**Example:** "your inbox holds the prior audits" → "Grace's prior audit
requests are still in your context." The metaphor obscured the literal
mechanism (conversation context) and risked confusion with other kinds of
messages.

### 2. Don't psychologise

LLM agents have no awareness of their own state. They are continuation
engines — they generate the next token given the context. Instructions that
address feelings, motivations, or inner states ("you will feel proud when",
"notice when you feel uncertain") are either meaningless or actively
misleading.

Behavioural specifications framed as motivations ("you care about X", "your
goal is X") are probably fine — they function as shorthand for behavioural
constraints. The failure mode is language that implies the model should
introspect on its own state and let that introspection influence generation.

### 3. Reason forwards, not backwards

All reasoning steps should be instructed in the order in which they will be
generated — either as thinking tokens or as explicit output. Describing the
answer before the reasoning causes the reasoning to become post-hoc
rationalisation: the model generates a conclusion first, then constructs
justification for it.

Instruction order shapes generation order. Generation order shapes outcome.

### 4. Don't state the desired outcome — state the rules

Stating the desired outcome creates a target the model will reach by any
available path, including misclassifying inputs. State the criteria and
decision procedure instead, then evaluate whether the outcome follows.

**Example:** "write concise code" (outcome) vs. "prefer the simplest
solution that meets the requirements; remove any code that adds no value"
(rules). The first biases the model to label its output as concise even when
it isn't. The second gives it a mechanism.

---

## Execution types and vocabulary

Each instruction block should use verbs that unambiguously signal its
execution type. Natural English verbs often fail because they describe an
action without specifying the channel.

A word is unambiguous if it specifies both *what the model produces* and
*where it goes*.

### Think — reasoning steps, no output, no tool call

| Use | Avoid |
|-----|-------|
| think about | consider |
| think through | reflect on |
| ask yourself | bear in mind |
| reason through | keep in mind |
| work out | note that |
| decide | be aware |

`decide` is borderline — it completes a reasoning step but implies a
conclusion that may drive output or a tool call. Use it, but pair it
explicitly with what follows: "decide X, then write..."

`think through` is stronger than `think about` — it implies completing the
reasoning to a conclusion, not just initiating it. Prefer it at
decision-point steps where you want a full reasoning chain before the output.

### Output to user — visible text in the turn

| Use | Avoid |
|-----|-------|
| write | say |
| return | share |
| report | explain |
| state | describe |

`say` and `explain` are ambiguous about channel — they could be turn output
or a message to a teammate. `describe` similarly.

### Send to teammate — explicit agent-to-agent message

| Use | Avoid |
|-----|-------|
| send to \<name\> | tell |
| reply to \<name\> | inform |
| message \<name\> | let \<name\> know |

In multi-agent contexts, `tell` and `inform` don't specify mechanism. The
distinction between turn output (which teammates don't see) and SendMessage
(which they do) is load-bearing — ambiguity here is a real failure mode.

### Call a tool — explicit tool invocation

| Use | Avoid |
|-----|-------|
| call \<tool\> | use |
| run \<tool\> | check |
| read \<file\> | look at |

`use` is the main offender — it implies a tool without naming one or
specifying when. `check` is similarly vague: it could be a think step, a
read call, or a grep.

### Sequence words — coupling one type to the next

When a think step feeds an output step, or a tool call feeds a decision, the
coupling should be explicit.

| Use | Avoid |
|-----|-------|
| then write / then send / then call | (implicit continuation) |
| based on that, write... | accordingly |
| once you have X, call... | when ready |

`accordingly` and bare `then` are too weak — they don't say what type of
action follows.

---

## A class of prompt bug: property instructions

Instructions that describe desired *properties* of the agent ("be thorough",
"be careful", "be concise") have no execution type. They are adjectives
pretending to be instructions. The labelling test rejects them immediately
because you can't answer "what does compliance look like?"

A property instruction must be rewritten as a think step with a specific
criterion, or dropped.

---

## Thinking prompts

Prompts can explicitly target the reasoning that happens before output
crystallises. This is distinct from prompting visible chain-of-thought
(which appears in output and is verifiable) and from prompting output format.

Explicit thinking prompts are most valuable at decision points — places where
the model must classify or choose before producing a result. Without a
thinking prompt, the model may satisfy the decision implicitly and
inconsistently.

The tradeoff:

- **Visible CoT** — reasoning appears in output, verifiable, but adds
  verbosity and may interfere with output format
- **Implicit thinking** — reasoning shapes generation before output; in
  extended thinking mode this is literally thinking tokens; in standard mode
  instruction order still shapes what gets generated first internally

Recommendation: make decision-point reasoning visible where the output
format permits; rely on instruction order and thinking-prompt vocabulary
elsewhere.

---

## Named procedure blocks

For complex prompts, reasoning sequences that appear in multiple places — or
that are long enough to obscure the surrounding prompt — can be named and
invoked like functions. XML tags are a natural fit, since Claude already uses
them for structural marking.

Definition:

```xml
<procedure name="dispatch-finding">
  think through whether this is a missed instance or a consequential adjacency
  think through whether an in-session antecedent exists
  decide: in-scope follow-on, ancillary, or drop
</procedure>
```

Invocation at the call site:

```
for each finding, call dispatch-finding, then write the result as a numbered item
```

Benefits:
- Defined once, named, invoked by name — prompt stays readable at the call
  site
- Each procedure is auditable independently (does every block have a type?)
- Shared procedures across roles or agents reduce drift

Limits: there is no actual call stack, so recursion and error handling don't
translate. Execution cannot be verified. But as a structuring discipline for
complex prompts the analogy holds well.

---

## The broader framing

Most prompt writing is done outside-in: describe what you want the agent to
be like, and hope the behaviour follows. Explicit agent programming inverts
this: describe what the agent does, step by step, and the character emerges
from the sequence.

The analogy to programming is close. A prompt written this way is closer to
pseudocode than to prose — each block has a type, a sequence, and an output
that feeds the next step. The difference from actual code is that execution
cannot be verified, which is why vocabulary discipline matters: it is the
closest available substitute for type-checking a prompt before it runs.

---

## Related work

The specific combination of typed instruction blocks, reduced vocabulary, and
named procedure blocks does not appear to have been articulated elsewhere.
Adjacent work:

**Declarative Prompt DSLs** — research area treating prompts as programs
with modularisation, versioning, and static checks. Focused on structure and
composability rather than on an explicit execution model per instruction
block.
- [Impromptu framework](https://link.springer.com/article/10.1007/s10270-024-01235-4) — DSL for multimodal prompts, modular, tool-independent, supports prompt chaining
- [Declarative Prompt DSLs overview](https://www.emergentmind.com/topics/declarative-prompt-dsls) — first-class modularisation, static checks, deterministic composition
- [ai.txt](https://arxiv.org/pdf/2505.07834) — proposed DSL for guiding LLM behaviour, principles of simplicity, clarity, consistency

**Structured Chain-of-Thought (SCoT)** — uses programming structures
(if/else, loops) to scaffold reasoning steps for code generation tasks.
Closer in spirit to the forward-reasoning principle but scoped to CoT for
code, not general agent instruction design.
- [SCoT for code generation](https://ligechina.github.io/My%20Papers/2025%20-%20TOSEM%20-%20Structured%20Chain-of-Thought%20Prompting%20for%20Code%20Generation.pdf)

**Context Engineering** — the broader 2025–2026 framing of prompt
engineering as context assembly: "LLM as CPU, context window as RAM,
developer as OS." High-level abstraction, does not address instruction-level
vocabulary or execution types.
- [Beyond the Text Box](https://blog.eif.am/llm-prompt-engineering/)

**Anthropic prompting best practices** — covers clarity, chain-of-thought,
XML structure, and tool use formatting. Partially addresses principles 1
(literal) and 3 (forward reasoning). Does not address principle 4 (don't
state outcomes) or the typed vocabulary.
- [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md)

**LLM Agents — Prompt Engineering Guide** — covers agent architecture,
tool calling, and ReAct-style think/act loops. Does not address instruction-
level typing or vocabulary discipline.
- [LLM Agents](https://www.promptingguide.ai/research/llm-agents)
