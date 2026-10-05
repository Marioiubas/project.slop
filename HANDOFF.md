# HANDOFF — 2026-10-05 — Stage 0: Foundations (skeleton, network layer, tests, tooling)

## Goal of this session
Implement all of Stage 0 and verify it (build, lint, types, tests, cold clone, Studio).

## What was done
- Rojo project `default.project.json` → `src/{shared,server,client}`; configs `stylua.toml`, `selene.toml`, `.luaurc`, `wally.toml` (no deps yet), `.gitignore`, `.gitattributes` (LF everywhere).
- Shared modules (`src/shared/`): `Config` (deep-frozen tunables), `Types`, `Log`, `Signal`, `Janitor`, `Safe` (xpcall + traceback), `Validate` (composable arg/shape validators), `Lifecycle` (dependency-ordered `init` then `start`).
- Network (ADR 0006): `Remotes.luau` registry (`Intent`/`Request`/`Notify`), server `Services/NetworkService` (rate limit → validate → handler), `server/RateLimiter`, client `Controllers/NetworkController`; `Ping` request wired end to end via `DiagnosticsService`/`DiagnosticsController`. Entry points: `server/Main.server.luau`, `client/Main.client.luau`.
- Content skeleton: `Content/{Rarities (5 tiers), Artifacts (empty), Schema}`, `ContentValidator`, `tools/validate_content`.
- Tests (ADR 0005): Lune pinned in `rokit.toml` (user trusted it); `tools/lib/rojo_loader.luau` loads real modules via `rojo sourcemap`; `tests/lib/testkit.luau`; 10 specs / 116 tests in `tests/specs/`. Mutation-checked: deliberately broken modules make them fail.
- `tools/check` (single gate), `tools/typecheck`, `README.md`; ADRs 0004/0005/0006; `how-to-work.md` + `CLAUDE.md` updated.

## State of the repo
- Branch: `stage0/rojo-skeleton` (from `chore/planning-docs`; neither merged to `main`). Implementation commit `27a0c31`; docs/handoff in the commits after it. **Pushed to `origin/stage0/rojo-skeleton`; no PR opened yet.**
- Builds: yes   Lint: pass (stylua, selene)   Types: pass (luau-lsp, old and new solver)   Tests: pass (116/116)
- Cold clone: fresh clone + `rokit install` + `lune run tools/check` → all 6 steps pass.
- Verified in Studio: yes, manually via MCP. The Rojo plugin was connected to `rojo serve` and synced the full tree. Play (server+client) booted with no errors, `Ping` round trip OK (steady ~50 ms), and string/negative/NaN/extra/missing args plus over-burst calls were rejected with throttled server warnings.

## Not done / stubbed / known broken
- `Artifacts` content is empty on purpose (Stage 1 adds the first, Stage 2 widens the schema).
- `NetworkService`, `NetworkController`, `Main.*` need Roblox APIs, so they are verified only by the manual Studio playtest above, not unit tests. Only `Request` (`Ping`) was exercised at runtime; the `Intent` and `Notify` paths exist but have not been run.
- Wally packages not mapped in the project (nothing to install yet; mapping needs a `$path` that exists). Stage 4 adds ProfileService + mapping.
- `tools/typecheck` needs a Roblox type-definitions file that is not in the repo (it found one from the Antigravity luau-lsp extension). Without it the step prints `SKIPPED`, and the gate still passes.

## Decisions made (and why)
- ADR [0004](docs/adr/0004-rojo-vs-studio-split.md) code vs `assets/`; [0005](docs/adr/0005-test-framework.md) Lune tests; [0006](docs/adr/0006-network-layer-and-bootstrap.md) remote registry + Lifecycle.
- `Safe.call` wraps xpcall: one place for tracebacks and it sidesteps a Luau typing quirk with `xpcall`/`pcall` on functions that return nothing.

## Noticed (out of scope, not acted on)
- Studio's open place is still the default Baseplate + SpawnLocation; the Rojo-synced tree is unsaved in that session. Stage 1's hub replaces the baseplate.
- First `Ping` after Play reads ~2 s (server warm-up); disable with `Config.Debug.PingOnStart` if noisy.
- luau-lsp 1.70.1 rejects `declare class` definition files from older releases; `tools/typecheck` converts them to `declare extern type`.
- `chore/planning-docs` already exists on `origin` (the previous handoff said unpushed).

## USER ACTION needed
- Review/merge `chore/planning-docs`, then `stage0/rojo-skeleton` (or tell Claude to open the PR(s); ADR 0003). Compare link: https://github.com/Marioiubas/project.slop/pull/new/stage0/rojo-skeleton
- Save/publish the Studio place when you want the Rojo-synced scripts persisted there.
- Luau Language Server 1.70.1 is now installed in VS Code and Cursor (Antigravity still has 1.66.0). It downloads Roblox type definitions the first time it opens a Roblox project; `tools/typecheck` picks them up automatically.

## Next step (exactly)
1. New branch `stage1/hub-greybox` (from `main` once merged, else from `stage0/rojo-skeleton`). Run `lune run tools/check` first to confirm a green baseline.
2. Stage 1, first group in `docs/dev-plan.md`: hub greybox (spawn facing a central portal) + portal moving the player into a Rift arena in the same place (ADR 0001). Author geometry in Studio, export to `assets/` per ADR 0004 (tags/attributes, no scripts in assets). New server logic as a `Services/` unit; any remote goes in `src/shared/Remotes.luau`.

## Files to read first next time
- `docs/how-to-work.md`, `docs/dev-plan.md` (Stage 1), `README.md`, ADRs 0001/0004/0006, blueprint "First-Time User Experience" and "Procedural Rift System".

## Plan status
Stage 0: 10/10 items done. Gate met? Yes (cold clone, 2026-10-05).
