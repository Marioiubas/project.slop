# ADR 0006 — Remote registry, validation pipeline, and Service/Controller bootstrap

Status: accepted (2026-10-05)

## Context
The blueprint requires an authoritative server, client "intent" only, argument/rate validation on every remote, and clean separation of systems. Stage 1+ will add many remotes and systems; the shape needs to be fixed before they pile up.

## Decision
**Remotes.** `src/shared/Remotes.luau` is the single registry. Each entry has a `kind` and a validator per argument:
- `Intent`: client → server `RemoteEvent` (fire and forget).
- `Request`: client → server `RemoteFunction`; the server answers `true, ...results` or `false, reason`.
- `Notify`: server → client `RemoteEvent`.
There is no server → client `RemoteFunction` (a client can hang the server by never answering).

`NetworkService` (server) creates the instances from the registry and runs every client call through **rate limit (token bucket per player per remote) → `Validate.args` → handler** (handlers run in `Safe.call`). Rejections are dropped and logged, throttled per player/remote. `NetworkController` (client) mirrors the API and also validates before sending so mistakes show up in dev instead of being silently dropped. Payloads are flat primitives (ids, numbers, strings); never Instances or paths.

**Bootstrap.** `Lifecycle` boots units (server `Services`, client `Controllers`): a unit has a unique `Name`, optional `Dependencies`, a synchronous `init(registry)` and an optional yielding `start()`. Order is a deterministic topological sort (registration order breaks ties); all `init`s run before any `start`; a failing `init` aborts boot loudly naming the unit, a failing `start` is logged. Units reach each other through `registry:get(name)` annotated with the dependency's exported `Api` type, never through each other's internals.

## Consequences
- Adding a remote = one registry entry + one handler; the validation/rate-limit cannot be forgotten.
- The registry, `Validate`, `RateLimiter` and `Lifecycle` are pure and unit-tested; `NetworkService`/`NetworkController` need Roblox and are verified in Studio.
- `reportViolation` in `NetworkService` is the hook for exploit telemetry (Stage 6).
- Not covered yet: `UnreliableRemoteEvent` for high-frequency data, table-shaped payloads beyond `Validate.shape`, and per-remote cooldown/sequence checks (add when a feature needs them).
