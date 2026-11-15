#!/usr/bin/env bash
# Source of truth for shadcn init + core component add. Invoked by the add-shadcn skill.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: init.sh <absolute-target-directory>" >&2
  exit 2
fi

TARGET="$1"

if [[ "$TARGET" != /* ]]; then
  echo "add-shadcn: target must be an absolute path (got: $TARGET)" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "add-shadcn: target directory does not exist: $TARGET" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "add-shadcn: node is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "add-shadcn: pnpm is required but was not found on PATH" >&2
  exit 1
fi

if [[ -f "$TARGET/components.json" ]]; then
  echo "add-shadcn: components.json already exists — shadcn appears initialized. Aborting." >&2
  exit 1
fi

# Locked init: CLI v4 defaults → style radix-nova, baseColor neutral, cssVariables true, rsc true, oklch theme.
pnpm dlx shadcn@latest init -d --base radix --css-variables --no-monorepo -y -c "$TARGET"

# Fixed core primitives. form omitted: current registry yields no files.
COMPONENTS=(
  button
  input
  label
  card
  dialog
  dropdown-menu
  separator
  sonner
  skeleton
)

pnpm dlx shadcn@latest add "${COMPONENTS[@]}" -y -c "$TARGET"
