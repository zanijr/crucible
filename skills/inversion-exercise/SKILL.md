---
name: inversion-exercise
version: 1.0.0
description: Use when stuck on unquestioned assumptions or feeling forced into "the only way" to do something — flip each core assumption and see what the opposite reveals
user-invocable: true
allowed-tools: Read, Write
argument-hint: [assumption or problem]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Inversion Exercise

Flip every assumption and see what still works. Sometimes the opposite reveals the truth.

**Announce at start:** "I'm using the inversion-exercise skill to surface hidden assumptions."

**Core principle:** Inversion exposes hidden assumptions and alternative approaches.

## Starting Points

| Normal assumption | Inverted | What it reveals |
|---|---|---|
| Cache to reduce latency | Add latency to enable caching | Debouncing patterns |
| Pull data when needed | Push data before it's needed | Prefetching, eager loading |
| Handle errors when they occur | Make errors impossible by construction | Type systems, contracts, defense-in-depth |
| Build features users want | Remove features users don't need | Subtractive design, simplicity |
| Optimize for the common case | Optimize for the worst case | Resilience patterns |
| Retry on failure | Fail fast and escalate | Circuit breakers |
| Trust the caller | Validate everything | Zero-trust patterns |

## Process

1. **List the core assumptions.** What "must" be true for the current approach to make sense?
2. **Invert each one systematically.** "What if the opposite were true?"
3. **Explore implications.** What would change? What would we do differently?
4. **Find valid inversions.** Which ones actually work in some context?

## Example

**Problem:** Users complain the app is slow.

**Normal approach:** Make everything faster (caching, optimization, CDN).

**Inverted:** Make *some* things intentionally slower.
- **Debounce search** — add 300ms latency → better results, fewer calls
- **Rate-limit requests** — add friction → prevent abuse, better per-request quality
- **Lazy-load content** — delay non-essential loads → faster initial render

**Insight:** Strategic slowness can improve UX. "Faster" is not always the answer.

## Red Flags You Need This

- "There's only one way to do this"
- You're forcing a solution that feels wrong but you can't articulate why
- You can't explain **why** the current approach is necessary — just that it is
- "This is just how it's done" (cargo-culting)

## Integration

**Pairs with:**
- `crucible:when-stuck` (routes here when assumptions feel forced)
- `crucible:collision-zone-thinking` (invert the assumptions of a borrowed metaphor)

## Remember

- Not all inversions work — test the boundaries
- Valid inversions reveal context-dependence — the "right" answer depends on which side you're on
- Sometimes the opposite *is* the answer
- Question every "must be" statement
