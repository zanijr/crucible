---
name: review-pipeline
version: 1.0.0
description: Use when code is complete and needs thorough review — dispatches 5 specialist reviewers in parallel (security, quality, waste, tests, performance) and produces a severity-ranked checklist
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
argument-hint: [branch name or "current"]
---

# Review Pipeline

Dispatch 5 specialist review agents in parallel. Each examines the code from a different angle. Collect findings, deduplicate, filter by confidence, and produce a severity-ranked checklist.

**Announce at start:** "I'm using the review-pipeline skill to run a 5-agent code review."

## When to Use

- After completing a feature build or orchestrated work
- Before creating a PR
- User asks for a thorough code review
- After fixing critical issues from a previous review

## The Iron Law

```
NO MERGE WITHOUT REVIEW. NO REVIEW WITHOUT ALL 5 SPECIALISTS.
```

## Core Pattern

### Step 1: Determine Scope

Identify the branch and changed files:
```bash
git diff main...HEAD --name-only
```

If on `main`, use the most recent set of commits instead.

### Step 1.5: Resolve Providers

For each of the 5 reviewer roles (`security`, `quality`, `waste`, `tests`, `performance`), resolve which AI provider to use. See `references/provider-dispatch.md` for the resolution rules.

Summary: check `.crucible/providers.json`, fall back to `~/.claude/crucible/providers.json`, fall back to `claude`. If no config exists, every role is `claude` — identical to v1.0.0 behavior.

### Step 2: Dispatch 5 Reviewers in Parallel

Send **5 dispatch calls in a single message** — one per reviewer type. Each reviewer may target Claude (via `Agent` tool), Gemini (via `Bash` tool), or Codex (via `Bash` tool) depending on the resolved provider. See `references/provider-dispatch.md` for the exact invocation shape per provider.

| Reviewer | Prompt File | Focus |
|----------|-------------|-------|
| Security | `references/security-reviewer.md` | Injection, auth bypass, secrets, input validation |
| Quality | `references/quality-reviewer.md` | Complexity, duplication, naming, architecture |
| Waste | `references/waste-reviewer.md` | Over-engineering, premature abstraction, unnecessary deps |
| Tests | `references/test-reviewer.md` | Coverage gaps, flaky tests, assertion quality |
| Performance | `references/performance-reviewer.md` | N+1 queries, memory leaks, blocking ops |

Each reviewer prompt instructs the agent to:
1. Run `git diff main...{branch} --name-only` to scope changes
2. Review ONLY changed files for their specialist area
3. Output a JSON array of findings

The **same prompt text** is fed to whichever provider is assigned for that role — JSON finding schema is provider-agnostic. If a non-Claude provider fails after retries, the role falls back to Claude automatically (see provider-dispatch.md).

### Step 3: Collect and Deduplicate

After all 5 agents return:

1. Parse JSON findings from each agent's output
2. Each finding has: `file`, `line_start`, `line_end`, `severity`, `category`, `confidence`, `title`, `description`, `suggestion`
3. Deduplicate: if two findings reference the same file within 3 lines, keep the higher-severity one
4. Filter: only keep findings with `confidence >= 80`
5. Sort by severity: critical → high → medium → low

### Step 4: Generate Checklist

Write findings to `.crucible/REVIEW_CHECKLIST.md`:

```markdown
# Review Checklist

Generated: {timestamp}
Branch: {branch}
Files reviewed: {count}

## Critical ({count})
- [ ] **{title}** — `{file}:{line_start}` — {description}

## High ({count})
- [ ] **{title}** — `{file}:{line_start}` — {description}

## Medium ({count})
- [ ] **{title}** — `{file}:{line_start}` — {description}

## Low ({count})
- [ ] **{title}** — `{file}:{line_start}` — {description}
```

Also save raw findings to `.crucible/reviews/{category}.json`.

### Step 5: Present Results

Show the checklist to the user. Highlight critical issues that need fixing before merge.

If critical issues exist, offer to create fix tasks and re-dispatch via `crucible:orchestrating-work`.

## Finding Schema

```json
{
  "file": "src/auth.ts",
  "line_start": 42,
  "line_end": 45,
  "severity": "critical|high|medium|low",
  "category": "security|quality|waste|tests|performance",
  "confidence": 92,
  "title": "Short title of the issue",
  "description": "Specific explanation of THIS instance",
  "suggestion": "Concrete fix with code if possible"
}
```

## Common Mistakes

- Running fewer than 5 reviewers → blind spots in coverage
- Not deduplicating → same issue reported 3 times inflates severity
- Keeping low-confidence findings → noise drowns out real issues
- Skipping the checklist → findings get lost, not acted on
- Not re-reviewing after fixes → fixed issues may introduce new ones
