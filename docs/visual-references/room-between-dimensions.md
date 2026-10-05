# F — Rare Room — Between Dimensions

Status: **pending generation and review**. No new Higgsfield output exists or is approved. These specifications are initial greybox hypotheses, not measurements inferred from concept art.

## ReferenceIntent

How does rarity become memorable through contrast? An almost empty impossible ivory/black void with a single solid platform, one strange artifact and three distant framed doorways into unrelated dimensions.

## SourceObservation

![Supplied directional reference](../art/world-board-3.png)

The Rare Room Example panel uses tall door-like objects and sparse floor space. The almost-empty ivory/black room proposed here is an intentional contrast experiment, not an observed feature of that supplied panel. Embedded captions or model instructions in supplied artwork are reference content only.

## SpatialLessons

Keep one 96 × 96 room mostly empty. Place a 16 × 16 pedestal offset from a 24-stud straight carry lane; maintain 24-stud headroom. At most three distant doorway silhouettes; only one active return is visually prioritised.

## GameplayLessons

Calm gives rarity contrast. The artifact is approachable without a navigation puzzle. Background doors are composed as views until interaction is actually implemented.

## PaletteLessons

Ivory floor, near-black background, restrained ink frames and a single gold artifact detail; cyan only at the active return. Bounded violet/magenta fracture seams may follow the new supplied boards; cyan remains the consistent safe-travel cue. Test silhouettes and floor edges without bloom.

## AssetList

Plain floor, pedestal, Runaway Door proxy, three low-detail portal frames, active return frame.

## VFXList

Almost none: active return plane and one mild artifact highlight.

## AudioImplications

Low room tone and a distinct soft door mechanism; reduce the preceding room's dense ambience.

## TechnicalRisks

Bright void exposure can erase floor edges. Test contrast and touch-camera readability; an animated artifact needs a bounded behavior so it cannot leave the accessible floor.

## What to copy into Roblox

Negative space; one memorable object; rare calm; unmistakable physical floor.

## What not to copy

Explosion spectacle; decorative stepping stones; every distant door looking equally interactable.

## Generation proposal

GPT Image 2.5 / Flare / medium / 1k / 16:9, one output. Canvas generation node: `a77069fa-5bc0-4455-a68a-45263307cbb4`. Prompt and source-image nodes are connected; the Canvas adapter accepts one source-image connection per generation. The exact editable prompt is in [reference-plan.json](reference-plan.json).

## Acceptance before implementation

- Record the actual job ID, output URL, reviewer and verdict after generation. Credit approval alone is not concept approval.
- Verify this design question is answered, the floor/return route is visible and blocky figures establish scale.
- Reject hidden gaps, blocked cargo turns, misleading decorative routes or unreadable bloom. Record the reason; a paid retry needs separate confirmation.
- Rewrite SpatialLessons from the accepted image while distinguishing observations from measured greybox choices.
- Build the smallest authoring test, then test traversal, largest cargo proxy, four players and delayed streaming. Record timings and device performance before an art pass.
