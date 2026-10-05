# GRAB THE WEIRD! — Development Plan

Source of truth for *what* we're building: [grab-the-weird-blueprint.md](grab-the-weird-blueprint.md).
This file is *how and in what order*. Process rules live in [how-to-work.md](how-to-work.md).

**Principle:** prove the emotional core (physically grabbing strange things and escaping with them) before building breadth. Each stage ends in something playable and a go/no-go gate.

**Status legend:** `[ ]` todo · `[~]` in progress · `[x]` done. Update this file as work lands.

**World-package work (5 October 2026):** the user separately authorized the supplied world brief's audit + Phase 1 and an offline Command Bar delivery. `stage3/command-bar-world-foundation` implements the allocator, room/socket kit, seeded assembly, route validation and portal return tests under `src/world/`. See `WORLD_ARCHITECTURE_AUDIT.md`, `docs/PHASE_1_VALIDATION.md` and ADR 0007. Stage 0 from PR #2 was merged at 64e49a9 during publication and is preserved here. This package does not advance the artifact/carry/playtest gates below.

**Visual preparation before Nexus polish (user request, 5 October 2026):** see [Higgsfield pipeline](HIGGSFIELD_DIMENSION_VISUAL_PIPELINE.md). This is preproduction direction; it does not advance gameplay gates.

- [x] Inspect live Higgsfield image/reference, Canvas, video and 3D capabilities.
- [x] Prepare nine-column Dimension Bible, eight focused prompts/translation notes, and preserved supplied reference boards.
- [x] Obtain explicit confirmation for the eight-image paid set; all eight generated and reviewed, observed credit decrease four. A–F accepted for direction; G/H have limited component acceptance with corrections.
- [x] Use official Roblox Studio MCP to execute the installer and verify one-client entry, route navigation, extraction and four-cell exhaustion/cleanup in the isolated test place.
- [ ] Update accepted concepts with provenance and measured Studio traversal/cargo/multiplayer/mobile results before an art pass.

---

## Stage 0 — Foundations (before any gameplay)

Goal: a repo where any fresh Claude session can build, lint, and ship a change safely.

- [x] Rojo project (`default.project.json`) + folder layout (see Architecture below)
- [x] Toolchain pinned in `rokit.toml` (rojo, stylua, selene, luau-lsp, wally, lune) — installed and verified
- [x] `stylua.toml`, `selene.toml`, `.gitignore`, `.gitattributes` (+ `.luaurc`, `wally.toml`; Wally packages are mapped in Stage 4 when ProfileService arrives)
- [x] Shared modules: `Config` (deep-frozen), `Types`, `Signal`, `Janitor`, `Safe`, `Log`, `Validate`, `Lifecycle`
- [x] Network layer: single remote registry (`Remotes`), server `NetworkService` (rate limit -> validation -> handler), client `NetworkController`; `Ping` request exercises it end to end (ADR 0006)
- [x] Service/Controller bootstrap (`Lifecycle`: dependency-ordered `init`, then `start`; server `Services`, client `Controllers`)
- [x] Content pipeline skeleton: `src/shared/Content/` (Rarities, empty Artifacts, Schema) + `ContentValidator` + `tools/validate_content` (IDs, rarity refs, missing/unknown fields, uniqueness)
- [x] Test harness: Lune + rojo-sourcemap module loader + small testkit (ADR 0005); 116 passing specs over every pure module; `lune run tools/check` is the single gate
- [x] CLAUDE.md, HANDOFF.md, how-to-work.md in place
- [x] Verified: `rojo build` succeeds; Studio connected through `rojo serve` and synced the full tree; Play ran with no errors (server + client booted, `Ping` round trip OK, bad/over-rate calls rejected). Studio verification was manual via the MCP, not automated

**Gate:** clean build + lint + test run from a cold clone. **Met (2026-10-05):** fresh clone of `stage0/rojo-skeleton` + `rokit install` + `lune run tools/check` passed all six steps.

---

## Stage 1 — Greybox core loop (the "is it fun" stage)

Goal: hub → portal → greybox Rift → pick up a thing → bring it back. No persistence, no polish.

- [ ] Hub greybox: spawn facing central portal, portal as the visual destination (FTUE 0–10s)
- [ ] Portal moves player into a Rift arena inside the same place (ADR 0001); no TeleportService
- [ ] Rift greybox: one room chain, spawn point, extraction zone
- [ ] Artifact v0: one physical object, server-owned, pick up / drop / carry (server validates distance + state)
- [ ] Carrying feel: mass → walk-speed penalty, drop on hit, basic carry animation/pose
- [ ] Extraction v0: server detects artifact inside extraction zone while carried → success event
- [ ] Minimal feedback: pickup sound/anim/UI, extraction payoff placeholder
- [ ] Playtest with 3+ people who haven't read the blueprint

**Gate:** testers understand the goal without explanation and want a second run. If not, iterate here — do not proceed.

---

## Stage 2 — Artifact framework + the 15

Goal: data-driven artifacts with genuinely different behaviour.

- [ ] Artifact definition schema (blueprint "Artifact Architecture" fields) + validator rules
- [ ] `ArtifactService` spawns artifacts from data, assigns immutable instance IDs
- [ ] Behaviour profiles as reusable components (floats, rolls, runs away, noisy, heavy-shift, magnetic, expanding…)
- [ ] Weight classes: small / large / cart / multi-player carry (multi-player can stub to "too heavy" until Stage 7)
- [ ] 15 artifacts across rarity tiers with distinct silhouettes + sounds
- [ ] Proximity-based simulation (don't simulate artifacts nobody is near)
- [ ] Network ownership strategy decided and documented (ADR)

**Gate:** each of the 15 produces a different decision or a funny moment; none are reskins.

---

## Stage 3 — Rift structure, hazards, tension

Goal: a 2–5 minute expedition with rising danger and a greed/risk choice.

- [ ] Rift definition schema (theme, room pool, hazards, artifact pool, difficulty, extraction rules)
- [~] Modular room assembly (handbuilt rooms, randomized chain) — standalone Phase 1 package implemented and one-client Studio MCP route verified; PR integration, actual cargo, multiplayer and mobile gates pending
- [ ] Rift-specific rule (the "gameplay distinction", e.g. altered gravity or unstable floors)
- [ ] Instability clock: environment worsens over time, readable without popups
- [ ] 2–3 hazards + optionally one wandering threat
- [ ] Fail state: lose unextracted loot only; return to hub
- [ ] Extraction countdown/zone rules; leave-early vs stay-greedy

**Gate:** expedition length lands 2–5 min; testers report at least one "I almost didn't make it" story.

---

## Stage 4 — Persistence + personal museum

Goal: extracted artifacts become permanent and visible.

- [ ] Profile schema v1 (versioned) + migration scaffold
- [ ] `DataService` wrapping ProfileService via Wally (ADR 0002): session lock, autosave, release on leave/BindToClose
- [ ] Artifact inventory keyed by unique instance ID (never by type only)
- [ ] Personal museum plot (temporary-garage tier): load/unload per player
- [ ] Place / remove / move artifact in display slots (server-validated)
- [ ] Visitor + reputation response on placement (controlled passive income)
- [ ] Anti-dupe invariants + tests (artifact in exactly one place)

**Gate:** rejoin keeps everything; kill-server/disconnect mid-extract never dupes or loses extracted items.

---

## Stage 5 — Economy, progression, FTUE

Goal: a complete first-session loop that makes players want the next thing.

- [ ] Primary currency + museum reputation only
- [ ] Income formula (active > passive; offline cap + diminishing returns)
- [ ] First museum upgrade affordable inside the first extraction (visible world change)
- [ ] Equipment v1: 2–3 capability upgrades (e.g. cart, grapple, scanner) that open new decisions, not just multipliers
- [ ] FTUE pass against blueprint timeline (0–10s, 10–20s … 60–120s)
- [ ] "Want something I don't have" hooks: collection-book silhouettes, locked destination, another player's museum visible
- [ ] Config-driven tuning values (first-rift length, first-upgrade cost, etc.)

**Gate:** new players complete first extraction in 60–120 s and can answer "what do I want next?"

---

## Stage 6 — Analytics, hardening, MVP playtest

Goal: MVP shippable to a closed audience with measurement.

- [ ] Analytics events from blueprint (session_started … session_ended) with timestamps/properties
- [ ] Exploit pass: every remote audited (types, distance, state, cooldown, rate); exploit telemetry
- [ ] Mobile pass: touch controls, UI scaling, safe areas, perf budget (parts, physics, particles, memory)
- [ ] Join-time + control-as-soon-as-possible check
- [ ] Content validator in CI
- [ ] Closed playtest (friends/Discord), collect funnel + qualitative notes

**Gate (MVP):** strangers understand the loop unaided; funnel + retention baseline recorded; decide continue/iterate/cut.

---

## Post-MVP (order by playtest evidence, not by this list)

| Stage | Theme | Notes |
|---|---|---|
| 7 | Co-op | Multi-player carry, revive, multi-player doors, party expeditions |
| 8 | Mutations + collection book | Compositional mutations that change behaviour, silhouettes/clues |
| 9 | More Rifts | Reuse Stage 3 framework; each needs a unique rule |
| 10 | Museum depth | Tier progression, layouts, visiting, customization, reactions |
| 11 | Events + quests | Rift Storm modifier framework, forgiving daily/weekly |
| 12 | Trading | Two-stage lock, audit logs, eligibility gates — only after economy is stable |
| 13 | Monetization | Cosmetics-first, idempotent receipts, no pay-to-win |
| 14 | LiveOps tooling | Designer-facing content pipeline, A/B config, dashboards |

---

## Architecture (target layout)

```
default.project.json
rokit.toml  stylua.toml  selene.toml
src/
  shared/      -- types, config, content data, pure logic (no Instances where avoidable)
  server/      -- Services (authoritative state, validation, persistence)
  client/      -- Controllers (input, UI, camera, feedback)
tools/         -- validate_content, build/lint scripts
tests/         -- unit tests (pure logic first)
assets/        -- Studio-authored .rbxm/.rbxl pieces (maps, rooms, models)
docs/          -- blueprint, this plan, how-to-work, ADRs (docs/adr/NNNN-*.md)
```

Rules: server authoritative; data separate from systems; Services/Controllers never reach into each other's internals; each system testable in isolation where practical.

## Decisions to record as ADRs early
Done: 0001 Rift instancing (same place), 0002 persistence (ProfileService), 0003 git policy, 0004 Rojo vs Studio split, 0005 test framework, 0006 network layer + bootstrap.
Still to write:
1. Network ownership + carry replication model (Stage 2)
