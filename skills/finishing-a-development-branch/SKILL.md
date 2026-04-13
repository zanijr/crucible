---
name: finishing-a-development-branch
version: 1.0.0
description: Use when development is complete on a branch — runs final verification, presents merge/PR options, handles cleanup
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [branch name or "current"]
---

# Finishing a Development Branch

Clean completion of a development branch: verify everything works, present options, execute the user's choice, clean up.

## When to Use

- All tasks on a branch are complete and verified
- Ready to merge or create a PR
- After `crucible:executing-plans` or `crucible:orchestrating-work` completes

## Core Pattern

### Step 1: Final Verification

Run ALL verification:

```bash
# Check for uncommitted changes
git status

# Run full test suite
npm test  # or equivalent

# Run build
npm run build  # if applicable

# Run linter
npm run lint  # if applicable
```

ALL must pass. If anything fails, fix it before proceeding.

### Step 2: Present Options

Present these options to the user:

1. **Merge to main** — `git checkout main && git merge {branch}`
2. **Create PR** — `gh pr create --base main --title "..." --body "..."`
3. **Keep branch** — Leave it for manual review
4. **Squash merge** — `git checkout main && git merge --squash {branch}`

### Step 3: Execute Choice

Execute the user's chosen option.

If creating a PR, include:
- Summary of changes
- Tasks completed (with issue references if using GitHub integration)
- Test results
- Review checklist link (if review-pipeline was run)

### Step 4: Clean Up

After merge or PR creation:

```bash
# Remove worktree if applicable
git worktree remove ../project-{branch} 2>/dev/null

# Delete local branch (if merged)
git branch -d {branch}
```

## Common Mistakes

- Merging without running the full test suite → broken main
- Not cleaning up worktrees → stale directories pile up
- Creating a PR without a summary → reviewer has no context
- Force-merging when tests fail → defeats the purpose
