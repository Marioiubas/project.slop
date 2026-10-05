# GRAB THE WEIRD! (PROJECT ODDVAULT) — Roblox game, Rojo project

Read, in this order, at the start of every session:
1. `HANDOFF.md` — state from the last session and the exact next step
2. `docs/how-to-work.md` — the workflow, coding standards, and definition of done (**mandatory**)
3. `docs/dev-plan.md` — staged plan; work only on the current stage
4. `docs/grab-the-weird-blueprint.md` — product/design source of truth (read relevant sections only)

Non-negotiables:
- Server is authoritative; the client only sends intent.
- `lune run tools/check` must pass before you finish (format, lint, types, build, tests, content). Auto-format with `stylua src tests tools`.
- One task per session; finish by updating `docs/dev-plan.md` and overwriting `HANDOFF.md` using the template in how-to-work.md.
- Be honest about what was and wasn't verified.
