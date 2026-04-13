# Failure Taxonomy

Use this classification tree to analyze failures before choosing a retry strategy.

## Level 1: Where did it fail?

### Agent-level failures (the agent itself had issues)

| Failure | Symptoms | Fix |
|---------|----------|-----|
| No output | Agent returned nothing, timeout | Simplify prompt, reduce scope |
| No STATUS line | Output exists but no protocol compliance | Add explicit STATUS instruction, treat as DONE_WITH_CONCERNS |
| Wrong task | Agent worked on something unrelated | Make task description more specific, add "DO NOT" constraints |
| Scope violation | Modified files outside task | List allowed files explicitly in prompt |
| Infinite loop | Agent retried same action repeatedly | Add "If X fails twice, STOP and report BLOCKED" |

### Code-level failures (the code produced was wrong)

| Failure | Symptoms | Fix |
|---------|----------|-----|
| Syntax error | Code doesn't parse/compile | Include language version, expected patterns |
| Wrong API | Used deprecated or wrong function | Provide correct API reference in prompt |
| Missing import | ReferenceError, ModuleNotFound | Include dependency list in prompt |
| Logic error | Tests fail, wrong behavior | Provide expected input/output examples |
| Type error | TypeScript/type checking fails | Include type definitions in prompt |

### Environment-level failures (the system had issues)

| Failure | Symptoms | Fix |
|---------|----------|-----|
| Missing dependency | npm install fails, import errors | Run dependency install before agent |
| Permission denied | File/network access blocked | Check permissions, run with correct user |
| Port in use | Server won't start | Kill existing process or use different port |
| Disk full | Write failures | Clean up, free space |
| Network timeout | API calls fail | Check connectivity, add retry logic |

### Design-level failures (the approach was wrong)

| Failure | Symptoms | Fix |
|---------|----------|-----|
| Wrong abstraction | Code works but is fundamentally overcomplicated | Redesign with simpler approach |
| Missing requirement | Implementation is correct but incomplete | Add missing acceptance criteria |
| Conflicting changes | Merge conflicts with parallel tasks | Sequence conflicting tasks |
| Wrong technology | Tool/library doesn't support needed feature | Switch to appropriate tool |

## Decision Tree

```
Failure occurred
├── Agent produced no output?
│   → Agent-level: simplify prompt, retry
├── Output exists but wrong?
│   ├── Wrong files modified?
│   │   → Scope violation: constrain prompt
│   ├── Tests fail?
│   │   ├── Syntax/import errors?
│   │   │   → Code-level: fix specific issue
│   │   └── Logic errors?
│   │       → Code-level: add examples to prompt
│   └── Right code but wrong place?
│       → Design-level: redesign task
├── Environment error?
│   → Environment-level: fix env, retry
└── 3+ retries on same issue?
    → Design-level: escalate to user
```
