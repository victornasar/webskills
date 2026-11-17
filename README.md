# webskills

Agent skills for starting a thin Next.js App Router app and layering the next boring defaults on top.

Host-agnostic: any coding agent that can load a `SKILL.md` (Cursor, Claude Code, Codex, Windsurf, …) can run these packages. This repo is documentation + process + thin scripts — not a template monorepo and not a SaaS.

## What you get

| Skill | Does | Does not |
| --- | --- | --- |
| [`init-next`](init-next/) | Empty Next.js App Router baseline via `create-next-app` (pnpm, TS, Tailwind, no `src/`, `--empty`) + `pnpm build` smoke | UI kits, auth, DB, feature folders, custom README |
| [`add-shadcn`](add-shadcn/) | Locked shadcn/ui init + fixed core primitives + Toaster mount + build smoke | Demos, example pages, per-run style/color picks |
| [`add-clerk`](add-clerk/) | Clerk auth infrastructure via the official CLI (accountless keys, public-by-default `proxy.ts`, `/sign-in` + `/sign-up`), shadcn theme when present + `clerk doctor` + build smoke | Dashboards, headers/user controls, route protection, roles, `.env.example` |
| [`add-env`](add-env/) | Build-time env validation (`@t3-oss/env-nextjs` + zod) adopting existing `.env*` names, tracked `.env.example`, `SKIP_ENV_VALIDATION` escape hatch + build smoke | Rewriting `process.env` usages, guessing types, overwriting an existing `.env.example` |
| [`add-guardrails`](add-guardrails/) | Core-ESLint bans as errors: no `useEffect`/`useLayoutEffect`/`useInsertionEffect`, `process.env` only in `lib/env.ts`, features imported only via `@/features/<name>`, inline `eslint-disable` inert; `components/ui` ignored + `AGENTS.md` section + lint check | New packages, rewriting violating code, warnings, escape-hatch wrappers |
| [`init-readme`](init-readme/) | Short high-signal `README.md` + optional `AGENTS.md` Project blurb | Badges, emoji essays, inventing product copy |

Typical pipeline (run only what you need, in order):

```text
init-next  →  add-shadcn  →  add-clerk  →  add-env  →  add-guardrails  →  init-readme
```

## Philosophy

1. **Deterministic where it matters** — official CLIs (`create-next-app`, `shadcn`, `clerk`) own files and versions; skills own process, guards, and completion criteria.
2. **Thin opinions** — locked defaults, no fat starter trees, no freehand generation of the whole app.
3. **Explicit invocation** — skills do not auto-fire; the human (or an explicit prompt) chooses them.
4. **Fail fast, leave the tree** — clear aborts; on smoke failure, no automatic rollback.
5. **Report and stop** — minimal success output; no unsolicited follow-on actions.
6. **Agent-friendly docs** — each skill has ordered steps with completion criteria; shared layout lives in one convention file.

## Repository layout

```text
webskills/
  README.md                 # this file (humans + agents)
  AGENTS.md                 # kit index for agents working in this repo
  conventions/
    feature-directories.md  # preferred app layout (single source of truth)
  init-next/
    SKILL.md
    scripts/init.sh
  add-shadcn/
    SKILL.md
    scripts/init.sh
  add-clerk/
    SKILL.md
    scripts/init.sh
  add-env/
    SKILL.md
    scripts/init.sh
  add-guardrails/
    SKILL.md
    scripts/init.sh
  init-readme/
    SKILL.md
```

## Install (any host)

Skills are discovered as **directories that contain `SKILL.md`**. Install each package you want as a top-level skill in your agent’s skills directory (names must stay `init-next`, `add-shadcn`, `add-clerk`, `add-env`, `add-guardrails`, `init-readme`).

Examples:

```bash
# Cursor (personal)
ln -s "$(pwd)/init-next"   ~/.cursor/skills/init-next
ln -s "$(pwd)/add-shadcn"  ~/.cursor/skills/add-shadcn
ln -s "$(pwd)/add-clerk"   ~/.cursor/skills/add-clerk
ln -s "$(pwd)/add-env"     ~/.cursor/skills/add-env
ln -s "$(pwd)/add-guardrails" ~/.cursor/skills/add-guardrails
ln -s "$(pwd)/init-readme" ~/.cursor/skills/init-readme

# Claude Code / generic agents dir (adjust path to your setup)
ln -s "$(pwd)/init-next"   ~/.agents/skills/init-next
ln -s "$(pwd)/add-shadcn"  ~/.agents/skills/add-shadcn
ln -s "$(pwd)/add-clerk"   ~/.agents/skills/add-clerk
ln -s "$(pwd)/add-env"     ~/.agents/skills/add-env
ln -s "$(pwd)/add-guardrails" ~/.agents/skills/add-guardrails
ln -s "$(pwd)/init-readme" ~/.agents/skills/init-readme
```

Or copy the folders instead of symlinking. Nested under `webskills/` is for **this kit’s source**; most hosts expect sibling skill folders at the skills root.

Project-scoped install: copy or symlink the same folders into a repo’s `.cursor/skills/` (or that host’s project skills path).

**Smoke test after install:** run `init-next` against an empty lowercase-named temp dir (e.g. `/tmp/webskills-smoke`) and confirm `pnpm build` passes there.

## Prerequisites

| Tool | Used by |
| --- | --- |
| Node.js | all scaffold scripts |
| pnpm | all skills (locked; no npm/yarn/bun switching) |
| Network | `npx` / `pnpm dlx` for CLIs |
| Clerk account | not needed — `add-clerk` uses accountless keys; claim the app later |

## Locked baselines (summary)

**init-next** — `create-next-app@latest` with: `--yes --ts --eslint --tailwind --app --no-src-dir --import-alias "@/*" --agents-md --empty --use-pnpm` plus `--no-agent-feedback`, and `--disable-git` only if `.git` already exists. Flags live in [`init-next/scripts/init.sh`](init-next/scripts/init.sh).

**add-shadcn** — `shadcn@latest init -d --base radix --css-variables --no-monorepo -y`, then add: `button` `input` `label` `card` `dialog` `dropdown-menu` `separator` `sonner` `skeleton`. Style ends up `radix-nova`, base color `neutral`, oklch CSS variables, RSC on. `form` omitted (current registry no-op). Flags live in [`add-shadcn/scripts/init.sh`](add-shadcn/scripts/init.sh).

**add-clerk** — `clerk@latest init --framework next --pm pnpm --accountless --no-skills -y`; if `components.json` exists, also `@clerk/ui` + the `shadcn` theme on `<ClerkProvider>` + `@clerk/ui/themes/shadcn.css`. Then `clerk doctor` + `pnpm build`. Flags live in [`add-clerk/scripts/init.sh`](add-clerk/scripts/init.sh).

**add-env** — no CLI; the script installs `@t3-oss/env-nextjs` + `zod`, reads variable names (never values) from `.env` / `.env.*`, and generates `lib/env.ts` (`z.string().min(1)` per name, `NEXT_PUBLIC_*` → client), `.env.example`, `!.env.example` in `.gitignore`, and `import "./lib/env"` atop `next.config.ts`. Run after skills that write env vars (e.g. `add-clerk`). Template lives in [`add-env/scripts/init.sh`](add-env/scripts/init.sh).

**add-guardrails** — no CLI, no packages; the script writes `eslint.guardrails.mjs` (core `no-restricted-imports` / `no-restricted-syntax` / `no-restricted-properties`, `noInlineConfig: true`, `components/ui/**` ignored), pushes it last in `eslint.config.mjs`, and appends a `## Guardrails` section to `AGENTS.md`. Requires `lib/env.ts` (run after `add-env`). `pnpm build` does not lint — bans bite where `pnpm lint` runs. Rules live in [`add-guardrails/scripts/init.sh`](add-guardrails/scripts/init.sh).

**init-readme** — no CLI; agent writes a fixed-shape README from name + one-sentence description (+ optional extra tech).

## App layout convention

After the baseline exists, prefer the structure in [`conventions/feature-directories.md`](conventions/feature-directories.md): thin `app/`, domain in `features/<name>/`, primitives in `components/ui/`, shared non-UI in `lib/`.

`init-next` deliberately does **not** create that tree — it stays an empty official baseline. Later skills and day-to-day work follow the convention.

## How agents should run a skill

1. Open the skill’s `SKILL.md`.
2. Follow steps in order; honor each completion criterion before moving on.
3. Treat `scripts/*.sh` as the source of truth for CLI flags.
4. Never scaffold into this kit directory.
5. On success: short report, stop. On failure: leave target as-is, report error, stop.

## Extending the kit

Add a new sibling folder with its own `SKILL.md` (and optional `scripts/`). Keep it thin, explicit-invocation, and point at [`conventions/feature-directories.md`](conventions/feature-directories.md) instead of forking layout rules. Update [`AGENTS.md`](AGENTS.md) and this README’s skill table.
