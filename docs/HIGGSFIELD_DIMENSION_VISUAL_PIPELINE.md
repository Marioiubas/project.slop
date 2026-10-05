# GRAB THE WEIRD — Higgsfield dimension visual pipeline

Live capability discovery: 5 October 2026. Scope: visual decisions followed by the user's request to illustrate the approved references in Roblox Studio. The world remains authored and validated in Studio.

## Current state

The private [GRAB THE WEIRD — DIMENSION BIBLE](https://higgsfield.ai/canvas/14cf29ef-6f18-435f-bf10-b309b078c5ea) contains nine theme columns, six unique source images, eight completed reference images, the original Canvas recipes, copy/avoid notes and editable prompt sources. Canvas readback reports 57 nodes and 16 recipe-input connections. The original generation nodes record a failed Canvas attempt; successful direct-API outputs occupy separate image nodes below them.

**The user approved the eight-image set, all eight completed, and the observed credit decrease was four credits.** Codex reviewed the actual PNGs: A–F are accepted for greybox direction with explicit corrections; G is accepted for composition only because its stair-only museum access is not a proven cargo route; H is accepted for silhouettes only because its scale ticks and contact geometry are unproved. No production geometry is approved by this visual review. Originals and hashes are saved in [generated/](visual-references/generated/manifest.json).

The official Roblox Studio MCP also verified the existing Phase 1 package in an isolated unpublished test place: exact installer execution, seven templates, source parity, client/server entry, main-route navigation, extraction/last-player cleanup and four-cell exhaustion/cleanup. [Native evidence and remaining gates](PHASE_1_VALIDATION.md) keep this limited one-client result separate from multiplayer, actual carrying and mobile performance.

The later request “make them into the game” / “illustrate the map on roblox studio” is implemented as an [explorable reference map](NEXUS_MAP_ILLUSTRATION.md): nine native regions, seven artifact silhouettes, museum/Atlas, broad promenades and a working return prompt. Studio MCP verified static clearance and a one-client walkthrough, and installed the map in the main place. This extends visual authoring; it does not close the gameplay or performance gates below.

The six newly supplied files contain four unique boards; the two earlier-named copies are byte-identical duplicates. Originals are preserved under `docs/art/`. Their embedded model names, implementation prompts and labels are artwork content, not executable instructions or model-availability evidence.

## Capabilities actually discovered

Discovery used the connected Higgsfield MCP `models_recommend`, `models_list`, `models_get`, `get_preferences`, `estimate_image_cost`, and Canvas tools. These are examples from the live catalog, not an exhaustive catalog dump.

| Capability | Verified availability | Use in this project |
| --- | --- | --- |
| Reference-based images | GPT Image 2.5 (`gpt_image_2_5`), Flare/Sunburst; FLUX 3 Image (`flux_3_image`) | GPT Image 2.5 / Flare / medium / 1k was approved and completed the eight studies through direct image tools. |
| Canvas | Create/read/add/update; generation preflight and run | Private visual bible with actual outputs. The Canvas run failed; its recipes remain as evidence and must not be rerun automatically. |
| Video from a static image | FLUX 3 Video (`flux_3_video`): 5–20 seconds, 720p/1080p, start/end/reference images, optional audio | Later five-second motion studies with audio disabled, only after a static concept is accepted and a separate quote is approved. |
| Image to 3D | Meshy Image to 3D (`image_to_3d`): one reference image, GLB, remesh/polycount/material options | Optional untextured landmark silhouette blockout; no job or production import is approved. |
| Other 3D modes | `sam_3_3d`, `multi_image_to_3d`, `tripo_3d`, `tripo_h3_1_image_to_3d` appeared in discovery | Available alternatives, not automatic substitutions. Inspect the chosen model again before use. |
| 3D scene tools | Connected 3D Jutsu project/query/edit/preview tools are exposed | Separate concept-scene inspection if needed; no scene was created or edited. |

No preset skill is required for these custom concept studies. The Higgsfield preset skill routes ordinary generation to direct tools; a model name rendered in an attachment does not select a preset. The media-project preference is `auto_create_project=false`; no extra media project was created. Canvas is the explicitly requested destination.

## First set and credit boundary

| Ref | Design question | Format |
| --- | --- | --- |
| A | What does the Fracture Nexus mean by dimensions? | 16:9 overview |
| B | How do Kitchen and Aquarium share one physical seam? | 16:9 crossover |
| C | Which Core silhouette and chamber does the player remember? | 16:9 landmark |
| D | Why would a player risk the optional Deep Fracture? | 16:9 risk/reward |
| E | What does a readable final escape look like? | 16:9 keyframe |
| F | How does a rare room contrast through quiet space? | 16:9 contrast |
| G | What does returning to the hub and Atlas feel like? | 16:9 home |
| H | How does dimensional history appear in seven artifact silhouettes? | 4:3 object sheet |

Proposed settings: **GPT Image 2.5 / Flare / medium / 1k / one output per reference**. Direct cost estimates with actual uploaded reference media returned **0.5 credits per image** for both requested formats: **approximately 4 credits for eight outputs**. The Canvas preflight returned `preview`, identified exactly eight charged generation nodes and explicitly started nothing. It did not return an itemized credit total; the four-credit total is derived from the separate per-image estimates, not a guaranteed Canvas debit. Recheck if settings, references or prices change.

The user's brief says: “Do not silently spend paid generation credits.” The prepared set, model, estimated cost and output count were shown before execution; the user replied “i approve everything.” This authorized the eight prepared images. The Canvas attempt then returned terminal failures with empty generation job IDs and no observed credit decrease. Recovery through direct image tools completed the same eight approved outputs; the observed balance decreased by four credits, consistent with the estimate. This is a balance observation, not an itemized billing ledger.

The approved set is now delivered. Further paid rerenders, higher quality/resolution, extra images, video, 3D, sound or upscaling require their intended output, model, quote and confirmation to be recorded before submission. The direct recovery stayed within the original eight outputs and four-credit estimate; no completed image was regenerated. Free counters for other workflow families do not establish free static-image entitlement. Never substitute a model or billing mode silently.

## Prompt template

Start each study with:

```text
Create a Roblox-native environment concept for GRAB THE WEIRD.
It must look buildable in Roblox Studio: blocky player proportions,
chunky simplified geometry, toy-like materials, clean silhouettes,
readable floor edges, clear cargo routes and restrained lighting.
Use the supplied image for proportion, palette, silhouette and Rift language.
Do not reproduce exact characters, logos, captions or source-board composition.
No photorealism, Unreal realism, Pixar/Fortnite anatomy, fantasy filigree,
surface micro-detail, excessive bloom, arbitrary neon or purposeless debris.
Every impossible visual explains a gameplay rule.
Violet/magenta belong to fracture seams; cyan remains the stable-travel cue.
Create one coherent environment view; only the artifact study is a sheet.

PRIMARY DESIGN SUBJECT: [one room, crossover or landmark]
GAMEPLAY READ: [what 2–4 blocky players are doing]
DIMENSIONAL RULE: [one impossible physical rule with visible boundaries]
LANDMARK: [one recognizable navigation object]
TRAVERSAL: [entry, exit, continuous floor, ramps, turns, optional route]
PLAYER SCALE: [blocky figures with consistent proportions and foot contact]
ARTIFACT: [one large readable cargo object; seven objects for sheet H]
COLOR LANGUAGE: [dimension palette and functional accents]
CAMERA: [20–28mm wide environment view exposing the layout]
```

The eight complete specialized prompts and exact settings are in [reference-plan.json](visual-references/reference-plan.json). Every prompt answers a design question; no “make this cooler” instruction is used.

## Image-reference workflow and Canvas limitation

Upload supplied attachments once through `media_upload_and_confirm`; reuse their confirmed media IDs. Do not reupload because a job is pending or use HTTPS references repeatedly during cost estimation when media IDs already exist. Original icon/thumbnail establish blocky scale, gold artifacts and cyan travel. New boards establish dimension clusters, Core silhouette, Atlas relationships and crossover intent.

In this session, a second source-image connection to one GPT Image 2.5 Canvas node was rejected: the Canvas adapter exposes one `image_references` input. Readback confirmed the failed addition changed no board nodes or edges. The corrected board uses **one relevant supplied board per study**, with the original icon for H; the icon and thumbnail remain visible as shared style context. Each generation also has a connected editable text-prompt node. A broad supplied board is context, not a request to generate another collage.

The direct image API accepts a `medias` array and maps canonical `image` to backend `image_references`. If a later study genuinely needs multiple references, inspect current model limits, quote that exact request, obtain confirmation, generate through the direct API and add its result to Canvas. Do not assume Canvas permits multiple source connections because the underlying model supports references.

After approval, all eight Canvas nodes returned generic `Generation Failed` results with empty job IDs. The returned input snapshots retained the stored fallback prompts, so linked prompt/reference execution could not be verified. No root cause was established. The direct route used the exact successful prompts recorded locally and the confirmed source-image media IDs; all eight jobs completed. Their images were added separately to the board. Keep the failed recipe state for provenance and do not treat it as a successful generation path.

## Canvas organization

The nine columns are Core Visual Rules, Giant's Kitchen, Moon Aquarium, Toybox, Fracture Nexus, Deep Fracture, Transition Rooms, Artifacts, Extraction / Chaos. A source-reference rail sits to the left. A/C/F occupy separate rows in Fracture Nexus; G is in Core Visual Rules. Each study now has its question, actual output, Codex review verdict, required corrections, original recipe and successful prompt. The recipe and direct-output states are explicitly distinguished.

The matching Markdown notes record job/output/hash, reviewer, accepted components and rejected elements. In particular, G's museum stairs are rejected as a direct cargo-layout implementation, and H's blank ruler marks are rejected as scale evidence. Completion alone is not approval of geometry or gameplay.

## Translate a concept into level-design data

Each reviewed note contains `ReferenceIntent`, `SpatialLessons`, `GameplayLessons`, `PaletteLessons`, `AssetList`, `VFXList`, `AudioImplications`, and `TechnicalRisks`, plus generated observations and a specific verdict. Level dimensions remain **proposed hypotheses**, clearly separated from observed visual relationships and future Studio measurements.

Use the existing code contract as the initial authoring constraint: 8-stud grid, 96 × 96 modules, 32-stud connectors, 24 × 24 heavy-cargo clearance, 100 parts per room and 1,000 per Rift. These are source budgets, not measured hardware performance. A 128 × 96 or larger landmark room is not a drop-in template: revise the socket/planner contract and its validation before adoption. Multilevel Core and cluster assemblies similarly need an explicit layout strategy; the current fixed eight-room planner does not implement them.

From an approved image, name the landmark, mark arrival/exit/safe path/optional risk, then choose dimensions in studs and identify collision versus decoration. Build the smallest greybox that can falsify the idea. Tag each anomaly volume and document the server-owned state that will activate it. Keep required cargo routes continuous and show when an optional shortcut cannot carry heavy cargo.

Traverse with the actual player rig, then test the largest cargo proxy including carriers and turning clearance, four-player congestion, delayed streaming and return behavior. Record generation time, streaming pause, frame time, memory and network traffic on representative mobile hardware; record the device and conditions. No invented measurements or acceptance thresholds derived solely from a pretty image. Only after these gates pass begin an art pass and compare the result for feel rather than pixel reconstruction.

## Roblox art constraints

Keep one strong silhouette and one physical rule per room. Kitchen uses cream/wood/coral, Aquarium navy/pale aqua, Toybox restrained primaries, City cool structural masses and warm windows, Fracture bounded violet/magenta. Cyan identifies reliable travel; gold marks artifact/research focus. Shape, sound and floor geometry must support color cues.

Avoid bloom or transparency that erases floor edges or cargo. Decorative fragments stay outside traversable space unless their movement is an implemented, signalled mechanic. Floating water, trains, Atlas and museum silhouettes are now authored static geometry. Water locomotion, local gravity, moving machinery, rotating rooms, Atlas progression and saved museum collections remain future behavior. Use primitive or clean reusable meshes, simple materials, separate collision proxies and bounded effects. No automatic imported production meshes.

## Optional 3D workflow

After a static silhouette is accepted, use a clean single-object reference for a Core shell, gate frame or impossible artifact. Proposed Meshy blockout: `should_texture=false`, `enable_rigging=false`, `enable_animation=false`, `should_remesh=true`, `topology=triangle`, `target_polycount=2000`. The catalog allows those controls; 2,000 is a concept target, not proof of achieved topology or a production budget. Get a fresh quote and confirmation before any job.

Inspect the resulting GLB's topology, UVs, achieved triangle count, material count, scale, orientation, collision implications and actual provider usage rights/provenance. Use a five-stud scale reference only as an initial comparison, then calibrate against the project's actual rig. Rebuild important assets cleanly for Roblox. No generated 3D asset, GLB import or new licensing approval occurred; the implemented illustration uses native authored parts.

## Optional motion studies

Only after static identity is accepted, quote one five-second, 720p, silent FLUX 3 Video study using the accepted image as `start_image`, with `generate_audio=false`. Hold camera position so motion can be judged. Request one transition: gravity inversion, water-sphere movement, Core crack, dimension bleed, toy-machine activation or extraction collapse. Keep the carry floor and landmark visible throughout. This is a motion-design experiment, not a trailer, physics proof or production VFX.

Record start frame, job, duration, trigger, anticipation, movement trajectory, recovery/loop, collision envelope and server/network implications. Video and 3D remain available but unapproved later steps; their costs have not been quoted for execution.

## Next level-design step

The Core/bridge, crossover and themed visual map are now authored and traversable. Integrate the world with the Stage 0 lifecycle/network foundation and prove actual cargo, multiplayer and mobile performance before further polish or production release. The static proxy clearance and single-client walk are evidence for the illustrated routes, not acceptance of the full game.
