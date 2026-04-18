# Crucible

**Where discipline meets firepower.**

A Claude Code plugin that combines disciplined development methodology with multi-agent orchestration. Install it and every AI agent session gains structured workflows, parallel task execution, 5-specialist code reviews, and GitHub-integrated project management.

## Install

One command, idempotent, safe to rerun for updates:

```bash
git clone https://github.com/zanijr/crucible.git ~/.claude/crucible \
  && bash ~/.claude/crucible/scripts/install.sh
```

The install script:
1. Clones (or pulls if already installed) to `~/.claude/crucible`
2. Auto-detects the Gemini / Codex CLIs on your `PATH` and, if present, merges `Bash(gemini:*)` and `Bash(codex:*)` into `permissions.allow` in `~/.claude/settings.local.json` (existing keys preserved, JSON-aware — no clobber)
3. Reports the final state so you can verify

Then **restart Claude Code** to pick up the new skill definitions.

### Flags

- `--no-cli` — skip the allow-list setup (pure-Claude install; use this if you'll never route roles to Gemini/Codex)
- `--force-cli` — add the allow-list even if the CLIs aren't installed yet (useful if you plan to install them later)

### Updating

Rerun the same script — it does a `git pull --ff-only` and re-verifies the allow-list.

```bash
bash ~/.claude/crucible/scripts/install.sh
```

### Multi-AI CLIs (optional)

If you want Gemini or Codex as review/advisor providers, install their CLIs separately:

```bash
npm install -g @google/gemini-cli @openai/codex-cli
```

Then rerun `scripts/install.sh` — it will detect them and add the allow-list entries.

> If the install script can't write to `~/.claude/settings.local.json` (no `python3` or `node` available), it tells you exactly which patterns to add manually. The `multi-ai-providers` skill also runs a pre-flight check at dispatch time and halts with an actionable error if the patterns are missing.

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


## License

MIT
