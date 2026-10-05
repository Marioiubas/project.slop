--!strict
--[[
	Dev-only startup self-check: pings the server once and logs the round trip, so a
	broken remote layer shows up the moment you press Play. Controlled by
	`Config.Debug.PingOnStart` and only runs in Studio.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Config = require(Shared.Config)
local Lifecycle = require(Shared.Lifecycle)
local Log = require(Shared.Log)
local NetworkController = require(script.Parent.NetworkController)

local log = Log.new("DiagnosticsController")

local network: NetworkController.Api

local DiagnosticsController = {
	Name = "DiagnosticsController",
	Dependencies = { "NetworkController" },
}

function DiagnosticsController:init(registry: Lifecycle.Registry)
	network = registry:get("NetworkController")
end

function DiagnosticsController:start()
	if not (Config.Debug.PingOnStart and RunService:IsStudio()) then
		return
	end

	-- Wait first so the measurement is the round trip, not the time the server took to boot.
	network:waitUntilReady()
	local startedAt = os.clock()
	local ok, echoedTime, serverTime = network:request("Ping", startedAt)
	if not ok then
		log:error("ping failed: %s", tostring(echoedTime))
		return
	end
	if echoedTime ~= startedAt then
		log:error("ping answered with a different timestamp than we sent")
		return
	end
	log:info(
		"ping ok: round trip %.1f ms, server time %.2f",
		(os.clock() - startedAt) * 1000,
		serverTime
	)
end

return DiagnosticsController
