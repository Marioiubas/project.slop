return function(env, installer)
	-- Appended to the exact installer by run_tests.py, with a deterministic engine double.
	local count = 0
	local function check(condition, message)
		count += 1
		assert(condition, message)
	end
	local storage, replicated, scripts =
		env.Services.ServerStorage, env.Services.ReplicatedStorage, env.Services.ServerScriptService
	local world, templates = env.workspace.OddvaultWorld, storage.OddvaultTemplates
	local server, shared = scripts.OddvaultServer, replicated.OddvaultShared
	local Generator, Builder = env.require(server.RiftGenerator), env.require(server.WorldBuilder)
	local Rooms = env.require(shared.RoomDefinitions)
	check(
		#templates.GiantsKitchen.Rooms:GetChildren() == 7,
		"Installer did not create seven templates"
	)
	check(#world.RiftRuntime:GetChildren() == 1, "Installer preview missing")
	check(world.RiftRuntime:GetChildren()[1]:GetAttribute("Preview") == true, "Preview not marked")
	check(
		env.workspace.StreamingEnabled and env.workspace.StreamingTargetRadius == 384,
		"Streaming settings missing"
	)
	check(
		server.Bootstrap.Enabled
			and env.Services.StarterPlayer.StarterPlayerScripts.OddvaultClient.Enabled,
		"Scripts disabled"
	)
	for _, room in ipairs(templates.GiantsKitchen.Rooms:GetChildren()) do
		check(
			pcall(Generator.ValidateTemplate, room, Rooms[room:GetAttribute("RoomId")]),
			"Authored kit rejected"
		)
	end
	local counter = templates.GiantsKitchen.Rooms.Countertop
	local blocker = Builder.Part(
		counter.Collision,
		"MaliciousCargoBlocker",
		env.Vector3.new(8, 10, 8),
		env.CFrame.new(0, 5, 0),
		nil,
		true
	)
	check(
		not pcall(Generator.ValidateTemplate, counter, Rooms.Countertop),
		"Actual obstructed cargo geometry accepted"
	)
	blocker:Destroy()
	local floor = counter.Collision.Floor
	floor.CanCollide = false
	check(
		not pcall(Generator.ValidateTemplate, counter, Rooms.Countertop),
		"Floorless template accepted"
	)
	floor.CanCollide = true
	local socket = counter.Sockets.Socket_N
	local originalFrame = socket.CFrame
	socket.CFrame = socket.CFrame * env.CFrame.Angles(0, math.pi, 0)
	check(
		not pcall(Generator.ValidateTemplate, counter, Rooms.Countertop),
		"Inward-facing socket accepted"
	)
	socket.CFrame = originalFrame
	socket:SetAttribute("Width", 12)
	check(
		not pcall(Generator.ValidateTemplate, counter, Rooms.Countertop),
		"Narrow socket accepted"
	)
	socket:SetAttribute("Width", 24)
	local landmark = templates.GiantsKitchen.Rooms.FridgeLandmark
	local marker = landmark.LandmarkPoints.FridgeLandmark
	marker._tags.Landmark = nil
	check(
		not pcall(Generator.ValidateTemplate, landmark, Rooms.FridgeLandmark),
		"Landmarkless template accepted"
	)
	marker._tags.Landmark = true
	local fingerprints = {}
	for seed = 1, 100 do
		local generated = Generator.Generate(templates, world.RiftRuntime, {
			RiftId = "GeometryTest_" .. seed,
			DimensionId = "GiantsKitchen",
			Seed = seed,
			Difficulty = 1,
			PartyId = "Test",
			CellId = "A",
			Origin = env.Vector3.new(1536, 0, 0),
		})
		check(
			#generated.Graph.Nodes == 8 and generated.Statistics.BaseParts < 1000,
			"Generated geometry exceeds budget"
		)
		check(
			generated.Statistics.PhysicsParts == 0 and generated.Statistics.Artifacts == 0,
			"Foundation claims live physics/artifacts"
		)
		local floors = {}
		for _, part in ipairs(generated.Model:GetDescendants()) do
			check(
				part:GetAttribute("RiftId") == "GeometryTest_" .. seed,
				"Rift descendant not traceable"
			)
			if part:IsA("BasePart") and part.Name == "Floor" then
				table.insert(floors, part)
			end
		end
		check(#floors == 16, "Room or connector floor missing")
		for i, a in ipairs(floors) do
			local function extent(part)
				local r, u, l =
					part.CFrame.RightVector, part.CFrame.UpVector, part.CFrame.LookVector
				return env.Vector3.new(
					math.abs(r.X) * part.Size.X / 2
						+ math.abs(u.X) * part.Size.Y / 2
						+ math.abs(l.X) * part.Size.Z / 2,
					1,
					math.abs(r.Z) * part.Size.X / 2
						+ math.abs(u.Z) * part.Size.Y / 2
						+ math.abs(l.Z) * part.Size.Z / 2
				)
			end
			local aExtent = extent(a)
			for j = i + 1, #floors do
				local b, bExtent = floors[j], extent(floors[j])
				local delta = a.Position - b.Position
				check(
					math.abs(delta.X) >= aExtent.X + bExtent.X - 0.01
						or math.abs(delta.Z) >= aExtent.Z + bExtent.Z - 0.01,
					"Assembled room/connector floors overlap"
				)
			end
		end
		fingerprints[seed] = generated.Model:GetAttribute("GraphFingerprint")
		generated.Model:Destroy()
	end
	check(#world.RiftRuntime:GetChildren() == 1, "Generated instances leaked")

	local Service = env.require(server.RiftService)
	world.RiftRuntime:GetChildren()[1]:Destroy()
	local service = Service.new(world, templates, shared.Remotes)
	local rifts = {}
	for i = 1, 4 do
		rifts[i] = assert(service:Create("GiantsKitchen", i))
	end
	check(service.Allocator:Count() == 4, "Concurrent cell reservations missing")
	check(not service:Create("GiantsKitchen", 5), "Fifth concurrent Rift accepted")
	for _, rift in ipairs(rifts) do
		service:Close(rift, "Test cleanup")
	end
	check(
		service.Allocator:Count() == 0 and #world.RiftRuntime:GetChildren() == 0,
		"Cleanup leaked map or lease"
	)
	local invalid, reason = service:Create("MissingDimension", 1)
	check(
		not invalid and reason and service.Allocator:Count() == 0,
		"Failed generation leaked reservation"
	)
	check(#world.RiftRuntime:GetChildren() == 0, "Failed generation published a partial map")

	local player = env.Instance.new("Player")
	player.Name, player.Parent = "TestPlayer", env.Services.Players
	local character = env.Instance.new("Model")
	local root = env.Instance.new("Part")
	root.Name, root.Parent = "HumanoidRootPart", character
	character.PrimaryPart = root
	local humanoid = env.Instance.new("Humanoid")
	humanoid.Health, humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 100, 16, 50, 7.2
	humanoid.Parent, player.Character = character, character
	local rift = assert(service:Create("GiantsKitchen", 12345))
	root.CFrame = env.CFrame.new(world.Hub.PortalEntry.Position)
	check(service:Transition(player, rift, true, world.Hub.PortalEntry), "Entry transition failed")
	check(humanoid.WalkSpeed == 0, "Source movement not held during streaming")
	local pending = service.Pending[player]
	service:Acknowledge(player, "forged-token", true)
	check(
		service.Membership[player] == nil and service.Pending[player] == pending,
		"Forged ack changed ownership"
	)
	service:Acknowledge(player, pending.Token, true)
	check(
		service.Membership[player] == rift.RiftId and rift.State == "Active",
		"Validated entry failed"
	)
	check(
		(root.Position - rift.Generated.Entry.Position).Magnitude < 0.01
			and humanoid.WalkSpeed == 16,
		"Entry did not restore movement"
	)
	service:Extract(player, rift)
	check(not service.Pending[player], "Distant extraction accepted")
	root.CFrame = env.CFrame.new(rift.Generated.Extraction.Position)
	service:Extract(player, rift)
	check(
		service.Pending[player] and not service.Pending[player].Entering,
		"Extraction transition missing"
	)
	service:Acknowledge(player, service.Pending[player].Token, true)
	check(
		not service.Membership[player] and service.Allocator:Count() == 0,
		"Last extraction did not clean up Rift"
	)
	check(
		(root.Position - world.Hub.HomeArrival.Position).Magnitude < 0.01,
		"Extraction did not return to hub"
	)
	check(humanoid.WalkSpeed == 16 and humanoid.JumpPower == 50, "Movement state leaked")
	local expired = assert(service:Create("GiantsKitchen", 17))
	root.CFrame = env.CFrame.new(world.Hub.PortalEntry.Position)
	service:Transition(player, expired, true, world.Hub.PortalEntry)
	service.Pending[player].Deadline = -1
	service:Acknowledge(player, service.Pending[player].Token, true)
	check(
		not service.Membership[player] and not service.Pending[player] and humanoid.WalkSpeed == 16,
		"Expired transition admitted player"
	)
	service:Close(expired, "Test cleanup")
	local failedStream = assert(service:Create("GiantsKitchen", 19))
	service:Transition(player, failedStream, true, world.Hub.PortalEntry)
	service:Acknowledge(player, service.Pending[player].Token, false)
	check(
		not service.Membership[player] and not service.Pending[player],
		"Failed stream admitted player"
	)
	service:Close(failedStream, "Test cleanup")
	local closing = assert(service:Create("GiantsKitchen", 21))
	service:Transition(player, closing, true, world.Hub.PortalEntry)
	service:Close(closing, "Run expired")
	check(
		not service.Pending[player] and humanoid.WalkSpeed == 16 and service.Allocator:Count() == 0,
		"Close leaked pending transition"
	)

	local function fixturePlayer(name)
		local p = env.Instance.new("Player")
		p.Name, p.Parent = name, env.Services.Players
		local char, body, hum =
			env.Instance.new("Model"), env.Instance.new("Part"), env.Instance.new("Humanoid")
		body.Name, body.Parent = "HumanoidRootPart", char
		char.PrimaryPart, char.Parent = body, env.workspace
		hum.Health, hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = 100, 16, 50, 7.2
		hum.Parent, p.Character = char, char
		body.CFrame = env.CFrame.new(world.Hub.PortalEntry.Position)
		return p, body, hum
	end
	local p2, root2, hum2 = fixturePlayer("SecondPlayer")
	local p3, root3 = fixturePlayer("ThirdPlayer")
	-- New expeditions remain separate even before either client finishes streaming.
	service:Enter(p2, false, world.Hub.PortalEntry)
	service:Enter(p3, false, world.Hub.PortalEntry)
	check(service.Pending[p2] and service.Pending[p3], "Concurrent entry did not reserve maps")
	local pendingFirst, pendingSecond = service.Pending[p2].Rift, service.Pending[p3].Rift
	check(pendingFirst ~= pendingSecond, "New expeditions shared a pending destination")
	local joining, joiningRoot = fixturePlayer("JoiningPlayer")
	joiningRoot.CFrame = env.CFrame.new(world.Hub.JoinEntry.Position)
	service:Enter(joining, true, world.Hub.JoinEntry)
	check(
		service.Pending[joining] and service.Pending[joining].Rift == pendingFirst,
		"Join station did not share the oldest open expedition"
	)
	service:Close(pendingFirst, "Test cleanup")
	service:Close(pendingSecond, "Test cleanup")
	check(
		not next(service.Pending) and service.Allocator:Count() == 0,
		"Concurrent entry cleanup leaked transitions or cells"
	)
	local first, second =
		assert(service:Create("GiantsKitchen", 31)), assert(service:Create("GiantsKitchen", 32))
	service:Transition(p2, first, true, world.Hub.PortalEntry)
	service:Transition(p3, second, true, world.Hub.PortalEntry)
	service:Acknowledge(p2, service.Pending[p2].Token, true)
	service:Acknowledge(p3, service.Pending[p3].Token, true)
	check(
		service.Membership[p2] ~= service.Membership[p3],
		"Independent players share Rift membership"
	)
	check(
		(root2.Position - root3.Position).Magnitude > 1000,
		"Rift cells are not spatially isolated"
	)
	root2.CFrame = env.CFrame.new(second.Generated.Extraction.Position)
	service:Extract(p2, second)
	check(not service.Pending[p2], "Player extracted through another Rift")
	service:Close(first, "Run expired")
	check(
		not service.Membership[p2] and service.Membership[p3] == second.RiftId,
		"Closing one Rift damaged another"
	)
	service:Leave(p3)
	check(service.Allocator:Count() == 0, "Last member departure leaked cells")
	local readyExpiry = assert(service:Create("GiantsKitchen", 41))
	service:Tick(readyExpiry.ExpiresAt + 1)
	check(
		readyExpiry.State == "Destroyed" and service.Allocator:Count() == 0,
		"Unused ready map did not expire"
	)
	local activeExpiry = assert(service:Create("GiantsKitchen", 42))
	root2.CFrame = env.CFrame.new(world.Hub.PortalEntry.Position)
	service:Transition(p2, activeExpiry, true, world.Hub.PortalEntry)
	service:Acknowledge(p2, service.Pending[p2].Token, true)
	service:Tick(activeExpiry.ExpiresAt + 1)
	check(
		activeExpiry.State == "Destroyed"
			and not service.Membership[p2]
			and (root2.Position - world.Hub.HomeArrival.Position).Magnitude < 0.01,
		"Active expiry did not safely return player"
	)
	local timeout = assert(service:Create("GiantsKitchen", 43))
	root2.CFrame = env.CFrame.new(world.Hub.PortalEntry.Position)
	service:Transition(p2, timeout, true, world.Hub.PortalEntry)
	service:Tick(service.Pending[p2].Deadline + 0.1)
	check(
		not service.Pending[p2] and hum2.WalkSpeed == 16,
		"Lifecycle tick did not release held player"
	)
	service:Close(timeout, "Test cleanup")
	service:Start()
	local live = assert(service:Create("GiantsKitchen", 44))
	service:Transition(p2, live, true, world.Hub.PortalEntry)
	service:Acknowledge(p2, service.Pending[p2].Token, true)
	p2.CharacterRemoving:Fire(p2.Character)
	check(
		not service.Membership[p2] and live.State == "Destroyed",
		"Character reset leaked membership"
	)
	env.Services.Players.PlayerRemoving:Fire(p3)
	check(
		not service.PlayerConnections[p3]
			and not service.Cooldowns[p3]
			and not service.AckLimits[p3],
		"Disconnect leaked player state"
	)
	service:Stop()
	check(
		service.Allocator:Count() == 0 and #world.RiftRuntime:GetChildren() == 0,
		"Stop did not clean all maps"
	)

	-- Reinstall archives owned edits and preserves unrelated objects.
	templates:SetAttribute("DesignerEdit", "preserved")
	local unrelated = env.Instance.new("Part")
	unrelated.Name, unrelated.Parent = "UnrelatedUserBuild", env.workspace
	installer()
	check(env.workspace.UnrelatedUserBuild == unrelated, "Reinstall removed unrelated content")
	check(env.workspace.OddvaultWorld ~= world, "Reinstall retained old active world")
	local backup = storage.OddvaultBackups:GetChildren()[1]
	check(
		backup and backup.OddvaultTemplates:GetAttribute("DesignerEdit") == "preserved",
		"Reinstall discarded designer edits"
	)
	check(#backup:GetChildren() == 5, "Incomplete installation backup")
	local installed = env.workspace.OddvaultWorld
	local baselineRequire = env.require
	env.require = function(module)
		local result = baselineRequire(module)
		if module.Name == "WorldBuilder" then
			local originalRoom = result.Room
			result.Room = function(definition)
				local room = originalRoom(definition)
				result.Part(
					room.Collision,
					"BrokenKit",
					env.Vector3.new(8, 8, 8),
					env.CFrame.new(0, 4, 0),
					nil,
					true
				)
				return room
			end
		end
		return result
	end
	check(not pcall(installer), "Installer accepted broken kit geometry")
	check(
		env.workspace.OddvaultWorld == installed and #storage.OddvaultBackups:GetChildren() == 1,
		"Failed staging replaced old installation"
	)
	env.require = baselineRequire
	installed:SetAttribute("OddvaultOwned", false)
	check(not pcall(installer), "Installer overwrote a foreign root")
	check(
		env.workspace.OddvaultWorld == installed and #storage.OddvaultBackups:GetChildren() == 1,
		"Rejected installation changed existing content"
	)
	for _, child in ipairs(storage:GetChildren()) do
		check(not string.match(child.Name, "^OddvaultStaging_"), "Staging folder leaked")
	end
	-- Rojo installs code only; execute the same bootstrap without prebuilt geometry/remotes.
	installed:Destroy()
	storage.OddvaultTemplates:Destroy()
	replicated.OddvaultShared.Remotes:Destroy()
	local currentServer = scripts.OddvaultServer
	local bootstrap = assert(loadstring(currentServer.Bootstrap.Source, "RojoBootstrap"))
	setfenv(bootstrap, setmetatable({ script = currentServer.Bootstrap }, { __index = env }))
	bootstrap()
	check(
		env.workspace.OddvaultWorld.Hub ~= nil
			and #storage.OddvaultTemplates.GiantsKitchen.Rooms:GetChildren() == 7,
		"Rojo bootstrap did not recreate authored kit"
	)
	check(
		#env.workspace.OddvaultWorld.RiftRuntime:GetChildren() == 1
			and replicated.OddvaultShared.Remotes.StreamReady ~= nil,
		"Rojo bootstrap did not create initial Rift/remotes"
	)
	print(
		string.format(
			"PASS: %d engine-double checks, 100 assembled maps, multiplayer cell isolation, transitions, failure cleanup and safe reinstall.",
			count
		)
	)
end
