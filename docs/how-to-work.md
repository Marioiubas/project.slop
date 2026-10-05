# How To Work (read this first, every session)

This repo is built across many short Claude sessions. Context is cleared between them, so **files are the memory**. Follow this loop every time.

## Session start (do in order)
1. Read `HANDOFF.md` (repo root) — the last session's state and the exact next step.
2. Read the current stage in `docs/dev-plan.md`.
3. Skim the relevant blueprint section(s) in `docs/grab-the-weird-blueprint.md` — only what the task touches.
4. `git status` and `git log --oneline -10` to confirm the tree matches the handoff.
5. Restate the task in 1–3 lines and confirm scope with the user if it's ambiguous.

If `HANDOFF.md` and the repo disagree, trust the repo, say so, and fix the handoff.

## Scope rules
- **One task per session**, sized to finish and verify (roughly one plan checkbox group). Don't start the next stage's work.
- Only change what the task needs. No drive-by refactors; note them in the handoff under "Noticed".
- Don't add features the blueprint's **Quality Bar** would reject.
- New design decisions that affect structure → write a short ADR in `docs/adr/NNNN-title.md` (context, decision, consequences).

## Tooling
Tools are pinned in `rokit.toml` (rojo, stylua, selene, luau-lsp, wally, lune). If a command isn't found, run `rokit install`; in Git Bash ensure `~/.rokit/bin` is on PATH. Adding a new tool needs the user's explicit trust (`rokit` refuses otherwise): ask first.

Commands (full table in `README.md`):
- `lune run tools/check` — the whole gate: format, lint, types, rojo build, unit tests, content validation.
- `lune run tests/run [filter]` — unit tests (specs in `tests/specs/`, see ADR 0005).
- `stylua src tests tools` — auto-format before running the gate.

## Coding standards
- Luau, `--!strict` on all new modules. Typed public APIs.
- **Server is authoritative.** Client sends *intent*; server validates type, distance, state, cooldown, ownership, rate. Never trust client currency/inventory/rarity/extraction/purchase.
- Content is data (`src/shared/Content/`), systems are logic. Adding an artifact/rift/mutation should need no system changes.
- No magic numbers for tunables — put them in `Config`.
- Clean up connections/instances (Janitor-style). No unbounded per-frame work; respect the mobile performance budget.
- Match the surrounding code's style; run `stylua` and `selene` before finishing.
- Prefer small pure modules that can be unit-tested outside Studio.

## Rojo / Studio workflow
- Code lives in `src/` and syncs via `rojo serve`. Do **not** hand-edit scripts inside Studio; they'd be overwritten.
- World geometry (hub, rooms, models) is authored in Studio and saved under `assets/` (rules in ADR 0004: no scripts inside assets, find things by tag/attribute). Record in the handoff exactly which assets were added/changed and how they're wired into the Rojo project.
- Studio MCP tools (when available) may be used to inspect/build/playtest; anything they create that matters must be exported into `assets/` or recreated from code — never leave important state only in an unsaved Studio session.
- If the user must do something in Studio manually (publish, plugin, settings), list it explicitly as **USER ACTION** in the handoff.

## Definition of done (all must be true before ending)
- [ ] `lune run tools/check` passes: `rojo build`, `stylua --check`, `selene`, type check, unit tests, content validation (or failures documented as pre-existing)
- [ ] New logic has tests where practical (pure logic in `tests/specs/`; code that needs Roblox APIs is verified in Studio instead)
- [ ] Type check wasn't skipped: `tools/typecheck` prints `SKIPPED` when no Roblox type definitions are found; say so in the handoff if it did
- [ ] Verified in Studio/playtest if the change is behavioural — say plainly if it was **not** verified
- [ ] `docs/dev-plan.md` checkboxes updated
- [ ] Changes committed locally on a feature branch `stage<N>/<task>` (ADR 0003): never force-push, never commit to `main`; push/PR only when the user says so
- [ ] **`HANDOFF.md` written** (below)

## Reporting honestly
State what works, what's untested, and what's broken. If something was skipped or stubbed, say so in the handoff — don't leave it implied.

## Ending a session: write `HANDOFF.md`
Overwrite `HANDOFF.md` at the repo root (the previous one lives in git history). It must let a brand-new session continue with zero chat history. Use this template:

```markdown
# HANDOFF — <date> — Stage <N>: <task title>

## Goal of this session
<1–2 lines>

## What was done
- <bullets; reference files as `path:line` where useful>

## State of the repo
- Branch: <name>   Last commit: <hash + subject>
- Builds: yes/no   Lint: pass/fail   Tests: pass/fail (X/Y)
- Verified in Studio: yes/no/partial — <what was actually tried>

## Not done / stubbed / known broken
- <be specific>

## Decisions made (and why)
- <include ADR links>

## Noticed (out of scope, not acted on)
- <bugs, debt, ideas>

## USER ACTION needed
- <manual Studio steps, publishing, asset uploads, API keys — or "none">

## Next step (exactly)
1. <first concrete action for the next session, with file paths>
2. <…>

## Files to read first next time
- <paths>

## Plan status
Stage <N>: <x>/<y> items done. Gate met? <yes/no — why>
```

Keep it factual and short (aim for one screen). The user may clear the conversation immediately after reading it.
