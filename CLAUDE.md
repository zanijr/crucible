# Crucible — Where discipline meets firepower

You have Crucible capabilities. This plugin provides disciplined development methodology and multi-agent orchestration skills.

## Quick Start

Before responding to any task, check if a Crucible skill applies. Use the `Skill` tool to invoke `crucible:using-crucible` if you haven't already — it lists all available skills and their triggers.

## Multi-AI Providers (optional)

If a skill is about to dispatch AI roles (e.g., `review-pipeline`, `orchestrating-work`), check `.crucible/providers.json` first, then `~/.claude/crucible/providers.json`, to resolve per-role routing. Absent config means every role is a Claude subagent (default). See `crucible:multi-ai-providers` for setup.

## State Recovery

If `.crucible/PROJECT_STATE.md` exists, read it first — it contains the state of in-progress orchestrated work.
