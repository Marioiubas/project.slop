--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local sharedRef = script.Parent:FindFirstChild("SharedRef")
local Shared = sharedRef and sharedRef.Value or ReplicatedStorage:WaitForChild("OddvaultShared")
local Constants = require(Shared.Constants)
local Dimensions = require(Shared.DimensionDefinitions)
local Rooms = require(Shared.RoomDefinitions)
local Planner = require(Shared.GraphPlanner)
local Builder = require(script.Parent.WorldBuilder)
local Generator = {}
export type Statistics = {
	Instances: number,
	BaseParts: number,
	PhysicsParts: number,
	ParticleEmitters: number,
	Lights: number,
	NPCs: number,
	Artifacts: number,
	GenerationMilliseconds: number?,
}
export type Request = {
	RiftId: string,
	DimensionId: string,
	Seed: number,
	Difficulty: number,
	PartyId: string,
	CellId: string,
	Origin: Vector3,
}
export type Generated = {
	Model: Model,
	Graph: Planner.Graph,
	Rooms: { [number]: Model },
	Entry: BasePart,
	Extraction: BasePart,
	Statistics: Statistics,
}

local function hasTagUnder(model, tag)
	for _, object in ipairs(model:GetDescendants()) do
		if CollectionService:HasTag(object, tag) then
			return true
		end
	end
	return false
end

local function intersects(aMin, aMax, bMin, bMax)
	return aMin.X < bMax.X - 0.01
		and aMax.X > bMin.X + 0.01
		and aMin.Y < bMax.Y - 0.01
		and aMax.Y > bMin.Y + 0.01
		and aMin.Z < bMax.Z - 0.01
		and aMax.Z > bMin.Z + 0.01
end

local function localBounds(part, pivot)
	local cf = pivot:ToObjectSpace(part.CFrame)
	local size = part.Size / 2
	local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
	local extent = Vector3.new(
		math.abs(r.X) * size.X + math.abs(u.X) * size.Y + math.abs(l.X) * size.Z,
		math.abs(r.Y) * size.X + math.abs(u.Y) * size.Y + math.abs(l.Y) * size.Z,
		math.abs(r.Z) * size.X + math.abs(u.Z) * size.Y + math.abs(l.Z) * size.Z
	)
	return cf.Position - extent, cf.Position + extent
end

function Generator.ValidateTemplate(
	template: Model,
	definition: Builder.RoomDefinition
): { [string]: BasePart }
	assert(template:IsA("Model"), "Room template must be a Model")
	for _, key in ipairs({
		"RoomId",
		"Role",
		"Width",
		"Depth",
		"Height",
		"CarryWidth",
		"CarryHeight",
		"KitVersion",
	}) do
		assert(template:GetAttribute(key) == definition[key], "Room metadata mismatch: " .. key)
	end
	local pivot, parts = template:GetPivot(), 0
	local sockets, points = {}, template:FindFirstChild("Sockets")
	assert(points, "Missing sockets")
	for _, socket in ipairs(points:GetChildren()) do
		local direction = Planner.Directions[socket:GetAttribute("Direction")]
		assert(socket:IsA("BasePart") and direction, "Invalid socket direction")
		local key = socket:GetAttribute("Direction")
		assert(not sockets[key], "Duplicate socket direction")
		assert(CollectionService:HasTag(socket, "RiftSocket"), "Socket tag missing")
		assert(
			socket:GetAttribute("SocketType") == "Large"
				and socket:GetAttribute("AllowedConnections") == "Large",
			"Incompatible socket type"
		)
		assert(
			socket:GetAttribute("Width") >= Constants.CarryWidth
				and socket:GetAttribute("Height") >= Constants.CarryHeight,
			"Socket clearance too small"
		)
		assert(
			socket:GetAttribute("OneWay") == false,
			"One-way sockets unsupported in foundation kit"
		)
		local cf = pivot:ToObjectSpace(socket.CFrame)
		assert(
			(cf.Position - Vector3.new(direction.X * 48, 12, direction.Z * 48)).Magnitude < 0.01,
			"Socket off grid or off edge"
		)
		assert(
			cf.LookVector:Dot(Vector3.new(direction.X, 0, direction.Z)) > 0.999,
			"Socket must face outward"
		)
		sockets[key] = socket
	end
	for direction in pairs(Planner.Directions) do
		assert(sockets[direction], "Missing socket " .. direction)
	end
	assert(hasTagUnder(template, "RoomBounds"), "Missing room bounds")
	assert(hasTagUnder(template, "PlayerSpawn"), "Missing safe spawn")
	assert(hasTagUnder(template, "ArtifactSpawn"), "Missing curated artifact authoring marker")
	if definition.Role == "Extraction" then
		assert(hasTagUnder(template, "ExtractionPoint"), "Missing extraction point")
	end
	if definition.Role == "Landmark" then
		assert(hasTagUnder(template, "Landmark"), "Missing landmark")
	end
	local h = Constants.CarryWidth / 2
	local lanes = {
		{ Vector3.new(-h, 0, -48), Vector3.new(h, Constants.CarryHeight, 48) },
		{ Vector3.new(-48, 0, -h), Vector3.new(48, Constants.CarryHeight, h) },
	}
	local floorFound = false
	for _, object in ipairs(template:GetDescendants()) do
		if object:IsA("BasePart") then
			parts += 1
			local low, high = localBounds(object, pivot)
			if object.CanCollide then
				assert(
					low.X >= -48.01 and high.X <= 48.01 and low.Z >= -48.01 and high.Z <= 48.01,
					"Collision outside room footprint"
				)
				for _, lane in ipairs(lanes) do
					assert(
						not intersects(low, high, lane[1], lane[2]),
						"Collision blocks cargo lane: " .. object.Name
					)
				end
				if
					low.X <= -47.99
					and high.X >= 47.99
					and low.Z <= -47.99
					and high.Z >= 47.99
					and math.abs(high.Y) < 0.01
				then
					floorFound = true
				end
			end
			if
				CollectionService:HasTag(object, "PlayerSpawn")
				or CollectionService:HasTag(object, "ExtractionPoint")
			then
				local point = pivot:PointToObjectSpace(object.Position)
				assert(
					math.abs(point.X) <= h - 2
						and math.abs(point.Z) <= 44
						and point.Y >= 3
						and point.Y <= 8,
					"Unsafe spawn/extraction marker"
				)
			end
			assert(object.Anchored, "Phase 1 kit must contain only anchored geometry")
		end
	end
	assert(floorFound, "Room requires a continuous, level collision floor")
	assert(parts <= Constants.MaxPartsPerRoom, "Room exceeds part budget")
	return sockets
end

function Generator.Statistics(model: Model): Statistics
	local stats = {
		Instances = 0,
		BaseParts = 0,
		PhysicsParts = 0,
		ParticleEmitters = 0,
		Lights = 0,
		NPCs = 0,
		Artifacts = 0,
	}
	for _, object in ipairs(model:GetDescendants()) do
		stats.Instances += 1
		if object:IsA("BasePart") then
			stats.BaseParts += 1
			if not object.Anchored then
				stats.PhysicsParts += 1
			end
		elseif object:IsA("ParticleEmitter") then
			stats.ParticleEmitters += 1
		elseif object:IsA("Light") then
			stats.Lights += 1
		elseif object:IsA("Humanoid") then
			stats.NPCs += 1
		end
		if object:GetAttribute("ArtifactInstanceId") then
			stats.Artifacts += 1
		end
	end
	return stats
end

function Generator.Generate(templates: Folder, parent: Folder, request: Request): Generated
	local started = os.clock()
	local dimension = assert(Dimensions[request.DimensionId], "Unknown DimensionId")
	assert(request.Difficulty == 1, "Only foundation difficulty 1 is supported")
	local graph = Planner.Plan(request.Seed, dimension, Rooms, Constants)
	local valid, errors = Planner.Validate(graph, Rooms, Constants)
	assert(valid, table.concat(errors, "; "))
	local templateDirectory =
		assert(templates:FindFirstChild(dimension.DimensionId), "Missing dimension templates")
	local sourceRooms = assert(templateDirectory:FindFirstChild("Rooms"), "Missing Rooms")
	local checked = {}
	-- Fail before allocating Instances if any selected authored room is invalid.
	for _, node in ipairs(graph.Nodes) do
		if not checked[node.TemplateId] then
			local template =
				assert(sourceRooms:FindFirstChild(node.TemplateId), "Missing room template")
			Generator.ValidateTemplate(template, Rooms[node.TemplateId])
			checked[node.TemplateId] = template
		end
	end
	local model = Instance.new("Model")
	model.Name = "Rift_" .. request.RiftId
	local ok, result = pcall(function()
		for _, key in ipairs({ "RiftId", "DimensionId", "Seed", "Difficulty", "PartyId", "CellId" }) do
			model:SetAttribute(key, request[key])
		end
		model:SetAttribute("GenerationVersion", graph.GenerationVersion)
		model:SetAttribute("GraphFingerprint", Planner.Fingerprint(graph))
		model:SetAttribute("State", "Generating")
		model:SetAttribute("MainPathLength", graph.MainPathLength)
		local geometry = Builder.Folder(model, "Geometry")
		local gameplay = Builder.Folder(model, "Gameplay")
		for _, name in ipairs({ "Artifacts", "Hazards", "Players", "Effects" }) do
			Builder.Folder(model, name)
		end
		local origin, roomModels, used = request.Origin, {}, {}
		for _, node in ipairs(graph.Nodes) do
			local room = checked[node.TemplateId]:Clone()
			room.Name = "Room_" .. node.Id .. "_" .. node.TemplateId
			room:SetAttribute("NodeId", node.Id)
			room:SetAttribute("Optional", node.Optional)
			room:PivotTo(CFrame.new(origin + Vector3.new(node.X, 0, node.Z)))
			room.Parent = geometry
			roomModels[node.Id], used[node.Id] = room, {}
		end
		for index, edge in ipairs(graph.Edges) do
			used[edge.A][edge.Direction], used[edge.B][edge.Opposite] = true, true
			local a, b = graph.Nodes[edge.A], graph.Nodes[edge.B]
			local middle = origin + Vector3.new((a.X + b.X) / 2, 0, (a.Z + b.Z) / 2)
			local direction = Planner.Directions[edge.Direction]
			local cf = CFrame.lookAt(middle, middle + Vector3.new(direction.X, 0, direction.Z))
			local connector = Instance.new("Model")
			connector.Name, connector.ModelStreamingMode, connector.Parent =
				"Connector_" .. index, Enum.ModelStreamingMode.Atomic, geometry
			connector:SetAttribute("RoomA", edge.A)
			connector:SetAttribute("RoomB", edge.B)
			Builder.Part(
				connector,
				"Floor",
				Vector3.new(28, 2, 32),
				cf * CFrame.new(0, -1, 0),
				Builder.Colors.Wood,
				true,
				Enum.Material.Wood
			)
			for _, x in ipairs({ -13, 13 }) do
				Builder.Part(
					connector,
					"Rail",
					Vector3.new(2, 8, 32),
					cf * CFrame.new(x, 4, 0),
					Builder.Colors.Cream,
					true
				)
			end
		end
		for id, room in pairs(roomModels) do
			for _, socket in ipairs(room.Sockets:GetChildren()) do
				local direction = socket:GetAttribute("Direction")
				socket:SetAttribute("Connected", used[id][direction] == true)
				if not used[id][direction] then
					Builder.Part(
						room.Collision,
						"SealedSocket",
						Vector3.new(24, 8, 2),
						socket.CFrame * CFrame.new(0, -8, 1),
						Builder.Colors.Cream,
						true
					)
				end
			end
		end
		local entryPoint, extractionPoint
		for _, object in ipairs(roomModels[graph.Entry]:GetDescendants()) do
			if CollectionService:HasTag(object, "PlayerSpawn") then
				entryPoint = object
			end
		end
		for _, object in ipairs(roomModels[graph.Extraction]:GetDescendants()) do
			if CollectionService:HasTag(object, "ExtractionPoint") then
				extractionPoint = object
			end
		end
		assert(entryPoint and extractionPoint, "Missing runtime endpoints")
		-- Endpoints stay inside atomic room models. Gameplay holds traceable metadata.
		gameplay:SetAttribute("EntryRoom", graph.Entry)
		gameplay:SetAttribute("ExtractionRoom", graph.Extraction)
		for _, object in ipairs(model:GetDescendants()) do
			object:SetAttribute("RiftId", request.RiftId)
		end
		local stats = Generator.Statistics(model)
		assert(stats.BaseParts <= Constants.MaxPartsPerRift, "Rift exceeds part budget")
		stats.GenerationMilliseconds = (os.clock() - started) * 1000
		for key, value in pairs(stats) do
			model:SetAttribute(key, value)
		end
		model:SetAttribute("State", "Ready")
		model.Parent = parent -- Publish only after all validation/assembly succeeds.
		return {
			Model = model,
			Graph = graph,
			Rooms = roomModels,
			Entry = entryPoint,
			Extraction = extractionPoint,
			Statistics = stats,
		}
	end)
	if not ok then
		model:Destroy()
		error(result, 0)
	end
	return result
end
return Generator
