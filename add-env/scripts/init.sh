#!/usr/bin/env bash
# Source of truth for add-env: t3-env install, name-only .env* discovery, and generated files.
# Invoked by the add-env skill. Never prints environment values.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: init.sh <absolute-target-directory>" >&2
  exit 2
fi

TARGET="$1"

if [[ "$TARGET" != /* ]]; then
  echo "add-env: target must be an absolute path (got: $TARGET)" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "add-env: target directory does not exist: $TARGET" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "add-env: node is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "add-env: pnpm is required but was not found on PATH" >&2
  exit 1
fi

cd "$TARGET"

# src/ projects keep lib/ under src/ (matches add-shadcn).
if [[ -d src/app ]]; then
  LIB_DIR=src/lib
else
  LIB_DIR=lib
fi
ENV_FILE="$LIB_DIR/env.ts"

if [[ ! -f next.config.ts ]]; then
  echo "add-env: next.config.ts not found — only a TypeScript Next config is supported. Aborting." >&2
  exit 1
fi

if grep -q '"@t3-oss/env-nextjs"' package.json 2>/dev/null; then
  echo "add-env: @t3-oss/env-nextjs already in package.json — env validation appears initialized. Aborting." >&2
  exit 1
fi

if [[ -e "$ENV_FILE" ]]; then
  echo "add-env: $ENV_FILE already exists. Aborting." >&2
  exit 1
fi

if [[ -e .env.example ]]; then
  echo "add-env: .env.example already exists — refusing to overwrite developer-maintained docs. Aborting." >&2
  exit 1
fi

# Names only, from .env and .env.* (not .env.example, not .envrc). Uses dotenv's line grammar so
# comments, `export` prefixes, quoted and multi-line values never produce names. Values stay in memory.
NAMES=$(node -e '
const fs = require("fs");
const LINE = /(?:^|^)\s*(?:export\s+)?([\w.-]+)(?:\s*=\s*?|:\s+?)(\s*\x27(?:\\\x27|[^\x27])*\x27|\s*"(?:\\"|[^"])*"|\s*`(?:\\`|[^`])*`|[^#\r\n]+)?\s*(?:#.*)?(?:$|$)/mg;
const names = new Set();
for (const f of fs.readdirSync(".")) {
  if (f !== ".env" && !f.startsWith(".env.")) continue;
  if (f === ".env.example" || !fs.statSync(f).isFile()) continue;
  const src = fs.readFileSync(f, "utf8").replace(/\r\n?/g, "\n");
  for (const m of src.matchAll(LINE)) {
    if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(m[1])) names.add(m[1]);
  }
}
console.log([...names].sort().join("\n"));
')

SERVER=()
CLIENT=()
while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  if [[ "$name" == NEXT_PUBLIC_* ]]; then
    CLIENT+=("$name")
  else
    SERVER+=("$name")
  fi
done <<< "$NAMES"

pnpm add @t3-oss/env-nextjs zod --config.strict-dep-builds=false

# Prints `  key: {` + one line per name + `  },`, or `  key: {},` when there are no names.
block() {
  local key="$1" fmt="$2"
  shift 2
  if [[ $# -eq 0 ]]; then
    echo "  $key: {},"
    return
  fi
  echo "  $key: {"
  for n in "$@"; do echo "    ${fmt//\{\}/$n}"; done
  echo '  },'
}

mkdir -p "$LIB_DIR"
{
  echo 'import { createEnv } from "@t3-oss/env-nextjs";'
  if [[ ${#SERVER[@]} -gt 0 || ${#CLIENT[@]} -gt 0 ]]; then echo 'import { z } from "zod";'; fi
  echo
  echo 'export const env = createEnv({'
  block server '{}: z.string().min(1),' ${SERVER[@]+"${SERVER[@]}"}
  block client '{}: z.string().min(1),' ${CLIENT[@]+"${CLIENT[@]}"}
  block runtimeEnv '{}: process.env.{},' ${SERVER[@]+"${SERVER[@]}"} ${CLIENT[@]+"${CLIENT[@]}"}
  echo '  skipValidation: !!process.env.SKIP_ENV_VALIDATION,'
  echo '  emptyStringAsUndefined: true,'
  echo '});'
} > "$ENV_FILE"

{
  for n in ${SERVER[@]+"${SERVER[@]}"} ${CLIENT[@]+"${CLIENT[@]}"}; do echo "$n="; done
} > .env.example

if ! grep -qx '!.env.example' .gitignore 2>/dev/null; then
  if [[ -s .gitignore && -n "$(tail -c1 .gitignore)" ]]; then echo >> .gitignore; fi
  printf '!.env.example\n' >> .gitignore
fi

# Validate env at build time: next.config.ts imports the env module first.
CONFIG_IMPORT="import \"./$LIB_DIR/env\";"
{ echo "$CONFIG_IMPORT"; cat next.config.ts; } > next.config.ts.tmp && mv next.config.ts.tmp next.config.ts

echo "add-env: wrote $ENV_FILE (${#SERVER[@]} server, ${#CLIENT[@]} client), .env.example, .gitignore, next.config.ts"
