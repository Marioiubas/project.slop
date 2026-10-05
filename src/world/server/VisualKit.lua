--!strict
-- Native, editable geometry. These models convey identity, not collectible state.
local Kit = {}
Kit.Colors = {
	Ink = Color3.fromRGB(29, 38, 61),
	Stone = Color3.fromRGB(69, 83, 111),
	Cream = Color3.fromRGB(244, 225, 193),
	Wood = Color3.fromRGB(174, 99, 53),
	Gold = Color3.fromRGB(255, 191, 48),
	Coral = Color3.fromRGB(232, 75, 52),
	Cyan = Color3.fromRGB(39, 219, 255),
	Blue = Color3.fromRGB(32, 119, 209),
	Violet = Color3.fromRGB(146, 64, 244),
	Pink = Color3.fromRGB(247, 83, 193),
	Green = Color3.fromRGB(66, 157, 90),
	White = Color3.fromRGB(245, 248, 255),
}
local C = Kit.Colors

function Kit.Model(parent: Instance, name: string): Model
	local model = Instance.new("Model")
	model.Name, model.Parent = name, parent
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	return model
end

function Kit.Part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	collide: boolean?,
	material: Enum.Material?
): Part
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored, p.CanCollide = true, collide == true
	p.CanTouch, p.CanQuery = false, collide == true
	p.Material, p.Color = material or Enum.Material.SmoothPlastic, color
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function Kit.Ball(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local p = Kit.Part(parent, name, size, cf, color, false, material)
	p.Shape = Enum.PartType.Ball
	return p
end

function Kit.Disc(
	parent: Instance,
	name: string,
	diameter: number,
	height: number,
	cf: CFrame,
	color: Color3,
	collide: boolean?
): Part
	local p = Kit.Part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		cf * CFrame.Angles(0, 0, math.pi / 2),
		color,
		collide
	)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Kit.Segment(
	parent: Instance,
	name: string,
	a: Vector3,
	b: Vector3,
	width: number,
	color: Color3,
	material: Enum.Material?
): Part
	return Kit.Part(
		parent,
		name,
		Vector3.new(width, width, (b - a).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color,
		false,
		material
	)
end

-- Ring lies in the local XY plane; bounded segments avoid texture or mesh dependencies.
function Kit.Ring(
	parent: Instance,
	name: string,
	cf: CFrame,
	radius: number,
	width: number,
	color: Color3,
	count: number?,
	material: Enum.Material?
)
	local segments = count or 20
	for i = 1, segments do
		local a, b = (i - 1) * math.pi * 2 / segments, i * math.pi * 2 / segments
		Kit.Segment(
			parent,
			name,
			cf * Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0),
			cf * Vector3.new(math.cos(b) * radius, math.sin(b) * radius, 0),
			width,
			color,
			material
		)
	end
end

function Kit.Label(
	parent: Instance,
	name: string,
	text: string,
	cf: CFrame,
	width: number,
	height: number?,
	color: Color3?
): Part
	local p = Kit.Part(parent, name, Vector3.new(width, height or 6, 0.6), cf, color or C.Ink)
	local gui = Instance.new("SurfaceGui")
	gui.Face, gui.SizingMode, gui.PixelsPerStud =
		Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 24
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	label.Text, label.TextColor3, label.TextScaled, label.TextWrapped = text, C.White, true, true
	label.Font, label.Parent = Enum.Font.GothamBold, gui
	return p
end

function Kit.Jellyfish(parent: Instance, cf: CFrame, scale: number, color: Color3)
	local dome = Kit.Ball(
		parent,
		"JellyfishBell",
		Vector3.new(10, 6, 10) * scale,
		cf,
		color,
		Enum.Material.Glass
	)
	dome.Transparency = 0.24
	for i = 1, 5 do
		local a = i * math.pi * 2 / 5
		local x, z = math.cos(a) * 3 * scale, math.sin(a) * 3 * scale
		Kit.Segment(
			parent,
			"Tentacle",
			cf * Vector3.new(x, -2 * scale, z),
			cf * Vector3.new(x * 0.6, -12 * scale, z * 0.6),
			0.45 * scale,
			color,
			Enum.Material.Neon
		)
	end
end

function Kit.Artifact(parent: Instance, name: string, cf: CFrame, scale: number?): Model
	local s = scale or 1
	local model = Kit.Model(parent, name)
	model:SetAttribute("VisualArtifact", name)
	model:SetAttribute("DisplayOnly", true)
	local function part(n, size, pos, color, material)
		return Kit.Part(model, n, size * s, cf * CFrame.new(pos * s), color, false, material)
	end
	local function ball(n, size, pos, color, material)
		return Kit.Ball(model, n, size * s, cf * CFrame.new(pos * s), color, material)
	end
	if name == "GoldenFridge" then
		part("Cabinet", Vector3.new(16, 20, 12), Vector3.new(0, 10, 0), C.Gold, Enum.Material.Metal)
		part("Freezer", Vector3.new(15, 7, 1), Vector3.new(0, 16, -6.6), C.Gold)
		part("Door", Vector3.new(15, 11, 1), Vector3.new(0, 6, -6.6), C.Gold)
		for _, y in ipairs({ 5, 16 }) do
			part("Handle", Vector3.new(1, 5, 1.8), Vector3.new(-5.5, y, -7.5), C.Cream)
		end
		ball(
			"ImpossibleEye",
			Vector3.new(5, 5, 1.5),
			Vector3.new(2, 16, -7.5),
			C.Cyan,
			Enum.Material.Neon
		)
		part("Pupil", Vector3.new(0.9, 3.5, 0.7), Vector3.new(2, 16, -8.3), C.Ink)
		for _, points in ipairs({ { -6, 2, -2, 7 }, { -2, 7, 3, 9 }, { 3, 9, 5, 13 } }) do
			Kit.Segment(
				model,
				"Fracture",
				cf * (Vector3.new(points[1], points[2], -7.2) * s),
				cf * (Vector3.new(points[3], points[4], -7.2) * s),
				0.25 * s,
				C.Cyan,
				Enum.Material.Neon
			)
		end
	elseif name == "Moonjar" then
		Kit.Disc(model, "Base", 16 * s, 2 * s, cf * CFrame.new(0, s, 0), C.Gold)
		local glass = ball(
			"GlassMoon",
			Vector3.new(14, 18, 14),
			Vector3.new(0, 11, 0),
			C.Cyan,
			Enum.Material.Glass
		)
		glass.Transparency = 0.65
		Kit.Jellyfish(model, cf * CFrame.new(0, 14 * s, 0), 0.65 * s, C.Pink)
		Kit.Disc(model, "Lid", 13 * s, 1.5 * s, cf * CFrame.new(0, 20 * s, 0), C.Gold)
	elseif name == "SmallSun" then
		ball("Sun", Vector3.new(10, 10, 10), Vector3.new(0, 9, 0), C.Gold, Enum.Material.Neon)
		Kit.Disc(model, "CageBase", 16 * s, 2 * s, cf * CFrame.new(0, s, 0), C.Ink)
		Kit.Disc(model, "CageCap", 16 * s, 2 * s, cf * CFrame.new(0, 18 * s, 0), C.Ink)
		for i = 1, 6 do
			local a = i * math.pi / 3
			part(
				"CageBar",
				Vector3.new(0.7, 18, 0.7),
				Vector3.new(math.cos(a) * 7, 9, math.sin(a) * 7),
				C.Ink
			)
		end
	elseif name == "RunawayDoor" then
		part("Door", Vector3.new(13, 21, 2), Vector3.new(0, 13, 0), C.Cream)
		for _, x in ipairs({ -7, 7 }) do
			part("Frame", Vector3.new(1.6, 23, 3), Vector3.new(x, 13, 0), C.Gold)
			ball("Wheel", Vector3.new(4, 4, 2), Vector3.new(x, 2, 0), C.Ink)
		end
		part("Header", Vector3.new(15, 2, 3), Vector3.new(0, 25, 0), C.Gold)
		ball("Handle", Vector3.new(1.5, 1.5, 1.5), Vector3.new(4, 13, -2), C.Gold)
		part(
			"Window",
			Vector3.new(6, 7, 0.4),
			Vector3.new(0, 19, -1.4),
			C.Cyan,
			Enum.Material.Glass
		)
	elseif name == "ImpossibleCrown" then
		Kit.Disc(model, "Band", 17 * s, 4 * s, cf * CFrame.new(0, 3 * s, 0), C.Gold)
		for i = 1, 5 do
			local a = i * math.pi * 2 / 5
			part(
				"CrownPoint",
				Vector3.new(3, 8, 3),
				Vector3.new(math.cos(a) * 7, 8, math.sin(a) * 7),
				C.Gold
			)
			ball(
				"Ruby",
				Vector3.new(2.5, 3, 2.5),
				Vector3.new(math.cos(a) * 7, 12, math.sin(a) * 7),
				C.Coral
			)
		end
	elseif name == "LivingLavaLamp" then
		Kit.Disc(model, "LampBase", 11 * s, 3 * s, cf * CFrame.new(0, 1.5 * s, 0), C.Ink)
		local glass = ball(
			"LampGlass",
			Vector3.new(9, 18, 9),
			Vector3.new(0, 12, 0),
			C.Violet,
			Enum.Material.Glass
		)
		glass.Transparency = 0.6
		for i = 1, 3 do
			ball(
				"LivingBlob",
				Vector3.new(4, 5, 4),
				Vector3.new((i % 2) * 2 - 1, 5 + i * 4, 0),
				C.Pink,
				Enum.Material.Neon
			)
		end
		Kit.Disc(model, "LampCap", 7 * s, 3 * s, cf * CFrame.new(0, 22 * s, 0), C.Ink)
	elseif name == "GravityHeart" then
		ball("HeartLeft", Vector3.new(8, 8, 6), Vector3.new(-3, 12, 0), C.Pink)
		ball("HeartRight", Vector3.new(8, 8, 6), Vector3.new(3, 12, 0), C.Pink)
		Kit.Part(
			model,
			"HeartPoint",
			Vector3.new(8, 8, 5) * s,
			cf * CFrame.new(0, 8 * s, 0) * CFrame.Angles(0, 0, math.pi / 4),
			C.Pink
		)
		Kit.Ring(
			model,
			"Orbit",
			cf * CFrame.new(0, 11 * s, 0) * CFrame.Angles(math.pi / 3, 0, 0),
			11 * s,
			0.35 * s,
			C.Violet,
			14,
			Enum.Material.Neon
		)
	else
		error("Unknown visual artifact: " .. name)
	end
	return model
end

return Kit
