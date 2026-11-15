# webskills

Agent skills for starting a thin Next.js App Router app and layering the next boring defaults on top.

Host-agnostic: any coding agent that can load a `SKILL.md` (Cursor, Claude Code, Codex, Windsurf, …) can run these packages. This repo is documentation + process + thin scripts — not a template monorepo and not a SaaS.

## What you get

| Skill | Does | Does not |
| --- | --- | --- |
| [`init-next`](init-next/) | Empty Next.js App Router baseline via `create-next-app` (pnpm, TS, Tailwind, no `src/`, `--empty`) + `pnpm build` smoke | UI kits, auth, DB, feature folders, custom README |
| [`add-shadcn`](add-shadcn/) | Locked shadcn/ui init + fixed core primitives + Toaster mount + build smoke | Demos, example pages, per-run style/color picks |
| [`init-readme`](init-readme/) | Short high-signal `README.md` + optional `AGENTS.md` Project blurb | Badges, emoji essays, inventing product copy |

Typical pipeline (run only what you need, in order):

```text
init-next  →  add-shadcn  →  init-readme
```

## Philosophy

1. **Deterministic where it matters** — official CLIs (`create-next-app`, `shadcn`) own files and versions; skills own process, guards, and completion criteria.
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
  init-readme/
    SKILL.md
```

## Install (any host)

Skills are discovered as **directories that contain `SKILL.md`**. Install each package you want as a top-level skill in your agent’s skills directory (names must stay `init-next`, `add-shadcn`, `init-readme`).

Examples:

```bash
# Cursor (personal)
ln -s "$(pwd)/init-next"   ~/.cursor/skills/init-next
ln -s "$(pwd)/add-shadcn"  ~/.cursor/skills/add-shadcn
ln -s "$(pwd)/init-readme" ~/.cursor/skills/init-readme

# Claude Code / generic agents dir (adjust path to your setup)
ln -s "$(pwd)/init-next"   ~/.agents/skills/init-next
ln -s "$(pwd)/add-shadcn"  ~/.agents/skills/add-shadcn
ln -s "$(pwd)/init-readme" ~/.agents/skills/init-readme
```

Or copy the three folders instead of symlinking. Nested under `webskills/` is for **this kit’s source**; most hosts expect sibling skill folders at the skills root.

Project-scoped install: copy or symlink the same three folders into a repo’s `.cursor/skills/` (or that host’s project skills path).

**Smoke test after install:** run `init-next` against an empty lowercase-named temp dir (e.g. `/tmp/webskills-smoke`) and confirm `pnpm build` passes there.

## Prerequisites

| Tool | Used by |
| --- | --- |
| Node.js | all scaffold scripts |
| pnpm | all skills (locked; no npm/yarn/bun switching) |
| Network | `npx` / `pnpm dlx` for CLIs |

## Locked baselines (summary)

**init-next** — `create-next-app@latest` with: `--yes --ts --eslint --tailwind --app --no-src-dir --import-alias "@/*" --agents-md --empty --use-pnpm` plus `--no-agent-feedback`, and `--disable-git` only if `.git` already exists. Flags live in [`init-next/scripts/init.sh`](init-next/scripts/init.sh).

**add-shadcn** — `shadcn@latest init -d --base radix --css-variables --no-monorepo -y`, then add: `button` `input` `label` `card` `dialog` `dropdown-menu` `separator` `sonner` `skeleton`. Style ends up `radix-nova`, base color `neutral`, oklch CSS variables, RSC on. `form` omitted (current registry no-op). Flags live in [`add-shadcn/scripts/init.sh`](add-shadcn/scripts/init.sh).

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
