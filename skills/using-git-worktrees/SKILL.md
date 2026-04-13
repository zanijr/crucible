---
name: using-git-worktrees
version: 1.0.0
description: Use when you need isolated workspaces for parallel development — creates git worktrees so multiple agents or tasks can work simultaneously without conflicts
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [branch name]
---

# Using Git Worktrees

Git worktrees let you check out multiple branches simultaneously in separate directories. Essential for parallel agent work where multiple tasks run at the same time.

## When to Use

- Dispatching multiple agents that will edit code simultaneously
- Need to work on a feature without disrupting the main branch
- Testing changes in isolation before merging

## Core Pattern

### Create a Worktree

```bash
# Create a new worktree with a new branch
git worktree add ../project-task-1 -b task-1

# Or from an existing branch
git worktree add ../project-task-1 task-1
```

### Verify Baseline

Before starting work in a worktree:

```bash
cd ../project-task-1
npm install  # or equivalent dependency install
npm test     # verify baseline tests pass
```

If baseline tests fail, the worktree has issues — fix before proceeding.

### Work in Isolation

Each agent/task works in its own worktree. Changes don't affect other worktrees or the main checkout.

### Clean Up

After merging or completing work:

```bash
git worktree remove ../project-task-1
```

Or if the branch was already merged:

```bash
git worktree remove ../project-task-1 --force
git branch -d task-1
```

### List Active Worktrees

```bash
git worktree list
```

## Key Rules

- Always verify baseline tests pass in new worktrees before starting work
- Install dependencies in each worktree (node_modules aren't shared)
- Clean up worktrees after work is complete or merged
- Don't work in a worktree that another agent is using

## Common Mistakes

- Forgetting to install dependencies → import errors
- Not verifying baseline → blaming your changes for pre-existing failures
- Leaving stale worktrees → confusing directory clutter
- Editing the same worktree from multiple agents → conflicts
