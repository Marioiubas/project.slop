--!strict
--[[
	Answers the `Ping` request so the client can measure round-trip time. Also the
	smallest possible example of a service: copy this shape for new ones.

	  - Declare `Dependencies` so Lifecycle initialises those units first.
	  - Get a dependency from the registry inside `init` and annotate it with that
	    unit's exported `Api` type.
	  - Register remote handlers; never create remotes here (they live in Shared/Remotes).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Lifecycle = require(Shared.Lifecycle)
local NetworkService = require(script.Parent.NetworkService)

local DiagnosticsService = {
	Name = "DiagnosticsService",
	Dependencies = { "NetworkService" },
}

function DiagnosticsService:init(registry: Lifecycle.Registry)
	local network: NetworkService.Api = registry:get("NetworkService")

	network:onRequest("Ping", function(_player: Player, clientTime: number)
		-- Echo the client's own timestamp back with the server's, nothing else.
		return clientTime, workspace:GetServerTimeNow()
	end)
end

return DiagnosticsService
