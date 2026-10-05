--!strict
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedRef = script.Parent:FindFirstChild("SharedRef")
local Shared = sharedRef and sharedRef.Value or ReplicatedStorage:WaitForChild("OddvaultShared")
local Constants = require(Shared.Constants)
local Allocator = require(script.Parent.RiftCellAllocator)
local Generator = require(script.Parent.RiftGenerator)
local Service = {}
export type Rift = {
	RiftId: string,
	Lease: Allocator.Lease,
	Generated: Generator.Generated,
	State: string,
	CreatedAt: number,
	ExpiresAt: number,
	Occupants: { [Player]: boolean },
	Connections: { RBXScriptConnection },
	InstabilityLevel: number,
}
-- Dynamic Instance child access is confined to the standalone package boundary.
export type RiftService = typeof(setmetatable({} :: any, Service))
Service.__index = Service

local function rootOf(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return nil
	end
	return root, humanoid, character
end

function Service.new(world: Model, templates: Folder, remotes: Folder): RiftService
	return setmetatable({
		World = world,
		Templates = templates,
		Remotes = remotes,
		Allocator = Allocator.new(Constants.Cells),
		Rifts = {},
		Pending = {},
		Membership = {},
		Cooldowns = {},
		AckLimits = {},
		Connections = {},
		Running = false,
	}, Service)
end

function Service.Notify(self: RiftService, player: Player, message: string)
	if player.Parent == Players then
		self.Remotes.Notice:FireClient(player, message)
	end
end

function Service.Create(self: RiftService, dimensionId: string, seed: number): (Rift?, string?)
	local riftId = HttpService:GenerateGUID(false)
	local lease, allocationError = self.Allocator:Reserve(riftId)
	if not lease then
		return nil, allocationError
	end
	local ok, generated = pcall(Generator.Generate, self.Templates, self.World.RiftRuntime, {
		RiftId = riftId,
		DimensionId = dimensionId,
		Seed = seed,
		Difficulty = 1,
		PartyId = "Open_" .. riftId,
		CellId = lease.CellId,
		Origin = Vector3.new(lease.X, 0, lease.Z),
	})
	if not ok then
		self.Allocator:Release(lease)
		warn("[Oddvault] Generation rejected", dimensionId, seed, generated)
		return nil, "Room validation failed. Check the server Output."
	end
	local now = os.clock()
	local rift = {
		RiftId = riftId,
		Lease = lease,
		Generated = generated,
		State = "Ready",
		CreatedAt = now,
		ExpiresAt = now + Constants.ReadyLifetime,
		Occupants = {},
		Connections = {},
		InstabilityLevel = 0,
	}
	self.Rifts[riftId] = rift
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText, prompt.ObjectText = "Return home", "EXTRACTION GATE"
	prompt.MaxActivationDistance, prompt.HoldDuration, prompt.RequiresLineOfSight = 12, 0.3, false
	prompt:SetAttribute("RiftId", riftId)
	prompt.Parent = generated.Extraction
	table.insert(
		rift.Connections,
		prompt.Triggered:Connect(function(player)
			self:Extract(player, rift)
		end)
	)
	return rift
end

function Service.FinishPending(
	self: RiftService,
	player: Player,
	success: boolean,
	message: string?
)
	local pending = self.Pending[player]
	if not pending then
		return
	end
	self.Pending[player] = nil
	if pending.Humanoid.Parent and pending.Humanoid.Health > 0 then
		pending.Humanoid.WalkSpeed, pending.Humanoid.JumpPower, pending.Humanoid.JumpHeight =
			pending.WalkSpeed, pending.JumpPower, pending.JumpHeight
	end
	if player.Parent == Players then
		self.Remotes.TransitionDone:FireClient(player, pending.Token, success, message or "")
	end
end

function Service.Leave(self: RiftService, player: Player)
	local id = self.Membership[player]
	self.Membership[player] = nil
	player:SetAttribute("OddvaultRiftId", nil)
	local rift = id and self.Rifts[id]
	if rift then
		rift.Occupants[player] = nil
		if rift.State == "Active" and not next(rift.Occupants) then
			self:Close(rift, "Last player left")
		end
	end
end

function Service.Close(self: RiftService, rift: Rift, reason: string)
	if rift.State == "Destroyed" or rift.State == "Closing" then
		return
	end
	rift.State = "Closing"
	rift.Generated.Model:SetAttribute("State", "Closing")
	for player, pending in pairs(self.Pending) do
		if pending.Rift == rift then
			self:FinishPending(player, false, "Rift closed")
		end
	end
	-- Emergency return at expiry uses the known safe hub, never a client destination.
	-- The hub is per-player persistent while they are away; regular extraction still pre-streams.
	for player in pairs(rift.Occupants) do
		self.Membership[player] = nil
		player:SetAttribute("OddvaultRiftId", nil)
		local root, _, character = rootOf(player)
		if root then
			character:PivotTo(CFrame.new(self.World.Hub.HomeArrival.Position))
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		end
		self:Notify(
			player,
			reason == "Run expired" and "The test Rift closed. Back home safely." or "Rift closed."
		)
	end
	table.clear(rift.Occupants)
	for _, connection in ipairs(rift.Connections) do
		connection:Disconnect()
	end
	table.clear(rift.Connections)
	rift.Generated.Model:Destroy()
	assert(self.Allocator:Release(rift.Lease), "Cell lease was lost")
	self.Rifts[rift.RiftId], rift.State = nil, "Destroyed"
end

function Service.Capacity(self: RiftService, rift: Rift): boolean
	local count = 0
	for _ in pairs(rift.Occupants) do
		count += 1
	end
	for _, pending in pairs(self.Pending) do
		if pending.Rift == rift and pending.Entering then
			count += 1
		end
	end
	return count < Constants.MaxOccupants
end

function Service.Transition(
	self: RiftService,
	player: Player,
	rift: Rift,
	entering: boolean,
	source: BasePart
): boolean
	local root, humanoid, character = rootOf(player)
	if not root or self.Pending[player] or (root.Position - source.Position).Magnitude > 14 then
		return false
	end
	if entering then
		if
			self.Membership[player]
			or (rift.State ~= "Ready" and rift.State ~= "Active")
			or not self:Capacity(rift)
		then
			return false
		end
	else
		if self.Membership[player] ~= rift.RiftId or rift.State ~= "Active" then
			return false
		end
	end
	local destination = entering and rift.Generated.Entry.Position
		or self.World.Hub.HomeArrival.Position
	local pending = {
		Token = HttpService:GenerateGUID(false),
		Rift = rift,
		Entering = entering,
		Source = source,
		Destination = destination,
		Character = character,
		Humanoid = humanoid,
		Deadline = os.clock() + Constants.TransitionTimeout,
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
	}
	self.Pending[player] = pending
	humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 0, 0, 0
	self.Remotes.Transition:FireClient(player, {
		Token = pending.Token,
		Position = destination,
		Entering = entering,
		RiftId = rift.RiftId,
		RoomName = rift.Generated.Rooms[rift.Generated.Graph.Entry].Name,
	})
	return true
end

function Service.Enter(self: RiftService, player: Player, joinExisting: boolean, source: BasePart)
	if self.Pending[player] or self.Membership[player] then
		return
	end
	local root = rootOf(player)
	if not root or (root.Position - source.Position).Magnitude > 14 then
		return
	end
	local now = os.clock()
	if now < (self.Cooldowns[player] or 0) then
		return
	end
	self.Cooldowns[player] = now + 2
	local rift
	local claimed = {}
	for _, pending in pairs(self.Pending) do
		if pending.Entering then
			claimed[pending.Rift.RiftId] = true
		end
	end
	for _, candidate in pairs(self.Rifts) do
		if
			self:Capacity(candidate)
			and (joinExisting or not claimed[candidate.RiftId])
			and (candidate.State == "Ready" or (joinExisting and candidate.State == "Active"))
		then
			if not rift or candidate.CreatedAt < rift.CreatedAt then
				rift = candidate
			end
		end
	end
	if not rift and joinExisting then
		self:Notify(player, "No open expedition yet. Use the main portal.")
		return
	end
	if not rift then
		local generationError
		rift, generationError =
			self:Create("GiantsKitchen", Random.new():NextInteger(0, 2147483645))
		if not rift then
			self:Notify(player, generationError or "Rifts are busy. Try again shortly.")
			return
		end
	end
	if not self:Transition(player, rift, true, source) then
		self:Notify(player, "Portal unavailable. Try again.")
	end
end

function Service.Extract(self: RiftService, player: Player, rift: Rift)
	if not self:Transition(player, rift, false, rift.Generated.Extraction) then
		return
	end
end

function Service.Acknowledge(self: RiftService, player: Player, token: unknown, ready: unknown)
	-- This remote has no position, artifact identity, inventory or reward argument.
	local now = os.clock()
	local bucket = self.AckLimits[player]
	if not bucket or now - bucket.Start >= 1 then
		bucket = { Start = now, Count = 0 }
		self.AckLimits[player] = bucket
	end
	bucket.Count += 1
	if bucket.Count > 8 then
		return
	end
	if type(token) ~= "string" or #token > 64 or type(ready) ~= "boolean" then
		return
	end
	local pending = self.Pending[player]
	if not pending or pending.Token ~= token then
		return
	end
	local root, _, character = rootOf(player)
	local valid = ready
		and os.clock() <= pending.Deadline
		and character == pending.Character
		and root
		and pending.Source.Parent
		and (root.Position - pending.Source.Position).Magnitude <= 14
		and self.Rifts[pending.Rift.RiftId] == pending.Rift
		and (pending.Rift.State == "Ready" or pending.Rift.State == "Active")
	if not valid then
		self:FinishPending(player, false, "Destination did not stream in time. Try again.")
		return
	end
	local rift, entering = pending.Rift, pending.Entering
	if not entering and self.Membership[player] ~= rift.RiftId then
		self:FinishPending(player, false, "Expedition state changed")
		return
	end
	character:PivotTo(
		CFrame.lookAt(pending.Destination, pending.Destination + Vector3.new(0, 0, 1))
	)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	if entering then
		if rift.State == "Ready" then
			rift.ExpiresAt = os.clock() + Constants.RunLifetime
		end
		rift.State, rift.Occupants[player], self.Membership[player] = "Active", true, rift.RiftId
		rift.Generated.Model:SetAttribute("State", "Active")
		player:SetAttribute("OddvaultRiftId", rift.RiftId)
		self:FinishPending(player, true, "Follow the countertop to the cyan extraction gate.")
	else
		self:FinishPending(player, true, "Route complete. Artifact recovery arrives in Phase 2.")
		self:Leave(player)
	end
end

function Service.Tick(self: RiftService, now: number)
	for player, pending in pairs(self.Pending) do
		if now > pending.Deadline then
			self:FinishPending(player, false, "Portal timed out. Try again.")
		end
	end
	local closing = {}
	for _, rift in pairs(self.Rifts) do
		if now >= rift.ExpiresAt then
			table.insert(closing, rift)
		elseif rift.State == "Active" then
			-- Phase 1 diagnostics only: no fake promise of active hazards.
			rift.InstabilityLevel =
				math.clamp(100 * (1 - (rift.ExpiresAt - now) / Constants.RunLifetime), 0, 100)
			rift.Generated.Model:SetAttribute("InstabilityLevel", rift.InstabilityLevel)
		end
	end
	for _, rift in ipairs(closing) do
		self:Close(rift, rift.State == "Active" and "Run expired" or "Unused Rift expired")
	end
end

function Service.Start(self: RiftService)
	assert(not self.Running, "RiftService already started")
	self.Running = true
	-- Keeping only the small hub persistent ensures emergency returns have a floor.
	self.World.Hub.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local function promptAt(marker, action, callback)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText = action, "GIANT'S KITCHEN"
		prompt.RequiresLineOfSight, prompt.HoldDuration, prompt.MaxActivationDistance =
			false, 0.25, 12
		prompt.Parent = marker
		table.insert(self.Connections, prompt.Triggered:Connect(callback))
	end
	promptAt(self.World.Hub.PortalEntry, "Enter a new Rift", function(player)
		self:Enter(player, false, self.World.Hub.PortalEntry)
	end)
	local join = self.World.Hub:FindFirstChild("JoinEntry")
	if join then
		promptAt(join, "Join an open Rift", function(player)
			self:Enter(player, true, join)
		end)
	end
	table.insert(
		self.Connections,
		self.Remotes.StreamReady.OnServerEvent:Connect(function(player, token, ready)
			self:Acknowledge(player, token, ready)
		end)
	)
	local function added(player)
		player.RespawnLocation = self.World.Hub.OddvaultSpawn
		local function reset()
			self:FinishPending(player, false, "Character respawned")
			self:Leave(player)
		end
		local function characterAdded(character)
			reset()
			task.defer(function()
				local root = character:WaitForChild("HumanoidRootPart", 10)
				if
					root
					and player.Character == character
					and not self.Membership[player]
					and not self.Pending[player]
				then
					character:PivotTo(
						CFrame.lookAt(
							self.World.Hub.OddvaultSpawn.Position + Vector3.new(0, 4, 0),
							self.World.Hub.PortalEntry.Position
						)
					)
				end
			end)
		end
		local connections = {
			player.CharacterRemoving:Connect(reset),
			player.CharacterAdded:Connect(characterAdded),
		}
		self.PlayerConnections[player] = connections
		if player.Character then
			characterAdded(player.Character)
		end
	end
	self.PlayerConnections = {}
	table.insert(self.Connections, Players.PlayerAdded:Connect(added))
	table.insert(
		self.Connections,
		Players.PlayerRemoving:Connect(function(player)
			self:FinishPending(player, false)
			self:Leave(player)
			self.Cooldowns[player] = nil
			self.AckLimits[player] = nil
			for _, connection in ipairs(self.PlayerConnections[player] or {}) do
				connection:Disconnect()
			end
			self.PlayerConnections[player] = nil
		end)
	)
	for _, player in ipairs(Players:GetPlayers()) do
		added(player)
	end
	task.spawn(function()
		while self.Running do
			self:Tick(os.clock())
			task.wait(0.5)
		end
	end)
	local rift, reason = self:Create("GiantsKitchen", 12345)
	if not rift then
		warn("[Oddvault] Initial generation failed:", reason)
	end
end

function Service.Stop(self: RiftService)
	self.Running = false
	local rifts = {}
	for _, rift in pairs(self.Rifts) do
		table.insert(rifts, rift)
	end
	for _, rift in ipairs(rifts) do
		self:Close(rift, "Server stopping")
	end
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	for _, connections in pairs(self.PlayerConnections or {}) do
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end
	table.clear(self.Connections)
end
return Service
