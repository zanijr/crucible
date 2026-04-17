---
name: root-cause-tracing
version: 1.0.0
description: Use when an error appears deep in the call stack and you need to trace back to the original trigger — complements systematic-debugging with a specific "fix at the source, not the symptom" method
user-invocable: true
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: [error or symptom description]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Root Cause Tracing

Bugs often surface deep in the call stack (`git init` in the wrong directory, file created in the wrong place, DB opened with the wrong path). The instinct is to fix where the error appears — but that's patching a symptom. Trace backward until you find the original trigger, then fix at the source.

**Announce at start:** "I'm using the root-cause-tracing skill to find the source of this bug."

## When to Use

- Error appears deep in execution (not at an entry point)
- Stack trace shows a long call chain
- Unclear where an invalid value originated
- "The error is in module X, but X is getting bad data from somewhere"

## The Process

### 1. Observe the Symptom

Capture the actual error — full message, stack trace, failing test name.

### 2. Find the Immediate Cause

What line of code directly produces the error? Not "which module" — which **line**.

### 3. Ask: Who Called This?

Walk up the stack one frame at a time. Write down the chain:

```
gitInit(projectDir='')            ← where error surfaces
  ← WorktreeManager.create(projectDir='')
    ← Session.initializeWorkspace(projectDir='')
      ← Session.create(projectDir='')
        ← test at line 42
```

### 4. Keep Tracing Up

At each level, ask: **what value was passed in?** When you find the bad value, ask: **where did that value come from?**

```
Empty string as `cwd` to `execFileAsync` → resolves to `process.cwd()`
  → which is the source tree during tests
  → that's why .git landed in the wrong place
```

### 5. Find the Original Trigger

Keep walking until you hit the **source** of the bad value — the place a human or external input introduced it. Stop walking when the answer is "this came from outside the system."

### 6. Fix At the Source

Fix the bug where the bad value is **produced**, not where it's **consumed**.

Then — see `crucible:defense-in-depth` — add validation at each layer on the way down so this bug is structurally impossible.

## When You Can't Trace Manually

Add stack-trace instrumentation before the dangerous operation:

```javascript
async function gitInit(directory) {
  console.error('DEBUG git init', {
    directory,
    cwd: process.cwd(),
    stack: new Error().stack,
  });
  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**In tests,** use `console.error` — logger output is often suppressed.

Then run the failing scenario and capture the stack:

```bash
npm test 2>&1 | grep 'DEBUG git init'
```

## Bisection: Finding Which Test Causes Pollution

If something appears during tests but you don't know which test:

```bash
# Run tests one at a time until pollution appears
for test in tests/**/*.test.ts; do
  rm -rf .test-artifact
  npm test "$test"
  if [ -e .test-artifact ]; then
    echo "Polluter: $test"
    break
  fi
done
```

## Red Flags You're Fixing the Symptom

- "I'll just add a check here to handle the bad value" → no, trace up
- "It's not really a bug, I'll catch the exception" → the caller is broken
- The fix is in a module different from where the bad data originated
- You don't know **why** the bad value was passed — you just know it was

## Integration

**Pairs with:**
- `crucible:systematic-debugging` (general 4-phase debug methodology)
- `crucible:defense-in-depth` (after finding root cause, add layered validation)

## Remember

- The symptom site is almost never the right place to fix
- Trace backward one frame at a time — don't skip
- Instrument with `console.error` + `new Error().stack` when tracing stalls
- After fixing the source, add defense-in-depth so the bug can't recur
