---
name: self-healing
version: 1.0.0
description: Use when an agent or task has failed — provides structured failure analysis, adaptive retry strategies, and lesson recording to prevent repeat failures
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [task-id or description of failure]
---

# Self-Healing

When something fails, don't retry blindly. Analyze the failure, classify it, choose an adapted strategy, and record what you learned.

**Announce at start:** "I'm using the self-healing skill to analyze this failure."

## When to Use

- A worker agent fails or produces no STATUS line
- A task fails spec verification
- An Agent tool call returns an error
- The same task has failed multiple times
- Something unexpected breaks during orchestration

## The Iron Law

```
NEVER RETRY WITHOUT ANALYZING FIRST. NEVER FAIL WITHOUT RECORDING.
```

## Core Pattern

### Step 1: Capture

Record the exact failure:
- What was attempted (task description, agent prompt)
- What happened (error message, wrong output, timeout)
- Environment state (changed files, git status, test results)

### Step 2: Classify

See `references/failure-taxonomy.md` for the full classification tree.

| Category | Examples | Typical Fix |
|----------|----------|-------------|
| **Prompt gap** | Agent lacked context, misunderstood task | Enrich prompt with missing details |
| **Code bug** | Syntax error, wrong API usage, missing import | Fix the specific bug |
| **Environment** | Missing dependency, wrong Node version, permissions | Fix environment, re-dispatch |
| **Scope creep** | Agent modified files outside task scope | Constrain prompt, list allowed files |
| **Architecture** | Wrong approach entirely, fundamental design issue | Redesign task, possibly split into subtasks |
| **Flaky** | Timing issue, network error, intermittent failure | Retry once, if persists → investigate |

### Step 3: Adapt

Based on classification, choose a strategy:

1. **Enrich prompt** — Add missing context, be more specific about expectations
2. **Constrain scope** — Explicitly list allowed files, forbidden operations
3. **Split task** — Break into smaller, more focused subtasks
4. **Change approach** — Try a different agent type or implementation strategy
5. **Fix and retry** — Fix the specific issue yourself, then re-dispatch
6. **Escalate** — If 3+ retries fail, stop and report to user

### Step 4: Retry

Re-dispatch with the adapted prompt. Include what went wrong:

```
PREVIOUS ATTEMPT FAILED.
Failure: {classification} — {description}
What to do differently: {specific guidance}
```

Maximum 2 retries per task. After 3 total attempts, escalate.

### Step 5: Record

Append to `.crucible/memory/failure-log.md`:

```markdown
## [{date}] {task_title}
- **Classification**: {category}
- **Error**: {error_description}
- **Root cause**: {analysis}
- **Fix applied**: {what_resolved_it}
- **Retries**: {count}
- **Outcome**: {resolved|escalated}
```

If the failure revealed a reusable lesson, also append to `.crucible/memory/lessons-learned.md`:

```markdown
## [{date}] {lesson_title}
- **What worked**: {description}
- **What failed**: {description}
- **For next time**: {actionable advice}
```

## Key Rules

- Never retry with the exact same prompt — that's the definition of insanity
- Always classify before choosing a strategy — wrong classification → wrong fix
- Record EVERY failure, even trivial ones — patterns emerge from data
- After 3+ fixes on the same task, suspect the architecture, not the implementation

## Common Mistakes

- Retrying immediately without analysis → same failure, wasted tokens
- Blaming the agent when the prompt was unclear → fix the prompt, not the agent
- Not recording lessons → same failure happens next week
- Over-engineering the retry → sometimes the simplest fix is best
