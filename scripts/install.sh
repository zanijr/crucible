#!/usr/bin/env bash
# Crucible install / upgrade script -- idempotent, safe to rerun.
#
# Usage:
#   bash scripts/install.sh              # clone/update + setup (auto-detect multi-AI)
#   bash scripts/install.sh --no-cli     # skip allow-list setup (pure Claude install)
#   bash scripts/install.sh --force-cli  # add allow-list even if gemini/codex not installed
#
# What it does:
#   1. Ensures ~/.claude/crucible/ exists and is at latest main
#   2. If Gemini or Codex CLI is on PATH (or --force-cli), merges
#      Bash(gemini:*) and Bash(codex:*) into permissions.allow in
#      ~/.claude/settings.local.json (created if missing, preserved if present)
#   3. Reports final state so the user can verify
#
# Non-goals:
#   - Does NOT install Node, Gemini CLI, or Codex CLI (user-controlled)
#   - Does NOT modify ~/.claude/settings.json (user-owned, not machine-specific)
#   - Does NOT pipe curl to shell

set -euo pipefail

INSTALL_DIR="${CRUCIBLE_INSTALL_DIR:-$HOME/.claude/crucible}"
SETTINGS_FILE="$HOME/.claude/settings.local.json"
REPO_URL="${CRUCIBLE_REPO_URL:-https://github.com/zanijr/crucible.git}"

mode="auto"
for arg in "$@"; do
  case "$arg" in
    --no-cli)    mode="no-cli" ;;
    --force-cli) mode="force-cli" ;;
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Step 1: clone or update
# ---------------------------------------------------------------------------
echo "==> Ensuring plugin at $INSTALL_DIR"
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "   existing install found -- pulling latest"
  git -C "$INSTALL_DIR" fetch --tags origin >/dev/null 2>&1 || true
  git -C "$INSTALL_DIR" pull --ff-only origin main 2>&1 | sed 's/^/   /'
else
  if [[ -e "$INSTALL_DIR" ]]; then
    echo "ERROR: $INSTALL_DIR exists but is not a git clone. Move or remove it and rerun." >&2
    exit 1
  fi
  echo "   cloning $REPO_URL"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone "$REPO_URL" "$INSTALL_DIR" 2>&1 | sed 's/^/   /'
fi
VERSION="$(git -C "$INSTALL_DIR" describe --tags --always 2>/dev/null || echo 'unknown')"
echo "   plugin version: $VERSION"

# ---------------------------------------------------------------------------
# Step 2: decide whether to set up multi-AI allow-list
# ---------------------------------------------------------------------------
need_allow_list=0
case "$mode" in
  no-cli)
    echo "==> Skipping allow-list setup (--no-cli)"
    ;;
  force-cli)
    need_allow_list=1
    echo "==> Forcing allow-list setup (--force-cli)"
    ;;
  auto)
    if command -v gemini >/dev/null 2>&1 || command -v codex >/dev/null 2>&1; then
      need_allow_list=1
      echo "==> Detected Gemini or Codex CLI on PATH -- will set up allow-list"
    else
      echo "==> No Gemini/Codex CLI detected -- skipping allow-list setup"
      echo "   (rerun with --force-cli if you plan to install them later)"
    fi
    ;;
esac

# ---------------------------------------------------------------------------
# Step 3: merge allow-list into settings.local.json
# ---------------------------------------------------------------------------
if (( need_allow_list == 1 )); then
  echo "==> Updating $SETTINGS_FILE"
  mkdir -p "$(dirname "$SETTINGS_FILE")"

  # Pick a JSON engine: prefer python3, then node, then warn-and-exit.
  engine=""
  if command -v python3 >/dev/null 2>&1; then
    engine="python3"
  elif command -v node >/dev/null 2>&1; then
    engine="node"
  else
    cat >&2 <<EOF
WARNING: no python3 or node available -- cannot safely merge JSON.

Add these entries to the "permissions.allow" array in $SETTINGS_FILE manually:

  "Bash(gemini:*)",
  "Bash(codex:*)"

Then rerun: bash scripts/install.sh --force-cli (to verify the edit took).
EOF
    exit 3
  fi

  case "$engine" in
    python3)
      python3 - "$SETTINGS_FILE" <<'PY'
import json, os, sys
path = sys.argv[1]
wanted = ["Bash(gemini:*)", "Bash(codex:*)"]
if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"   ERROR: existing {path} is not valid JSON ({e}). "
                  "Fix it manually and rerun.", file=sys.stderr)
            sys.exit(4)
else:
    data = {}
perms = data.setdefault("permissions", {})
allow = perms.setdefault("allow", [])
added = []
for pat in wanted:
    if pat not in allow:
        allow.append(pat)
        added.append(pat)
tmp = path + ".crucible.tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
os.replace(tmp, path)
if added:
    print(f"   added: {', '.join(added)}")
else:
    print("   allow-list already contains both patterns -- no change")
PY
      ;;
    node)
      node - "$SETTINGS_FILE" <<'JS'
const fs = require('fs');
const path = process.argv[2];
const wanted = ['Bash(gemini:*)', 'Bash(codex:*)'];
let data = {};
if (fs.existsSync(path)) {
  try { data = JSON.parse(fs.readFileSync(path, 'utf8')); }
  catch (e) {
    console.error(`   ERROR: existing ${path} is not valid JSON (${e.message}). Fix it manually and rerun.`);
    process.exit(4);
  }
}
data.permissions = data.permissions || {};
data.permissions.allow = data.permissions.allow || [];
const added = [];
for (const pat of wanted) {
  if (!data.permissions.allow.includes(pat)) {
    data.permissions.allow.push(pat);
    added.push(pat);
  }
}
const tmp = path + '.crucible.tmp';
fs.writeFileSync(tmp, JSON.stringify(data, null, 2) + '\n');
fs.renameSync(tmp, path);
if (added.length) console.log(`   added: ${added.join(', ')}`);
else console.log('   allow-list already contains both patterns -- no change');
JS
      ;;
  esac
fi

# ---------------------------------------------------------------------------
# Step 4: report
# ---------------------------------------------------------------------------
echo
echo "==> Install complete."
echo "   Plugin:        $INSTALL_DIR ($VERSION)"
if (( need_allow_list == 1 )); then
  echo "   Settings:      $SETTINGS_FILE (allow-list ready)"
fi
# Gemini prints version on stdout but can also print a deprecation warning on stdout on older setups.
# Grep for a semver-shaped line; fall back to raw first line.
gemini_version() {
  local raw sem
  raw="$(gemini --version 2>/dev/null || true)"
  sem="$(printf '%s\n' "$raw" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
  printf '%s' "${sem:-${raw:-unknown}}"
}
codex_version() {
  codex --version 2>/dev/null | head -1 || echo "unknown"
}
if command -v gemini >/dev/null 2>&1; then
  echo "   Gemini CLI:    $(gemini_version)"
else
  echo "   Gemini CLI:    not installed (install with: npm install -g @google/gemini-cli)"
fi
if command -v codex >/dev/null 2>&1; then
  echo "   Codex CLI:     $(codex_version)"
else
  echo "   Codex CLI:     not installed (install with: npm install -g @openai/codex-cli)"
fi
echo
echo "Next: restart Claude Code to pick up skill definitions."
