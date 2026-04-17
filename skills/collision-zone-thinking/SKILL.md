---
name: collision-zone-thinking
version: 1.0.0
description: Use when conventional approaches feel inadequate and you need a breakthrough — force unrelated concepts together to discover emergent properties ("what if we treated X like Y?")
user-invocable: true
allowed-tools: Read, Write
argument-hint: [problem]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Collision-Zone Thinking

Breakthroughs come from forcing unrelated concepts together. Treat X like Y and see what emerges.

**Announce at start:** "I'm using the collision-zone-thinking skill to generate alternatives."

**Core principle:** Deliberate metaphor-mixing generates novel solutions.

## Starting Points

| Stuck on | Try treating as | Might discover |
|---|---|---|
| Code organization | DNA / genetics | Mutation testing, evolutionary algorithms |
| Service architecture | Lego bricks | Composable microservices, plug-and-play |
| Data management | Water flow | Streaming, data lakes, flow-based systems |
| Request handling | Postal mail | Message queues, async processing |
| Error handling | Electrical circuits | Fault isolation, circuit breakers, graceful degradation |
| State management | Physical inventory | Accounting, double-entry ledger patterns |

## Process

1. **Pick two unrelated concepts** — one from your domain, one from a totally different field.
2. **Force the combination.** "What if we treated [A] like [B]?"
3. **Explore emergent properties.** What new capabilities appear?
4. **Test boundaries.** Where does the metaphor break?
5. **Extract the insight.** What did you learn — even from failed collisions?

## Example

**Problem:** Distributed system with cascading failures

**Collision:** "What if we treated services like electrical circuits?"

**Emergent properties:**
- Circuit breakers (disconnect on overload)
- Fuses (one-time failure protection)
- Ground faults (error isolation)
- Load balancing (current distribution)

**Where it works:** preventing cascade failures.
**Where it breaks:** circuits don't have retry logic.
**Insight:** fault-isolation patterns from electrical engineering apply directly.

## Best Source Domains

When you're looking for a metaphor to collide with your problem, these fields tend to produce rich ones:

- **Physics** — conservation laws, phase transitions, potential wells
- **Biology** — evolution, immune systems, ecosystems, metabolism
- **Economics** — markets, incentives, auctions, scarcity
- **Psychology** — attention, memory, habit formation
- **Logistics** — supply chains, queuing, routing
- **Electrical engineering** — circuits, signals, feedback

## Red Flags You Need This

- "I've tried everything in this domain"
- Solutions feel incremental, not breakthrough
- Stuck in the framing you were handed
- Need innovation, not optimization

## Integration

**Pairs with:**
- `crucible:when-stuck` (routes here when you need a breakthrough)
- `crucible:inversion-exercise` (after a collision, invert to stress-test)

## Remember

- Wild combinations often yield the best insights
- Test metaphor boundaries rigorously — don't over-extend
- Document even failed collisions — they teach something
- The metaphor doesn't have to be perfect to be useful
