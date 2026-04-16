# CLI Reference — Gemini and Codex

Exact invocation shapes Crucible uses to dispatch roles to external CLIs. These are the same shapes referenced from `../../review-pipeline/references/provider-dispatch.md` — duplicated here for standalone troubleshooting.

## Gemini CLI

### Version

Tested against Gemini CLI `0.37.2`. Install: `npm install -g @google/gemini-cli`.

### Invocation shape

```bash
gemini --model gemini-3-pro-preview --approval-mode default -p "<wrapper instruction>" <<'CRUCIBLE_EOF_<RANDOM>'
<full prompt body>
CRUCIBLE_EOF_<RANDOM>
```

`<RANDOM>` is an 8+ char hex suffix the dispatcher generates per invocation. See `../../review-pipeline/references/provider-dispatch.md` § "Heredoc EOF token — collision safety" for rationale. Do **not** use a fixed token.

### Flags

| Flag | Why |
|------|-----|
| `--model gemini-3-pro-preview` | Pins the model. Override in `providers.json` → `cli.gemini.command_prefix` if your Gemini subscription uses a different tier. |
| `--approval-mode default` | Keeps Gemini read-only. **Do not change.** |
| `-p "<wrapper>"` | One-line instruction to Gemini. Crucible uses a generic wrapper like `"Review for correctness, best practices, and potential improvements. Do NOT commit, push, or modify any files."` |
| `<<'CRUCIBLE_EOF_<random>' ... CRUCIBLE_EOF_<random>` | Heredoc feeds the full specialist prompt via stdin. Random suffix prevents collision with the literal string appearing in prompt body (issue #10). Single-quoted EOF prevents shell variable expansion in the body. |

### Output

Gemini writes results to stdout. Expected format depends on the role:
- Reviewer roles → JSON array matching the Finding Schema (see review-pipeline/SKILL.md).
- Advisor role → free-form text (inserted into worker prompt as-is).

### Known quirks

- **Deprecated `experimental.plan` warning** at startup is non-blocking and emitted on **stderr** (not stdout). Verified on Gemini CLI 0.37.2 — stdout stays clean even with the warning active, so the parser is unaffected. The "scan for first `[`" rule is kept defensively in case a future Gemini version moves the warning back to stdout. To silence the stderr noise: remove `experimental.plan` from `~/.gemini/settings.json` (or the system-level Gemini config if `gemini --version` shows the warning despite a clean user config).
- Gemini sometimes prepends/appends commentary despite prompt instructing JSON-only. When parsing fails, save raw output to `.crucible/reviews/<role>.raw.txt` and retry per `retry` config.
- **Gemini CLI in non-interactive mode does NOT autonomously run shell commands.** Reviewer prompts that say "run git diff to see changed files" produce hallucination or refusal — always inline the diff into the heredoc body. See `../../review-pipeline/references/provider-dispatch.md` § "Inlining context".

## Codex CLI

### Version

Tested against Codex CLI `0.120.0`. Install: `npm install -g @openai/codex-cli`.

### Invocation shape

```bash
codex exec --model gpt-5.3-codex --sandbox read-only - <<'CRUCIBLE_EOF_<RANDOM>'
<wrapper instruction>

<full prompt body>
CRUCIBLE_EOF_<RANDOM>
```

`<RANDOM>` is an 8+ char hex suffix the dispatcher generates per invocation (see Gemini section above and `../../review-pipeline/references/provider-dispatch.md`).

### Flags

| Flag | Why |
|------|-----|
| `exec` | Non-interactive execution. |
| `--model gpt-5.3-codex` | Pins the model. Override in `providers.json` → `cli.codex.command_prefix` for your tier. |
| `--sandbox read-only` | Guarantees Codex cannot write files. **Do not change.** |
| `-` | Read prompt body from stdin (vs. passing as argument — avoids Windows arg-length limits). |
| `<<'CRUCIBLE_EOF_<random>' ... CRUCIBLE_EOF_<random>` | Heredoc. Unlike Gemini, Codex takes the wrapper instruction inside the heredoc body (no `-p` flag). Random suffix prevents issue #10 collision. |

### Output

Codex writes results to stdout. Same output conventions as Gemini (JSON for reviewers, free text for advisor).

### Known quirks

- **Session header and footer on stderr (not stdout):** Codex 0.120.0 on Windows prints the session header (`workdir`, `model`, `provider`, `approval`, `sandbox`, `reasoning effort`, `session id`) and the `tokens used N` footer on **stderr**. Stdout contains only the response (e.g., the JSON array). Earlier Crucible drafts incorrectly described these as stdout content; the "scan for first `[`" parse rule is kept defensively against future drift.
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
gemini --model ... -p "..." <<'CRUCIBLE_EOF_<RANDOM>'
...
CRUCIBLE_EOF_<RANDOM>
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
# Gemini smoke test — random token not required for smoke (no prompt-body risk)
gemini --model gemini-3-pro-preview --approval-mode default -p "Say hello" <<'EOF'
Test input.
EOF

# Codex smoke test
codex exec --model gpt-5.3-codex --sandbox read-only - <<'EOF'
Say hello.
EOF
```

If either fails standalone (auth error, model not found, network), Crucible will also fail and fall back to Claude. Fix the standalone case first.

## Heredoc Collision Regression Test (issue #10)

To verify the dispatcher correctly handles prompt bodies containing heredoc-looking strings:

```bash
# Run this at a shell — substitute a random suffix for <RANDOM>
gemini --model gemini-3-pro-preview --approval-mode default \
  -p "Output ONLY the literal text GOT_FULL_INPUT. Nothing else." <<'CRUCIBLE_EOF_<RANDOM>'
Marker before: BEGIN_PROMPT
A diff might contain text like REVIEW_EOF on its own line:
REVIEW_EOF
And then more text after.
Marker after: END_PROMPT
CRUCIBLE_EOF_<RANDOM>
```

**Expected:** Gemini echoes `GOT_FULL_INPUT` (or equivalent), exit 0, no `command not found` errors on stderr.
**Failure mode before fix:** Bash exits 127 with `REVIEW_EOF: command not found` leaking to stderr (the old fixed-token dispatcher broke when body contained `REVIEW_EOF`).
**Equivalent Codex test:** substitute `codex exec --model gpt-5.3-codex --sandbox read-only -` for the `gemini ... -p "..."` prefix and adapt the instruction wrapper into the body.

If this test passes, the random-token mitigation for issue #10 is working.
