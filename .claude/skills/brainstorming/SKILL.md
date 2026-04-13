---
name: brainstorming
version: 1.0.0
description: Use when you have a new project, feature idea, or design decision — BEFORE writing any code. Explores requirements, alternatives, and trade-offs before committing to an approach.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [topic or feature idea]
---

# Brainstorming

Explore before you build. Ask questions, discover requirements, evaluate alternatives, and get approval before any code is written.

**Announce at start:** "I'm using the brainstorming skill to explore this before we build."

## When to Use

- New project or feature idea
- Design decision with multiple viable approaches
- User says "I want to build X" or "How should we approach Y"
- Before invoking `crucible:writing-plans`

## The Iron Law

```
NO CODE WITHOUT A DESIGN. NO DESIGN WITHOUT EXPLORATION.
```

Do NOT invoke any implementation skill, write any code, scaffold any project, or take any action until you have presented a design and the user has approved it.

## Core Pattern

### Step 1: Understand the Goal

Ask clarifying questions — ONE AT A TIME. Don't dump a list of 10 questions.

Focus on:
- What problem are we solving?
- Who is the user/audience?
- What are the constraints (time, tech stack, existing code)?
- What does "done" look like?

### Step 2: Explore Context

Read existing code, docs, and config to understand the current state:
- What already exists that we can build on?
- What patterns does the codebase follow?
- Are there constraints from existing architecture?

### Step 3: Generate Alternatives

Present 2-3 alternative approaches with trade-offs:

```markdown
## Option A: {name}
- **Approach**: {description}
- **Pros**: {list}
- **Cons**: {list}
- **Effort**: {rough estimate}

## Option B: {name}
...
```

Don't present a "straw man" option just to make your preferred one look good. Each option should be genuinely viable.

### Step 4: Recommend

State your recommendation and WHY. Be specific about the trade-offs you're accepting.

### Step 5: Get Approval

Present the design in digestible sections. Wait for the user to approve before proceeding.

Hard gate: Do NOT proceed to planning or implementation until the user explicitly approves.

### Step 6: Save Design

Save the approved design to `docs/crucible/specs/{date}-{topic}-design.md`.

## Red Flags

| Thought | Reality |
|---------|---------|
| "This is obvious, no need to brainstorm" | Obvious solutions often miss edge cases |
| "I already know the best approach" | You know ONE approach. Explore others. |
| "The user just wants it done" | Fast wrong work costs more than slow right work |
| "Let me just start coding" | That's the impulse this skill prevents |

## Common Mistakes

- Asking too many questions at once → user gets overwhelmed
- Presenting only one option → no real decision-making
- Skipping context exploration → missing existing code you could reuse
- Not saving the design doc → decisions get lost
