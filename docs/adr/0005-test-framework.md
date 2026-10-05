# ADR 0005 — Tests run under Lune with a small in-repo framework

Status: accepted (2026-10-05)

## Context
The gate for Stage 0 is "clean build + lint + test run from a cold clone", and fresh Claude sessions need to run tests without opening Studio. Candidate setups:
- **TestEZ / Jest-Lua** (Wally packages): need a Roblox runtime, so tests only run inside Studio or a cloud runner.
- **Plain scripts run inside Studio**: not repeatable from the command line.
- **Lune** (a standalone Luau runtime, pinned in `rokit.toml`): runs from the CLI, but has no DataModel, so Roblox-style `require(script.Parent.X)` doesn't work out of the box.

## Decision
Use **Lune 0.10.5** plus two small in-repo pieces:
- `tools/lib/rojo_loader.luau` asks `rojo sourcemap` for the real instance tree and builds a stand-in (`Name`, `Parent`, children by name, `FindFirstChild`, `GetService`, `IsA`, `script`, `require`). Production modules load unchanged, so tests exercise the exact files that ship. `task.spawn/defer/delay` report errors in the spawned function through `warn` (as Roblox prints them) so tests can assert on them.
- `tests/lib/testkit.luau` is a ~400-line `describe` / `it` / `expect` framework with hooks and async-friendly tests. Specs live in `tests/specs/*.spec.luau`; `lune run tests/run [filter]` runs them and exits non-zero on failure.

`lune run tools/check` chains format, lint, type check, build, tests and content validation into the single gate.

## Consequences
- **Only pure logic is unit-testable**: modules that call Roblox APIs (`Instance.new`, services, datatypes like `Vector3`) can't load under Lune. Keep logic in small pure modules and keep Services/Controllers thin wiring (as `NetworkService` is); verify the wiring in a Studio playtest and say so in the handoff.
- The loader approximates Roblox (`WaitForChild` doesn't yield, no Roblox datatypes); don't rely on it for engine behaviour.
- If we later need in-engine tests (physics, replication), add Jest-Lua alongside; nothing here blocks it.
- Lune is a new third-party binary; it is pinned in `rokit.toml` and was explicitly trusted by the project owner.
