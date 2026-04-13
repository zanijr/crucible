# Crucible

**Where discipline meets firepower.**

A Claude Code plugin that combines disciplined development methodology with multi-agent orchestration. Install it and every AI agent session gains structured workflows, parallel task execution, 5-specialist code reviews, and GitHub-integrated project management.

## Install

```bash
# Clone to your Claude Code plugins directory
git clone https://github.com/zanijr/crucible.git ~/.claude/crucible
```

## What You Get

### Methodology Skills (from Superpowers)

Disciplined workflows that prevent agents from cutting corners:

- **brainstorming** — Design-first exploration before any code
- **writing-plans** — Comprehensive task decomposition with acceptance criteria
- **executing-plans** — Structured implementation with verification checkpoints
- **test-driven-development** — RED-GREEN-REFACTOR enforcement
- **systematic-debugging** — 4-phase root cause analysis before fixes
- **verification-before-completion** — Evidence-based completion claims
- **using-git-worktrees** — Isolated workspaces for parallel work
- **finishing-a-development-branch** — Clean branch completion and cleanup

### Orchestration Skills (from Forge)

Multi-agent coordination that scales complex work:

- **orchestrating-work** — Decompose goals into tasks, dispatch parallel agents, manage dependencies
- **review-pipeline** — 5 specialist reviewers in parallel (security, quality, waste, tests, performance)
- **spec-verification** — Verify implementations against acceptance criteria
- **github-integration** — Tasks as GitHub issues with labels, branches, and PRs
- **self-healing** — Failure analysis, adaptive retry, lesson recording
- **progress-tracking** — Persistent state that survives session compaction

### Meta Skills

- **using-crucible** — Bootstrap skill, loaded every session
- **writing-skills** — Create new Crucible skills

## How It Works

Skills auto-trigger based on context. When you describe complex work, the agent automatically:

1. **Brainstorms** — Explores requirements and alternatives
2. **Plans** — Decomposes into tasks with acceptance criteria
3. **Orchestrates** — Dispatches parallel agents for independent tasks
4. **Verifies** — Checks each task against its spec
5. **Reviews** — Runs 5-specialist code review pipeline
6. **Reports** — Produces a severity-ranked checklist

No commands needed. The agent decides when each skill applies.

## Project State

Crucible maintains state in `.crucible/` per project:

- `plan.json` — Task states, dependencies, acceptance criteria
- `PROJECT_STATE.md` — Human-readable state (survives compaction)
- `REVIEW_CHECKLIST.md` — Generated review findings
- `memory/` — Lessons learned and failure logs

## Credits

Crucible combines ideas from:

- [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent — disciplined development methodology
- [Forge](https://github.com/zbonham/forge) — multi-agent orchestration engine

## License

MIT
