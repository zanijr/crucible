#!/usr/bin/env bash
# Regression test for issue #11 — allow-list pre-flight check.
#
# Purpose: verify that the pre-flight check documented in
#   skills/multi-ai-providers/SKILL.md § "Pre-flight check"
# correctly detects the Bash(gemini:*) and Bash(codex:*) patterns across
# all 4 settings file locations Claude Code reads:
#   1. $HOME/.claude/settings.json
#   2. $HOME/.claude/settings.local.json
#   3. <cwd>/.claude/settings.json
#   4. <cwd>/.claude/settings.local.json
#
# The check must PASS when the patterns appear in ANY of the existing
# files (Claude Code unions permissions.allow across all of them) and
# FAIL when both are missing from every scanned file.
#
# Usage:  ./tests/regression-allow-list-check.sh
# Exit 0 = all cases pass.

set -euo pipefail

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# A minimal `check` implementation that mirrors the SKILL.md spec.
# Skill instructions tell Claude to perform the logical equivalent; this
# script exists as a crisp executable reference so edge cases are
# unambiguous and verifiable without invoking the Claude runtime.
check() {
  local home="$1" cwd="$2"
  local files=(
    "$home/.claude/settings.json"
    "$home/.claude/settings.local.json"
    "$cwd/.claude/settings.json"
    "$cwd/.claude/settings.local.json"
  )
  local have_gemini=0 have_codex=0 scanned=""
  for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then
      scanned="${scanned:+$scanned, }$f"
      # Text-level grep is intentional — tolerates comments, trailing commas,
      # minor JSON syntax drift. Skill doc also says "fallback: grep the raw text".
      if grep -Fq '"Bash(gemini:*)"' "$f"; then have_gemini=1; fi
      if grep -Fq '"Bash(codex:*)"'  "$f"; then have_codex=1; fi
    fi
  done
  if (( have_gemini == 1 && have_codex == 1 )); then
    echo "PASS scanned=[$scanned]"
    return 0
  fi
  local missing=""
  (( have_gemini == 0 )) && missing='"Bash(gemini:*)"'
  (( have_codex  == 0 )) && missing="${missing:+$missing and }\"Bash(codex:*)\""
  echo "FAIL scanned=[$scanned] missing=[$missing]"
  return 1
}

# Helpers
mk_home() { mkdir -p "$1/.claude"; }
mk_cwd()  { mkdir -p "$1/.claude"; }
write_settings() {
  # $1 = path, $2..$N = allow entries (may be empty)
  local path="$1"; shift
  local entries=""
  for e in "$@"; do entries="${entries:+$entries, }\"$e\""; done
  cat > "$path" <<JSON
{
  "permissions": {
    "allow": [ $entries ]
  }
}
JSON
}

pass_expected() {
  local label="$1" home="$2" cwd="$3"
  if check "$home" "$cwd" >/dev/null; then
    echo "  ok — $label"
  else
    echo "  FAIL (expected PASS) — $label"; return 1
  fi
}
fail_expected() {
  local label="$1" home="$2" cwd="$3"
  if ! check "$home" "$cwd" >/dev/null; then
    echo "  ok — $label"
  else
    echo "  FAIL (expected FAIL) — $label"; return 1
  fi
}

echo "Case 1: no settings files anywhere → FAIL"
H="$TMP/c1-home"; C="$TMP/c1-cwd"; mkdir -p "$H" "$C"
fail_expected "no settings" "$H" "$C"

echo "Case 2: patterns in ~/.claude/settings.local.json → PASS (user's current setup)"
H="$TMP/c2-home"; C="$TMP/c2-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.local.json" "Bash(gemini:*)" "Bash(codex:*)" "Bash(ls:*)"
pass_expected "both in user local" "$H" "$C"

echo "Case 3: patterns in ~/.claude/settings.json (user-level) → PASS"
H="$TMP/c3-home"; C="$TMP/c3-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.json" "Bash(gemini:*)" "Bash(codex:*)"
pass_expected "both in user-level settings.json" "$H" "$C"

echo "Case 4: patterns split across user-level settings.json and settings.local.json → PASS"
H="$TMP/c4-home"; C="$TMP/c4-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.json"       "Bash(gemini:*)"
write_settings "$H/.claude/settings.local.json" "Bash(codex:*)"
pass_expected "union across two user files" "$H" "$C"

echo "Case 5: patterns only in project .claude/settings.json → PASS"
H="$TMP/c5-home"; C="$TMP/c5-cwd"; mkdir -p "$H"; mk_cwd "$C"
write_settings "$C/.claude/settings.json" "Bash(gemini:*)" "Bash(codex:*)"
pass_expected "both in project settings.json" "$H" "$C"

echo "Case 6: gemini in user, codex in project → PASS (union across scopes)"
H="$TMP/c6-home"; C="$TMP/c6-cwd"; mk_home "$H"; mk_cwd "$C"
write_settings "$H/.claude/settings.local.json" "Bash(gemini:*)"
write_settings "$C/.claude/settings.local.json" "Bash(codex:*)"
pass_expected "union across user+project" "$H" "$C"

echo "Case 7: only gemini anywhere → FAIL"
H="$TMP/c7-home"; C="$TMP/c7-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.local.json" "Bash(gemini:*)"
fail_expected "codex missing" "$H" "$C"

echo "Case 8: only codex anywhere → FAIL"
H="$TMP/c8-home"; C="$TMP/c8-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.local.json" "Bash(codex:*)"
fail_expected "gemini missing" "$H" "$C"

echo "Case 9: wildcard-only allow (e.g., Bash(*)) without explicit gemini/codex → FAIL"
# Design choice: the check requires the exact patterns. A blanket Bash(*)
# technically allows everything, but (a) users almost never set that, and
# (b) requiring the exact patterns makes the error message actionable and
# matches the install instructions. Documented behavior.
H="$TMP/c9-home"; C="$TMP/c9-cwd"; mk_home "$H"; mkdir -p "$C"
write_settings "$H/.claude/settings.local.json" "Bash(*)"
fail_expected "blanket Bash(*) is not a substitute" "$H" "$C"

echo "Case 10: malformed JSON but patterns present in raw text → PASS (grep fallback)"
H="$TMP/c10-home"; C="$TMP/c10-cwd"; mk_home "$H"; mkdir -p "$C"
cat > "$H/.claude/settings.local.json" <<'BAD'
// intentionally not valid JSON (comment + trailing comma)
{
  "permissions": {
    "allow": [
      "Bash(gemini:*)",
      "Bash(codex:*)",
    ],
  }
}
BAD
pass_expected "grep fallback catches patterns in malformed JSON" "$H" "$C"

echo
echo "ALL CHECKS PASSED"
