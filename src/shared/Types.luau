--!strict
--[[
	Cross-cutting types shared by server and client.
	Types used by a single module live in that module instead.
]]

export type LogLevel = "Debug" | "Info" | "Warn" | "Error"

-- Returns `(true)` when valid, `(false, reason)` when not. Never throws.
export type Validator = (value: unknown) -> (boolean, string?)

export type RateLimitSpec = {
	Burst: number, -- max calls that can be made back-to-back
	PerSecond: number, -- sustained calls per second once the burst is spent
}

--[[
	Intent:  client -> server RemoteEvent (fire and forget)
	Request: client -> server RemoteFunction (server answers `ok, ...`)
	Notify:  server -> client RemoteEvent
]]
export type RemoteKind = "Intent" | "Request" | "Notify"

export type RemoteDefinition = {
	kind: RemoteKind,
	-- One validator per positional argument. Extra arguments are rejected.
	-- Ignored for `Notify` (the server is the sender).
	args: { Validator },
	-- Overrides Config.Network.DefaultRate. Ignored for `Notify`.
	rate: RateLimitSpec?,
}

return {}
