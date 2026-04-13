---
name: spec-verification
version: 1.0.0
description: Use when a task claims to be complete — verify the implementation against acceptance criteria by comparing git diff to the spec, running verification commands, and producing a pass/fail verdict
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [task-id or "all"]
---

# Spec Verification

Check whether a task's implementation actually meets its acceptance criteria. Not "does the code look reasonable" — does it PASS every criterion, verifiably?

**Announce at start:** "I'm using the spec-verification skill to verify task completion."

## When to Use

- After a worker agent reports STATUS: DONE
- Before marking a task as complete in plan.json
- When user asks "did this actually work?"
- As part of the orchestrating-work Phase 5

## The Iron Law

```
NO TASK MARKED DONE WITHOUT SPEC VERIFICATION.
```

A task is not done because an agent said so. A task is done because evidence proves it.

## Core Pattern

### Step 1: Load Task Spec

Read the task from `.crucible/plan.json`. Extract:
- `acceptance_criteria` — the list of conditions
- `verify_command` — optional verification command
- Task description for context

### Step 2: Gather Evidence

```bash
# Get the diff for the task's changes
git diff main...HEAD
```

If the task worked on a specific branch, diff that branch instead.

### Step 3: Check Each Criterion

For each acceptance criterion:

1. **Search the diff** — Is there code that addresses this criterion?
2. **Run verification** — If `verify_command` exists, run it and check output
3. **Run tests** — If test files were changed, run them
4. **Verdict** — Does the evidence confirm this criterion is met?

### Step 4: Produce Verdict

Output a JSON result:

```json
{
  "pass": true,
  "criteria_results": [
    { "criterion": "API returns 200 for valid input", "met": true, "evidence": "Test passes: GET /api/users returns 200" },
    { "criterion": "Invalid input returns 400", "met": true, "evidence": "Validation middleware added at line 23" }
  ],
  "reasons": ["All criteria met", "Tests pass"]
}
```

Or if failing:

```json
{
  "pass": false,
  "criteria_results": [
    { "criterion": "Rate limiting on public endpoints", "met": false, "evidence": "No rate limiting middleware found in diff" }
  ],
  "reasons": ["Criterion 3 not met: missing rate limiting implementation"]
}
```

### Step 5: Act on Result

- **Pass**: Update task status to `"done"` in plan.json
- **Fail + retries remaining**: Generate specific feedback about what's missing, re-dispatch the worker with this feedback
- **Fail + no retries**: Mark task `"failed"`, log the gap, report to user

## Strictness

Be strict. If a criterion is partially met, it's a fail. "Close enough" is not done.

## Common Mistakes

- Assuming a criterion is met because related code exists → verify the SPECIFIC behavior
- Skipping the verify_command → it exists for a reason
- Trusting "tests pass" without checking WHICH tests → new code needs new tests
- Marking done on first pass without checking ALL criteria → some get missed
