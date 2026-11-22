#!/bin/sh
# Started by Anvil when a kimi-web model is first used; stopped when Anvil quits.
set -eu
read_key() {
  printf '%s' "$1" | .venv/bin/python -c 'import sys,json; d=json.load(sys.stdin); print(d.get("access_token") or d.get("kimi-auth") or "")' 2>/dev/null || true
}
KIMI_TOKEN_VALUE=""
if [ -n "${ANVIL_PROVIDER_LOCALSTORAGE:-}" ]; then
  KIMI_TOKEN_VALUE=$(printf '%s' "$ANVIL_PROVIDER_LOCALSTORAGE" | .venv/bin/python -c 'import sys,json; print(json.load(sys.stdin).get("access_token",""))' 2>/dev/null || true)
  REFRESH=$(printf '%s' "$ANVIL_PROVIDER_LOCALSTORAGE" | .venv/bin/python -c 'import sys,json; print(json.load(sys.stdin).get("refresh_token",""))' 2>/dev/null || true)
  [ -n "${REFRESH:-}" ] && export KIMI_REFRESH_TOKEN="$REFRESH"
fi
if [ -z "$KIMI_TOKEN_VALUE" ] && [ -n "${ANVIL_PROVIDER_COOKIES:-}" ]; then
  KIMI_TOKEN_VALUE=$(read_key "$ANVIL_PROVIDER_COOKIES")
fi
[ -n "$KIMI_TOKEN_VALUE" ] && export KIMI_TOKEN="$KIMI_TOKEN_VALUE"
export KIMI_API_BASE="https://www.kimi.ai"
export PORT="${PORT:-37991}"
export HOST="127.0.0.1"
cd upstream
exec ../.venv/bin/python main.py
