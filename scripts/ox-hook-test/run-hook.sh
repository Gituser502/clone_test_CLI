#!/usr/bin/env bash
# Simulate Cursor hook events against ~/.cursor/hooks/ox_mind.js
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OX_HOOK="${HOME}/.cursor/hooks/ox_mind.js"
FIXTURES="$SCRIPT_DIR/fixtures"

usage () {
  echo "Usage: $0 <sessionStart|beforeSubmitPrompt|preToolUse-write|all>"
  exit 1
}

run_fixture () {
  local name="$1"
  local file="$FIXTURES/${name}.json"
  if [[ ! -f "$file" ]]; then
    echo "Missing fixture: $file" >&2
    exit 1
  fi
  # Use repo path in fixture (portable sed for macOS)
  local payload
  payload="$(sed "s|/Users/vadimkolchinsky/GitHub/Free/juice-shop|${REPO_ROOT}|g" "$file")"

  echo "=== $name ==="
  echo "--- stdin (fixture) ---"
  echo "$payload" | head -c 400
  echo ""
  echo "--- hook stdout (JSON) ---"
  local stdout stderr exit_code
  stdout="$(echo "$payload" | node "$OX_HOOK" --ide cursor 2>/tmp/ox-hook-test.stderr || true)"
  stderr="$(cat /tmp/ox-hook-test.stderr 2>/dev/null || true)"
  exit_code=$?
  echo "$stdout" | python3 -m json.tool 2>/dev/null || echo "$stdout"
  if [[ -n "$stderr" ]]; then
    echo "--- hook stderr (deny / guidelines) ---"
    echo "$stderr" | head -c 2000
    echo ""
    if [[ ${#stderr} -gt 2000 ]]; then echo "... (truncated)"; fi
  fi
  echo "(exit $exit_code — 2 often means preToolUse deny with guidelines)"
  echo ""
}

[[ $# -ge 1 ]] || usage

case "$1" in
  sessionStart) run_fixture sessionStart ;;
  beforeSubmitPrompt) run_fixture beforeSubmitPrompt ;;
  preToolUse-write) run_fixture preToolUse-write ;;
  all)
    run_fixture sessionStart
    run_fixture beforeSubmitPrompt
    run_fixture preToolUse-write
    ;;
  *) usage ;;
esac

echo "Tip: tail ~/.cursor/.ox/debug.log and cat ~/.cursor/.ox/guidelines.json"
