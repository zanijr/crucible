# Crucible

**Where discipline meets firepower.**

A Claude Code plugin that combines disciplined development methodology with multi-agent orchestration. Install it and every AI agent session gains structured workflows, parallel task execution, 5-specialist code reviews, and GitHub-integrated project management.

## Install

```bash
# Clone to your Claude Code plugins directory
git clone https://github.com/zanijr/crucible.git ~/.claude/crucible
```

### If you plan to use multi-AI (Gemini / Codex)

> **Required one-time step — skipping this makes every external-CLI dispatch prompt for manual approval.**

Add these two entries to the `permissions.allow` array in `~/.claude/settings.local.json`:

```json
"Bash(gemini:*)",
"Bash(codex:*)"
```

The `multi-ai-providers` skill auto-detects a missing allow-list when you first route a role to an external CLI and surfaces an explicit error with this same command. Default-Claude users can ignore this step entirely.

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

## Multi-AI (optional)

By default, every dispatched role runs on a Claude subagent. Crucible also supports routing individual roles to **Gemini CLI** or **Codex CLI** for diverse review perspectives and pre-flight advice:

- Create `.crucible/providers.json` (per-project) or `~/.claude/crucible/providers.json` (global) declaring which provider runs each role — for example, `security` on Gemini, `performance` on Codex, everything else on Claude.
- External CLIs always run read-only (`--sandbox read-only` / `--approval-mode default`). **Only Claude subagents ever write files** — single-writer invariant preserved.
- If a CLI fails after retries, the role automatically falls back to Claude. The pipeline never stalls on a flaky external provider.
- `worker_advisor` role can feed read-only pre-flight notes from Gemini/Codex into each Claude worker prompt before code is written.

Without a `providers.json`, behavior is identical to v1.0.0. See the `multi-ai-providers` skill for setup, verification, and troubleshooting.

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
