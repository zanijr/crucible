---
name: preserving-productive-tensions
version: 1.0.0
description: Use when oscillating between equally valid design approaches that optimize for different legitimate priorities — decide whether to preserve both via config/parallel impls or force a resolution
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: [design decision]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Preserving Productive Tensions

Some design tensions aren't problems to solve — they're valuable information to preserve. When multiple approaches are genuinely valid in different contexts, forcing a premature choice destroys flexibility. But not every tension is productive — some need resolution. This skill helps tell the difference.

**Announce at start:** "I'm using the preserving-productive-tensions skill to decide if this tension should be resolved or preserved."

## When to Use

- Brainstorming surfaced 2+ approaches and each is genuinely strong
- You keep flip-flopping between approaches in the same session
- You feel pressure to "just pick one" but neither feels wrong
- Stakeholders have conflicting valid concerns (cost vs latency, simplicity vs features, etc.)

## Productive vs. Needs-Resolution

**A tension is PRODUCTIVE (preserve) when:**
- Both approaches optimize for different **valid** priorities
- The "better" choice depends on deployment context, not technical superiority
- Different users or deployments would reasonably choose differently
- The trade-off is real and won't disappear with cleverer engineering

**A tension NEEDS RESOLUTION when:**
- Preserving both adds prohibitive implementation/maintenance cost
- The approaches fundamentally conflict (can't coexist cleanly)
- One is objectively better **for this specific context** (not just "I prefer it")
- It's a one-way door — the choice locks architecture
- Preserving both adds complexity with no downstream value (YAGNI)

## Preservation Patterns

### Pattern A: Configuration

Make the choice a runtime config knob, with both paths equally clean.

```python
class Config:
    mode: Literal["optimize_cost", "optimize_latency"]
```

Best when both approaches are architecturally compatible.

### Pattern B: Parallel Implementations

Maintain both as separate clean modules behind a shared interface.

```
processor/
├── batch.py     # optimizes for cost
├── stream.py    # optimizes for latency
└── interface.py # def process(data) -> Result
```

Best when approaches diverge significantly but share the contract.

### Pattern C: Documented Trade-off (ADR)

Capture the tension explicitly, defer the choice to deployment config.

```markdown
## Unresolved Tension: Authentication Strategy

**Option A: JWT** — stateless, scales easily; revocation is hard
**Option B: Sessions** — easy revocation; requires shared state

**Why unresolved:** Different deployments need different trade-offs
**Decision deferred to:** Deployment configuration
**Review trigger:** If 80% of deployments land on one option, revisit
```

Best when you can't preserve both in code but want the next maintainer to know the choice was deliberate.

## Red Flags: You're Forcing Resolution

- "Which is best?" when both are valid
- "We just need to pick one" without explaining **why** picking matters now
- Choosing based on your aesthetic vs. the user's actual context
- Resolving tensions to "make progress" — when preserving them **is** progress
- Forcing consensus when diversity is the point

## When to Force Resolution

You **should** force resolution when any of these apply:

1. **Implementation cost is prohibitive.** Building/maintaining both slows the team down.
2. **Fundamental conflict.** The approaches make contradictory architectural assumptions.
3. **Clear technical superiority for this context.** "X solves our constraints, Y doesn't" — not aesthetic preference.
4. **One-way door.** The choice locks architecture; migration later would be expensive.
5. **YAGNI.** You only need one path today; building both is speculative work.

**When unsure, ask the user:** *"Should I pick one, or preserve both as options?"* Don't decide silently.

## Documentation Format

```markdown
## Tension: {name}

**Context:** {why this tension exists}

**Option A:** {approach}
- Optimizes for: {priority}
- Trade-off: {cost}
- Best when: {context}

**Option B:** {approach}
- Optimizes for: {different priority}
- Trade-off: {different cost}
- Best when: {different context}

**Preservation strategy:** {Configuration | Parallel | Documented}
**Resolution trigger:** {conditions that would force a choice}
```

## Integration

**Pairs with:**
- `crucible:brainstorming` (where tensions usually surface)
- `crucible:writing-plans` (document preserved tensions in the plan)

## Remember

- Tensions between valid priorities are features, not bugs
- Premature consensus destroys flexibility
- Configuration > forced choice (when reasonable)
- Always document the trade-off — even when you resolve it
