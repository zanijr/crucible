---
name: progress-tracking
version: 1.0.0
description: Use when managing multi-task work — maintains plan.json state, generates PROJECT_STATE.md for compaction recovery, and provides status summaries
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [status or update]
---

# Progress Tracking

Maintain persistent state for orchestrated work. Every state change gets recorded in plan.json and summarized in PROJECT_STATE.md so work survives session compaction and restarts.

**Announce at start:** "I'm using the progress-tracking skill to update project state."

## When to Use

- After any task status change (started, completed, failed, blocked)
- After dispatching a wave of agents
- After review pipeline completes
- When user asks for status
- At the start of a session (check for existing state)

## Core Pattern

### Reading State

On session start, check for existing state:

```bash
cat .crucible/plan.json 2>/dev/null
cat .crucible/PROJECT_STATE.md 2>/dev/null
```

If state exists, report current status before proceeding.

### Updating plan.json

After any task status change, update `.crucible/plan.json`:
- Set `task.status` to the new value
- Set `updated_at` to current ISO timestamp
- Update `plan.status` if all tasks are done/failed

### Generating PROJECT_STATE.md

After every update to plan.json, regenerate `.crucible/PROJECT_STATE.md`:

```markdown
# Crucible Project State

**Project:** {project_name}
**Status:** {plan_status}
**Updated:** {timestamp}

## Summary
{total} tasks: {done} done, {in_progress} in progress, {blocked} blocked, {failed} failed, {todo} remaining

## Tasks

### Done
- [x] {task_title} (#{issue_number})

### In Progress
- [ ] {task_title} — assigned, working
  - Depends on: {deps}

### Blocked
- [ ] {task_title} — blocked on: {reason}

### Remaining
- [ ] {task_title} (priority: {priority})
  - Depends on: {deps}

## Recent Activity
- {timestamp}: Task "{title}" completed
- {timestamp}: Task "{title}" dispatched to agent

## Next Steps
{what_should_happen_next}
```

This file is the **compaction recovery document**. When a session compacts, the bootstrap hook restores it. An agent reading this file should be able to pick up exactly where work left off.

### Status Summary

When asked for status, format as:

```
Project: {name} [{status}]
━━━━━━━━━━━━━━━━━━━━━━━━━
✓ {done_count} done
▶ {progress_count} in progress
✕ {blocked_count} blocked
○ {remaining_count} remaining

{details for in-progress and blocked tasks}
```

## Key Rules

- Update state AFTER every change, not in batches
- PROJECT_STATE.md must be self-contained — no references to conversation context
- Always include "Next Steps" — this guides the agent after compaction
- Keep the file under 500 lines — prune completed task details if needed

## Common Mistakes

- Updating plan.json but not PROJECT_STATE.md → compaction loses context
- Batching updates → intermediate states lost on crash
- Including conversation context in PROJECT_STATE.md → doesn't survive compaction
- Not including next steps → agent after compaction doesn't know what to do
