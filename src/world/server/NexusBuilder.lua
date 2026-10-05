--!strict
-- Reference-to-geometry illustration. Each island streams atomically and has real floors.
-- Dimension rules, cargo ownership and timed collapse remain separate gameplay work.
local Kit = require(script.Parent.VisualKit)
local C = Kit.Colors
local Nexus = {}
local V = Vector3.new
local CF = CFrame.new
local Neon = Enum.Material.Neon

local function p(parent, name, size, pos, color, collide, material)
	return Kit.Part(parent, name, size, CF(pos), color, collide, material)
end

local function island(root, name, center, size, color, openings)
	local model = Kit.Model(root, name)
	model:SetAttribute("IllustratedRegion", name)
	model:SetAttribute("FloorY", 0)
	p(model, "WalkableDeck", V(size, 4, size), center + V(0, -2, 0), color, true)
	p(model, "IslandRim", V(size + 4, 5, size + 4), center + V(0, -6, 0), C.Stone)
	for i = 1, 8 do
		local angle = i * math.pi / 4
		Kit.Part(
			model,
			"FracturedFoundation",
			V(size * 0.33, 18 + (i % 3) * 8, size * 0.32),
			CF(center + V(math.cos(angle) * size * 0.28, -20, math.sin(angle) * size * 0.28))
				* CFrame.Angles(0, angle, (i % 2) * 0.12),
			i % 2 == 0 and C.Stone or C.Ink
		)
	end
	for i = 1, 5 do
		local angle = i * math.pi * 2 / 5
		local shard = Instance.new("WedgePart")
		shard.Name, shard.Size = "TaperedIslandShard", V(size * 0.32, 40, size * 0.36)
		shard.CFrame = CF(
			center + V(math.cos(angle) * size * 0.2, -34, math.sin(angle) * size * 0.2)
		) * CFrame.Angles(math.pi, angle, 0.1)
		shard.Anchored, shard.CanCollide, shard.CanTouch, shard.CanQuery = true, false, false, false
		shard.Material, shard.Color, shard.Parent = Enum.Material.Slate, C.Ink, model
	end
	for _, edge in ipairs({ { "N", 0, -1 }, { "S", 0, 1 }, { "E", 1, 0 }, { "W", -1, 0 } }) do
		local horizontal = edge[2] == 0
		local length = openings[edge[1]] and (size - 48) / 2 or size
		local offsets = openings[edge[1]] and { -(size + 48) / 4, (size + 48) / 4 } or { 0 }
		for _, offset in ipairs(offsets) do
			local position = center
				+ V(
					horizontal and offset or edge[2] * (size / 2 - 1),
					3,
					horizontal and edge[3] * (size / 2 - 1) or offset
				)
			p(
				model,
				"SafetyRail",
				horizontal and V(length, 6, 2) or V(2, 6, length),
				position,
				C.Ink,
				true
			)
			p(
				model,
				"RailCap",
				horizontal and V(length, 0.6, 2.4) or V(2.4, 0.6, length),
				position + V(0, 3.2, 0),
				C.Gold
			)
		end
	end
	return model
end

local function bridge(root, name, a, b, color, width)
	local model = Kit.Model(root, name)
	local w = width or 40
	local length = (b - a).Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	model:SetAttribute("CarryWidth", w - 4)
	Kit.Part(model, "WalkableBridge", V(w, 4, length + 1), cf * CF(0, -2, 0), color, true)
	for _, side in ipairs({ -1, 1 }) do
		Kit.Part(
			model,
			"BridgeRail",
			V(2, 6, length),
			cf * CF(side * (w / 2 - 1), 3, 0),
			C.Ink,
			true
		)
		Kit.Part(model, "RailTop", V(2.5, 0.6, length), cf * CF(side * (w / 2 - 1), 6.2, 0), C.Gold)
		for i = 0, math.floor(length / 24) do
			Kit.Part(
				model,
				"RailPost",
				V(3, 8, 3),
				cf * CF(side * (w / 2 - 1), 4, -length / 2 + i * 24),
				C.Stone
			)
		end
	end
	for i = 0, math.floor(length / 16) do
		Kit.Part(
			model,
			"DeckJoint",
			V(w - 4, 0.05, 0.3),
			cf * CF(0, 0.025, -length / 2 + i * 16),
			C.Stone
		)
	end
	return model
end

local function tree(parent, at, scale)
	p(parent, "Trunk", V(3, 12, 3) * scale, at + V(0, 6, 0) * scale, C.Wood)
	for i = 1, 3 do
		p(
			parent,
			"BlockLeaves",
			V(12, 7, 12) * scale,
			at + V((i - 2) * 5, 13 + (i % 2) * 4, 0) * scale,
			C.Green
		)
	end
end

local function portal(parent, cf, radius, color)
	Kit.Ring(parent, "PortalStone", cf, radius + 2, 4, C.Ink, 20)
	Kit.Ring(parent, "PortalEnergy", cf, radius, 1.2, color, 20, Neon)
	Kit.Ring(
		parent,
		"PortalInner",
		cf * CFrame.Angles(0, 0, 0.2),
		radius * 0.78,
		0.6,
		color,
		18,
		Neon
	)
	local face = Kit.Ball(parent, "PortalGlow", V(radius * 1.5, radius * 1.5, 1), cf, color, Neon)
	face.Transparency = 0.75
end

local function core(root)
	local center = V(0, 0, 320)
	local m = island(
		root,
		"FractureNexus",
		center,
		224,
		C.Stone,
		{ N = true, S = true, E = true, W = true }
	)
	Kit.Disc(m, "CoreDais", 72, 4, CF(center + V(0, 2, 0)), C.Ink, true)
	Kit.Disc(m, "CoreTrim", 76, 1, CF(center + V(0, 4.3, 0)), C.Gold)
	local orbit = Kit.Model(m, "CoreOrbit")
	orbit:SetAttribute("AmbientMotion", "Core")
	orbit:SetAttribute("MotionCenter", center + V(0, 68, 0))
	local cf = CF(center + V(0, 68, 0))
	Kit.Ball(orbit, "FractureHeart", V(35, 35, 35), cf, C.Violet, Neon)
	for i = 1, 8 do
		local a = i * math.pi / 4
		Kit.Part(
			orbit,
			"CoreShard",
			V(24, 31, 23),
			cf * CFrame.Angles(0.5, a, 0.25) * CF(0, 0, 20),
			C.Ink
		)
	end
	Kit.Ring(orbit, "ContainmentRing", cf * CFrame.Angles(0.25, 0.4, 0), 39, 3, C.Stone, 24)
	Kit.Ring(orbit, "FractureRing", cf * CFrame.Angles(-0.6, 0.8, 0.3), 33, 0.9, C.Violet, 22, Neon)
	for _, x in ipairs({ -43, 43 }) do
		p(m, "ContainmentPylon", V(9, 62, 9), center + V(x, 31, 0), C.Ink)
		p(m, "PylonCap", V(13, 4, 13), center + V(x, 63, 0), C.Gold)
	end
	Kit.Label(m, "NexusName", "FRACTURE NEXUS", CF(0, 20, 228), 76, 9)
	for i = 1, 12 do
		local a = i * math.pi / 6
		Kit.Part(
			m,
			"OrbitingFragment",
			V(5 + (i % 3) * 2, 7, 6),
			CF(center + V(math.cos(a) * 63, 73 + math.sin(a) * 29, math.sin(a) * 45))
				* CFrame.Angles(a, a * 0.7, a * 0.4),
			i % 4 == 0 and C.Violet or C.Stone
		)
	end
	for _, x in ipairs({ -64, 64 }) do
		p(m, "Promenade", V(32, 0.06, 206), center + V(x, 0.03, 0), C.Cream)
	end
	for _, z in ipairs({ 248, 392 }) do
		p(m, "Crossing", V(204, 0.06, 32), V(0, 0.04, z), C.Cream)
	end
	return m
end

local function kitchen(root)
	local c = V(-288, 0, 320)
	local m = island(root, "GiantsKitchen", c, 160, C.Cream, { E = true, S = true })
	Kit.Label(m, "RegionName", "GIANT'S KITCHEN", CF(c + V(0, 29, -62)), 100, 10, C.Coral)
	for _, x in ipairs({ -50, 50 }) do
		p(m, "KitchenBackdrop", V(47, 62, 4), c + V(x, 31, 76), C.Cream)
		p(m, "WallCupboard", V(42, 21, 10), c + V(x, 53, 69), C.White)
		p(m, "CupboardHandle", V(1.5, 10, 2), c + V(x, 53, 62.5), C.Gold)
	end
	-- Landmark wall leaves the central 40-stud cross unobstructed.
	for _, x in ipairs({ -52, 52 }) do
		p(m, "Cabinet", V(40, 32, 26), c + V(x, 16, 48), C.Cream)
		p(m, "Countertop", V(44, 4, 30), c + V(x, 34, 48), C.Wood)
		for _, offset in ipairs({ -11, 11 }) do
			p(m, "DrawerFront", V(18, 23, 1), c + V(x + offset, 15, 34.5), C.White)
			p(m, "DrawerPull", V(7, 1, 2), c + V(x + offset, 25, 33), C.Gold)
		end
	end
	Kit.Artifact(m, "GoldenFridge", CF(c + V(-48, 36, 49)), 1.8)
	local mugCF = CF(c + V(47, 49, 45))
	Kit.Disc(m, "RedMug", 28, 25, mugCF, C.Coral)
	Kit.Disc(m, "Cocoa", 24, 0.6, mugCF * CF(0, 12.8, 0), C.Wood)
	Kit.Ring(
		m,
		"MugHandle",
		mugCF * CF(19, 0, 0) * CFrame.Angles(0, math.pi / 2, 0),
		10,
		4,
		C.Coral,
		12
	)
	Kit.Disc(m, "CookingPot", 27, 22, CF(c + V(50, 13, -8)), C.Coral)
	Kit.Disc(m, "PotLid", 30, 2, CF(c + V(50, 25, -8)), C.Coral)
	Kit.Ball(m, "LidKnob", V(5, 5, 5), CF(c + V(50, 28, -8)), C.Gold)
	for _, x in ipairs({ -17, 17 }) do
		p(m, "PotHandle", V(8, 3, 6), c + V(50 + x, 19, -8), C.Ink)
	end
	p(m, "CerealBox", V(27, 48, 14), c + V(-53, 24, -46), C.Coral)
	Kit.Label(m, "CerealPrint", "ODD O'S", CF(c + V(-53, 29, -53.5)), 24, 12)
	Kit.Disc(m, "Plate", 35, 2, CF(c + V(51, 1, -45)), C.White)
	Kit.Disc(m, "Pancake", 29, 4, CF(c + V(51, 4, -45)), C.Gold)
	Kit.Disc(m, "Pancake", 27, 4, CF(c + V(51, 8, -45)), C.Gold)
	p(m, "Butter", V(9, 5, 9), c + V(51, 12, -45), C.Cream)
	local fork = CF(c + V(-70, 34, -10)) * CFrame.Angles(0, 0, -0.25)
	Kit.Part(m, "ForkHandle", V(4, 40, 3), fork, C.White)
	Kit.Part(m, "ForkHead", V(18, 7, 3), fork * CF(0, 23, 0), C.White)
	for x = -7, 7, 4.7 do
		Kit.Part(m, "ForkTine", V(2, 16, 3), fork * CF(x, 34, 0), C.White)
	end
	return m
end

local function aquarium(root)
	local c = V(288, 0, 320)
	local m = island(root, "MoonAquarium", c, 160, C.Blue, { W = true, S = true })
	Kit.Label(m, "RegionName", "MOON AQUARIUM", CF(c + V(0, 25, -60)), 104, 10)
	local domeCF = CF(c + V(0, 0, 0))
	for _, angle in ipairs({ 0, math.pi / 3, math.pi * 2 / 3 }) do
		local frame = domeCF * CFrame.Angles(0, angle, 0)
		for i = 1, 12 do
			local a, b = (i - 1) * math.pi / 12, i * math.pi / 12
			Kit.Segment(
				m,
				"BrokenDomeRib",
				frame * V(math.cos(a) * 68, math.sin(a) * 68, 0),
				frame * V(math.cos(b) * 68, math.sin(b) * 68, 0),
				3,
				C.Stone
			)
		end
	end
	for i, info in ipairs({ { -43, 24, 39, 30 }, { 46, 39, 37, 39 }, { 30, 61, -39, 24 } }) do
		local cf = CF(c + V(info[1], info[2], info[3]))
		local water = Kit.Ball(
			m,
			"FloatingWater",
			V(info[4], info[4], info[4]),
			cf,
			C.Cyan,
			Enum.Material.Glass
		)
		water.Transparency = 0.74
		Kit.Jellyfish(m, cf * CF(0, 4, 0), i == 2 and 1.3 or 0.9, i == 2 and C.Pink or C.Cyan)
	end
	-- Whale silhouette above the dry walkway; no transparent full-scene dome.
	local whale = CF(c + V(0, 88, 14))
	Kit.Ball(m, "MoonWhale", V(65, 21, 25), whale, C.Ink)
	Kit.Part(m, "WhaleTail", V(18, 3, 32), whale * CF(36, 0, 0) * CFrame.Angles(0, 0, -0.2), C.Blue)
	Kit.Part(
		m,
		"WhaleFin",
		V(18, 3, 12),
		whale * CF(-6, -8, -17) * CFrame.Angles(0, 0.4, 0.2),
		C.Blue
	)
	Kit.Ball(m, "WhaleEye", V(2, 2, 2), whale * CF(-26, 3, -11), C.Cyan, Neon)
	for _, x in ipairs({ -58, 58 }) do
		for i = 1, 3 do
			p(
				m,
				"Coral",
				V(4, 8 + i * 3, 4),
				c + V(x + (i - 2) * 5, 4 + i * 1.5, -34),
				i % 2 == 0 and C.Pink or C.Violet
			)
		end
	end
	return m
end

local function toybox(root)
	local c = V(0, 0, 608)
	local m = island(root, "ToyboxCatastrophe", c, 160, C.Gold, { N = true, E = true, W = true })
	Kit.Label(m, "RegionName", "TOYBOX CATASTROPHE", CF(c + V(0, 26, -61)), 115, 10, C.Blue)
	for i = 1, 12 do
		local x = i <= 6 and -53 or 53
		local row = (i - 1) % 6
		local h = 12 + (row % 3) * 10
		local color = ({ C.Coral, C.Blue, C.Green, C.Gold })[(i % 4) + 1]
		p(m, "ToyBrick", V(27, h, 22), c + V(x, h / 2, -48 + row * 19), color)
		for _, dx in ipairs({ -7, 7 }) do
			Kit.Disc(m, "BrickStud", 7, 2, CF(c + V(x + dx, h + 1, -48 + row * 19)), color)
		end
	end
	local bear = CF(c + V(0, 35, 53))
	Kit.Ball(m, "TeddyBody", V(29, 34, 24), bear, C.Wood)
	Kit.Ball(m, "TeddyHead", V(27, 27, 24), bear * CF(0, 26, 0), C.Wood)
	for _, x in ipairs({ -13, 13 }) do
		Kit.Ball(m, "BearEar", V(10, 10, 8), bear * CF(x, 38, 0), C.Wood)
		Kit.Ball(m, "BearFoot", V(14, 13, 20), bear * CF(x, -20, -4), C.Cream)
		Kit.Ball(m, "BearEye", V(2.7, 2.7, 1.5), bear * CF(x * 0.42, 28, -12), C.Ink)
	end
	Kit.Ball(m, "BearMuzzle", V(14, 9, 4), bear * CF(0, 20, -13), C.Cream)
	Kit.Ball(m, "BearNose", V(4, 3, 2), bear * CF(0, 23, -16), C.Ink)
	-- Elevated circular railway is scenery; the ground route stays static and clear.
	local trackCF = CF(c + V(0, 42, 0)) * CFrame.Angles(math.pi / 2, 0, 0)
	Kit.Ring(m, "ToyRail", trackCF, 69, 2, C.Coral, 32)
	Kit.Ring(m, "ToyRail", trackCF, 61, 2, C.Ink, 32)
	for i = 1, 8 do
		local a = i * math.pi / 4
		p(m, "RailSupport", V(3, 40, 3), c + V(math.cos(a) * 65, 20, math.sin(a) * 65), C.Blue)
	end
	for _, x in ipairs({ -38, 38 }) do
		p(m, "ToyCastleTower", V(18, 62, 18), c + V(x, 31, 66), C.Blue)
		p(m, "TowerBattlement", V(23, 5, 23), c + V(x, 64, 66), C.Coral)
		for _, dx in ipairs({ -8, 8 }) do
			p(m, "CastleMerlon", V(5, 7, 23), c + V(x + dx, 70, 66), C.Gold)
		end
	end
	local train = Kit.Model(m, "ToyTrain")
	local tf = CF(c + V(-48, 48, -43)) * CFrame.Angles(0, -math.pi / 4, 0)
	Kit.Part(train, "Chassis", V(14, 5, 24), tf, C.Coral)
	Kit.Part(train, "Engine", V(12, 10, 13), tf * CF(0, 6, -4), C.Coral)
	Kit.Part(train, "Cab", V(14, 15, 9), tf * CF(0, 9, 9), C.Blue)
	Kit.Part(train, "Chimney", V(5, 9, 5), tf * CF(0, 15, -7), C.Gold)
	for _, x in ipairs({ -8, 8 }) do
		for _, z in ipairs({ -8, 8 }) do
			Kit.Ball(train, "Wheel", V(3, 8, 8), tf * CF(x, -2, z), C.Ink)
		end
	end
	return m
end

local function city(root)
	local c = V(-288, 0, 608)
	local m = island(root, "UpsideDownCity", c, 160, C.Stone, { N = true, E = true, S = true })
	Kit.Label(m, "RegionName", "UPSIDE-DOWN CITY", CF(c + V(0, 23, -60)), 110, 10)
	for i, at in ipairs({ V(-52, 0, -40), V(50, 0, -30), V(-48, 0, 46), V(48, 0, 47) }) do
		local h = 47 + i * 9
		p(m, "CityBuilding", V(29, h, 28), c + at + V(0, h / 2, 0), C.Ink)
		for row = 1, 4 do
			for _, dx in ipairs({ -7, 7 }) do
				p(m, "WarmWindow", V(5, 5, 0.3), c + at + V(dx, row * 11, -14.2), C.Gold, false)
			end
		end
	end
	local ceiling = c + V(0, 153, 0)
	p(m, "InvertedCityIsland", V(142, 8, 112), ceiling, C.Ink)
	for i = 1, 4 do
		Kit.Part(
			m,
			"CeilingFracture",
			V(38, 13, 35),
			CF(ceiling + V(-62 + i * 26, 8, 0)) * CFrame.Angles(0, i * 0.4, 0.3),
			C.Stone
		)
	end
	for i = 1, 5 do
		local x = -62 + (i - 1) * 31
		local h = 25 + (i % 3) * 16
		p(m, "HangingSkyscraper", V(23, h, 24), ceiling + V(x, -h / 2 - 4, 28), C.Stone)
		for row = 1, 3 do
			p(m, "InvertedWindow", V(13, 4, 0.3), ceiling + V(x, -row * 10 - 6, 15.8), C.Gold)
		end
	end
	Kit.Label(m, "StreetSign", "GRAVITY IS AN OPTION", CF(c + V(0, 12, 63)), 74, 7)
	return m
end

local function deep(root)
	local c = V(288, 0, 608)
	local m = island(root, "DeepFracture", c, 160, C.Ink, { N = true, W = true, S = true })
	Kit.Label(m, "RegionName", "DEEP FRACTURE", CF(c + V(0, 25, -61)), 98, 10, C.Violet)
	for _, x in ipairs({ -59, 59 }) do
		for i = 1, 4 do
			local h = 27 + (i % 3) * 12
			local cf = CF(c + V(x, h / 2, -55 + i * 26))
				* CFrame.Angles(0.1, i * 0.6, x < 0 and 0.18 or -0.18)
			Kit.Part(m, "FractureObelisk", V(16, h, 18), cf, C.Stone)
			Kit.Part(
				m,
				"ObeliskSeam",
				V(0.7, h * 0.8, 0.6),
				cf * CF(0, 0, -9.2),
				C.Violet,
				false,
				Neon
			)
		end
	end
	Kit.Artifact(m, "SmallSun", CF(c + V(49, 0, 48)), 1.25)
	portal(m, CF(c + V(0, 49, 59)), 25, C.Violet)
	return m
end

local function transition(root)
	local c = V(160, 0, 320)
	local m = Kit.Model(root, "KitchenAquariumTransition")
	m:SetAttribute("IllustratedRegion", "KitchenAquariumTransition")
	-- The bridge below remains the collision authority. Set dressing stays to either side.
	for _, side in ipairs({ -1, 1 }) do
		p(
			m,
			"SeamBalcony",
			V(72, 3, 30),
			c + V(0, -1.5, side * 38),
			side < 0 and C.Cream or C.Blue,
			true
		)
	end
	Kit.Artifact(m, "GoldenFridge", CF(c + V(-10, 0, 40)), 1.6)
	local water = Kit.Ball(
		m,
		"WaterCrossing",
		V(40, 40, 40),
		CF(c + V(9, 44, 39)),
		C.Cyan,
		Enum.Material.Glass
	)
	water.Transparency = 0.72
	Kit.Jellyfish(m, CF(c + V(9, 48, 39)), 1, C.Pink)
	p(m, "ColdSeam", V(1, 0.1, 40), c + V(0, 0.08, 0), C.Cyan, false, Neon)
	Kit.Label(m, "CrossoverName", "KITCHEN × AQUARIUM", CF(c + V(0, 26, -41)), 83, 7)
	return m
end

local function rare(root)
	local c = V(-288, 0, 848)
	local m = island(root, "RoomBetweenDimensions", c, 128, C.Cream, { N = true })
	Kit.Label(m, "RegionName", "THE ROOM BETWEEN", CF(c + V(0, 24, -44)), 93, 9)
	Kit.Artifact(m, "RunawayDoor", CF(c + V(-39, 0, 26)), 1.3)
	for _, x in ipairs({ -41, 41 }) do
		p(m, "FloatingViewFrame", V(26, 33, 3), c + V(x, 32, 56), C.Ink)
		p(m, "QuietVoidWindow", V(22, 28, 0.4), c + V(x, 32, 54.3), C.Violet)
	end
	Kit.Artifact(m, "GravityHeart", CF(c + V(39, 0, 23)), 1)
	return m
end

local function escape(root, builder)
	local c = V(288, 0, 848)
	local m = island(root, "ExtractionDeck", c, 128, C.Cream, { N = true })
	builder.Portal(m, c + V(0, 0, 43), "IllustratedExtractionSurface")
	Kit.Label(m, "RegionName", "EXTRACTION", CF(c + V(0, 41, 43)), 68, 9)
	Kit.Artifact(m, "GoldenFridge", CF(c + V(-37, 0, 11)), 1)
	for i = 1, 5 do
		Kit.Part(
			m,
			"BrokenSideDeck",
			V(14, 3, 18),
			CF(c + V(84 + i * 9, -i * 6, -64 + i * 24)) * CFrame.Angles(i * 0.2, 0.3, i * 0.3),
			C.Stone
		)
	end
	return m
end

function Nexus.HubArt(hub: Model)
	local gallery = Kit.Model(hub, "ArtifactGallery")
	-- Level floor and wide open frontage instead of the reference's stair-only entrance.
	for _, x in ipairs({ 39, 105 }) do
		p(gallery, "GalleryPillar", V(4, 30, 4), V(x, 15, 38), C.Cream, true)
	end
	p(gallery, "GalleryBack", V(74, 30, 3), V(72, 15, 109), C.Cream, true)
	p(gallery, "GalleryRoof", V(76, 3, 77), V(72, 32, 73), C.Ink)
	Kit.Label(gallery, "MuseumLabel", "ODDVAULT MUSEUM", CF(72, 29, 35), 68, 6)
	local names = {
		"GoldenFridge",
		"Moonjar",
		"SmallSun",
		"RunawayDoor",
		"ImpossibleCrown",
		"LivingLavaLamp",
		"GravityHeart",
	}
	for i, name in ipairs(names) do
		local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
		local at = V(50 + col * 22, 0, 52 + row * 21)
		p(gallery, "DisplayPedestal", V(16, 2, 14), at + V(0, 1, 0), C.Ink, true)
		Kit.Artifact(gallery, name, CF(at + V(0, 2, 0)), 0.48)
		Kit.Label(
			gallery,
			"ArtifactCaption",
			name:gsub("(%u)", " %1"):gsub("^ ", ""),
			CF(at + V(0, 1.6, -7.5)),
			15,
			2
		)
	end
	local atlas = Kit.Model(hub, "DimensionalAtlas")
	Kit.Disc(atlas, "AtlasTable", 36, 5, CF(-71, 2.5, 62), C.Ink, true)
	Kit.Disc(atlas, "AtlasTrim", 37, 0.5, CF(-71, 5.3, 62), C.Gold)
	Kit.Ball(atlas, "AtlasCore", V(9, 9, 9), CF(-71, 16, 62), C.Violet, Neon)
	Kit.Ring(
		atlas,
		"AtlasOrbit",
		CF(-71, 16, 62) * CFrame.Angles(math.pi / 2, 0, 0),
		13,
		0.3,
		C.Cyan,
		16,
		Neon
	)
	for i, color in ipairs({ C.Gold, C.Cyan, C.Coral }) do
		local a = i * math.pi * 2 / 3
		p(
			atlas,
			"DimensionNode",
			V(5, 5, 5),
			V(-71 + math.cos(a) * 13, 16, 62 + math.sin(a) * 13),
			color
		)
	end
	Kit.Label(atlas, "AtlasLabel", "DIMENSIONAL ATLAS", CF(-71, 29, 81), 66, 8)
	for _, x in ipairs({ -100, 100 }) do
		tree(hub, V(x, 0, -57), 0.9)
	end
	-- Monumental circular portal surrounds the existing functional prompt/surface.
	Kit.Ring(hub, "HubPortalArch", CF(0, 19, -7), 23, 5, C.Stone, 20)
	Kit.Ring(hub, "HubPortalRim", CF(0, 19, -9.5), 20.5, 0.8, C.Cyan, 20, Neon)
	Kit.Label(
		hub,
		"MapDirections",
		"NEXUS EXPLORATION →",
		CF(-43, 10, 10) * CFrame.Angles(0, 0.4, 0),
		43,
		7
	)
end

function Nexus.Build(world: Model, builder: any): Folder
	local root = Instance.new("Folder")
	root.Name, root.Parent = "DimensionMap", world
	root:SetAttribute("VisualVersion", 1)
	root:SetAttribute("IllustrationOnlyRules", true)
	bridge(root, "HubToNexus", V(0, 0, 112), V(0, 0, 208), C.Cream, 48)
	core(root)
	kitchen(root)
	aquarium(root)
	toybox(root)
	city(root)
	deep(root)
	bridge(root, "KitchenBridge", V(-112, 0, 320), V(-208, 0, 320), C.Cream)
	bridge(root, "AquariumBridge", V(112, 0, 320), V(208, 0, 320), C.Blue)
	bridge(root, "ToyboxBridge", V(0, 0, 432), V(0, 0, 528), C.Cream)
	bridge(root, "KitchenToCity", V(-288, 0, 400), V(-288, 0, 528), C.Cream)
	bridge(root, "AquariumToDeep", V(288, 0, 400), V(288, 0, 528), C.Blue)
	bridge(root, "CityToToybox", V(-208, 0, 608), V(-80, 0, 608), C.Stone)
	bridge(root, "ToyboxToDeep", V(80, 0, 608), V(208, 0, 608), C.Cream)
	transition(root)
	rare(root)
	escape(root, builder)
	bridge(root, "RareRoomBridge", V(-288, 0, 688), V(-288, 0, 784), C.Cream)
	bridge(root, "ExtractionBridge", V(288, 0, 688), V(288, 0, 784), C.Cream)
	local points = Instance.new("Folder")
	points.Name, points.Parent = "TourPoints", root
	for name, at in pairs({
		NexusArrival = V(0, 4, 225),
		CoreWest = V(-64, 4, 320),
		Kitchen = V(-288, 4, 320),
		Aquarium = V(288, 4, 320),
		Toybox = V(0, 4, 608),
		City = V(-288, 4, 608),
		Deep = V(288, 4, 608),
		RareRoom = V(-288, 4, 848),
		Extraction = V(288, 4, 862),
	}) do
		local marker = p(points, name, V(1, 1, 1), at, C.Cyan)
		marker.Transparency = 1
	end
	return root
end

return Nexus
