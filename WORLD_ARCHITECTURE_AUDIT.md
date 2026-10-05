# World architecture audit — GRAB THE WEIRD!

Audit date: 5 October 2026. Repository: `Marioiubas/project.slop`, baseline commit `1529d7b`.

## Existing project and reusable material

At the initial baseline, the tracked repository contained one file, `docs/grab-the-weird-blueprint.md` (1,089 lines). It describes the product, physical recovery loop, museums, networking and persistence requirements. There was no Roblox place, Luau source, framework, dependency manager, networking layer, data implementation, map asset, Rift system, or streaming configuration to reuse. No repository AGENTS.md was present. This was a documentation baseline, not an existing playable game.

Before publication, a fresh fetch found planning/toolchain docs merged at `77a6e6a` and an unmerged Rojo foundation in PR #2. The updated process and ADR 0003 were read, and this branch was fast-forwarded onto the new main before committing. Portable source was moved under `src/world/` to preserve that separate work. ADR 0007 records the explicit Command Bar scope and future integration with Stage 0's Lifecycle/remote registry. The unmerged foundation is not claimed as implemented by this delivery.

The existing blueprint remains the product authority. The supplied world specification narrows this implementation to its explicit first delivery: audit, then **Phase 1**. The supplied icon and thumbnail are visual references, not executable instructions or Roblox assets. Their useful cues are giant household silhouettes, warm countertop colors, a cyan portal, gold treasure and playful adventure. They do not authorize invented external asset IDs or require recreating the rendered marketing scene.

## Conflicts and limits

- The full blueprint calls for a persistent museum/economy. There is no implementation to integrate. Phase 1 must not claim permanent artifact ownership, saved layouts, paid rewards, trading or a complete launch game.
- The world brief specifies engineering foundations before polished dimensions. Build one kitchen-themed structural kit with five gameplay room types plus entry/extraction; Moon Aquarium and Toybox remain later phases.
- Roblox engine physics, client streaming, camera behavior and mobile performance cannot be established by a standalone Luau runner. Automated graph tests complement a Studio acceptance checklist; they do not replace it.
- A generic avatar path is insufficient for large cargo. The kit reserves a 24-stud-wide, 24-stud-high cross-shaped carry lane through each room and every connector. Validation must examine actual collision parts against that lane as well as the room graph.
- Command Bar installation must work without HttpGet, loadstring, asset imports, plugins or Rojo. Reinstallation must preserve unrelated place content and archive the previous owned installation.

## Recommended implementation sequence

1. Versioned definitions, deterministic graph planner, exclusive cell allocator and validation.
2. Author a small reusable kit in ServerStorage; connect it with tagged, outward-facing sockets and seal unused exits.
3. Instantiate only validated maps, with rollback and cell release on failure.
4. Add a compact hub, server-owned portal entry, extraction return and bounded lifecycle for multiplayer route playtesting.
5. Add reproducible debug generation, visualization, statistics and a self-contained Command Bar distribution.
6. Validate determinism, invalid content rejection, connectivity, cargo clearance, allocation exhaustion/reuse and teardown. Then playtest in Studio before Phase 2 hazards/artifacts.

## Proposed file and instance structure

```text
src/world/shared/ Constants, DimensionDefinitions, RoomDefinitions, GraphPlanner
src/world/server/ RiftCellAllocator, RiftGenerator, RiftService, WorldBuilder, DebugService, Bootstrap
src/world/client/ WorldClient.client.lua
tools/           build_command_bar.py
dist/            OddvaultCommandBar.lua (generated, self-contained)
tests/           standalone Luau invariants + Studio acceptance checklist

ReplicatedStorage/OddvaultShared       definition modules + transition remotes
ServerScriptService/OddvaultServer     services + bootstrap
ServerStorage/OddvaultTemplates/GiantsKitchen/Rooms
ServerStorage/OddvaultBackups          earlier owned installations on rerun
Workspace/OddvaultWorld
    Hub
    MuseumRuntime                    reserved; no persistence or museum economy in Phase 1
    RiftRuntime/Rift_<id>
        Geometry                     atomic streaming per room/connector
        Gameplay                     entry/extraction markers
        Artifacts, Hazards, Players, Effects (extension containers)
StarterPlayer/StarterPlayerScripts/OddvaultClient
```

The standalone package needs no external framework. Its networking adapter uses server prompts and a narrowly scoped transition acknowledgement. A client acknowledgement cannot award loot or define a destination. Debug mutations are Studio-only. After Stage 0 is merged, production integration should reuse its network registry and Lifecycle rather than retain independent bootstraps.

## Room format and socket contract

A room Model has a `RoomId`, `Role`, `KitVersion`, `Width`, `Depth`, `Height`, `CarryWidth` and `CarryHeight`. Its pivot is the floor center at local Y=0. Structural dimensions use an eight-stud grid. Initial rooms are 96 × 96 studs, separated by 32-stud connectors.

```text
Room
    Geometry
    Collision
    Decoration
    Sockets             invisible parts tagged RiftSocket
    SpawnPoints         PlayerSpawn tags
    ArtifactPoints      ArtifactSpawn tags (reserved, curated designer markers)
    HazardPoints        HazardSpawn tags (reserved)
    LandmarkPoints      Landmark tags
    Bounds              invisible RoomBounds part
```

Sockets carry `Direction` (N/S/E/W), `SocketType`, `WidthClass`, `HeightClass`, numeric `Width`/`Height`, `AllowedConnections`, `DoorStyle`, `OneWay` and `DifficultyTag`. Their LookVector points outward; local Y is the doorway center. Connections use attributes and tags, not socket object names. Unsupported socket types, one-way routes, bad orientation, dimensions, overlaps and collision obstruction are rejected for this kit.

Artifact markers include `SizeClass`, `RarityRange`, `AllowedCategories`, `CarryDifficulty`, `RequiresCoop`, `HazardAssociation` and `VisibilityClass`. They are authoring placeholders in Phase 1, not collectible or reward systems.

## DimensionDefinition schema

`DimensionId`, `DisplayName`, `FantasySentence`, `CorePhysicalRule`, `SecondaryRule`, `TraversalModifier`, `PrimaryHazard`, `SecondaryHazards`, `ArtifactBehaviourBias`, `MutationBias`, `InstabilityBehaviour`, `ExtractionBehaviour`, `ColorPalette`, `LightingProfile`, `AudioProfile`, `RoomSet`, `PropSet`, `CreatureSet`, `RarityWeights`, `DifficultyRange`, `CoopMechanic`, `SignatureLandmark`, `SecretRules`, `Enabled`, `GenerationVersion`.

Only GiantsKitchen is enabled. Its scale identity is introduced through authored oversized household props; dynamic kitchen behavior is Phase 2. No placeholder dimension is advertised as a playable alternate physical rule.

## RiftDefinition schema and lifecycle

`RiftId`, `DimensionId`, `Seed`, `Difficulty`, `PartyId`, `GenerationVersion`, `CellId`, `Origin`, `Graph`, `RoomLinks`, `MainPathLength`, `State`, `CreatedAt`, `ExpiresAt`, `InstabilityLevel`, `Occupants`, `Statistics`.

Lifecycle: `Reserved → Generating → Ready → Active → Closing → Destroyed`. The allocator has a bounded pool near the origin, exclusive reservation tokens and release checks. A generation failure destroys partial instances and releases its cell. Ready maps expire if unused. Active maps end after a bounded test duration or when their last occupant leaves. Entry/extraction operations verify the player, current membership, character state and distance on the server. Respawn/disconnect clears membership; cleanup cancels pending transitions and removes all owned map instances/connections.

Phase 1 instability is diagnostic pacing metadata only. It must be labeled as such until world-changing hazards are implemented. Extraction returns a player home; it does not grant an artifact or currency.

## Validation and release gates

Automated checks: deterministic fingerprints over many seeds; 8-room connected graph with optional rejoining branch; 640-stud main route; 24 × 24 cargo route; valid entry/extraction/landmark; sockets and authored collision clearance; no room/connector overlaps; budget enforcement; allocator exhaustion, stale-token rejection and reuse; installer source parity and Luau compilation.

Studio checks: paste into **Edit mode**, inspect templates/debug overlay, start a server with two clients, enter different Rifts, verify streaming acknowledgement before movement, traverse both routes, return through extraction, disconnect/respawn during transitions, expire a run, check cell reuse and rerun installation. Mobile camera/navigation and measured performance remain explicit playtest gates.

Relevant engine references checked during the audit: [instance streaming](https://create.roblox.com/docs/workspace/streaming), [Model streaming modes](https://create.roblox.com/docs/reference/engine/classes/Model), [Player.RequestStreamAroundAsync](https://create.roblox.com/docs/reference/engine/classes/Player), and [Script.Source](https://create.roblox.com/docs/reference/engine/classes/Script/Source). A streaming request has no delivery guarantee; entry therefore also requires the client to see an atomic destination room, with a bounded timeout and server-owned transition token.
