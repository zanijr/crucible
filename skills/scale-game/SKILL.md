---
name: scale-game
version: 1.0.0
description: Use when uncertain about scalability, edge cases are unclear, or validating architecture for production volumes — test at extremes (1000x bigger/smaller, instant/year-long) to expose fundamentals hidden at normal scales
user-invocable: true
allowed-tools: Read, Write
argument-hint: [architecture or design to stress]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Scale Game

Test your approach at extreme scales to find what breaks and what surprisingly survives. Extremes expose fundamental truths hidden at normal scales.

**Announce at start:** "I'm using the scale-game skill to stress-test this design."

## Dimensions to Vary

| Dimension | Test at extremes | What it reveals |
|---|---|---|
| **Volume** | 1 item vs 1 billion items | Algorithmic complexity, data structure choice |
| **Speed** | Instant vs 1 year | Async requirements, caching needs, persistence |
| **Users** | 1 user vs 1 billion users | Concurrency issues, resource limits, contention |
| **Duration** | Milliseconds vs years | Memory leaks, state growth, clock drift |
| **Failure rate** | Never fails vs always fails | Error-handling adequacy, retry storms |
| **Latency** | 0ms vs 30s | Timeout behavior, user-facing degradation |

## Process

1. **Pick the dimension** most relevant to the design.
2. **Test the minimum.** What if this was 1000× smaller / faster / fewer?
3. **Test the maximum.** What if this was 1000× bigger / slower / more?
4. **Note what breaks.** Where do limits appear? At what scale?
5. **Note what survives.** What's fundamentally sound and what's lucky?

## Examples

### Example 1: Error Handling
- **Normal scale:** "Handle errors when they occur" works fine.
- **At 1B events/day:** Error volume overwhelms logging, crashes monitoring.
- **Reveals:** Need to make errors structurally impossible (types, contracts) or design for them systemically (chaos engineering, budgets).

### Example 2: Synchronous APIs
- **Normal scale:** Direct function calls work great.
- **At global scale:** Network latency across regions makes sync calls untenable.
- **Reveals:** Async/messaging becomes a survival requirement, not an optimization.

### Example 3: In-Memory State
- **Normal duration:** Works for hours/days.
- **At years of continuous uptime:** Memory grows unbounded, eventual OOM.
- **Reveals:** Need persistence or periodic cleanup; can't rely on "it restarts occasionally."

## Red Flags You Need This

- "It works in dev" — but will it work in production?
- No idea where the limits are
- "Should scale fine" — without having tested it
- Surprised by production behavior after launch

## Integration

**Pairs with:**
- `crucible:when-stuck` (routes here when scale is the uncertainty)
- `crucible:writing-plans` (bake scale assumptions into the plan)

## Remember

- Extremes reveal fundamentals that "typical" inputs hide
- What works at one scale often fails at another — check both directions
- Test bigger **and** smaller — both surface different failure modes
- Use insights to validate architecture **early**, while changes are cheap
