# GRAB THE WEIRD! / PROJECT ODDVAULT

**Jump through a portal. Grab something weird. Get it home alive.**

This repository contains the game blueprint, **Phase 1 world foundation**, and an **explorable Dimension Bible map** built from the approved references. The Roblox Luau implementation ships as a single offline Studio Command Bar installer.

## Install in Roblox Studio

To open the illustrated map directly, use Studio’s **Open from File** with [assets/OddvaultDimensionMap.rbxl](assets/OddvaultDimensionMap.rbxl), then press Play. The Command Bar option below installs the same source into an existing place.

1. Open a place in Studio and **stop Play**. A fresh Baseplate place is convenient.
2. Open **View → Command Bar** (or find Command Bar through Studio's search).
3. Open [`dist/OddvaultCommandBar.lua`](dist/OddvaultCommandBar.lua), use **Raw**, and copy the **entire file**.
4. Paste it into the **Command Bar in Edit mode** and execute it once. It installs the map, museum, modules, room templates and a seeded preview. It preserves unrelated place objects.
5. Check Output for `[Oddvault] Installed Dimension Bible map…`. In Workspace Properties, confirm `StreamingEnabled = true`, `StreamingMinRadius = 64`, `StreamingTargetRadius = 384`; the installer attempts to set these and reports any permission failure.
6. Press **Play**. Walk behind the hub along the bridge to explore the Nexus and its themed islands. The illustrated extraction deck returns you to the museum. The hub's cyan Rift portal still starts the separate kitchen expedition, where **Return home** completes its route. **Explore together** joins an open Rift.
7. Stop Play and save the place to preserve the installation.

No plugin, Rojo, HTTP request, loadstring, imported model or external asset ID is needed. Paste into Studio's **Command Bar**, not a Script or the in-game developer console: the installer needs Studio permission to write script Source. Installer settings are at the top of the file.

## What is implemented

- A research hub, circular portal arch, Dimensional Atlas and a level-access museum displaying seven modeled artifacts.
- An explorable Fracture Nexus with Kitchen, Moon Aquarium, Toybox, inverted City, Deep Fracture, Kitchen/Aquarium crossover, rare room and extraction deck. Native editable parts, solid bridges and region signs illustrate the reference composition. [Map details and Studio evidence](docs/NEXUS_MAP_ILLUSTRATION.md).
- Seven authored room templates: entry, five gameplay room types, extraction. Seeded selection assembles eight rooms, a main route and an optional branch that rejoins it.
- A 640-stud main route with 24 × 24-stud cargo clearance, standardized outward-facing sockets, unused exit sealing, level collision floors and validation of actual authored collision parts.
- Four exclusive reusable Rift cells near the origin. Maps publish only after validation; failures roll back and release reservations.
- Server-controlled entry, open expedition joining, streamed destination checks, distance/state validation, token checks, remote rate limits, return-to-hub extraction and bounded cleanup.
- Ninety-second unused-map expiry and four-minute active route tests. Respawn, disconnect, last-player departure and timeout handling.
- Studio-only bounds, socket links, room IDs, seed reproduction and instance/part/physics/light/NPC statistics.
- A generated distribution with source hashes, automated Luau tests and GitHub validation.

**This is a world foundation and playable map illustration, not a finished game.** Museum artifacts are display geometry. Physical carrying, artifact rewards, dimension-specific gravity/water/machinery, timed collapse, saved collections, progression, economy and audio are later gameplay work. Extraction returns the player home without granting items or currency. `InstabilityLevel` is diagnostic pacing metadata until Phase 2.

## Studio debug commands

During Play, use the **server** Command Bar:

```lua
local result = workspace.OddvaultWorld.DebugActions:Invoke("generate", "GiantsKitchen", 12345)
print(result.RiftId, result.CellId, result.Error)
```

```lua
print(workspace.OddvaultWorld.DebugActions:Invoke("stats"))
workspace.OddvaultWorld.DebugActions:Invoke("visualize", true)
workspace.OddvaultWorld.DebugActions:Invoke("visualize", false)
print(workspace.OddvaultWorld.DebugActions:Invoke("cleanup").CellsInUse)
```

Debug generation uses the same allocator and validation as normal entry. It refuses a fifth simultaneous map. Debug tools are absent in published servers. The edit-mode preview is removed automatically when Play starts.

## Editing the kit

Templates live in `ServerStorage/OddvaultTemplates/GiantsKitchen/Rooms`. Follow the [room and socket contract](WORLD_ARCHITECTURE_AUDIT.md). Keep the floor center pivot, all four socket attributes/orientations, the full level floor, and the clear 24 × 24 cross-shaped lanes. Decorative props can use non-colliding geometry; blocking geometry must pass validation.

Add a same-sized room by copying a valid template, assigning its `RoomId`/`Role` attributes, and adding matching entries to `RoomDefinitions` and the dimension's `RoomSet`. No RiftGenerator change is needed. Move or add tagged ArtifactSpawn markers visually in Studio; actual artifact spawning is Phase 2. Return routes intentionally use the same heavy-cargo dimensions throughout this first kit.

Re-running the installer creates a fresh installation and archives the previous five owned roots under `ServerStorage/OddvaultBackups`. **Your edited templates remain in that backup.** Restore selected edits manually before testing again. A name conflict with an unowned root stops installation before changing existing content. The installer refuses to run during Play.

## Source and validation

- [Architecture audit](WORLD_ARCHITECTURE_AUDIT.md)
- [Product blueprint](docs/grab-the-weird-blueprint.md)
- [Supplied world specification](docs/world-design-specification.md)
- [Art direction and references](docs/art-direction.md)
- [Higgsfield visual-development pipeline](docs/HIGGSFIELD_DIMENSION_VISUAL_PIPELINE.md) and [eight proposed reference studies](docs/visual-references/README.md)
- [Validation results and remaining Studio checks](docs/PHASE_1_VALIDATION.md)

The distribution is generated from `src/world/`, which is the source of truth. After editing source files:

```sh
python3 tools/build_command_bar.py
python3 tools/run_tests.py --luau /path/to/luau --compiler /path/to/luau-compile --analyzer /path/to/luau-analyze
```

Tests use the official [Luau 0.741](https://github.com/luau-lang/luau/releases/tag/0.741) compiler/runtime. The standalone engine double checks geometry math and lifecycle code; it does not emulate Roblox rendering, physics, replication or Studio permissions. Official Studio MCP now verifies installer execution, one-client entry/route/extraction and four-cell cleanup in an isolated place; [validation evidence](docs/PHASE_1_VALIDATION.md) records the scope. Two-client, physical-cargo and mobile tests remain open.

The optional standalone Rojo path is `rojo build world.project.json -o world.rbxlx` (Rojo 7.7.1). Its bootstrap recreates the kit without the Command Bar install. Use `world.project.json` explicitly; the main game's separate foundation from PR #2 is now merged. [ADR 0007](docs/adr/0007-command-bar-world-package.md) describes the integration boundary. Review the mappings before running both source-sync projects against one place.

Formatting/lint: `stylua --config-path tools/world-stylua.toml --check src/world tests` and `selene --config tools/world-selene.toml src/world`. Pure module strict analysis passes; full Roblox-aware engine type analysis is still unverified.

## Main Rojo foundation

A Roblox game about physically grabbing strange artifacts from unstable Rifts and escaping with them. Built with Rojo; design lives in [docs/grab-the-weird-blueprint.md](docs/grab-the-weird-blueprint.md), the plan in [docs/dev-plan.md](docs/dev-plan.md), and the working rules in [docs/how-to-work.md](docs/how-to-work.md).

## Set up (cold clone)

```bash
rokit install            # installs the pinned tools in rokit.toml (rojo, stylua, selene, luau-lsp, wally, lune)
lune run tools/check     # format, lint, types, build, unit tests, content validation
```

`rokit` asks you to trust each tool the first time. Make sure `~/.rokit/bin` is on your PATH.

## Everyday commands

| Task | Command |
|---|---|
| Everything the gate checks | `lune run tools/check` |
| Unit tests (optionally filtered by name) | `lune run tests/run [filter]` |
| Validate game content | `lune run tools/validate_content` |
| Strict type check (needs Roblox type definitions, see the script header) | `lune run tools/typecheck` |
| Auto-format | `stylua src tests tools` |
| Live-sync into Studio | `rojo serve`, then click Connect in the Rojo plugin |
| Build a place file | `rojo build default.project.json -o build/GrabTheWeird.rbxl` |

## Layout

```
src/shared/   types, config, content data, pure logic (loaded by server and client)
src/server/   Services: authoritative state, validation (Main.server.luau boots them)
src/client/   Controllers: input, UI, feedback (Main.client.luau boots them)
tests/        unit tests (specs/*.spec.luau) run under Lune
tools/        check, typecheck, validate_content, and the Rojo-aware module loader
assets/       Studio-authored .rbxm pieces (see ADR 0004)
docs/         blueprint, plan, workflow, ADRs
```
