---
name: defense-in-depth
version: 1.0.0
description: Use after fixing a root-cause bug to add layered validation that makes the same bug structurally impossible to recur — pairs with root-cause-tracing
user-invocable: true
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: [area of code or data flow]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Defense-in-Depth Validation

After finding a root cause, adding one validation point feels sufficient. But that single check can be bypassed by different code paths, refactors, or mocks. Validate at **every layer** the data passes through — so the bug becomes structurally impossible, not just fixed.

**Announce at start:** "I'm using the defense-in-depth skill to make this bug impossible to recur."

## Why Multiple Layers

- Single validation: "we fixed the bug"
- Layered validation: "we made the bug impossible"

Different layers catch different cases:
- **Entry validation** catches most bugs at the system boundary
- **Business logic validation** catches edge cases and bad internal calls
- **Environment guards** prevent context-specific dangers (tests vs. prod)
- **Debug instrumentation** gives you forensics when other layers somehow fail

## The Four Layers

### Layer 1: Entry-Point Validation

Reject obviously invalid input at the API boundary.

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ...
}
```

### Layer 2: Business-Logic Validation

Ensure data makes sense **for this operation**, not just generally.

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) throw new Error('projectDir required for workspace init');
  if (!sessionId) throw new Error('sessionId required');
  // ...
}
```

### Layer 3: Environment Guards

Prevent dangerous operations in specific contexts (especially tests).

```typescript
async function gitInit(directory: string) {
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));
    if (!normalized.startsWith(tmpDir)) {
      throw new Error(`Refusing git init outside tmpdir during tests: ${directory}`);
    }
  }
  // ...
}
```

### Layer 4: Debug Instrumentation

Log enough context to reconstruct what happened when something does slip through.

```typescript
async function gitInit(directory: string) {
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack: new Error().stack,
  });
  // ...
}
```

## Applying the Pattern

After a root-cause fix:

1. **Trace the data flow.** Where did the bad value originate, and where was it used?
2. **Map every checkpoint** the data passes through.
3. **Add a validation at each layer** — Entry, Business, Environment, Debug.
4. **Try to bypass each layer individually.** If you can, Layer N+1 should catch it. Write a test for each.

## Example

**Bug:** Empty `projectDir` caused `git init` to run in the source tree.

**Data flow:**
1. Test setup returned `{ tempDir: '' }` before `beforeEach` ran
2. `Project.create(name, '')` accepted the empty value
3. `WorkspaceManager.createWorkspace('')` passed it through
4. `git init` ran in `process.cwd()` (the source directory)

**Four layers added:**
- Layer 1: `Project.create()` validates `workingDirectory` is non-empty, exists, and writable
- Layer 2: `WorkspaceManager` validates `projectDir` is not empty
- Layer 3: `WorktreeManager` refuses `git init` outside tmpdir when `NODE_ENV === 'test'`
- Layer 4: `logger.debug` + stack trace before every `git init`

**Result:** bug became structurally impossible. Tests that tried to trigger it surfaced clear validation errors pointing to the real cause.

## Red Flags

- "I fixed it in one place, we're done" → you fixed the symptom, not the system
- The fix is tightly tied to *how* the bad data was produced today — if someone changes the producer, the bug comes back
- No test attempts to bypass the first layer to prove the second catches it

## Integration

**Pairs with:**
- `crucible:root-cause-tracing` (find the source first, then harden the layers)
- `crucible:test-driven-development` (write a test per layer)

## Remember

- One validation = fix. Four validations = structural guarantee.
- Validate at every transition point: module boundary, context switch, subsystem entry
- Write a test that tries to reach each layer by bypassing the one before it
