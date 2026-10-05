# ADR 0007 — Portable Command Bar world foundation

Status: proposed for this feature PR (5 October 2026).

## Context

The user explicitly requested Lua implementation of the supplied world brief, a Command Bar ready delivery and a GitHub push. At initial inspection, main contained only the master blueprint (`1529d7b`). While implementation was underway, planning docs were merged (`77a6e6a`); the separate Stage 0 Rojo/network foundation then merged in [PR #2](https://github.com/Marioiubas/project.slop/pull/2) at `64e49a9` during publication.

The world brief asks for audit then Phase 1: allocator, socket contract, reusable rooms, deterministic assembly and validation. This request authorizes that scoped world task ahead of the global plan's artifact/carry gates. It does not make the full Stage 3 or MVP complete.

## Decision

- Isolate portable source under `src/world/` with owned `Oddvault*` instance roots. Preserve the Stage 0 services/controllers.
- Generate the offline Command Bar distribution from the same source files. No remote code loading, imported assets or plugin requirement.
- Supply `world.project.json` as an optional standalone Rojo build. Its bootstrap recreates the authored kit at runtime if the Command Bar installation is absent; Command Bar users keep editable templates in ServerStorage.
- Follow ADR 0003: push `stage3/command-bar-world-foundation` and open a PR; the user merges.
- Use strict declarations and typed public APIs. Strict analysis passes for the pure planner/allocator/definitions. Full Roblox-aware analysis is still a gate; the dynamic standalone Instance/service boundary uses `any` and runtime validation.
- Keep artifacts/rewards, carrying, hazards, persistence and other dimensions out of this Phase 1 delivery.

## Consequences

The package works independently of PR #2 and does not replace the main Rojo project. Stage 0 merged at 64e49a9 during publication. Integrate the world through its Lifecycle and remote registry before adopting one production architecture. Until then its remotes are a standalone adapter. Do not blindly combine both Rojo projects; review their instance mappings and network contracts.

The existing Stage 0 foundation is preserved; later gameplay/playtest gates remain open. Source authority stays in Git; regenerate the Command Bar bundle after source edits.
