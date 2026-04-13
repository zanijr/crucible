---
name: systematic-debugging
version: 1.0.0
description: Use when something is broken or failing — BEFORE proposing fixes. Requires systematic root cause investigation in four phases before attempting any solutions.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [error or symptom description]
---

# Systematic Debugging

Random fixes waste time and create new bugs. Find the root cause before attempting any fix.

**Core principle:** Symptom fixes are failures. Always find root cause first.

## When to Use

- Something is broken, failing, or producing wrong output
- Tests are failing
- User reports a bug
- Unexpected behavior after a change

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The Four Phases

### Phase 1: Root Cause Investigation

1. **Read the error** — Full stack trace, exact error message. Not just the last line.
2. **Reproduce** — Can you trigger the failure reliably? What exact steps?
3. **Check recent changes** — `git log --oneline -10`, `git diff`. What changed?
4. **Gather evidence** — Logs, test output, network responses. Facts, not theories.

Deliverable: A clear statement of what's failing and what the evidence shows.

### Phase 2: Pattern Analysis

1. **Find working examples** — Where does similar code work correctly?
2. **Compare** — What's different between working and broken cases?
3. **Identify the delta** — What specific change or condition causes the failure?

### Phase 3: Hypothesis and Testing

1. **Form hypothesis** — "The failure occurs because X"
2. **Test minimally** — Change ONE variable to test the hypothesis
3. **If confirmed** — Proceed to Phase 4
4. **If disproven** — Return to Phase 1 with new evidence

### Phase 4: Implementation

1. **Write a failing test** that reproduces the bug (invoke `crucible:test-driven-development`)
2. **Implement the fix** — ONE change that addresses root cause
3. **Run ALL tests** — The fix must not break anything else
4. **Verify** — Does the original error still occur? (It shouldn't.)

## Escalation Rule

If you've made 3+ fix attempts without resolving the issue, STOP. The problem is likely architectural, not implementational. Report to the user with all evidence gathered.

## Red Flags

| Thought | Reality |
|---------|---------|
| "I think I know what's wrong" | Prove it. Evidence, not intuition. |
| "Let me try this quick fix" | Quick fixes that miss root cause create new bugs. |
| "It works on my machine" | That's evidence of an environment difference, not a resolution. |
| "Let me just restart/reset" | That hides the cause, doesn't fix it. |

## Common Mistakes

- Jumping to fixes without reading the full error → fixing the wrong thing
- Changing multiple things at once → can't tell which change fixed it
- Not writing a regression test → same bug returns later
- Giving up after 1 failed hypothesis → investigation is iterative
- Not checking recent changes → the bug is often in the last commit
