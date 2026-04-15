# CLI Reference — Gemini and Codex

Exact invocation shapes Crucible uses to dispatch roles to external CLIs. These are the same shapes referenced from `../../review-pipeline/references/provider-dispatch.md` — duplicated here for standalone troubleshooting.

## Gemini CLI

### Version

Tested against Gemini CLI `0.37.2`. Install: `npm install -g @google/gemini-cli`.

### Invocation shape

```bash
gemini --model gemini-3-pro-preview --approval-mode default -p "<wrapper instruction>" <<'REVIEW_EOF'
<full prompt body>
REVIEW_EOF
```

### Flags

| Flag | Why |
|------|-----|
| `--model gemini-3-pro-preview` | Pins the model. Override in `providers.json` → `cli.gemini.command_prefix` if your Gemini subscription uses a different tier. |
| `--approval-mode default` | Keeps Gemini read-only. **Do not change.** |
| `-p "<wrapper>"` | One-line instruction to Gemini. Crucible uses a generic wrapper like `"Review for correctness, best practices, and potential improvements. Do NOT commit, push, or modify any files."` |
| `<<'REVIEW_EOF' ... REVIEW_EOF` | Heredoc feeds the full specialist prompt (e.g., security-reviewer.md body) via stdin. Single-quoted EOF prevents shell variable expansion. |

### Output

Gemini writes results to stdout. Expected format depends on the role:
- Reviewer roles → JSON array matching the Finding Schema (see review-pipeline/SKILL.md).
- Advisor role → free-form text (inserted into worker prompt as-is).

### Known quirks

- **Deprecated `experimental.plan` warning** at startup is non-blocking but appears as a **preamble in stdout** before any response. The dispatcher's parser must scan past it (locate first `[` for JSON arrays). Verified during v1.1 testing on Gemini CLI 0.37.2. To silence the warning entirely: remove `experimental.plan` from `~/.gemini/settings.json`.
- Gemini sometimes prepends/appends commentary despite prompt instructing JSON-only. When parsing fails, save raw output to `.crucible/reviews/<role>.raw.txt` and retry per `retry` config.
- **Gemini CLI in non-interactive mode does NOT autonomously run shell commands.** Reviewer prompts that say "run git diff to see changed files" produce hallucination or refusal — always inline the diff into the heredoc body. See `../../review-pipeline/references/provider-dispatch.md` § "Inlining context".

## Codex CLI

### Version

Tested against Codex CLI `0.120.0`. Install: `npm install -g @openai/codex-cli`.

### Invocation shape

```bash
codex exec --model gpt-5.3-codex --sandbox read-only - <<'REVIEW_EOF'
<wrapper instruction>

<full prompt body>
REVIEW_EOF
```

### Flags

| Flag | Why |
|------|-----|
| `exec` | Non-interactive execution. |
| `--model gpt-5.3-codex` | Pins the model. Override in `providers.json` → `cli.codex.command_prefix` for your tier. |
| `--sandbox read-only` | Guarantees Codex cannot write files. **Do not change.** |
| `-` | Read prompt body from stdin (vs. passing as argument — avoids Windows arg-length limits). |
| `<<'REVIEW_EOF' ... REVIEW_EOF` | Heredoc. Unlike Gemini, Codex takes the wrapper instruction inside the heredoc body (no `-p` flag). |

### Output

Codex writes results to stdout. Same output conventions as Gemini (JSON for reviewers, free text for advisor).

### Known quirks

- **Session preamble in stdout:** Codex prints a header before the response listing `workdir`, `model`, `provider`, `approval`, `sandbox`, `reasoning effort`, and `session id`. After the response, it prints a `tokens used N` footer. The dispatcher's parser must skip past these (scan for first `[` for JSON arrays).
- `--sandbox read-only` suppresses shell commands inside Codex's turns. If you see "tool call blocked" messages in output, that's expected — it just means Codex tried to run something and was correctly prevented. The review/advice itself comes through.
- **Codex CLI in `exec` mode does NOT autonomously run shell commands either** (read-only sandbox suppresses them). Reviewer prompts must inline the diff into the heredoc body. See `../../review-pipeline/references/provider-dispatch.md` § "Inlining context".
- Codex output is generally well-formed JSON when asked, but like Gemini may occasionally add commentary. Handle via retry + raw-output fallback.

## Timeout and Retry

Both CLIs default to `timeout_ms: 300000` (5 minutes) in `providers.json`. Retry count defaults to `2`. Tune per-provider if you hit frequent timeouts.

Crucible enforces these at the `Bash` tool level (`timeout` parameter). If a dispatch exceeds timeout, the Bash tool returns a timeout error, which Crucible treats as a retry-eligible failure.

## First-Token Rule

Every `Bash` call Crucible makes for a non-Claude provider MUST have the CLI binary as its **first token**. No pipes, no `cd && ...`, no shell wrappers. This is required so `Bash(gemini:*)` and `Bash(codex:*)` allow patterns in `~/.claude/settings.local.json` match without prompting.

**Correct:**
```bash
gemini --model ... -p "..." <<'REVIEW_EOF'
...
REVIEW_EOF
```

**Wrong (won't match allow pattern, prompts user every call):**
```bash
cd /path/to/repo && gemini --model ... -p "..."
cat brief.md | gemini --model ... -p "..."
/usr/local/bin/gemini --model ... -p "..."   # absolute path — first token is the path, not "gemini"
```

If you need to run Crucible from a non-default cwd, set cwd in the Bash tool invocation separately rather than prefixing with `cd &&`.

## Verifying the Shape at a Terminal

Before trusting Crucible to dispatch correctly, run each CLI manually at a shell and confirm it works standalone:

```bash
# Gemini smoke test
gemini --model gemini-3-pro-preview --approval-mode default -p "Say hello" <<'EOF'
Test input.
EOF

# Codex smoke test
codex exec --model gpt-5.3-codex --sandbox read-only - <<'EOF'
Say hello.
EOF
```

If either fails standalone (auth error, model not found, network), Crucible will also fail and fall back to Claude. Fix the standalone case first.
