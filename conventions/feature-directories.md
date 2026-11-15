# Feature directories

Preferred layout for apps produced or extended by this kit.

```
app/                    # routing only — keep thin
  (groups)/             # route groups when useful
  layout.tsx
  page.tsx
features/<name>/        # domain / vertical slices
  components/
  actions.ts            # server actions
  hooks/
  types.ts
  index.ts              # public API
components/
  ui/                   # shared UI primitives (e.g. shadcn)
lib/                    # shared non-UI (db, utils, …)
```

## Rules

1. Keep `app/` thin. Pages mostly compose features.
2. Put domain logic, feature-specific components, actions, and hooks in `features/<name>/`.
3. Shared UI primitives live in `components/ui/`.
4. Prefer colocation over scattering by technical type alone.

Do not scaffold empty `features/` trees unless the user asks. Document the convention; create folders when the first real feature lands.
