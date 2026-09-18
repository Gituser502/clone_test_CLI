#!/usr/bin/env bash
# Watch Ox hook debug output (run in a separate terminal while testing in Cursor)
set -euo pipefail

OX_DIR="${HOME}/.cursor/.ox"
echo "Watching Ox logs in $OX_DIR"
echo "  debug.log       — hook events"
echo "  guidelines.json — last API guidelines"
echo "  state.json      — session prompt capture"
echo ""
touch "$OX_DIR/debug.log"
tail -f "$OX_DIR/debug.log"
