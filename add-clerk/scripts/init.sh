#!/usr/bin/env bash
# Source of truth for Clerk CLI init + shadcn theme package. Invoked by the add-clerk skill.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: init.sh <absolute-target-directory>" >&2
  exit 2
fi

TARGET="$1"

if [[ "$TARGET" != /* ]]; then
  echo "add-clerk: target must be an absolute path (got: $TARGET)" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "add-clerk: target directory does not exist: $TARGET" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "add-clerk: node is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "add-clerk: pnpm is required but was not found on PATH" >&2
  exit 1
fi

if grep -q '"@clerk/nextjs"' "$TARGET/package.json" 2>/dev/null; then
  echo "add-clerk: @clerk/nextjs already in package.json — Clerk appears initialized. Aborting." >&2
  exit 1
fi

for f in proxy.ts middleware.ts src/proxy.ts src/middleware.ts; do
  if [[ -e "$TARGET/$f" ]]; then
    echo "add-clerk: $f already exists — merging into an existing proxy/middleware is unsupported. Aborting." >&2
    exit 1
  fi
done

cd "$TARGET"

# Locked init: accountless temporary keys → .env.local; --no-skills keeps agent skills out of global dirs.
pnpm dlx clerk@latest init --framework next --pm pnpm --accountless --no-skills -y

# shadcn theme package, only when shadcn is initialized. core-js (transitive) has a banner-only
# postinstall; pnpm's strict build check would fail the add, so keep it ignored without failing.
if [[ -f components.json ]]; then
  pnpm add @clerk/ui --config.strict-dep-builds=false
fi
