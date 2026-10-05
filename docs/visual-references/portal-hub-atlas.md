# G — Portal Hub / Dimensional Atlas

Status: **pending generation and review**. No new Higgsfield output exists or is approved. These specifications are initial greybox hypotheses, not measurements inferred from concept art.

## ReferenceIntent

What does coming home feel like? A stable research plaza with one huge primary Rift gate, a simple physical Dimensional Atlas showing three discovered nodes, and a visible museum/research wing.

## SourceObservation

![Supplied directional reference](../art/world-board-1.png)

The Hub / Museum panel uses a central portal landmark and a research/gallery plaza. The supplied boards also show an Atlas and museum displays; these are direction for future features, not current gameplay. Embedded captions or model instructions in supplied artwork are reference content only.

## SpatialLessons

Use the existing 224-stud plaza as context. Reserve a 32-stud return lane and 32 × 32 turning area; put Atlas browsing beside the lane and keep the join station approach clear. A 48 × 48 museum bay is an initial authoring target, not persistent museum implementation.

## GameplayLessons

Returning produces spatial relief and a visible next destination. Three Atlas nodes show discovery as a proposed feature; museum placement/persistence and progression remain unimplemented.

## PaletteLessons

Warm cream and wood, ink research structures, gold progress accents and cyan travel. Calm directional lighting contrasts with fractured rooms. Bounded violet/magenta fracture seams may follow the new supplied boards; cyan remains the consistent safe-travel cue. Test silhouettes and floor edges without bloom.

## AssetList

Primary gate, low-detail Atlas rings/nodes, research counter, display plinths, wing signage, return landing.

## VFXList

Bounded Atlas projection, one portal plane and mild plinth highlight; no full-plaza neon.

## AudioImplications

Stable warm ambience; return cue resolves the Rift sound; discovery cue belongs to a later implemented event.

## TechnicalRisks

Atlas nodes and museum displays must not imply active progression in the present Phase 1 build. Avoid crowding arrival and the join prompt; profile display behavior before persistence work.

## What to copy into Roblox

Stable composition; portal-first orientation; quiet museum destination; warm home lighting.

## What not to copy

Huge UI holograms masking players; fake active discovery UI; physics-enabled artifacts left to accumulate.

## Generation proposal

GPT Image 2.5 / Flare / medium / 1k / 16:9, one output. Canvas generation node: `6f07eeaa-2321-4c28-b6d8-86028189286b`. Prompt and source-image nodes are connected; the Canvas adapter accepts one source-image connection per generation. The exact editable prompt is in [reference-plan.json](reference-plan.json).

## Acceptance before implementation

- Record the actual job ID, output URL, reviewer and verdict after generation. Credit approval alone is not concept approval.
- Verify this design question is answered, the floor/return route is visible and blocky figures establish scale.
- Reject hidden gaps, blocked cargo turns, misleading decorative routes or unreadable bloom. Record the reason; a paid retry needs separate confirmation.
- Rewrite SpatialLessons from the accepted image while distinguishing observations from measured greybox choices.
- Build the smallest authoring test, then test traversal, largest cargo proxy, four players and delayed streaming. Record timings and device performance before an art pass.
