#!/usr/bin/env bash
# Regression test for issue #10 — heredoc EOF collision.
#
# Purpose: verify that a prompt body containing the literal string
# "REVIEW_EOF" on its own line does NOT truncate the heredoc when the
# dispatcher uses the v1.1.1 random-token pattern.
#
# Usage:
#   ./tests/regression-heredoc-collision.sh gemini   # requires gemini CLI
#   ./tests/regression-heredoc-collision.sh codex    # requires codex CLI
#   ./tests/regression-heredoc-collision.sh both     # run both
#
# Exit 0 = PASS. Any non-zero exit from the CLI or missing "END_PROMPT"
# in captured stdout = FAIL.

set -euo pipefail

mode="${1:-both}"
rand="$(printf '%s' "$(date +%s%N)$$$RANDOM" | sha1sum 2>/dev/null | head -c 8 || echo "a1b2c3d4")"
token="CRUCIBLE_EOF_${rand}"

run_gemini() {
  echo "=== Gemini ==="
  local out err rc=0
  out="$(mktemp)"; err="$(mktemp)"
  # Intentional: body contains the old fixed token on its own line.
  # The random heredoc token must prevent truncation.
  gemini --model gemini-3-pro-preview --approval-mode default \
    -p "Echo the two marker lines back exactly as-is. Say nothing else." \
    <<EOF_RUNNER >"$out" 2>"$err" || rc=$?
$(printf 'Marker before: BEGIN_PROMPT\nA diff might contain text like REVIEW_EOF on its own line:\nREVIEW_EOF\nAnd then more text after.\nMarker after: END_PROMPT\n')
EOF_RUNNER
  # NB: the EOF_RUNNER above is itself fixed, but it wraps a printf that emits
  # the test body. That indirection is only for the test harness. The DISPATCHER
  # uses the $token-based random heredoc in real code paths.
  echo "exit=$rc"; echo "--- stdout ---"; cat "$out"; echo "--- stderr ---"; cat "$err"
  if [[ $rc -ne 0 ]]; then echo "FAIL: gemini exit=$rc"; return 1; fi
  if ! grep -q "END_PROMPT" "$out"; then echo "FAIL: END_PROMPT missing from stdout — body truncated"; return 1; fi
  echo "PASS"
}

run_gemini_random_token() {
  echo "=== Gemini (real dispatcher shape: random token) ==="
  local out err rc=0
  out="$(mktemp)"; err="$(mktemp)"
  # This is the shape the v1.1.1 dispatcher uses: token is generated per-call
  # and substituted into the heredoc lines.
  {
    printf 'gemini --model gemini-3-pro-preview --approval-mode default -p "Echo the marker lines." <<%s\n' "'$token'"
    printf 'Marker before: BEGIN_PROMPT\n'
    printf 'A diff might contain text like REVIEW_EOF on its own line:\n'
    printf 'REVIEW_EOF\n'
    printf 'And then more text after.\n'
    printf 'Marker after: END_PROMPT\n'
    printf '%s\n' "$token"
  } | bash >"$out" 2>"$err" || rc=$?
  echo "exit=$rc"; echo "--- stdout ---"; cat "$out"; echo "--- stderr ---"; cat "$err"
  if [[ $rc -ne 0 ]]; then echo "FAIL: gemini exit=$rc"; return 1; fi
  if ! grep -q "END_PROMPT" "$out"; then echo "FAIL: END_PROMPT missing from stdout — body truncated"; return 1; fi
  echo "PASS"
}

run_codex() {
  echo "=== Codex ==="
  local out err rc=0
  out="$(mktemp)"; err="$(mktemp)"
  {
    printf 'codex exec --model gpt-5.3-codex --sandbox read-only - <<%s\n' "'$token'"
    printf 'Echo the two marker lines back exactly as-is. Say nothing else.\n\n'
    printf 'Marker before: BEGIN_PROMPT\n'
    printf 'A diff might contain text like REVIEW_EOF on its own line:\n'
    printf 'REVIEW_EOF\n'
    printf 'And then more text after.\n'
    printf 'Marker after: END_PROMPT\n'
    printf '%s\n' "$token"
  } | bash >"$out" 2>"$err" || rc=$?
  echo "exit=$rc"; echo "--- stdout ---"; cat "$out"; echo "--- stderr ---"; cat "$err"
  if [[ $rc -ne 0 ]]; then echo "FAIL: codex exit=$rc"; return 1; fi
  if ! grep -q "END_PROMPT" "$out"; then echo "FAIL: END_PROMPT missing from stdout — body truncated"; return 1; fi
  echo "PASS"
}

case "$mode" in
  gemini) run_gemini_random_token ;;
  codex)  run_codex ;;
  both)   run_gemini_random_token && run_codex ;;
  *) echo "Usage: $0 [gemini|codex|both]"; exit 2 ;;
esac
echo "ALL CHECKS PASSED"
