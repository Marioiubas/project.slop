--!strict
--[[
	Every tunable lives here, never inline in a system.
	The table is deep-frozen: reads only, no runtime mutation.
]]

local function deepFreeze<T>(value: T): T
	if type(value) == "table" and not table.isfrozen(value) then
		table.freeze(value)
		for _, child in value :: any do
			deepFreeze(child)
		end
	end
	return value
end

local Config = {
	GameName = "GRAB THE WEIRD!",

	Log = {
		-- "Debug" | "Info" | "Warn" | "Error"
		Level = "Info",
	},

	Debug = {
		-- Client pings the server on start and logs the round trip (Studio only).
		PingOnStart = true,
	},

	Network = {
		RemotesFolderName = "Remotes",
		-- How long the client waits for the server to publish the remotes folder.
		RemotesWaitTimeoutSeconds = 30,
		-- Applied to any client -> server remote that doesn't declare its own `rate`.
		DefaultRate = {
			Burst = 10,
			PerSecond = 5,
		},
		-- A player's rejected calls to one remote are logged at most this often.
		ViolationLogIntervalSeconds = 5,
	},
}

return deepFreeze(Config)
