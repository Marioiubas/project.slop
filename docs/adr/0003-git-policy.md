# ADR 0003 — Git policy

Status: accepted (2026-10-05)

## Decision
- One feature branch per work session: `stage<N>/<short-task>` (e.g. `stage0/rojo-skeleton`); chores use `chore/<name>`.
- Small, clear commits. Never force-push. Never commit directly to `main`.
- Merge to `main` through a pull request; the user reviews/merges.
- Claude commits locally at the end of a session. Pushing and opening the PR happens on the user's say-so (or when explicitly told to).
- Studio-authored binary assets under `assets/` are committed too; keep them small and note changes in the handoff.
