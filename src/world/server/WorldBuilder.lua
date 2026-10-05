--!strict
-- Authored kit recipes. Randomness selects whole rooms; it never scatters geometry.
local CollectionService = game:GetService("CollectionService")
local NexusBuilder = require(script.Parent.NexusBuilder)
local Builder = {}
export type RoomDefinition = {
	RoomId: string,
	Role: string,
	Label: string,
	Prop: string,
	Width: number,
	Depth: number,
	Height: number,
	CarryWidth: number,
	CarryHeight: number,
	KitVersion: number,
}
export type Dimension = { DimensionId: string, RoomSet: { string } }
local C = {
	Cream = Color3.fromRGB(246, 225, 185),
	Wood = Color3.fromRGB(176, 103, 53),
	Coral = Color3.fromRGB(232, 88, 58),
	Cyan = Color3.fromRGB(48, 225, 245),
	Gold = Color3.fromRGB(255, 196, 50),
	Ink = Color3.fromRGB(36, 48, 69),
	White = Color3.fromRGB(244, 246, 244),
	Steel = Color3.fromRGB(151, 170, 181),
}
Builder.Colors = C

function Builder.Folder(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = name, parent
	return folder
end

function Builder.Part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3?,
	collide: boolean?,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name, part.Size, part.CFrame = name, size, cf
	part.Color = color or C.Cream
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored, part.CanCollide = true, collide == true
	part.CanTouch, part.CanQuery = false, collide == true
	part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function Builder.Marker(
	parent: Instance,
	name: string,
	position: Vector3,
	tag: string,
	attributes: { [string]: any }?
): Part
	local part =
		Builder.Part(parent, name, Vector3.new(2, 2, 2), CFrame.new(position), C.Cyan, false)
	part.Transparency = 1
	for key, value in pairs(attributes or {}) do
		part:SetAttribute(key, value)
	end
	CollectionService:AddTag(part, tag)
	return part
end

function Builder.Sign(
	parent: Instance,
	name: string,
	text: string,
	position: Vector3,
	width: number?,
	color: Color3?
): Part
	local anchor = Builder.Part(
		parent,
		name,
		Vector3.new(width or 28, 7, 1),
		CFrame.new(position),
		color or C.Ink,
		false
	)
	local gui = Instance.new("SurfaceGui")
	gui.Face, gui.SizingMode, gui.PixelsPerStud =
		Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 30
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	label.Text, label.TextColor3, label.Font = text, C.White, Enum.Font.GothamBold
	label.TextScaled, label.TextWrapped, label.Parent = true, true, gui
	return anchor
end

function Builder.Portal(parent: Instance, position: Vector3, name: string?): Part
	local frame = CFrame.new(position)
	for _, x in ipairs({ -15, 15 }) do
		Builder.Part(
			parent,
			"PortalPillar",
			Vector3.new(4, 32, 4),
			frame * CFrame.new(x, 16, 0),
			C.Ink,
			true
		)
		Builder.Part(
			parent,
			"PortalAccent",
			Vector3.new(1, 28, 1),
			frame * CFrame.new(x, 16, -2.1),
			C.Cyan,
			false,
			Enum.Material.Neon
		)
	end
	Builder.Part(
		parent,
		"PortalLintel",
		Vector3.new(34, 4, 4),
		frame * CFrame.new(0, 32, 0),
		C.Gold,
		true
	)
	local surface = Builder.Part(
		parent,
		name or "PortalSurface",
		Vector3.new(24, 28, 0.5),
		frame * CFrame.new(0, 15, 0),
		C.Cyan,
		false,
		Enum.Material.Neon
	)
	surface.Transparency = 0.42
	local light = Instance.new("PointLight")
	light.Color, light.Brightness, light.Range, light.Shadows, light.Parent =
		C.Cyan, 1, 32, false, surface
	return surface
end

local function props(parent, kind)
	local base = CFrame.new(28, 0, 28)
	local function part(name, size, x, y, z, color, material)
		return Builder.Part(parent, name, size, base * CFrame.new(x, y, z), color, false, material)
	end
	if kind == "Mug" then
		local mug = part("OversizedMug", Vector3.new(24, 20, 20), 0, 12, 0, C.Coral)
		mug.Shape = Enum.PartType.Cylinder
		mug.CFrame = base * CFrame.new(0, 12, 0) * CFrame.Angles(0, 0, math.pi / 2)
		part("MugHandleTop", Vector3.new(8, 3, 4), 12, 19, 0, C.Coral)
		part("MugHandleSide", Vector3.new(3, 16, 4), 16, 12, 0, C.Coral)
		part("MugHandleBottom", Vector3.new(8, 3, 4), 12, 5, 0, C.Coral)
		local cocoa = part("CocoaSurface", Vector3.new(0.8, 17, 17), 0, 24.2, 0, C.Wood)
		cocoa.Shape = Enum.PartType.Cylinder
		cocoa.CFrame = base * CFrame.new(0, 24.2, 0) * CFrame.Angles(0, 0, math.pi / 2)
	elseif kind == "CerealBox" then
		part("CerealBox", Vector3.new(24, 40, 12), 0, 20, 0, C.Coral)
		part("BoxTop", Vector3.new(26, 2, 14), 0, 41, 0, C.Gold)
		Builder.Sign(parent, "CerealLabel", "ODD O'S", Vector3.new(28, 26, 21.7), 20, C.Ink)
		for i = 1, 4 do
			local cereal = part(
				"CerealPiece",
				Vector3.new(5, 5, 5),
				-6 + (i % 2) * 12,
				4,
				-8 - math.floor(i / 3) * 7,
				C.Gold
			)
			cereal.Shape = Enum.PartType.Ball
		end
	elseif kind == "Fridge" then
		part("GiantRefrigerator", Vector3.new(28, 56, 24), 0, 28, 0, C.White)
		part("FreezerDoor", Vector3.new(26, 19, 2), 0, 44, -13, C.Cream)
		part("FridgeDoor", Vector3.new(26, 30, 2), 0, 17, -13, C.Cream)
		part("FreezerHandle", Vector3.new(2, 12, 3), -9, 44, -15, C.Steel)
		part("DoorHandle", Vector3.new(2, 19, 3), -9, 20, -15, C.Steel)
		local eye =
			part("ImpossibleEye", Vector3.new(1, 9, 9), 2, 43, -14.5, C.Cyan, Enum.Material.Neon)
		eye.Shape = Enum.PartType.Cylinder
		eye.CFrame = base * CFrame.new(2, 43, -14.5) * CFrame.Angles(0, math.pi / 2, 0)
		part("EyePupil", Vector3.new(2, 7, 1), 2, 43, -15.2, C.Ink)
	elseif kind == "Plate" then
		local plate = part("GiantPlate", Vector3.new(2, 30, 30), 0, 2, 0, C.White)
		plate.Shape = Enum.PartType.Cylinder
		plate.CFrame = base * CFrame.new(0, 2, 0) * CFrame.Angles(0, 0, math.pi / 2)
		part("ImpossibleButter", Vector3.new(12, 8, 10), 0, 7, 0, C.Gold)
	elseif kind == "Utensils" then
		part("ForkHandle", Vector3.new(4, 2, 32), 0, 2, -1, C.Steel)
		part("ForkShoulder", Vector3.new(16, 2, 6), 0, 2, -18, C.Steel)
		for x = -6, 6, 4 do
			part("ForkTine", Vector3.new(2, 2, 12), x, 2, -26, C.Steel)
		end
		part("DrawerSide", Vector3.new(4, 10, 64), 18, 5, -10, C.Wood)
	end
end

function Builder.Room(definition: RoomDefinition): Model
	local model = Instance.new("Model")
	model.Name, model.ModelStreamingMode = definition.RoomId, Enum.ModelStreamingMode.Atomic
	for key, value in pairs(definition) do
		model:SetAttribute(key, value)
	end
	local geometry = Builder.Folder(model, "Geometry")
	local collision = Builder.Folder(model, "Collision")
	local decoration = Builder.Folder(model, "Decoration")
	local sockets = Builder.Folder(model, "Sockets")
	local spawns = Builder.Folder(model, "SpawnPoints")
	local artifacts = Builder.Folder(model, "ArtifactPoints")
	local hazards = Builder.Folder(model, "HazardPoints")
	local landmarks = Builder.Folder(model, "LandmarkPoints")
	local floor = Builder.Part(
		collision,
		"Floor",
		Vector3.new(96, 2, 96),
		CFrame.new(0, -1, 0),
		C.Wood,
		true,
		Enum.Material.Wood
	)
	model.PrimaryPart = floor
	-- Floor center (not the floor part center) is the canonical room pivot.
	floor.PivotOffset = CFrame.new(0, 1, 0)
	for _, info in ipairs({
		{ "N", 0, -48, 0 },
		{ "S", 0, 48, math.pi },
		{ "E", 48, 0, -math.pi / 2 },
		{ "W", -48, 0, math.pi / 2 },
	}) do
		local cf = CFrame.new(info[2], 12, info[3]) * CFrame.Angles(0, info[4], 0)
		local socket = Builder.Marker(sockets, "Socket_" .. info[1], cf.Position, "RiftSocket", {
			Direction = info[1],
			SocketType = "Large",
			WidthClass = "Heavy",
			HeightClass = "Heavy",
			Width = 24,
			Height = 24,
			AllowedConnections = "Large",
			DoorStyle = "Countertop",
			OneWay = false,
			DifficultyTag = "Foundation",
		})
		socket.CFrame = cf
		local side = CFrame.new(0, 0, -47) * CFrame.Angles(0, 0, 0)
		local rotation = CFrame.Angles(0, info[4], 0)
		for _, x in ipairs({ -30, 30 }) do
			Builder.Part(
				collision,
				"EdgeRail",
				Vector3.new(36, 8, 2),
				rotation * side * CFrame.new(x, 4, 0),
				C.Cream,
				true
			)
		end
	end
	-- Subtle center-lane striping, above the floor but without extra collision.
	for _, x in ipairs({ -10, 10 }) do
		Builder.Part(
			geometry,
			"RouteStripe",
			Vector3.new(0.5, 0.08, 88),
			CFrame.new(x, 0.08, 0),
			C.Cream,
			false
		)
	end
	Builder.Sign(decoration, "RoomLabel", definition.Label, Vector3.new(-28, 12, 28), 28)
	Builder.Marker(spawns, "SafeSpawn", Vector3.new(0, 4, -24), "PlayerSpawn", { Safe = true })
	Builder.Marker(artifacts, "CuratedArtifact", Vector3.new(-28, 3, -28), "ArtifactSpawn", {
		SizeClass = "HEAVY",
		RarityRange = "Common:Impossible",
		AllowedCategories = "Household",
		CarryDifficulty = 1,
		RequiresCoop = false,
		HazardAssociation = "None",
		VisibilityClass = "Obvious",
	})
	Builder.Marker(hazards, "ReservedHazard", Vector3.new(28, 2, -28), "HazardSpawn", { Phase = 2 })
	local bounds = Builder.Marker(model, "Bounds", Vector3.new(0, 32, 0), "RoomBounds")
	bounds.Size = Vector3.new(96, 64, 96)
	if definition.Role == "Entry" then
		Builder.Portal(decoration, Vector3.new(0, 0, -28), "EntrySurface")
	end
	if definition.Role == "Extraction" then
		Builder.Portal(decoration, Vector3.new(0, 0, 24), "ExtractionSurface")
		Builder.Marker(model, "Extraction", Vector3.new(0, 4, 20), "ExtractionPoint")
	end
	props(decoration, definition.Prop)
	if definition.Role == "Landmark" then
		Builder.Marker(landmarks, "FridgeLandmark", Vector3.new(28, 28, 28), "Landmark")
	end
	return model
end

function Builder.Templates(
	root: Folder,
	definitions: { [string]: RoomDefinition },
	dimension: Dimension
)
	local directory = Builder.Folder(root, dimension.DimensionId)
	local rooms = Builder.Folder(directory, "Rooms")
	for _, roomId in ipairs(dimension.RoomSet) do
		local room = Builder.Room(definitions[roomId])
		room.Parent = rooms
	end
	for _, name in ipairs({ "Props", "Hazards", "ArtifactVisuals" }) do
		Builder.Folder(directory, name)
	end
end

function Builder.Hub(world: Model): Model
	local hub = Instance.new("Model")
	hub.Name, hub.ModelStreamingMode, hub.Parent = "Hub", Enum.ModelStreamingMode.Atomic, world
	Builder.Part(hub, "Plaza", Vector3.new(224, 4, 224), CFrame.new(0, -2, 0), C.Cream, true)
	Builder.Part(
		hub,
		"PortalWalk",
		Vector3.new(28, 0.1, 112),
		CFrame.new(0, 0.1, -32),
		C.Wood,
		false
	)
	Builder.Portal(hub, Vector3.new(0, 0, -8), "HubPortalSurface")
	Builder.Marker(hub, "PortalEntry", Vector3.new(0, 4, -14), "OddvaultHubEntry")
	Builder.Marker(hub, "JoinEntry", Vector3.new(42, 4, -14), "OddvaultHubEntry")
	Builder.Sign(hub, "JoinLabel", "EXPLORE TOGETHER", Vector3.new(42, 10, -10), 28)
	Builder.Sign(hub, "GameTitle", "GRAB THE WEIRD!", Vector3.new(0, 41, -8), 58)
	Builder.Sign(hub, "Objective", "JUMP IN. FIND THE WAY HOME.", Vector3.new(0, 8, -48), 42)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name, spawn.Size = "OddvaultSpawn", Vector3.new(12, 1, 12)
	spawn.CFrame, spawn.Anchored, spawn.Neutral =
		CFrame.new(0, 0.5, -72) * CFrame.Angles(0, math.pi, 0), true, true
	spawn.Material, spawn.Color, spawn.Duration = Enum.Material.SmoothPlastic, C.Wood, 0
	spawn.Parent = hub
	Builder.Marker(hub, "HomeArrival", Vector3.new(0, 4, -60), "OddvaultHomeArrival")
	NexusBuilder.HubArt(hub)
	NexusBuilder.Build(world, Builder)
	Builder.Folder(world, "RiftRuntime")
	Builder.Folder(world, "MuseumRuntime")
	return hub
end
return Builder
