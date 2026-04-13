---
name: test-driven-development
version: 1.0.0
description: Use when implementing any feature or bugfix — BEFORE writing implementation code. Enforces RED-GREEN-REFACTOR cycle where tests are always written first.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [feature or fix description]
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass. Refactor.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

## When to Use

**Always:**
- New features
- Bug fixes
- Behavior changes
- Refactoring

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration-only changes

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over.

Violating the letter of the rules is violating the spirit of the rules.

## The Cycle

### RED: Write a Failing Test

1. Write ONE test for the next piece of behavior
2. Run it — it MUST fail
3. Verify it fails for the RIGHT reason (not syntax error, not wrong import)

If the test passes immediately, either:
- The behavior already exists (you don't need to implement it)
- The test is wrong (it's not testing what you think)

### GREEN: Make It Pass

1. Write the MINIMUM code to make the test pass
2. No extra features, no "while I'm here" improvements
3. Run the test — it MUST pass
4. Run ALL tests — nothing else should break

### REFACTOR: Clean Up

1. Both test code and production code
2. Remove duplication
3. Improve naming
4. Simplify logic
5. Run ALL tests after refactoring — everything must still pass

## Key Rules

- One test at a time. Don't write a suite of tests and then implement.
- Minimal implementation. Don't add code that isn't required by a failing test.
- Run tests constantly. After every change, run the relevant tests.
- Test behavior, not implementation. Test WHAT it does, not HOW it does it.

## Red Flags

| Thought | Reality |
|---------|---------|
| "I'll write the tests after" | You won't. And they'll test the implementation, not the behavior. |
| "This is too simple for TDD" | Simple code + simple test = confidence. Skip it = doubt. |
| "I'll just add this one thing" | Scope creep. Write a test for it first. |
| "The test is obvious" | Write it anyway. Obvious tests catch non-obvious regressions. |
| "TDD is too slow" | Debugging without tests is slower. Every time. |

## Common Mistakes

- Writing multiple tests before implementing → lost focus, complex debugging
- Making the test pass with hardcoded values → test doesn't prove behavior
- Not running tests after refactoring → refactoring introduced a bug
- Testing implementation details → tests break when you refactor
- Skipping the RED step → test might already pass, proving nothing
