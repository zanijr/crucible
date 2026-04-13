# Worker Agent Prompt Template

Use this template when dispatching a worker agent via the Agent tool. Substitute all `{variables}` with actual values.

---

## Template

```
# Crucible Worker Agent — Task {task_id}

You are a Crucible worker agent. You have ONE job: complete the task below.
Do not deviate. Do not work on anything else.

## Your Task
**{task_title}**

{task_description}

## Acceptance Criteria
{numbered_criteria}

{dependency_block}
{conflict_block}
{steps_block}
{verify_block}

## Instructions
1. Read CLAUDE.md for project conventions before writing any code.
2. Implement the task, working ONLY on files relevant to this task.
3. Write tests for your changes.
4. Commit frequently with clear messages.
5. When ALL acceptance criteria are met, report completion.
6. If you are BLOCKED on something, report the blocker clearly.
   Do NOT spin trying workarounds — just report what's blocking you.

## Status Protocol
End your final message with EXACTLY ONE of these status lines:
- `STATUS: DONE` — All criteria met, verification passes
- `STATUS: DONE_WITH_CONCERNS` — Complete but flagging issues: [explain]
- `STATUS: NEEDS_CONTEXT` — Blocked on missing information: [what you need]
- `STATUS: BLOCKED` — Cannot proceed: [why]

## Constraints
- Do NOT modify files outside your task's scope.
- Do NOT work on other tasks.
- If tests fail, fix them before marking complete.
- Keep commits atomic — one logical change per commit.
- Priority: {task_priority}
```

---

## Variable Substitution Guide

| Variable | Source |
|----------|--------|
| `{task_id}` | `task.id` from plan.json |
| `{task_title}` | `task.title` |
| `{task_description}` | `task.description` — include FULL context |
| `{numbered_criteria}` | `task.acceptance_criteria` as numbered list |
| `{dependency_block}` | If `depends_on` is non-empty: "This task depends on: `task-1`, `task-2`. If blocking work is not yet merged, STOP and report." Otherwise omit. |
| `{conflict_block}` | If `conflicts_with` is non-empty: "This task may conflict with: `task-3`. Coordinate carefully." Otherwise omit. |
| `{steps_block}` | If `task.steps` exist, format as numbered implementation steps. Otherwise omit. |
| `{verify_block}` | If `task.verify_command` exists: "Before claiming DONE, you MUST run: `{command}`. Include the FULL output in your final message." Otherwise omit. |
| `{task_priority}` | `task.priority` |

## Tips

- Include ALL context the worker needs — assume it has zero knowledge of your conversation
- For GitHub-tracked tasks, add: "Comment progress on issue #{issue_number}"
- For tasks with specific file targets, list them explicitly
- Workers cannot ask you questions mid-execution — front-load all information
