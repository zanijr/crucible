---
name: subagent-driven-development
version: 1.0.0
description: Use when executing a plan in the current session with fresh subagents per task and code review between each task — different from executing-plans (which uses a separate session)
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [plan file path]
---

> Adapted from [obra/superpowers-skills](https://github.com/obra/superpowers-skills) (MIT © 2025 Jesse Vincent).

# Subagent-Driven Development

Execute a plan by dispatching a fresh subagent per task, with a code review subagent between each task. Fresh context per task + review gate = high quality, fast iteration, no context pollution.

**Announce at start:** "I'm using the subagent-driven-development skill to execute this plan."

## When to Use

- You have an approved plan (from `crucible:writing-plans`) and want to execute it **in the current session**
- Tasks are mostly independent — each can be done in a fresh context
- You want continuous progress with quality gates, without human-in-the-loop between each task
- Plan has well-defined, bite-sized tasks with acceptance criteria

## When NOT to Use

- Plan still needs revision → go back to `crucible:brainstorming` or `crucible:writing-plans`
- Tasks are tightly coupled (each depends on live state from the last) → execute manually
- You want a separate session for execution → use `crucible:executing-plans` instead
- You want parallel task execution (multiple tasks at once) → use `crucible:orchestrating-work`

## Comparison

| | subagent-driven-development | executing-plans | orchestrating-work |
|---|---|---|---|
| Session | Current session | New session | Current session |
| Context per task | Fresh subagent | Accumulated | Fresh agents |
| Parallelism | Sequential | Sequential | Parallel waves |
| Review cadence | After each task | Periodic | After each wave |
| Best for | Independent tasks, quality-first | Human checkpoints, long runs | Independent tasks, speed-first |

## The Process

### 1. Load the Plan

Read the plan file and create a TodoWrite list with every task.

### 2. Execute One Task

For the next todo, dispatch a **fresh general-purpose subagent**:

```
Agent (subagent_type: general-purpose):
  description: "Implement Task N: <task title>"
  prompt: |
    You are implementing Task N from <plan-file-path>.

    Read that task carefully. Your job is to:
    1. Implement exactly what the task specifies
    2. Write tests (follow TDD if the task says so — see crucible:test-driven-development)
    3. Verify the implementation works (run the tests)
    4. Commit your work with a meaningful message
    5. Report back

    Working directory: <project-root>

    Report back with: what you implemented, what you tested, test results,
    files changed, and any issues or deviations from the plan.
```

Wait for the subagent's report.

### 3. Capture SHAs for Review

Before the task: `git rev-parse HEAD` → `BASE_SHA`
After the task: `git rev-parse HEAD` → `HEAD_SHA`

### 4. Review the Work

Dispatch a **fresh code-reviewer subagent** (use Crucible's `crucible:review-pipeline` for heavyweight reviews, or a single-reviewer dispatch for light tasks):

```
Agent (subagent_type: reviewer):
  description: "Review Task N implementation"
  prompt: |
    Review the diff between <BASE_SHA>..<HEAD_SHA> against Task N in <plan-file>.

    What was implemented: <summary from step 2>
    Acceptance criteria from plan: <copy from plan>

    Return: Strengths, Issues (Critical / Important / Minor), Overall assessment.
    Do not make changes — only review.
```

### 5. Apply Feedback

- **Critical issues:** fix immediately with another implementation subagent.
- **Important issues:** fix before the next task.
- **Minor issues:** note them, decide at end of session.

Dispatch a fix subagent if needed:

```
Agent (subagent_type: general-purpose):
  description: "Fix review issues for Task N"
  prompt: |
    The code reviewer flagged these issues on Task N: <list>
    Fix each one and commit. Report back when done.
```

### 6. Mark Complete, Move On

- Mark the TodoWrite task `completed`
- Move to the next task and repeat steps 2–6

### 7. Final Review

After every task completes, dispatch one final reviewer to check the entire implementation against the full plan — catches cross-task drift.

### 8. Finish the Branch

Switch to `crucible:finishing-a-development-branch` to verify, present merge/PR options, and handle cleanup.

## Red Flags

- Skipping code review between tasks → bugs accumulate
- Proceeding with unfixed Critical issues → compound problems
- Dispatching multiple implementation subagents in parallel on the same branch → conflicts (use `crucible:orchestrating-work` with worktrees instead)
- Trying to "just fix it quickly" in the main agent → context pollution; dispatch a fix subagent instead

## Integration

**Pairs with:**
- `crucible:writing-plans` (creates the plan this executes)
- `crucible:review-pipeline` (for the review-between-tasks step)
- `crucible:test-driven-development` (subagents follow this for each task)

**Alternative to:**
- `crucible:executing-plans` (separate session)
- `crucible:orchestrating-work` (parallel waves)

## Remember

- Fresh subagent per task — never reuse a subagent's context
- Review between every task — not "at the end"
- Fix Critical before moving on
- Commit at the end of each task, not at the end of the plan
