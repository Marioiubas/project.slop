# E — Total Fracture Escape

Status: **pending generation and review**. No new Higgsfield output exists or is approved. These specifications are initial greybox hypotheses, not measurements inferred from concept art.

## ReferenceIntent

What does the strongest OH-NO moment look like? A Kitchen/Aquarium crossover collapses behind three blocky players carrying one bulky artifact. One emergency extraction gate is ahead, framed by solid dark supports. A bounded water anomaly moves beside the failing secondary route.

## SourceObservation

![Supplied directional reference](../art/world-board-1.png)

The Extraction Sequence panel puts a strong portal ahead of fleeing players. The readable path, cooperative cargo envelope and collapse timing still need a dedicated study. Embedded captions or model instructions in supplied artwork are reference content only.

## SpatialLessons

Study three connected 96 × 96 modules. Use existing 24 × 24 cargo clearance and a 32 × 32 extraction landing. Prototype a 32-second escape window as a hypothesis with 8 seconds of readable warning; measure actual heavy-cargo completion times before tuning it.

## GameplayLessons

Collapse removes optional space first. A surviving bypass remains visible and carries the largest test cargo. Four-player queues at extraction must not make success depend on an invisible timer.

## PaletteLessons

Warm cream/wood foreground; dark navy collapsing background; local amber warnings; cyan return gate remains the clearest focal point. Bounded violet/magenta fracture seams may follow the new supplied boards; cyan remains the consistent safe-travel cue. Test silhouettes and floor edges without bloom.

## AssetList

Intact return deck, sacrificial side deck, emergency portal frame, warning panels, bounded water visual, artifact proxy.

## VFXList

One local fracture seam; restrained debris outside the surviving path; gate pulse strongest at the destination.

## AudioImplications

Rising but legible collapse rhythm, distinct warning and extraction cue; keep footsteps and teammate audio audible.

## TechnicalRisks

The current package has only expiry/diagnostic instability, not collapse or carrying. This is a future behavior brief; server state, streaming availability and return path guarantees must precede effects.

## What to copy into Roblox

Collapse direction; surviving cargo path; emergency gate visibility; readable feet and floor.

## What not to copy

Particle walls; all routes failing simultaneously; camera shake used to hide poor navigation.

## Generation proposal

GPT Image 2.5 / Flare / medium / 1k / 16:9, one output. Canvas generation node: `57ab67e8-2098-45df-8bc5-cfc3066d78ad`. Prompt and source-image nodes are connected; the Canvas adapter accepts one source-image connection per generation. The exact editable prompt is in [reference-plan.json](reference-plan.json).

## Acceptance before implementation

- Record the actual job ID, output URL, reviewer and verdict after generation. Credit approval alone is not concept approval.
- Verify this design question is answered, the floor/return route is visible and blocky figures establish scale.
- Reject hidden gaps, blocked cargo turns, misleading decorative routes or unreadable bloom. Record the reason; a paid retry needs separate confirmation.
- Rewrite SpatialLessons from the accepted image while distinguishing observations from measured greybox choices.
- Build the smallest authoring test, then test traversal, largest cargo proxy, four players and delayed streaming. Record timings and device performance before an art pass.
