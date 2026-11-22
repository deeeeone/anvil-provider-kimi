#!/bin/sh
# Started by Anvil when a kimi-web model is first used; stopped when Anvil quits.
set -eu
# Anvil hands over the signed-in token from localStorage (or its access_token cookie).
KIMI_TOKEN_VALUE=""
if [ -n "${ANVIL_PROVIDER_LOCALSTORAGE:-}" ]; then
  KIMI_TOKEN_VALUE=$(printf '%s' "$ANVIL_PROVIDER_LOCALSTORAGE" | .venv/bin/python -c 'import sys,json; print(json.load(sys.stdin).get("access_token",""))' 2>/dev/null || true)
fi
if [ -z "$KIMI_TOKEN_VALUE" ] && [ -n "${ANVIL_PROVIDER_COOKIES:-}" ]; then
  KIMI_TOKEN_VALUE=$(printf '%s' "$ANVIL_PROVIDER_COOKIES" | .venv/bin/python -c 'import sys,json; d=json.load(sys.stdin); print(d.get("access_token") or d.get("kimi-auth") or "")' 2>/dev/null || true)
fi
[ -n "$KIMI_TOKEN_VALUE" ] && export KIMI_TOKEN="$KIMI_TOKEN_VALUE"
export KIMI_API_BASE="https://www.kimi.ai"
export PORT="${PORT:-37991}"
export HOST="127.0.0.1"
cd upstream
exec ../.venv/bin/python main.py
