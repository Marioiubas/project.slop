# Phase 1 validation

Date: 5 October 2026. Luau toolchain: official 0.741 release.

## Completed automated checks

- All source modules, scripts, generated installer and test files compile with `luau-compile --null`.
- Pure planner, allocator and definitions pass strict `luau-analyze`. Roblox-aware engine type analysis was not performed; strict declarations/public signatures and the dynamic boundary are documented in ADR 0007.
- StyLua 2.5.2 and Selene 0.32.0 checks are clean. Rojo 7.7.1 builds `world.project.json` to a standalone place file.
- The merged main foundation's full check command passes formatting, lint, default Rojo build, 116 core tests and content validation. Its Roblox-aware type step printed SKIPPED because type definitions were unavailable; that step is not counted as verified type safety.
- Checked-in Command Bar bundle and SHA-256 manifest exactly match their source files.
- 1,000 seeds reproduce identical fingerprints on replay, form connected eight-room graphs, preserve extraction/cargo paths and produce 18 tested template/branch compositions.
- Negative graph checks reject overlaps, missing entry/landmark/extraction connectivity, bad socket opposition, narrow connectors, duplicated edges and false route metrics.
- Engine-double execution runs the **exact generated installer** and creates/validates all seven authored templates.
- 100 assembled maps contain the expected eight room floors/eight connector floors, with no intersecting floor footprints and zero unanchored physics parts or live artifacts.
- Template rejection checks cover actual cargo-lane obstruction, missing collision floor, inward sockets, narrow sockets and missing landmark.
- Four concurrent reservations are isolated. Exhaustion, stale lease tokens, failed generation, complete teardown and cell reuse are checked.
- Simultaneous main-portal requests reserve separate destinations while clients are still streaming; the join station can share the oldest open expedition. Pending-entry cancellation releases both maps and transitions.
- Transition checks cover forged tokens, distant extraction, destination timeout/failure, movement restoration, successful entry/return, closure during streaming and last-occupant cleanup.
- Installation rerun archives all five owned roots including template edits, preserves unrelated content, rejects foreign name collisions and leaves no staging folder.

These are executable source-level and engine-double checks. The double implements enough Instance/vector/CFrame behavior to exercise the authored geometry and services. It does **not** validate engine permissions, actual player/network physics, streaming arrival, rendered art, mobile memory/frame rate, or whether a first-time player finds the game fun.

## Studio verification attempt and remaining acceptance

Roblox Studio is installed and was found running on this host. An isolated place containing the exact installer as a temporary ModuleScript was built successfully with Rojo. Opening that place stalled in Studio's native file picker: Open remained disabled, then the picker and subsequent Studio UI calls timed out. The user's existing place was not overwritten or published. No installer execution or live playtest was observed, so the following checks remain open:

- [ ] Paste the entire distribution into the Edit-mode Command Bar. Confirm seven templates, preview and Output success; save the place.
- [ ] Press Play. Confirm the player faces the portal, the correct spawn is used even with a default Baseplate SpawnLocation, and the prompt is readable on touch/gamepad.
- [ ] Confirm the preview is removed, initial Rift generation is ready, and entry waits for the atomic destination room. Test under delayed networking.
- [ ] Walk the main and optional routes. Inspect door turns and carry clearance with a 24 × 24 debug cargo box; Phase 2 must test actual physics cargo.
- [ ] Return through extraction. Check movement/jump values, hub floor availability and last-player cleanup.
- [ ] Start a server with two clients: enter separate Rifts, then test joining an open Rift. Confirm no cross-Rift prompt/extraction membership.
- [ ] Respawn/disconnect while entering, while inside and while extracting. Check that reservations, pending tokens and maps disappear appropriately.
- [ ] Wait for unused-map and active-map expiry. Verify emergency return to the persistent hub and reusable cells.
- [ ] Fill all four cells, try a fifth, clean up and regenerate the same seed.
- [ ] Re-run installation in Edit mode with an edited template and unrelated build. Inspect the archive and verify the unrelated build is preserved.
- [ ] Profile low-to-mid-tier mobile hardware: frame time, memory, network traffic, generation time and streaming pause. Static part budgets are not measured device performance.

Production release still requires the later artifact/carry/hazard/museum systems and actual Studio/mobile acceptance. No production game, artifact economy or saved collection is claimed by this delivery.
