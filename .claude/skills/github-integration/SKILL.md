---
name: github-integration
version: 1.0.0
description: Use when working on a tracked project with a GitHub repo — creates issues for tasks, manages labels, creates branches, and links PRs back to issues
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [setup or sync]
---

# GitHub Integration

Turn Crucible tasks into GitHub issues with labels, branches, and linked PRs. The GitHub issue becomes the single source of truth for each task's status.

**Announce at start:** "I'm using the github-integration skill to sync with GitHub."

## When to Use

- Starting orchestrated work on a GitHub-hosted project
- Need to track tasks as GitHub issues
- Creating branches and PRs for completed work
- Updating issue status as tasks progress

## Core Pattern

### Setup: Create Labels

On first use in a repo, create Crucible labels. See `references/label-schema.md` for the full set.

```bash
gh label create "crucible:todo" --color "0e8a16" --description "Ready for an agent" --force
gh label create "crucible:in-progress" --color "fbca04" --description "Agent working on it" --force
gh label create "crucible:blocked" --color "d93f0b" --description "Waiting on dependency" --force
gh label create "crucible:review" --color "1d76db" --description "Code complete, needs review" --force
gh label create "crucible:done" --color "6f42c1" --description "Merged and closed" --force
gh label create "crucible:critical" --color "b60205" --description "Review found critical issue" --force
gh label create "priority:p0" --color "b60205" --description "Do first" --force
gh label create "priority:p1" --color "d93f0b" --description "Do soon" --force
gh label create "priority:p2" --color "fbca04" --description "Do eventually" --force
```

### Create Issues for Tasks

For each task in the plan, create a GitHub issue. See `references/issue-template.md` for the body format.

```bash
gh issue create \
  --title "{task_title}" \
  --body "{issue_body}" \
  --label "crucible:todo,priority:{priority}"
```

Save the issue number to `task.issue_number` in plan.json.

### Update Labels as Tasks Progress

| Task Status | Label Change |
|-------------|-------------|
| `todo` → `in-progress` | Remove `crucible:todo`, add `crucible:in-progress` |
| `in-progress` → `review` | Remove `crucible:in-progress`, add `crucible:review` |
| `review` → `done` | Remove `crucible:review`, add `crucible:done`, close issue |
| Any → `blocked` | Add `crucible:blocked` |
| Any → `failed` | Add `crucible:critical` |

```bash
gh issue edit {issue_number} --remove-label "crucible:todo" --add-label "crucible:in-progress"
```

### Comment Progress

When a task makes progress:
```bash
gh issue comment {issue_number} --body "Progress: completed criterion X. (2/5 done)"
```

When a task completes:
```bash
gh issue comment {issue_number} --body "Task complete. All acceptance criteria met."
gh issue close {issue_number}
```

### Create PRs

After work is complete:
```bash
gh pr create --base main --title "feat: {task_title}" --body "Closes #{issue_number}"
```

## Common Mistakes

- Creating issues without acceptance criteria in the body → reviewers lack context
- Not updating labels → GitHub board becomes stale
- Creating PRs that don't reference issues → no audit trail
- Using generic labels instead of crucible-namespaced ones → conflicts with other tools
