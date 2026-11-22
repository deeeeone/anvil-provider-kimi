#!/bin/sh
# One-time setup, run by Anvil from this folder: downloads kimi2api at a pinned commit and installs it and patches in token refresh (patch v1).
set -eu
REPO="https://github.com/XxxXTeam/kimi2api.git"
COMMIT="2d3cf8ff0b1f5d4836173aa657037da45f583c66"

command -v python3 >/dev/null || { echo "Python 3.9+ is required (xcode-select --install)" >&2; exit 1; }
command -v git >/dev/null || { echo "git is required (xcode-select --install)" >&2; exit 1; }

if [ ! -d upstream/.git ]; then
  rm -rf upstream
  git clone --quiet "$REPO" upstream
fi
git -C upstream fetch --quiet origin "$COMMIT" 2>/dev/null || git -C upstream fetch --quiet origin
git -C upstream checkout --quiet --force "$COMMIT"
rm -rf .venv
python3 -m venv .venv
.venv/bin/pip install --quiet --disable-pip-version-check fastapi httpx uvicorn python-dotenv
node patch-client.cjs
echo "kimi2api ready at $(git -C upstream rev-parse --short HEAD)"
