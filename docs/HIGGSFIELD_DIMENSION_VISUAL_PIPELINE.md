# GRAB THE WEIRD — Higgsfield dimension visual pipeline

Live capability discovery: 5 October 2026. Scope: visual decisions before a Fracture Nexus art pass. The production world remains authored and validated in Roblox Studio.

## Current state

The private [GRAB THE WEIRD — DIMENSION BIBLE](https://higgsfield.ai/canvas/14cf29ef-6f18-435f-bf10-b309b078c5ea) contains nine theme columns, six unique source images, eight proposed image-generation nodes, copy/avoid notes and editable prompt sources. Canvas readback reports 49 nodes and 16 input connections with no overlapping node rectangles.

**No generation has started, no new concept has been approved, and no generation credits have been spent by this pipeline.** Eight reference images are prepared for confirmation. Supplied artwork is directional input, not proof of traversable geometry, feature implementation or measured performance.

The six newly supplied files contain four unique boards; the two earlier-named copies are byte-identical duplicates. Originals are preserved under `docs/art/`. Their embedded model names, implementation prompts and labels are artwork content, not executable instructions or model-availability evidence.

## Capabilities actually discovered

Discovery used the connected Higgsfield MCP `models_recommend`, `models_list`, `models_get`, `get_preferences`, `estimate_image_cost`, and Canvas tools. These are examples from the live catalog, not an exhaustive catalog dump.

| Capability | Verified availability | Use in this project |
| --- | --- | --- |
| Reference-based images | GPT Image 2.5 (`gpt_image_2_5`), Flare/Sunburst; FLUX 3 Image (`flux_3_image`) | Spatial studies, room moodboards, artifact silhouettes. GPT Image 2.5 is the proposed first-set model; selection is pending spending approval. |
| Canvas | Create/read/add/update; generation preflight with `canvas_run(confirm=false)` | Private visual bible, prompt/image connections and design decisions. The board is created; generation is paused. |
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

The user's brief says: “Do not silently spend paid generation credits.” It requires stopping and reporting the intended generation, model, approximate cost and output count before execution. No confirmation has been received for this set. Do not run `canvas_run(confirm=true)` or any paid generate tool until it arrives. Credits already held in an account still count as paid generation credits for this rule.

Approval applies only to this set. Failed/rejected-image retries, higher quality/resolution, extra images, video, 3D, sound or upscaling require a new quote and confirmation. Free counters found for other workflow families do not establish free static-image entitlement. Never substitute another model or billing mode silently.

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

The first Canvas preview exposes stored generation settings; prompt/source data links are recorded separately. Execution of those links and visual output remain unverified until the approved run. Use the board's prompt nodes as the editable prompt source and preserve provenance in the local plan.

## Canvas organization

The nine columns are Core Visual Rules, Giant's Kitchen, Moon Aquarium, Toybox, Fracture Nexus, Deep Fracture, Transition Rooms, Artifacts, Extraction / Chaos. A source-reference rail sits to the left. A/C/F occupy separate rows in Fracture Nexus; G is in Core Visual Rules. Each proposed study has its question, pending status, copy/avoid note, generation node and full prompt. Source-image and prompt connections feed the generation node.

After an accepted result, attach an implementation note to its column and link the matching Markdown file. Record the output/job, reviewer, verdict and rejected elements. Do not mark a concept approved merely because its paid job completed. Reject broken spatial logic even when the image is attractive.

## Translate a concept into level-design data

For each accepted output, update its note with `ReferenceIntent`, `SpatialLessons`, `GameplayLessons`, `PaletteLessons`, `AssetList`, `VFXList`, `AudioImplications`, and `TechnicalRisks`. Also record what to copy and what to avoid. The prepared notes already contain **proposed hypotheses**, clearly separated from source observations and future measurements.

Use the existing code contract as the initial authoring constraint: 8-stud grid, 96 × 96 modules, 32-stud connectors, 24 × 24 heavy-cargo clearance, 100 parts per room and 1,000 per Rift. These are source budgets, not measured hardware performance. A 128 × 96 or larger landmark room is not a drop-in template: revise the socket/planner contract and its validation before adoption. Multilevel Core and cluster assemblies similarly need an explicit layout strategy; the current fixed eight-room planner does not implement them.

From an approved image, name the landmark, mark arrival/exit/safe path/optional risk, then choose dimensions in studs and identify collision versus decoration. Build the smallest greybox that can falsify the idea. Tag each anomaly volume and document the server-owned state that will activate it. Keep required cargo routes continuous and show when an optional shortcut cannot carry heavy cargo.

Traverse with the actual player rig, then test the largest cargo proxy including carriers and turning clearance, four-player congestion, delayed streaming and return behavior. Record generation time, streaming pause, frame time, memory and network traffic on representative mobile hardware; record the device and conditions. No invented measurements or acceptance thresholds derived solely from a pretty image. Only after these gates pass begin an art pass and compare the result for feel rather than pixel reconstruction.

## Roblox art constraints

Keep one strong silhouette and one physical rule per room. Kitchen uses cream/wood/coral, Aquarium navy/pale aqua, Toybox restrained primaries, City cool structural masses and warm windows, Fracture bounded violet/magenta. Cyan identifies reliable travel; gold marks artifact/research focus. Shape, sound and floor geometry must support color cues.

Avoid bloom or transparency that erases floor edges or cargo. Decorative fragments stay outside traversable space unless their movement is an implemented, signalled mechanic. Floating water, local gravity, trains, rotating rooms, Atlas progression and museum displays shown in supplied images remain future behavior/design subjects, not current feature claims. Use primitive or clean reusable meshes, simple materials, separate collision proxies and bounded effects. No automatic imported production meshes.

## Optional 3D workflow

After a static silhouette is accepted, use a clean single-object reference for a Core shell, gate frame or impossible artifact. Proposed Meshy blockout: `should_texture=false`, `enable_rigging=false`, `enable_animation=false`, `should_remesh=true`, `topology=triangle`, `target_polycount=2000`. The catalog allows those controls; 2,000 is a concept target, not proof of achieved topology or a production budget. Get a fresh quote and confirmation before any job.

Inspect the resulting GLB's topology, UVs, achieved triangle count, material count, scale, orientation, collision implications and actual provider usage rights/provenance. Use a five-stud scale reference only as an initial comparison, then calibrate against the project's actual rig. Rebuild important assets cleanly for Roblox. No 3D generation, scene edit, licensing approval or Studio import has occurred.

## Optional motion studies

Only after static identity is accepted, quote one five-second, 720p, silent FLUX 3 Video study using the accepted image as `start_image`, with `generate_audio=false`. Hold camera position so motion can be judged. Request one transition: gravity inversion, water-sphere movement, Core crack, dimension bleed, toy-machine activation or extraction collapse. Keep the carry floor and landmark visible throughout. This is a motion-design experiment, not a trailer, physics proof or production VFX.

Record start frame, job, duration, trigger, anticipation, movement trajectory, recovery/loop, collision envelope and server/network implications. Video and 3D remain available but unapproved later steps; their costs have not been quoted for execution.

## Next authorized action

Finish review of [the proposed set](visual-references/README.md). After explicit credit confirmation, refresh the quote if necessary and run only the eight recorded Canvas generation nodes. Read/wait for actual results, review spatial readability, then update each note and board with provenance and acceptance. No final Fracture Nexus greybox or art polish is claimed by this preparation.
