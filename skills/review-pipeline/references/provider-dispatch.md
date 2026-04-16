# Provider Dispatch

How to route a Crucible role to Claude (default), Gemini, or Codex based on `providers.json`.

This reference is shared by `review-pipeline` and `orchestrating-work`. Both skills resolve providers the same way before they dispatch.

## Config Resolution

Check these locations in order. First hit wins:

1. `.crucible/providers.json` — per-project (highest priority)
2. `~/.claude/crucible/providers.json` — user global
3. Implicit default: `{"default": "claude"}` — no config means all roles are Claude

If the config file is missing, malformed, or unparseable: **fall back silently to Claude for every role**. Never block dispatch on config errors.

## Resolving a Role

For any role name (`security`, `quality`, `waste`, `tests`, `performance`, `worker`, `worker_advisor`):

1. Look up `roles.<name>` in the resolved config.
2. If unset, use `default` (which is itself `claude` if unset).
3. Resolved value is one of: `claude` | `gemini` | `codex`.

## Dispatch Path by Provider

### `claude` — Agent tool (today's behavior)

```
Agent({
  description: "<role> reviewer",
  subagent_type: "general-purpose",
  prompt: "<prompt text>"
})
```

No change from v1.0.0. Always the fallback when a non-Claude provider fails.

### `gemini` — Bash tool shelling to Gemini CLI

**First-token matching rule (critical):** The `Bash` command's first token MUST be `gemini`. No pipes, no `cd && gemini ...`, no wrappers. This makes `Bash(gemini:*)` allow-pattern match and avoids manual approval prompts per call.

```bash
gemini --model gemini-3-pro-preview --approval-mode default -p "Review for correctness. Do NOT commit, push, or modify any files." <<'CRUCIBLE_EOF_<RANDOM>'
<prompt text>
CRUCIBLE_EOF_<RANDOM>
```

Read `stdout` as the agent output. `--approval-mode default` keeps Gemini read-only.

### `codex` — Bash tool shelling to Codex CLI

First-token rule: `codex` MUST be the first token.

```bash
codex exec --model gpt-5.3-codex --sandbox read-only - <<'CRUCIBLE_EOF_<RANDOM>'
Review for correctness. Do NOT commit, push, or modify any files.

<prompt text>
CRUCIBLE_EOF_<RANDOM>
```

Read `stdout` as the agent output. `--sandbox read-only` guarantees no file writes.

### Heredoc EOF token — collision safety (CRITICAL)

`<RANDOM>` above is **not a literal** — it is an 8-character hex string the dispatcher MUST generate per-invocation. A fixed token like `REVIEW_EOF` causes silent truncation if the prompt body contains a line matching that token (common in diffs of Crucible's own code, test fixtures, or documentation).

**Rule:** Before forming a Bash call for Gemini/Codex, generate a random 8+ char hex suffix (e.g., from a timestamp hash, UUID, or `openssl rand -hex 4` run mentally). Use `CRUCIBLE_EOF_<hex>` as the heredoc token in BOTH the opening `<<'TOKEN'` and the closing terminator line. The body text is untouched.

**Example of a correctly-formed invocation:**

```bash
gemini --model gemini-3-pro-preview --approval-mode default -p "Review for correctness." <<'CRUCIBLE_EOF_a7f2e391'
Here is a diff. Even if the diff contains the string REVIEW_EOF or CRUCIBLE_EOF on its own line, the heredoc survives because the random suffix won't match.
--- a/foo.sh
+++ b/foo.sh
@@ ...
+ REVIEW_EOF
CRUCIBLE_EOF_a7f2e391
```

**Why single-quoted:** `<<'TOKEN'` suppresses shell expansion inside the body. The token itself is literal text — single-quoting it is defensive, not required.

**Why this rule exists:** Issue #10 — a diff containing `REVIEW_EOF` on its own line caused a 3-retry cascade (~75s waste) + CLI hallucination on truncated input. Claude fallback rescued correctness but not cost. Per-dispatch randomisation makes the collision probability zero in practice.

### Bash tool call parameters (both Gemini and Codex)

- `timeout`: `300000` ms (5 minutes) unless `cli.<provider>.timeout_ms` overrides.
- Do NOT set `run_in_background: true` — the dispatching skill needs stdout synchronously to parse.

### Inlining context (CRITICAL)

Unlike Claude subagents, **external CLIs in non-interactive mode do NOT autonomously run shell commands** (no `git diff`, no file reads). You must **pre-compute everything the reviewer needs and embed it in the heredoc body**.

For reviewer roles, this means:
1. Before dispatch, run `git diff main...{branch} -U10 -- <changed files>` yourself.
2. Append the diff text into the heredoc body, after the specialist prompt.
3. Tell the reviewer to base its findings on "the diff below" rather than instructing it to run `git diff` itself.

Claude subagents can be told "run git diff" because they have shell access. Gemini and Codex CLIs treat the prompt as text-only input and will hallucinate or refuse if asked to invoke commands.

## Parallel Dispatch

When multiple roles need to run in parallel (e.g., review-pipeline's 5 reviewers):

- Send **all** dispatch tool calls in a **single message**. Mix freely: some may be `Agent` (Claude), others `Bash` (Gemini/Codex). They all execute concurrently.
- Example: 3 Agent calls for security/quality/waste (Claude) + 1 Bash for tests (Gemini) + 1 Bash for performance (Codex) = 5 parallel dispatches.

## Output Parsing

External CLIs produce the same output format as Claude subagents **because the prompt instructs them to**. No provider-specific parsing.

- Reviewers → JSON array of findings (see review-pipeline's Finding Schema).
- Workers → final message ending in `STATUS: DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED`.

Gemini and Codex both emit response content on **stdout**, with envelope content (warnings, session headers, footers) routed to **stderr**. Verified on Gemini CLI 0.37.2 and Codex CLI 0.120.0 (Windows). The dispatcher reads stdout and ignores stderr for parsing purposes.

- **Gemini stderr noise:** May print a deprecation warning (e.g., `The system configuration contains deprecated settings: [experimental.plan]...`) on stderr. Cosmetic only — does not affect parsing. To silence: remove `experimental.plan` from `~/.gemini/settings.json` (or the system-level Gemini config if it's there).
- **Codex stderr noise:** Prints a session header (`workdir`, `model`, `provider`, `approval`, `sandbox`, `session id`) and a `tokens used` footer on stderr. Cosmetic only.

Parse rule (defensive, kept simple in case future CLI versions drift back to stdout): locate the first `[` (for JSON arrays) or the first line matching `^STATUS:` (for worker output) in stdout, and extract from there. Discard everything before. For arrays, locate the matching `]` to bound the extraction.

## Retry and Fallback

Per-provider config (`cli.<provider>.retry`, default `2`):

1. On non-zero exit, timeout, empty stdout, or malformed output (no JSON array / STATUS line found in stdout) → wait 15s, retry.
2. After `retry` attempts exhausted → **fall back to Claude** for that single role. Dispatch via `Agent` tool as if the role had been `claude` all along.
3. Log fallback to `.crucible/reviews/<role>.fallback.txt` (for reviewers) or `.crucible/PROJECT_STATE.md` (for workers).
4. Never abort the entire pipeline because one provider failed. The 5-reviewer and worker-dispatch guarantees still hold.

### Malformed output — terminal disposition

If even the Claude fallback fails to produce a parseable JSON array / STATUS line (rare; Claude subagents reliably follow protocol):

- **Reviewers:** treat as `[]` (empty findings) and log the malformed output to `.crucible/reviews/<role>.raw.txt` for manual inspection.
- **Workers:** treat as `STATUS: DONE_WITH_CONCERNS` per `references/status-protocol.md` rules.

This branch exists as a guarantee that the pipeline never stalls. Reaching it indicates an upstream prompt or protocol bug worth investigating.

## Safety Invariants

- **Single-writer:** Only Claude subagents ever write files. Codex always runs with `--sandbox read-only`; Gemini always with `--approval-mode default`. Never strip these flags.
- **No shell composition:** First token of every Bash call is the CLI binary name. No `cat file | gemini ...`, no `gemini x && gemini y`.
- **No background dispatch for review/worker roles:** dispatching skills need output synchronously.

## Configuring the Allow List

For frictionless operation, users add these to `~/.claude/settings.local.json` permission rules:

```json
{
  "permissions": {
    "allow": [
      "Bash(gemini:*)",
      "Bash(codex:*)"
    ]
  }
}
```

Without these, every CLI call prompts the user for approval. Crucible doesn't modify `settings.local.json` — the new `multi-ai-providers` skill instructs users on the exact JSON to add.
