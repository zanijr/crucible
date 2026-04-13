---
name: verification-before-completion
version: 1.0.0
description: Use when about to claim work is complete, fixed, or passing — BEFORE committing or creating PRs. Requires running verification commands and confirming output before making any success claims.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: ""
---

# Verification Before Completion

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

## When to Use

- About to say "done", "fixed", "working", or "tests pass"
- Before committing code
- Before creating a PR
- Before marking a task as complete

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in THIS message, you cannot claim it passes.

## The Gate Function

BEFORE claiming any status or expressing satisfaction:

1. **IDENTIFY**: What command proves this claim?
2. **RUN**: Execute the FULL command (fresh, complete)
3. **READ**: Full output, check exit code, count failures
4. **VERIFY**: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. **ONLY THEN**: Make the claim

Skip any step = lying, not verifying.

## What Counts as Verification

| Claim | Required Evidence |
|-------|-------------------|
| "Tests pass" | Full test suite output showing 0 failures |
| "Build succeeds" | Build command output with exit code 0 |
| "Bug is fixed" | The reproduction steps no longer trigger the bug |
| "Feature works" | Actual output matching expected behavior |
| "No regressions" | Full test suite passing, not just new tests |

## What Does NOT Count

- "I wrote the code correctly" → you think it's correct. Prove it.
- "The test should pass" → run it. "Should" is not evidence.
- "I tested this earlier" → test it NOW. Earlier results may be stale.
- "Similar code works elsewhere" → this instance needs its own verification.

## Red Flags

| Thought | Reality |
|---------|---------|
| "I'm confident this works" | Confidence is not evidence. Run the test. |
| "The change is trivial" | Trivial changes break things too. Verify. |
| "I already tested this" | Run it again. State may have changed. |
| "Tests take too long" | Shipping broken code takes longer. |

## Common Mistakes

- Running only the new test, not the full suite → regressions slip through
- Checking exit code but not reading output → "0 tests ran" counts as passing
- Verifying in a stale environment → cached results mask real failures
- Claiming "fixed" based on code review, not execution → wishful thinking
