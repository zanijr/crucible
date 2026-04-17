---
name: condition-based-waiting
version: 1.0.0
description: Use when tests have race conditions, timing dependencies, or inconsistent pass/fail behavior — replace arbitrary setTimeout/sleep delays with condition polling
user-invocable: true
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: [flaky test or area]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Condition-Based Waiting

Flaky tests often guess at timing with `setTimeout(50)` or `sleep(0.1)`. This creates race conditions: tests pass on fast machines, fail under load or in CI. Wait for the **actual condition** you care about, not a guess at how long it takes.

**Announce at start:** "I'm using the condition-based-waiting skill to fix flaky timing."

## When to Use

- A test uses `setTimeout`, `sleep`, `time.sleep`, `Thread.sleep`, or equivalent to wait for something
- Tests are flaky (pass locally, fail in CI — or vice versa)
- Tests time out when run in parallel
- Waiting for async work (events, state changes, file creation, DB writes)

## When NOT to Use

- You are actually testing timing behavior (debounce, throttle, rate-limit intervals) — but even then, document **why** the timeout value is what it is.

## Core Pattern

```typescript
// ❌ BEFORE — guessing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// ✅ AFTER — waiting for the actual condition
await waitFor(() => getResult() !== undefined, 'result to appear');
const result = getResult();
expect(result).toBeDefined();
```

## Quick Patterns

| Scenario | Pattern |
|---|---|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'), 'DONE event')` |
| Wait for state | `waitFor(() => machine.state === 'ready', 'machine ready')` |
| Wait for count | `waitFor(() => items.length >= 5, '5 items')` |
| Wait for file | `waitFor(() => fs.existsSync(path), \`file \${path}\`)` |
| Complex | `waitFor(() => obj.ready && obj.value > 10, 'obj ready and >10')` |

## Generic `waitFor` Implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000,
): Promise<T> {
  const start = Date.now();
  while (true) {
    const result = condition();
    if (result) return result as T;
    if (Date.now() - start > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }
    await new Promise(r => setTimeout(r, 10));
  }
}
```

Python equivalent:

```python
import time

def wait_for(condition, description, timeout=5.0, poll=0.01):
    start = time.time()
    while True:
        result = condition()
        if result:
            return result
        if time.time() - start > timeout:
            raise TimeoutError(f"Timeout waiting for {description} after {timeout}s")
        time.sleep(poll)
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| Polling every 1ms → wastes CPU | Poll every ~10ms |
| No timeout → hangs forever | Always include a timeout with a clear description |
| Caching the value outside the loop | Call the getter **inside** the condition closure |
| Vague description | Describe what you're waiting for so timeout errors are debuggable |

## When a Real Timeout IS Correct

Rarely, you genuinely need to wait a fixed duration:

```typescript
// Tool ticks every 100ms; we need 2 ticks to verify partial output.
await waitFor(() => toolStarted(), 'tool start');      // first: condition
await new Promise(r => setTimeout(r, 200));             // then: fixed (2 ticks)
// 200ms justified: known tick interval * 2
```

**Requirements whenever you use a fixed timeout:**
1. Wait for a triggering condition first
2. Base the duration on known timing (not a guess)
3. Comment explaining **why**

## Integration

**Pairs with:**
- `crucible:test-driven-development` (fixing flaky tests is part of the discipline)

## Remember

- Guess less, observe more
- Every arbitrary sleep is a latent race condition
- Poll every ~10ms, timeout at 5s by default, always describe what you're waiting for
