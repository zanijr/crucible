---
name: meta-pattern-recognition
version: 1.0.0
description: Use when noticing the same pattern across 3+ different domains or experiencing déjà vu in problem-solving — extract the universal principle and apply it elsewhere
user-invocable: true
allowed-tools: Read, Glob, Grep
argument-hint: [repeating pattern]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Meta-Pattern Recognition

When the same pattern appears in 3+ domains, it's probably a universal principle worth extracting explicitly.

**Announce at start:** "I'm using the meta-pattern-recognition skill to find the universal principle here."

**Core principle:** Find patterns in how patterns emerge.

## Starting Points

| Pattern appears in | Abstract form | Where else? |
|---|---|---|
| CPU / DB / HTTP / DNS caching | Store frequently-accessed data closer to the consumer | LLM prompt caching, CDN, memoization |
| Layering (network / storage / compute) | Separate concerns into abstraction levels | Software architecture, organization design |
| Queuing (message / task / request) | Decouple producer from consumer with a buffer | Event systems, async pipelines |
| Pooling (connection / thread / object) | Reuse expensive resources instead of recreating | Memory management, resource governance |
| Rate limiting (API / traffic / admission) | Bound resource consumption to prevent exhaustion | LLM token budgets, crawler backoff |

## Process

1. **Spot the repetition.** Same shape in 3+ places (different modules, different problems, different domains).
2. **Extract the abstract form.** Describe it independent of any single domain.
3. **Identify variation points.** How does it adapt per context? (What resource, what bound, what trigger?)
4. **Check applicability.** Where else might this help?

## Example

**Pattern spotted:** Rate limiting appears in API throttling, traffic shaping, circuit breakers, admission control.

**Abstract form:** Bound resource consumption to prevent exhaustion.

**Variation points:** *what* resource, *what* limit, *what* happens when exceeded.

**New application:** LLM token budgets — same pattern, new domain. Prevent context-window exhaustion with a bound and a defined overflow behavior (drop oldest, summarize, reject request).

## Red Flags You're Missing a Meta-Pattern

- "This problem is unique" — probably not
- Multiple teams independently solving "different" problems with identical shapes
- Reinventing wheels across domains
- "Haven't we done something like this?" — yes, go find it

## Integration

**Pairs with:**
- `crucible:when-stuck` (routes here when patterns feel familiar)
- `crucible:simplification-cascades` (use a meta-pattern to collapse many implementations into one)

## Remember

- 3+ domains = likely universal
- The abstract form reveals new applications
- Variation points show adaptation levers
- Universal patterns are battle-tested across decades
