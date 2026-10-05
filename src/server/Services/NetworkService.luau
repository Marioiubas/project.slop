--!strict
--[[
	Server side of the remote layer. Creates every remote declared in `Shared/Remotes`
	and guards each client call before any game code sees it:

	    rate limit (per player, per remote)  ->  argument validation  ->  your handler

	Rejected calls are dropped (Requests answer `false, reason`) and logged, throttled so
	a spammer can't flood the output. Handlers run through `Safe.call`, so a bug in one never
	breaks the remote for everybody else.

	Other services use it through the registry (see DiagnosticsService):

	    network:onIntent("DropArtifact", function(player, artifactId) ... end)
	    network:onRequest("Ping", function(player, clientTime) return clientTime, serverTime end)
	    network:notify("ArtifactPickedUp", player, artifactId)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Config = require(Shared.Config)
local Log = require(Shared.Log)
local Remotes = require(Shared.Remotes)
local Safe = require(Shared.Safe)
local Types = require(Shared.Types)
local Validate = require(Shared.Validate)
local RateLimiter = require(script.Parent.Parent.RateLimiter)

type RemoteDefinition = Types.RemoteDefinition

export type IntentHandler = (player: Player, ...any) -> ()
export type RequestHandler = (player: Player, ...any) -> ...any

export type Api = {
	onIntent: (self: Api, name: string, handler: IntentHandler) -> (),
	onRequest: (self: Api, name: string, handler: RequestHandler) -> (),
	notify: (self: Api, name: string, player: Player, ...any) -> (),
	notifyAll: (self: Api, name: string, ...any) -> (),
}

local log = Log.new("NetworkService")

local remoteInstances: { [string]: RemoteEvent | RemoteFunction } = {}
local limiters: { [string]: RateLimiter.RateLimiter } = {}
local intentHandlers: { [string]: IntentHandler } = {}
local requestHandlers: { [string]: RequestHandler } = {}
-- userId -> remote name -> os.clock() of the last logged violation
local lastViolationLog: { [number]: { [string]: number } } = {}

local NetworkService = {
	Name = "NetworkService",
}

local function reportViolation(player: Player, remoteName: string, reason: string)
	local perPlayer = lastViolationLog[player.UserId]
	if perPlayer == nil then
		perPlayer = {}
		lastViolationLog[player.UserId] = perPlayer
	end
	local now = os.clock()
	local last = perPlayer[remoteName]
	if last ~= nil and now - last < Config.Network.ViolationLogIntervalSeconds then
		return
	end
	perPlayer[remoteName] = now
	log:warn("rejected %s from %s (%d): %s", remoteName, player.Name, player.UserId, reason)
end

-- Returns nil if the call may proceed, otherwise a short machine-readable rejection code.
local function gate(player: Player, name: string, definition: RemoteDefinition, ...: any): string?
	if not limiters[name]:tryConsume(player.UserId) then
		reportViolation(player, name, "rate limited")
		return "rate_limited"
	end
	local ok, reason = Validate.args(definition.args, ...)
	if not ok then
		reportViolation(player, name, "invalid arguments: " .. tostring(reason))
		return "invalid_args"
	end
	return nil
end

local function handleIntent(player: Player, name: string, definition: RemoteDefinition, ...: any)
	if gate(player, name, definition, ...) ~= nil then
		return
	end
	local handler = intentHandlers[name]
	if handler == nil then
		log:warn("intent %s has no handler registered", name)
		return
	end
	local ok, err = Safe.call(handler, player, ...)
	if not ok then
		log:error("handler for %s threw: %s", name, tostring(err))
	end
end

local function handleRequest(
	player: Player,
	name: string,
	definition: RemoteDefinition,
	...: any
): (boolean, ...any)
	local rejection = gate(player, name, definition, ...)
	if rejection ~= nil then
		return false, rejection
	end
	local handler = requestHandlers[name]
	if handler == nil then
		log:warn("request %s has no handler registered", name)
		return false, "unavailable"
	end
	local results = table.pack(Safe.call(handler, player, ...))
	if not results[1] then
		log:error("handler for %s threw: %s", name, tostring(results[2]))
		return false, "server_error"
	end
	return true, table.unpack(results, 2, results.n)
end

local function createRemote(name: string, definition: RemoteDefinition): Instance
	if definition.kind == "Request" then
		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.OnServerInvoke = function(player: Player, ...: any)
			return handleRequest(player, name, definition, ...)
		end
		remoteInstances[name] = remote
		return remote
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	if definition.kind == "Intent" then
		remote.OnServerEvent:Connect(function(player: Player, ...: any)
			handleIntent(player, name, definition, ...)
		end)
	end
	remoteInstances[name] = remote
	return remote
end

function NetworkService:init()
	local folder = Instance.new("Folder")
	folder.Name = Config.Network.RemotesFolderName

	for name, definition in Remotes do
		assert(
			definition.kind == "Intent"
				or definition.kind == "Request"
				or definition.kind == "Notify",
			`Remotes.{name}: unknown kind {tostring(definition.kind)}`
		)
		if definition.kind ~= "Notify" then
			local rate = definition.rate or Config.Network.DefaultRate
			limiters[name] = RateLimiter.new({ Burst = rate.Burst, PerSecond = rate.PerSecond })
		end
		createRemote(name, definition).Parent = folder
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		for _, limiter in limiters do
			limiter:forget(player.UserId)
		end
		lastViolationLog[player.UserId] = nil
	end)

	-- Parent last so clients never see a half-built folder.
	folder.Parent = ReplicatedStorage
	log:info("published %d remote(s)", #folder:GetChildren())
end

function NetworkService:onIntent(name: string, handler: IntentHandler)
	local definition = Remotes[name]
	assert(definition ~= nil and definition.kind == "Intent", `{name} is not a registered Intent`)
	assert(intentHandlers[name] == nil, `{name} already has a handler`)
	intentHandlers[name] = handler
end

function NetworkService:onRequest(name: string, handler: RequestHandler)
	local definition = Remotes[name]
	assert(definition ~= nil and definition.kind == "Request", `{name} is not a registered Request`)
	assert(requestHandlers[name] == nil, `{name} already has a handler`)
	requestHandlers[name] = handler
end

local function getNotifyRemote(name: string): RemoteEvent
	local definition = Remotes[name]
	assert(definition ~= nil and definition.kind == "Notify", `{name} is not a registered Notify`)
	return remoteInstances[name] :: RemoteEvent
end

function NetworkService:notify(name: string, player: Player, ...: any)
	getNotifyRemote(name):FireClient(player, ...)
end

function NetworkService:notifyAll(name: string, ...: any)
	getNotifyRemote(name):FireAllClients(...)
end

return NetworkService
