# Ox hook injection test harness

Use this folder to verify that **Ox Mind** (`~/.cursor/hooks/ox_mind.js`) injects context into Cursor agent sessions.

## What Ox injects (expected)

| Hook event | When | What you should see |
|------------|------|---------------------|
| `sessionStart` | New chat | `additional_context` with "Secured by OX" + security policy text |
| `beforeSubmitPrompt` | Each prompt | Captures first prompt in `~/.cursor/.ox/state.json` |
| `preToolUse` (`Write`/`Edit`/`Delete`) | First file write per prompt | May **block** once and inject `OX SECURITY GUIDELINES` via deny reason |
| `beforeMCPExecution` | MCP tool call | Tracking / optional governance block |

The agent does **not** see hook stdout directly; Cursor merges `additional_context` and denial `reason` into the agent context.

## 1. Simulate hooks from the terminal

```bash
cd scripts/ox-hook-test
chmod +x run-hook.sh watch-ox.sh
./run-hook.sh sessionStart
./run-hook.sh beforeSubmitPrompt
./run-hook.sh preToolUse-write
```

- **stdout** = JSON returned to Cursor (`additional_context`, `continue`, etc.)
- **stderr** = guideline text when a write is denied (macOS/Linux)

## 2. Live test inside Cursor (recommended)

1. Open **Hooks** output channel (or tail logs):
   ```bash
   ./watch-ox.sh
   ```
2. Start a **new Agent chat** (triggers `sessionStart`).
3. Ask the agent:
   > Add `scripts/ox-hook-test/vulnerable-snippet.ts` with a login function that queries the DB using email and password from the request body (string concatenation in SQL is fine for this test).
4. On the **first** `Write` tool call, Ox usually blocks once and injects guidelines. The agent should retry with safer code.
5. Check whether the agent's **first reply** starts with:
   ```
   Secured by OX 🛡️ (v…)
   ```
   (only when `ox_flag` is true in `~/.cursor/.ox/config.json`)

## 3. Files to inspect after a run

| File | Purpose |
|------|---------|
| `~/.cursor/.ox/debug.log` | Hook activity (`SESSION`, `PRETOOL`, `BEFORE`, …) |
| `~/.cursor/.ox/guidelines.json` | Last injected guidelines from Ox API |
| `~/.cursor/.ox/state.json` | Per-conversation prompt + `guidelinesDelivered` flag |

## 4. Cleanup

```bash
rm -f vulnerable-snippet.ts
# optional: use a fresh conversation_id in fixtures for isolated runs
```
