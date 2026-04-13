---
name: using-crucible
version: 1.0.0
description: Use when starting any conversation — establishes how to find and use Crucible skills, requiring skill invocation before ANY response including clarifying questions
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: ""
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Using Crucible

Crucible combines disciplined development methodology with multi-agent orchestration. Every skill below is mandatory when its trigger condition matches.

## Instruction Priority

1. **User's explicit instructions** (CLAUDE.md, direct requests) — highest priority
2. **Crucible skills** — override default system behavior
3. **Default system prompt** — lowest priority

## How to Access Skills

Use the `Skill` tool to invoke skills by name. When invoked, the skill content is loaded — follow it directly. Never use the Read tool on skill files.

## Available Skills

### Methodology Skills (HOW to work)

| Skill | Trigger |
|-------|---------|
| `crucible:brainstorming` | New project, feature idea, or design decision — BEFORE writing any code |
| `crucible:writing-plans` | Have a spec or requirements for multi-step work — BEFORE touching code |
| `crucible:executing-plans` | Have a written plan ready to implement |
| `crucible:test-driven-development` | Implementing any feature or bugfix — BEFORE writing implementation code |
| `crucible:systematic-debugging` | Something is broken or failing — BEFORE proposing fixes |
| `crucible:verification-before-completion` | About to claim work is complete — BEFORE committing or creating PRs |
| `crucible:using-git-worktrees` | Need isolated workspace for parallel development |
| `crucible:finishing-a-development-branch` | Development complete, ready to merge/PR |
| `crucible:writing-skills` | Creating a new Crucible skill |

### Orchestration Skills (WHAT to coordinate)

| Skill | Trigger |
|-------|---------|
| `crucible:orchestrating-work` | Complex work needing multiple agents — task decomposition, parallel dispatch, dependency management |
| `crucible:review-pipeline` | Code complete, needs thorough review — dispatches 5 specialist reviewers in parallel |
| `crucible:spec-verification` | Task claims complete — verify implementation against acceptance criteria |
| `crucible:github-integration` | Tracked project work — tasks as GitHub issues, labels, branches, PRs |
| `crucible:self-healing` | Agent or task failed — failure analysis, adaptive retry, lesson recording |
| `crucible:progress-tracking` | Managing multi-task work — state persistence, compaction recovery |

## Skill Priority

When multiple skills could apply:

1. **Process skills first** (brainstorming, debugging) — determine HOW to approach
2. **Orchestration skills second** (orchestrating-work, review-pipeline) — coordinate WHAT to do
3. **Implementation skills last** (TDD, executing-plans) — guide execution

"Build X for me" → brainstorming first, then orchestrating-work, then TDD during execution.
"Fix this bug" → systematic-debugging first, then TDD for the fix.
"Review this code" → review-pipeline.

## Skill Types

**Rigid** (TDD, debugging, verification): Follow exactly. Don't adapt away discipline.
**Flexible** (brainstorming, orchestrating-work): Adapt principles to context.

The skill itself tells you which.

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I can do this without a skill" | Skills prevent the mistakes you don't see coming. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "This doesn't need orchestration" | If it has 3+ tasks, it does. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "I know what that skill says" | Skills evolve. Read current version. |

## State Recovery

If this session has compacted or restarted, check for `.crucible/PROJECT_STATE.md` — it contains the full state of any in-progress work. Read it before proceeding.
