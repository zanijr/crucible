---
name: orchestrating-work
version: 1.0.0
description: Use when complex work needs multiple agents — task decomposition, parallel dispatch via Agent tool, dependency management, wave-based execution, and progress tracking
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [goal or description of work]
---

# Orchestrating Work

Autonomous planner, builder, and learner. Take the user's goal, decompose it into tasks, dispatch parallel agents, handle failures, review results, and track what was learned.

**Announce at start:** "I'm using the orchestrating-work skill to coordinate this."

## When to Use

- User describes complex work with 3+ distinct tasks
- Work has natural parallelism (independent subtasks)
- Multiple files/components need simultaneous changes
- User says "build this", "orchestrate this", "have agents do this"

## The Iron Law

```
NEVER DISPATCH WITHOUT A PLAN. NEVER SKIP VERIFICATION.
```

## Core Workflow

### Phase 1: Decompose

Break work into discrete tasks. For each task define:
- **id**: Short identifier (e.g., `task-1`)
- **title**: What to build
- **description**: Full context — assume the worker knows nothing about your conversation
- **acceptance_criteria**: Specific, testable conditions (3-5 per task)
- **depends_on**: Task IDs that must complete first (empty array if independent)
- **priority**: `p0` (do first), `p1` (do soon), `p2` (do eventually)
- **complexity**: `mechanical` (clear specs, 1-2 files), `integration` (multi-file, some design), `architecture` (design decisions needed)
- **verify_command**: Command to verify completion (optional but recommended)

Write the plan to `.crucible/plan.json`:
```json
{
  "project": "project-name",
  "description": "What we're building",
  "status": "draft",
  "created_at": "ISO datetime",
  "updated_at": "ISO datetime",
  "tasks": [...]
}
```

Present the plan to the user. Do NOT proceed without approval.

### Phase 2: Approve

After user approves, update plan status to `"approved"`, then `"building"`.

### Phase 3: Dispatch Waves

Tasks execute in dependency waves:

1. **Wave 1**: All tasks where `depends_on` is empty — dispatch in parallel
2. **Wave 2**: Tasks whose dependencies all completed in Wave 1
3. **Wave N**: Continue until all tasks dispatched

For each task in a wave, dispatch using the **Agent tool**:
- Read `references/worker-prompt.md` for the worker prompt template
- Substitute task details into the template
- Dispatch ALL independent tasks in a single message (parallel Agent calls)
- Each agent works in isolation — include ALL context it needs in the prompt

**Worker dispatch is always Claude.** The single-writer invariant requires that only Claude subagents ever write files and commit. Do not route the `worker` role to Gemini or Codex — their CLIs run read-only.

#### Optional: Pre-flight advisor (multi-AI)

If `.crucible/providers.json` (or `~/.claude/crucible/providers.json`) sets `roles.worker_advisor` to `gemini` or `codex`, run a read-only advisor pass **before** each Claude worker dispatch.

**Pre-flight (required once per session):** Before the first Bash dispatch to Gemini/Codex, run the allow-list check from `crucible:multi-ai-providers` § "Pre-flight check". If the check fails, **skip the advisor pass silently** (omit `{advisor_block}`) and proceed with normal Claude worker dispatch — advisor failure must never block the worker. Surface the allow-list error once as a warning so the user can add the patterns for future sessions.

Advisor dispatch procedure:

1. For each task about to be dispatched, send the task's title, description, and acceptance criteria to the advisor CLI. Use the Bash invocation shape documented in `../review-pipeline/references/provider-dispatch.md`.
2. Capture the advisor's stdout (risks, unknowns, suggested approach).
3. Substitute it into the worker prompt template at the `{advisor_block}` placeholder (see `references/worker-prompt.md`). It appears in the final prompt as a `## Pre-flight advisor notes` section.
4. Then dispatch the Claude worker as normal.

If `worker_advisor` is unset or the advisor CLI fails (after retries per provider-dispatch.md), proceed without an advisor block — omit the placeholder entirely. Advisor failure is **never** a blocker for worker dispatch.

After each wave completes:
- Parse each agent's final STATUS line (see `references/status-protocol.md`)
- Update task status in `.crucible/plan.json`
- Update `.crucible/PROJECT_STATE.md` with current progress

### Phase 4: Handle Results

For each completed agent:

- **STATUS: DONE** → Mark task `"done"`, proceed to next wave
- **STATUS: DONE_WITH_CONCERNS** → Mark `"done"`, log concerns, continue
- **STATUS: NEEDS_CONTEXT** → Provide context and re-dispatch (1 retry)
- **STATUS: BLOCKED** → Mark `"blocked"`, log blocker, continue with other tasks

If a task fails (no STATUS line, error, or timeout):
- Invoke `crucible:self-healing` for failure analysis
- Re-dispatch with adapted prompt (up to 2 retries per task)

### Phase 5: Verify

After all tasks complete:
- Invoke `crucible:spec-verification` for each task
- Run any project-level verification (tests, build, lint)
- If verification fails, create fix tasks and re-dispatch

### Phase 6: Review

When all tasks pass verification:
- Invoke `crucible:review-pipeline` on the combined changes
- Present findings to user
- Fix critical issues if any

### Phase 7: Report

Summarize:
- Tasks completed vs. failed
- Retries and self-healing actions taken
- Review findings
- Suggested next steps

Update `.crucible/plan.json` status to `"done"`.

## GitHub Integration

If the project has a GitHub repo, invoke `crucible:github-integration` to:
- Create issues for each task
- Update labels as tasks progress
- Create PRs for completed work

## Progress Tracking

After every state change, invoke `crucible:progress-tracking` to:
- Update `.crucible/plan.json`
- Regenerate `.crucible/PROJECT_STATE.md`

## Key Rules

- **Be autonomous.** Plan, dispatch, fix, review, report. No permission needed between phases (except initial plan approval).
- **Be parallel.** Dispatch independent tasks simultaneously via multiple Agent tool calls in one message.
- **Be resilient.** Never stop at first failure. Analyze, adapt, retry.
- **Be verifiable.** Define acceptance criteria upfront and check them.
- **Be transparent.** Show the plan, show failures, show fixes, show results.

## Common Mistakes

- Dispatching without a plan → worker agents lack context, produce wrong output
- Sequential dispatch when tasks are independent → wastes time
- Skipping verification → broken code gets merged
- Not including full context in worker prompts → workers ask questions or guess wrong
- Ignoring STATUS: BLOCKED → cascading failures in dependent tasks
