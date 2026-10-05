local fs = require("@lune/fs")
local rbx = require("@lune/roblox")
local place = rbx.deserializePlace(fs.readFile("assets/OddvaultDimensionMap.rbxl"))
local world = place.Workspace.OddvaultWorld
local regions = 0
for _, m in world.DimensionMap:GetChildren() do
	if m:GetAttribute("IllustratedRegion") then
		regions += 1
	end
end
assert(regions == 9, "Missing regions in place snapshot")
local sourceCount = 0
for _, m in place.ServerScriptService.OddvaultServer:GetChildren() do
	if m.ClassName == "ModuleScript" or m.ClassName == "Script" then
		local suffix = m.Name == "Bootstrap" and ".server.lua" or ".lua"
		assert(
			m.Source == fs.readFile("src/world/server/" .. m.Name .. suffix),
			"Server source parity failed: " .. m.Name
		)
		sourceCount += 1
	end
end
for _, m in place.ReplicatedStorage.OddvaultShared:GetChildren() do
	assert(
		m.Source == fs.readFile("src/world/shared/" .. m.Name .. ".lua"),
		"Shared parity failed: " .. m.Name
	)
	sourceCount += 1
end
assert(
	place.StarterPlayer.StarterPlayerScripts.OddvaultClient.Source
		== fs.readFile("src/world/client/WorldClient.client.lua"),
	"Client parity failed"
)
sourceCount += 1
print(
	"Place snapshot verified: "
		.. regions
		.. " regions and "
		.. sourceCount
		.. " exact source scripts."
)
