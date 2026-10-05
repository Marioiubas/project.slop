-- Native Studio check: run in Edit or Server through execute_luau.
-- Samples an axis-aligned 24x24 cargo proxy along the authored promenade network.
-- This is clearance evidence, not a physical carrying or mobile-performance test.
local world = assert(workspace:FindFirstChild("OddvaultWorld"), "Install the map first")
local map = assert(world:FindFirstChild("DimensionMap"), "Dimension map missing")
local V = Vector3.new
local routes = {
	{ "HubToCore", { V(0, 0, 100), V(0, 0, 225), V(-64, 0, 225), V(-64, 0, 320) } },
	{ "KitchenRare", { V(-64, 0, 320), V(-288, 0, 320), V(-288, 0, 608), V(-288, 0, 848) } },
	{
		"AquariumExtraction",
		{
			V(-64, 0, 320),
			V(-64, 0, 392),
			V(64, 0, 392),
			V(64, 0, 320),
			V(288, 0, 320),
			V(288, 0, 608),
			V(288, 0, 862),
		},
	},
	{ "ToyboxLoop", { V(-64, 0, 392), V(0, 0, 392), V(0, 0, 608), V(-288, 0, 608) } },
	{ "DeepLoop", { V(0, 0, 608), V(288, 0, 608) } },
}
local ray = RaycastParams.new()
ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide =
	Enum.RaycastFilterType.Include, { world }, true
local overlap = OverlapParams.new()
overlap.FilterType, overlap.FilterDescendantsInstances, overlap.RespectCanCollide =
	Enum.RaycastFilterType.Include, { world }, true
local positions, rays, blockers, holes = 0, 0, {}, {}
for _, route in ipairs(routes) do
	local points = route[2]
	for i = 2, #points do
		local a, b = points[i - 1], points[i]
		local steps = math.ceil((b - a).Magnitude / 8)
		for step = 0, steps do
			local position = a + (b - a) * (step / steps)
			positions += 1
			for _, x in ipairs({ -12, 0, 12 }) do
				for _, z in ipairs({ -12, 0, 12 }) do
					rays += 1
					local hit = workspace:Raycast(position + V(x, 1, z), V(0, -2, 0), ray)
					if not hit or math.abs(hit.Position.Y) > 0.1 then
						table.insert(
							holes,
							{ Route = route[1], Position = tostring(position), X = x, Z = z }
						)
					end
				end
			end
			for _, part in
				ipairs(
					workspace:GetPartBoundsInBox(
						CFrame.new(position + V(0, 12.25, 0)),
						V(24, 24, 24),
						overlap
					)
				)
			do
				if part.CanCollide then
					table.insert(blockers, {
						Route = route[1],
						Position = tostring(position),
						Part = part:GetFullName(),
					})
				end
			end
		end
	end
end
local parts, physical, regions, displays = 0, 0, 0, 0
for _, instance in ipairs(map:GetDescendants()) do
	if instance:IsA("BasePart") then
		parts += 1
		if not instance.Anchored then
			physical += 1
		end
	end
end
for _, instance in ipairs(map:GetChildren()) do
	if instance:GetAttribute("IllustratedRegion") then
		regions += 1
	end
end
for _, instance in ipairs(world.Hub.ArtifactGallery:GetChildren()) do
	if instance:GetAttribute("VisualArtifact") then
		displays += 1
	end
end
return {
	Passed = #holes == 0 and #blockers == 0,
	SampledPositions = positions,
	FloorRays = rays,
	Blockers = blockers,
	FloorHoles = holes,
	MapParts = parts,
	UnanchoredParts = physical,
	Regions = regions,
	MuseumArtifacts = displays,
}
