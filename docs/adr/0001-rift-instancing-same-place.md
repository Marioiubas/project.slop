# ADR 0001 — Rifts live inside the same place

Status: accepted (2026-10-05)

## Context
Rifts could be separate places (TeleportService, reserved servers) or arenas inside the hub's place.

## Decision
Rifts are instanced **within the same place/server** as the hub. Each expedition gets its own arena (cloned room chain placed in a reserved far-away region of Workspace), owned by a `RiftService` that creates it, tracks participants, and destroys it on completion.

## Consequences
- Fast entry, no teleport loading, one codebase/place to publish, simple party handling.
- Server load scales with concurrent expeditions: enforce a cap on live arenas and per-arena part/physics budgets; clean up fully on end.
- Streaming/visibility: keep arenas far apart; hide other arenas' content from non-participants where it helps perf.
- If we later need more capacity, the `RiftService` interface should be the only thing that changes (swap in TeleportService-backed arenas).
