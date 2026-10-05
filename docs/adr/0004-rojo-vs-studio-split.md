# ADR 0004 — What lives in code (Rojo) vs Studio assets

Status: accepted (2026-10-05)

## Context
Rojo syncs files into Studio, but world geometry (hub, rooms, props, UI layouts) is far easier to author in Studio than as text. Without a rule, important state ends up only in an unsaved or unpublished Studio session, or logic gets hidden inside models where Claude and git can't see it.

## Decision
- **Code and data are files in `src/`**, mapped by `default.project.json`: all Luau, all content data (`src/shared/Content/`), all tunables (`Config`). Never hand-edit a script inside Studio; Rojo will overwrite it.
- **Studio-authored world pieces are exported to `assets/` as `.rbxm`** (one file per room/prop/model/UI kit) and mapped into the project at one clearly named place when the first one lands (e.g. `ServerStorage/Assets` for things the server clones, `ReplicatedStorage/Assets` for things clients also need).
- **No scripts inside assets.** An asset is geometry, appearance and markers only. Behaviour comes from code that finds markers by `CollectionService` tag or attribute (`ArtifactSpawn`, `ExtractionZone`, ...), never by hard-coded instance paths.
- **Numbers live in `Config`/`Content`, not in model attributes** (except placement markers like a spawn's id). That keeps tuning reviewable in diffs.
- **The Studio place file is disposable.** `build/*.rbxl` is gitignored; the only things that matter are `src/` + `assets/`. Terrain isn't Rojo-syncable, so avoid it for gameplay-critical spaces or export it explicitly and note it in the handoff.
- Every session that adds or changes an asset records the file and where it's wired in the handoff.

## Consequences
- Fresh clones rebuild the whole game from files; reviews see code and tunable changes as text.
- Binary `.rbxm` diffs aren't reviewable, so keep assets small and one-purpose, and describe changes in the commit message.
- Designers/Claude must add a marker (tag/attribute) in Studio for anything code needs to find, which is a small cost for decoupling code from model hierarchy.
