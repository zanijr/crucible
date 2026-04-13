# Status Protocol

Every worker agent must end its final message with exactly one status line.

## Status Values

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `STATUS: DONE` | All acceptance criteria met, verification passes | Mark task done, proceed to next wave |
| `STATUS: DONE_WITH_CONCERNS` | Complete but flagging issues | Mark done, log concerns for review |
| `STATUS: NEEDS_CONTEXT` | Missing information to proceed | Provide context and re-dispatch (1 retry) |
| `STATUS: BLOCKED` | Cannot proceed due to external blocker | Mark blocked, log blocker, skip in dependency chain |

## Parsing

Search for `STATUS:` at the start of a line in the agent's final output. Extract the value after the colon.

If no STATUS line is found:
- Check if the agent produced any output at all
- If yes: treat as `STATUS: DONE_WITH_CONCERNS` (task may be complete but didn't follow protocol)
- If no: treat as failed, invoke self-healing

## Failure Classification

| Symptom | Classification | Action |
|---------|---------------|--------|
| No output at all | Agent crash | Re-dispatch with simplified prompt |
| Output but no STATUS | Protocol violation | Treat as DONE_WITH_CONCERNS, verify manually |
| STATUS: NEEDS_CONTEXT | Information gap | Fill context, re-dispatch once |
| STATUS: BLOCKED | External dependency | Mark blocked, continue other tasks |
| Agent error/exception | Tool failure | Check for environment issues, re-dispatch |
