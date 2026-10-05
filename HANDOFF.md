# HANDOFF — 2026-10-05 — Planning + toolchain

## Goal of this session
Planning docs, workflow, toolchain install, and the first three decisions.

## What was done
- `docs/dev-plan.md`, `docs/how-to-work.md`, `CLAUDE.md`, this handoff.
- Toolchain installed and pinned in `rokit.toml`: rojo 7.7.1, StyLua 2.5.2, selene 0.32.0, luau-lsp 1.70.1, wally 0.3.2 (all verified with `--version`).
- ADRs: 0001 Rifts in same place, 0002 ProfileService behind `DataService`, 0003 git policy.

## State of the repo
- Branch: `chore/planning-docs`, committed locally, **not pushed**.
- No game code yet. Builds/lint/tests: n/a.

## Not done / known caveats
- ProfileService is the older library (successor: ProfileStore); wrapped behind `DataService` so it's swappable.
- stylua/selene/luau-lsp/wally configs not created yet.

## USER ACTION needed
- Create an empty Roblox place (private/unpublished is fine) and decide if Studio MCP will be connected.
- Review/merge the planning branch (or tell Claude to push and open a PR).

## Next step (exactly)
1. New branch `stage0/rojo-skeleton` from `main` (after planning branch is merged, or from it).
2. Stage 0 in `docs/dev-plan.md`: `default.project.json`, `src/{shared,server,client}`, `stylua.toml`, `selene.toml`, `wally.toml`, `.gitignore`, `.gitattributes`; verify `rojo build`.

## Files to read first next time
- `docs/how-to-work.md`, `docs/dev-plan.md`, `docs/adr/*`

## Plan status
Stage 0: 1/10 items done (toolchain).
