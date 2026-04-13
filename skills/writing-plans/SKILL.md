---
name: writing-plans
version: 1.0.0
description: Use when you have a spec or requirements for multi-step work — BEFORE touching code. Creates comprehensive implementation plans with bite-sized tasks, acceptance criteria, and dependency ordering.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [spec or feature description]
---

# Writing Plans

Create comprehensive implementation plans. Each task should be bite-sized (2-5 minutes), have clear acceptance criteria, and specify dependencies.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

## When to Use

- After brainstorming has produced an approved design
- User has a spec or requirements for multi-step work
- Before any implementation begins
- Before invoking `crucible:orchestrating-work` or `crucible:executing-plans`

## The Iron Law

```
NO IMPLEMENTATION WITHOUT A PLAN. NO VAGUE TASKS.
```

## Core Pattern

### Step 1: Scope Check

Break independent subsystems into separate plans. Each plan should produce independent, testable software.

### Step 2: Document Header

Every plan starts with:

```markdown
# Plan: {feature_name}

**Goal:** {one sentence}
**Architecture:** {key design decisions}
**Tech Stack:** {languages, frameworks, tools}
**Depends on:** {other plans or prerequisites}
```

### Step 3: Map Files

List every file being created or modified with its responsibility:

```markdown
## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `src/auth/middleware.ts` | Create | JWT validation middleware |
| `src/auth/types.ts` | Create | Auth type definitions |
| `tests/auth.test.ts` | Create | Auth middleware tests |
```

### Step 4: Define Tasks

Each task is a 2-5 minute action. For each task:

- **Title**: What to do (imperative, e.g., "Add JWT validation middleware")
- **Description**: Full context, assume zero knowledge
- **Acceptance criteria**: 3-5 specific, testable conditions
- **Depends on**: Which tasks must complete first
- **Priority**: p0/p1/p2
- **Complexity**: mechanical/integration/architecture
- **Steps**: Ordered list of actions with code examples where helpful
- **Verify command**: How to check it worked

### Step 5: Enforce Quality

Every task MUST have:
- [ ] At least 3 acceptance criteria
- [ ] A verify command or test to run
- [ ] Complete code examples (no "implement the logic" hand-waving)
- [ ] Explicit file paths for every file touched

### Step 6: Self-Review

Before presenting the plan:
- Scan for red flags: "TBD", "TODO", vague instructions, undefined references
- Verify spec coverage — does every requirement map to at least one task?
- Check dependency ordering — are circular dependencies possible?
- Verify type consistency — do types used across tasks match?

### Step 7: Save Plan

Save to `docs/crucible/plans/{date}-{feature-name}.md` for reference.

If this will be orchestrated, also write `.crucible/plan.json` using the schema from `crucible:orchestrating-work`.

## Task Size Guide

| Too Small | Right Size | Too Large |
|-----------|-----------|-----------|
| "Add import statement" | "Add JWT validation middleware with tests" | "Implement the entire auth system" |
| "Create empty file" | "Create user model with validation and migration" | "Build the API" |

Each task should be completable by a single agent in one pass, with clear start and end conditions.

## Common Mistakes

- Vague acceptance criteria ("it should work") → untestable, unverifiable
- Tasks without code examples → workers guess, guess wrong
- Missing dependency ordering → parallel agents conflict
- Giant tasks ("implement feature X") → too much scope for one agent
- Not including verify commands → no way to check completion
