#!/usr/bin/env bash
# Source of truth for create-next-app flags. Invoked by the web-start skill.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: init.sh <absolute-target-directory>" >&2
  exit 2
fi

TARGET="$1"

if [[ "$TARGET" != /* ]]; then
  echo "web-start: target must be an absolute path (got: $TARGET)" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "web-start: target directory does not exist: $TARGET" >&2
  exit 1
fi

BASENAME=$(basename "$TARGET")
if [[ ! "$BASENAME" =~ ^[a-z0-9]([a-z0-9._-]*[a-z0-9])?$ ]]; then
  echo "web-start: target basename must be a valid npm package name (lowercase letters, digits, dots, hyphens, underscores; must start and end alphanumeric; got: $BASENAME)" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "web-start: node is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "web-start: pnpm is required but was not found on PATH (install pnpm, then retry)" >&2
  exit 1
fi

ARGS=(
  create-next-app@latest
  "$TARGET"
  --yes
  --ts
  --eslint
  --tailwind
  --app
  --no-src-dir
  --import-alias "@/*"
  --agents-md
  --empty
  --use-pnpm
  --no-agent-feedback
)

if [[ -d "$TARGET/.git" ]]; then
  ARGS+=(--disable-git)
fi

exec npx --yes "${ARGS[@]}"
