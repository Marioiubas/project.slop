--!strict
--[[
	The single registry of every remote in the game. NetworkService (server) creates the
	RemoteEvent/RemoteFunction instances from this table and NetworkController (client)
	looks them up by the same names, so a remote that isn't listed here doesn't exist.

	Rules (blueprint "Client / Server Architecture"):
	  - The client only ever sends *intent*. The server decides what actually happens.
	  - Every client -> server remote lists a validator per argument; anything that fails
	    validation, or exceeds its rate limit, is dropped before reaching a handler.
	  - Send flat primitives (ids, numbers, strings). Never Instances or paths: the server
	    looks things up itself and checks distance/state/ownership.
	  - Names must be valid Instance names (they become the instances' names).
]]

local Types = require(script.Parent.Types)
local Validate = require(script.Parent.Validate)

local definitions: { [string]: Types.RemoteDefinition } = {
	-- Diagnostics: send your clock, get back (clientTime, serverTime) to measure round trip.
	Ping = {
		kind = "Request",
		args = { Validate.number({ min = 0 }) },
		rate = { Burst = 3, PerSecond = 1 },
	},
}

return table.freeze(definitions)
