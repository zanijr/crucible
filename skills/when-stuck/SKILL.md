---
name: when-stuck
version: 1.0.0
description: Use when stuck and unsure which problem-solving technique to apply — routes to the right specialist skill based on how you're stuck
user-invocable: true
allowed-tools: Read
argument-hint: [description of how you're stuck]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# When Stuck — Problem-Solving Dispatcher

Different kinds of "stuck" need different techniques. This skill matches the symptom to the right specialist skill.

**Announce at start:** "I'm using the when-stuck skill to pick the right technique."

## Stuck-Type → Skill

| How you're stuck | Use this skill |
|---|---|
| **Complexity spiraling** — same concept implemented 5+ ways, growing special cases, excessive if/else | `crucible:simplification-cascades` |
| **Need a breakthrough** — conventional solutions feel inadequate, can't find a fitting approach | `crucible:collision-zone-thinking` |
| **Recurring patterns** — same issue across different places, feels like you've seen it before, reinventing wheels | `crucible:meta-pattern-recognition` |
| **Forced by assumptions** — "it must be done this way", solution feels wrong but you can't say why | `crucible:inversion-exercise` |
| **Scale uncertainty** — will it work in production? edge cases unclear? unsure of limits? | `crucible:scale-game` |
| **Code broken** — wrong behavior, test failing, unexpected output | `crucible:systematic-debugging` |
| **Root cause unknown** — symptom clear, cause hidden deep in the stack | `crucible:root-cause-tracing` |
| **Multiple independent problems** — investigation can be parallelized | `crucible:orchestrating-work` |
| **Oscillating between two designs** — each is good in different ways | `crucible:preserving-productive-tensions` |

## Process

1. **Identify your stuck-type** from the table above.
2. **Load that skill** — read its process carefully.
3. **Apply the technique** as the skill describes.
4. **If still stuck,** try a different technique or combine two.

## Combining Techniques

Some problems need more than one tool:

- **Simplification + Meta-pattern:** find the pattern, then collapse all instances at once
- **Collision + Inversion:** force a metaphor, then invert its assumptions to stress-test it
- **Scale + Simplification:** push to extremes to find what's essential vs. accidental
- **Root-cause + Defense-in-depth:** find the source, then harden every layer so it can't recur

## Remember

- Match the symptom to the technique — don't just grab the one you know
- One at a time, then combine if needed
- Document what you tried and what worked — it's data for next time
