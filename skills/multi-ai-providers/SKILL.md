---
name: multi-ai-providers
version: 1.0.0
description: Use when setting up or configuring Crucible to route specific roles (reviewers, worker advisor) to Codex or Gemini instead of Claude subagents — explains providers.json, allow-list setup, verification, and troubleshooting
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [setup | verify | troubleshoot]
---

# Multi-AI Providers

Crucible defaults to dispatching every role to Claude subagents. This skill lets you optionally route individual roles to Gemini CLI or Codex CLI — for diverse review perspectives, second opinions, or pre-flight advice — while keeping Claude as the only writer.

**Announce at start:** "I'm using the multi-ai-providers skill to configure external AI providers for Crucible."

## When to Use

- First-time setup of Gemini or Codex as a Crucible provider
- Changing which role(s) route to which provider
- Verifying that external CLIs are installed and reachable
- Troubleshooting "dispatch fell back to Claude" or "Bash permission denied" errors

## The Iron Law

```
CLAUDE IS THE ONLY WRITER. EXTERNAL CLIS ARE ALWAYS READ-ONLY.
```

Gemini runs with `--approval-mode default`. Codex runs with `--sandbox read-only`. Never strip these flags.

## Concept

Crucible's two dispatching skills (`review-pipeline`, `orchestrating-work`) resolve each role against a config file before dispatching. See `../review-pipeline/references/provider-dispatch.md` for the full rules.

- **No config file exists** → every role is Claude. Identical to v1.0.0.
- **Config routes `security` to `gemini`** → review-pipeline sends the security prompt to Gemini CLI via Bash, keeps the other 4 reviewers on Claude.
- **Config routes `worker_advisor` to `codex`** → orchestrating-work asks Codex for read-only pre-flight notes on each task, then Claude writes the code.

Worker dispatch itself is **always** Claude — routing `worker` to anything else is ignored.

## Roles You Can Route

| Role | Used by | Purpose |
|------|---------|---------|
| `security` | review-pipeline | Security reviewer |
| `quality` | review-pipeline | Code quality reviewer |
| `waste` | review-pipeline | Over-engineering / dependency bloat reviewer |
| `tests` | review-pipeline | Test coverage/quality reviewer |
| `performance` | review-pipeline | Performance reviewer |
| `worker_advisor` | orchestrating-work | Read-only pre-flight advice before Claude workers run |
| `worker` | orchestrating-work | **Always Claude.** Config ignored if set otherwise. |

## Pre-flight check (REQUIRED before any external-CLI dispatch)

Before routing any role to a non-Claude provider, verify the allow-list is in place. This skill MUST run the following check the first time it is invoked in a session, and whenever `review-pipeline` or `orchestrating-work` is about to dispatch to Gemini/Codex for the first time in a session.

### The check

Claude Code merges `permissions.allow` from multiple files. The check MUST scan **all** that exist, and pass if the patterns appear in **any** of them (union semantics match Claude Code's own behavior):

1. `~/.claude/settings.json` — user-level
2. `~/.claude/settings.local.json` — user-level, machine-specific
3. `./.claude/settings.json` — project-level, shared
4. `./.claude/settings.local.json` — project-level, gitignored

Procedure:

1. For each of the 4 paths that exists, read it. Parse as JSON (fallback: grep the raw text for the two patterns).
2. Collect the union of every `permissions.allow` array found.
3. Verify the union contains **both**:
   - `"Bash(gemini:*)"`
   - `"Bash(codex:*)"`
4. If either is missing, **halt the dispatch** and emit the following error verbatim to the user (substitute the files actually scanned into the message):

```
Multi-AI dispatch halted: allow-list patterns are missing.

Scanned: <comma-separated list of existing settings files>
Missing: <"Bash(gemini:*)" and/or "Bash(codex:*)">

Add the missing entries to the "permissions.allow" array in one of those files
(recommended: ~/.claude/settings.local.json — user-level, machine-specific) and retry:

  "Bash(gemini:*)",
  "Bash(codex:*)"

Without them, every CLI dispatch (up to 6 per pipeline) prompts for manual approval, breaking parallel execution. See issue #11 for rationale.
```

5. Do not offer to edit the settings files automatically — users must own their permission configuration.

A runnable reference implementation lives at `tests/regression-allow-list-check.sh` — use it as the source of truth when in doubt about edge cases (comments in JSON, trailing commas, `deny` overrides).

### Why halt instead of continue-with-prompts

Letting a 5-reviewer parallel dispatch proceed with a missing allow-list causes five sequential approval prompts that block the parent session. The pipeline appears to hang. Halting early with a clear error is strictly less confusing than the alternative.

### When the check passes

Cache the result for the session — don't re-check before every dispatch. Subsequent dispatches in the same session skip straight to dispatch.

## Setup (first time)

### Step 1: Verify the CLIs are installed

```bash
gemini --version
codex --version
```

Expected: Gemini `0.37.2+`, Codex `0.120.0+`. If either is missing:

- **Gemini:** `npm install -g @google/gemini-cli`
- **Codex:** `npm install -g @openai/codex-cli`

Both install to `%APPDATA%\npm\` on Windows (`~/.npm-global/bin/` on Unix). Make sure that directory is on `PATH`.

### Step 2: Add allow patterns to settings.local.json

Open `~/.claude/settings.local.json`. Ensure the `permissions.allow` array contains:

```json
"Bash(gemini:*)",
"Bash(codex:*)"
```

Without these, every Crucible dispatch to an external CLI prompts for manual approval. With them, dispatch is frictionless.

### Step 3: Create a providers.json

Start with per-project scope to try it out. In your project root:

```bash
mkdir -p .crucible
```

Copy `references/providers.example.json` to `.crucible/providers.json` and edit the `roles` block to suit your preferences.

Once you're happy with the config, copy it to `~/.claude/crucible/providers.json` to apply as a global default across all projects. Per-project configs override the global.

## Verify Setup

Run this smoke test in a throwaway scratch repo:

1. **Create a minimal config** (`.crucible/providers.json`):
   ```json
   { "roles": { "security": "gemini" } }
   ```

2. **Make a trivial change** (add an unused variable `const unused = 1;` to any source file).

3. **Invoke the review-pipeline skill** on the branch.

4. **Check results:**
   - `.crucible/reviews/security.json` — should contain Gemini's JSON findings (Gemini often includes a distinctive "Gemini" or model signature in malformed-output cases, but valid JSON looks the same as Claude's).
   - `.crucible/reviews/quality.json`, `waste.json`, `tests.json`, `performance.json` — populated by Claude subagents.
   - `.crucible/REVIEW_CHECKLIST.md` — merged output from all 5.
   - `git status` — no files written by Gemini/Codex (verify via git blame on any new lines).

5. **Fallback test:** Temporarily break Gemini (set `GEMINI_API_KEY=bogus` or use a bad model flag). Re-run review-pipeline. Expected: 2 retries, then automatic fallback to Claude for the security role. Review still completes.

## Troubleshooting

### "Bash permission denied" on every dispatch

Missing allow patterns in `~/.claude/settings.local.json`. See Setup Step 2.

### Gemini shows "deprecated experimental.plan setting" warning

Non-blocking — Gemini still works. To silence, edit `~/.gemini/settings.json` and remove the `experimental.plan` key.

### CLI returns non-JSON for reviewer roles

Check `.crucible/reviews/<role>.raw.txt` — Crucible writes raw stdout there when JSON parsing fails. Common causes:
- Gemini added a preamble/postamble despite prompt saying "JSON only" — usually resolved by re-running.
- Codex output was truncated by sandbox policy — verify with `codex exec --sandbox read-only --help` that read-only flag syntax hasn't changed.
- Model ID pinned in config no longer exists — update `cli.<provider>.command_prefix`.

### Advisor output appears empty in worker prompt

If `{advisor_block}` is omitted from the worker prompt, it means either:
- `roles.worker_advisor` is not set in providers.json
- The advisor CLI failed all retries and fallback rules omit the block
- The advisor returned empty stdout

Check `.crucible/PROJECT_STATE.md` for fallback log entries.

### Fallback to Claude keeps happening for a specific role

Check the raw output file (e.g., `.crucible/reviews/security.raw.txt`). Common fixes:
- Update `cli.<provider>.timeout_ms` if the CLI is slow
- Update the model ID if pinned version is retired
- Verify the CLI runs standalone at a terminal with the exact command in `command_prefix`

## Key Rules

- **Don't strip read-only flags.** Removing `--sandbox read-only` (Codex) or `--approval-mode default` (Gemini) violates the single-writer invariant.
- **Don't route `worker` to non-Claude.** orchestrating-work ignores it. Use `worker_advisor` for multi-AI input on tasks.
- **Don't hand-edit CLI output.** Dedup and filtering in review-pipeline assume every finding came from the declared schema. Re-run if output is malformed.
- **Don't commit `.crucible/` to git.** It's per-session state — add to `.gitignore`.

## Common Mistakes

- Skipping Step 2 (allow patterns) → every dispatch prompts for manual approval, completely defeating frictionless operation
- Setting `roles.worker: "gemini"` → silently ignored, but suggests you misunderstood the single-writer invariant
- Putting providers.json in `.claude/` instead of `.crucible/` → Crucible doesn't look there; config silently ineffective
- Model ID drift → pin via `cli.<provider>.command_prefix` in providers.json; don't rely on CLI defaults
