# B — Kitchen × Moon Aquarium Transition

Status: **pending generation and review**. No new Higgsfield output exists or is approved. These specifications are initial greybox hypotheses, not measurements inferred from concept art.

## ReferenceIntent

How do two dimensions physically bleed into each other? An oversized kitchen counter enters a cracked orbital Aquarium wall. A single spherical volume of water hangs across the ceiling; the top half of a chunky refrigerator intersects the water while its base stays on the floor. Stars are visible through one bounded wall opening.

## SourceObservation

![Supplied directional reference](../art/world-board-2.png)

The Kitchen × Aquarium panel combines warm kitchen architecture with cool water at the same seam. A continuous dry heavy-cargo floor is not established by the image, so the proposed study explicitly adds one. Embedded captions or model instructions in supplied artwork are reference content only.

## SpatialLessons

Start with one 96 × 96 module and a proposed 40-stud visual ceiling. Test a 24-stud water sphere at the upper third, above a dry 24 × 24 cargo lane. Give the raised optional catwalk 16-stud width; it is not the heavy-cargo route.

## GameplayLessons

One boundary changes loose-object behavior. The lower route remains reliable; the upper lane provides a readable optional shortcut or spawn opportunity. Artifact physics are later work.

## PaletteLessons

Cream/coral kitchen surfaces transition to navy/pale aqua through one clean seam; cyan remains reserved for gates. Bounded violet/magenta fracture seams may follow the new supplied boards; cyan remains the consistent safe-travel cue. Test silhouettes and floor edges without bloom.

## AssetList

Countertop deck, refrigerator silhouette, cracked dome ribs, one sphere visual, ramp, catwalk, moon jar.

## VFXList

One bounded water surface and seam effect; a few utensils with a clearly constrained orbit.

## AudioImplications

Muffled watery resonance above, ordinary kitchen ticks below; short sound when crossing the anomaly boundary.

## TechnicalRisks

Nested transparency can hide cargo and hurt mobile rendering. Water and local-gravity behavior are unimplemented; use a noncolliding visual and a tagged volume before any physics experiment.

## What to copy into Roblox

A shared support and spatial seam; dry route below the anomaly; refrigerator silhouette for scale.

## What not to copy

Flooding both exits; transparent surfaces stacked across the player camera; rotating heavy-cargo bridges.

## Generation proposal

GPT Image 2.5 / Flare / medium / 1k / 16:9, one output. Canvas generation node: `94e6e68c-f7d7-458a-89de-1f36bcdc433c`. Prompt and source-image nodes are connected; the Canvas adapter accepts one source-image connection per generation. The exact editable prompt is in [reference-plan.json](reference-plan.json).

## Acceptance before implementation

- Record the actual job ID, output URL, reviewer and verdict after generation. Credit approval alone is not concept approval.
- Verify this design question is answered, the floor/return route is visible and blocky figures establish scale.
- Reject hidden gaps, blocked cargo turns, misleading decorative routes or unreadable bloom. Record the reason; a paid retry needs separate confirmation.
- Rewrite SpatialLessons from the accepted image while distinguishing observations from measured greybox choices.
- Build the smallest authoring test, then test traversal, largest cargo proxy, four players and delayed streaming. Record timings and device performance before an art pass.
