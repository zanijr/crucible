---
name: executing-plans
version: 1.0.0
description: Use when you have a written implementation plan to execute — loads plan, executes tasks in order, verifies each step, and handles failures
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [plan file path]
---

# Executing Plans

Load a plan, execute each task in order, verify as you go, and finish cleanly.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## When to Use

- A plan has been written (via `crucible:writing-plans`) and approved
- You're implementing tasks yourself (not dispatching to agents)
- For orchestrated multi-agent execution, use `crucible:orchestrating-work` instead

## Core Pattern

### Step 1: Load and Review Plan

1. Read the plan file
2. Review critically — identify any questions or concerns
3. If concerns: raise them with the user before starting
4. If no concerns: proceed

### Step 2: Execute Tasks

For each task in dependency order:

1. Mark as in_progress
2. Follow each step exactly as specified
3. Run verifications as specified in the task
4. If verification passes: mark as completed
5. If verification fails: fix the issue, re-verify

### Step 3: Verify Each Task

After completing a task, invoke `crucible:verification-before-completion`:
- Run the verify_command
- Check each acceptance criterion
- Only proceed to the next task if verification passes

### Step 4: Complete Development

After all tasks are completed and verified:
- Invoke `crucible:finishing-a-development-branch`
- Present options: merge, create PR, or keep branch

## When to Stop and Ask

**STOP executing immediately when:**
- Hit a blocker (missing dependency, instruction unclear)
- Plan has a critical gap
- Verification fails repeatedly (3+ times on same task)
- You don't understand an instruction

Ask for clarification rather than guessing.

## Common Mistakes

- Skipping verification between tasks → errors compound
- Guessing when instructions are unclear → wrong implementation
- Not following task order → dependency violations
- Marking tasks done without running verify_command → false completion
