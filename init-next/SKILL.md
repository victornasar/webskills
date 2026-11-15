---
name: init-next
description: >-
  Initializes a greenfield local Next.js App Router app via create-next-app
  (pnpm, empty baseline) with guards and a build smoke check.
disable-model-invocation: true
---

# init-next

Greenfield-only. Deterministic empty App Router baseline. No stack add-ons, no feature-directory scaffolding, no per-run flag overrides.

Part of the [webskills](../README.md) kit. Layout convention for *later* work: [`../conventions/feature-directories.md`](../conventions/feature-directories.md) — do not apply it during this skill.

Flag source of truth: [`scripts/init.sh`](scripts/init.sh) — do not restate or invent flags.

## Steps

1. **Resolve target**
   - Default: current workspace root.
   - If the user named another path, use that.
   - If that path is a new child directory that does not exist yet: parent must exist; create the child; then treat it as the target.
   - Project name = basename of the target (must be a valid npm package name: lowercase; `init.sh` enforces this).
   - Completion: absolute target path chosen.

2. **Self-hit guard**
   - Abort if the target is this skill package (contains this skill’s `SKILL.md` with `name: init-next`, or is clearly the `init-next` skill root).
   - Completion: target is not the skill package.

3. **Emptiness / greenfield guard**
   - Abort if `package.json` exists, or `app/` exists, or `src/app/` exists.
   - Abort if any entry exists outside the allowlist: `.git`, `.gitignore`, `.DS_Store`, `.cursor/`.
   - Completion: target is allowlist-only (or fully empty).

4. **Scaffold**
   - Run this skill’s `scripts/init.sh` with the absolute target path (requires network for `npx`).
   - Completion: script exits 0.

5. **Smoke check**
   - From the target: `pnpm build`.
   - On failure: leave the tree as-is, surface the error, stop. No rollback.
   - Completion: `pnpm build` exits 0.

6. **Report and stop**
   - Report only: absolute target path; scaffold + `pnpm build` passed; how to run `pnpm dev`.
   - Do not start `dev`, open a browser, commit, or deploy unless the user asks in the same turn.
   - Completion: minimal report delivered; no unsolicited follow-on.

## Ask only when blocked

Ask for a different path only when the default/cwd fails emptiness, allowlist, or self-hit checks — or when the user already named another path that still needs clarification.
