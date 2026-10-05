# GRAB THE WEIRD! (Project Oddvault)

A Roblox game about physically grabbing strange artifacts from unstable Rifts and escaping with them. Built with Rojo; design lives in [docs/grab-the-weird-blueprint.md](docs/grab-the-weird-blueprint.md), the plan in [docs/dev-plan.md](docs/dev-plan.md), and the working rules in [docs/how-to-work.md](docs/how-to-work.md).

## Set up (cold clone)

```bash
rokit install            # installs the pinned tools in rokit.toml (rojo, stylua, selene, luau-lsp, wally, lune)
lune run tools/check     # format, lint, types, build, unit tests, content validation
```

`rokit` asks you to trust each tool the first time. Make sure `~/.rokit/bin` is on your PATH.

## Everyday commands

| Task | Command |
|---|---|
| Everything the gate checks | `lune run tools/check` |
| Unit tests (optionally filtered by name) | `lune run tests/run [filter]` |
| Validate game content | `lune run tools/validate_content` |
| Strict type check (needs Roblox type definitions, see the script header) | `lune run tools/typecheck` |
| Auto-format | `stylua src tests tools` |
| Live-sync into Studio | `rojo serve`, then click Connect in the Rojo plugin |
| Build a place file | `rojo build default.project.json -o build/GrabTheWeird.rbxl` |

## Layout

```
src/shared/   types, config, content data, pure logic (loaded by server and client)
src/server/   Services: authoritative state, validation (Main.server.luau boots them)
src/client/   Controllers: input, UI, feedback (Main.client.luau boots them)
tests/        unit tests (specs/*.spec.luau) run under Lune
tools/        check, typecheck, validate_content, and the Rojo-aware module loader
assets/       Studio-authored .rbxm pieces (see ADR 0004)
docs/         blueprint, plan, workflow, ADRs
```
