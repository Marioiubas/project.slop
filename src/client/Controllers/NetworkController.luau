--!strict
--[[
	Client side of the remote layer. The client only ever sends *intent*; the server
	validates and decides. Arguments are checked here too, but only so mistakes show up
	immediately in the output instead of being silently dropped by the server.

	    network:fire("DropArtifact", artifactId)            -- Intent (fire and forget)
	    local ok, a, b = network:request("Ping", os.clock()) -- Request: ok == false -> a is the reason
	    network:on("ArtifactPickedUp", function(artifactId) ... end) -- Notify

	Remotes are published by the server a moment after join, so `request` and `fire` yield
	until they're ready (call them from `start`, not `init`). `on` can be called anywhere.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Config = require(Shared.Config)
local Log = require(Shared.Log)
local Remotes = require(Shared.Remotes)
local Signal = require(Shared.Signal)
local Validate = require(Shared.Validate)

export type Api = {
	-- Yields until the remotes are available. Returns false if they never appeared.
	waitUntilReady: (self: Api) -> boolean,
	fire: (self: Api, name: string, ...any) -> boolean,
	request: (self: Api, name: string, ...any) -> (boolean, ...any),
	on: (self: Api, name: string, handler: (...any) -> ()) -> (),
}

type Status = "Pending" | "Ready" | "Failed"

local log = Log.new("NetworkController")

local status: Status = "Pending"
local settled = Signal.new() :: Signal.Signal<()>
local remoteInstances: { [string]: Instance } = {}
local pendingListeners: { { Name: string, Handler: (...any) -> () } } = {}

local NetworkController = {
	Name = "NetworkController",
}

local function connectListener(name: string, handler: (...any) -> ())
	local remote = remoteInstances[name] :: Instance?
	if remote ~= nil and remote:IsA("RemoteEvent") then
		(remote :: RemoteEvent).OnClientEvent:Connect(handler)
	else
		log:warn("no RemoteEvent named %s to listen to", name)
	end
end

function NetworkController:start()
	-- With a timeout, WaitForChild returns nil instead of yielding forever (its type omits that).
	local folder = ReplicatedStorage:WaitForChild(
		Config.Network.RemotesFolderName,
		Config.Network.RemotesWaitTimeoutSeconds
	) :: Instance?
	if folder == nil then
		status = "Failed"
		log:error("remotes folder never appeared; the server may have failed to start")
		settled:Fire()
		return
	end

	for name in Remotes do
		local remote =
			folder:WaitForChild(name, Config.Network.RemotesWaitTimeoutSeconds) :: Instance?
		if remote == nil then
			status = "Failed"
			log:error("remote %s never appeared", name)
			settled:Fire()
			return
		end
		remoteInstances[name] = remote
	end

	status = "Ready"
	for _, listener in pendingListeners do
		connectListener(listener.Name, listener.Handler)
	end
	table.clear(pendingListeners)
	settled:Fire()
end

function NetworkController:waitUntilReady(): boolean
	if status == "Pending" then
		settled:Wait()
	end
	return status == "Ready"
end

function NetworkController:fire(name: string, ...: any): boolean
	local definition = Remotes[name]
	if definition == nil or definition.kind ~= "Intent" then
		log:error("%s is not a registered Intent", name)
		return false
	end
	local ok, reason = Validate.args(definition.args, ...)
	if not ok then
		log:error("not sending %s: %s", name, tostring(reason))
		return false
	end
	if not self:waitUntilReady() then
		return false
	end
	(remoteInstances[name] :: RemoteEvent):FireServer(...)
	return true
end

function NetworkController:request(name: string, ...: any): (boolean, ...any)
	local definition = Remotes[name]
	if definition == nil or definition.kind ~= "Request" then
		log:error("%s is not a registered Request", name)
		return false, "unknown_request"
	end
	local ok, reason = Validate.args(definition.args, ...)
	if not ok then
		log:error("not sending %s: %s", name, tostring(reason))
		return false, "invalid_args"
	end
	if not self:waitUntilReady() then
		return false, "unavailable"
	end

	local remote = remoteInstances[name] :: RemoteFunction
	local results = table.pack(pcall(remote.InvokeServer, remote, ...))
	if not results[1] then
		log:error("request %s failed: %s", name, tostring(results[2]))
		return false, "request_failed"
	end
	return table.unpack(results, 2, results.n)
end

function NetworkController:on(name: string, handler: (...any) -> ())
	local definition = Remotes[name]
	assert(definition ~= nil and definition.kind == "Notify", `{name} is not a registered Notify`)
	if status == "Ready" then
		connectListener(name, handler)
	else
		table.insert(pendingListeners, { Name = name, Handler = handler })
	end
end

return NetworkController
