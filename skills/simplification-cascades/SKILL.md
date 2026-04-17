---
name: simplification-cascades
version: 1.0.0
description: Use when implementing the same concept multiple ways, accumulating special cases, or complexity is spiraling — find one insight that eliminates multiple components
user-invocable: true
allowed-tools: Read, Edit, Glob, Grep
argument-hint: [area of complexity]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Simplification Cascades

Sometimes one insight eliminates ten things. Look for the unifying principle that makes multiple components unnecessary.

**Announce at start:** "I'm using the simplification-cascades skill to find the insight that collapses this."

**Core principle:** "Everything is a special case of..." collapses complexity dramatically — 10x wins, not 10% improvements.

## Symptoms

| Symptom | Likely Cascade |
|---|---|
| Same concept implemented 5+ ways | Abstract the common pattern |
| Growing special-case list | Find the general case |
| Complex rules with many exceptions | Find the rule with no exceptions |
| Excessive config options | Find defaults that work for 95% |

## Process

1. **List the variations.** What's being implemented multiple ways?
2. **Find the essence.** What's the same underneath the surface differences?
3. **Extract the abstraction.** Describe it independent of the specific domain.
4. **Test it.** Do all cases fit cleanly, or are you cheating?
5. **Measure the cascade.** How many things become unnecessary?

## Examples

### Cascade 1: Stream Abstraction
- **Before:** Separate handlers for batch / real-time / file / network data
- **Insight:** "All inputs are streams — just different sources"
- **After:** One stream processor, multiple stream sources
- **Eliminated:** 4 separate implementations

### Cascade 2: Resource Governance
- **Before:** Session tracking, rate limiting, file validation, connection pooling — all separate subsystems
- **Insight:** "All are per-entity resource limits"
- **After:** One `ResourceGovernor` with 4 resource types
- **Eliminated:** 4 custom enforcement systems

### Cascade 3: Immutability
- **Before:** Defensive copying, locking, cache invalidation, temporal coupling
- **Insight:** "Treat everything as immutable data + transformations"
- **After:** Functional patterns
- **Eliminated:** Entire classes of synchronization problems

## Red Flags You're Missing a Cascade

- "We just need to add one more case..." (repeating forever)
- "These are all similar but different" (maybe they're the same?)
- Refactoring feels like whack-a-mole (fix one, break another)
- Growing configuration file
- "Don't touch that, it's complicated" — complexity hiding a pattern

## Integration

**Pairs with:**
- `crucible:when-stuck` (routes here when complexity is spiraling)
- `crucible:meta-pattern-recognition` (once you see the pattern in 3+ domains, generalize further)

## Remember

- Cascades = 10x wins, not 10% improvements
- One powerful abstraction beats ten clever hacks
- The pattern is usually already there — it just needs recognition
- Success metric: "how many things can we delete?"
