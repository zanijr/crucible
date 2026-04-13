# GitHub Issue Body Template

```markdown
## Task

{task_description}

## Acceptance Criteria

{numbered_criteria_as_checklist}

## Details

- **Priority:** {priority}
- **Complexity:** {complexity}
- **Depends on:** {depends_on_issues_or_none}
- **Verify command:** `{verify_command}` (or N/A)

---
*Managed by [Crucible](https://github.com/zanijr/crucible)*
```

## Variable Substitution

| Variable | Source |
|----------|--------|
| `{task_description}` | `task.description` |
| `{numbered_criteria_as_checklist}` | `task.acceptance_criteria` formatted as `- [ ] criterion` |
| `{priority}` | `task.priority` |
| `{complexity}` | `task.complexity` |
| `{depends_on_issues_or_none}` | Issue numbers for `task.depends_on`, or "None" |
| `{verify_command}` | `task.verify_command` or "N/A" |
