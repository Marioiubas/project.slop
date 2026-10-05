# ADR 0002 — Persistence with ProfileService

Status: accepted (2026-10-05)

## Context
We need session-locked, dupe-safe player data (see blueprint "Data").

## Decision
Use **ProfileService** (loleris) via Wally for player profiles, wrapped behind our own `DataService` so the rest of the codebase never touches the library directly.

## Consequences
- Session locking, auto-save and release handling come from a proven library.
- Note: ProfileService's author has since released **ProfileStore** as its successor and ProfileService is no longer the actively developed option. If we hit limitations, swapping is contained to `DataService` because of the wrapper. Revisit before public launch.
- Profile schema is versioned from day one with a migration scaffold; artifacts are stored by unique instance ID.
