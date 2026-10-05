--!strict
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(script.Parent.RiftService)
local Debug = require(script.Parent.DebugService)
local Builder = require(script.Parent.WorldBuilder)
local shared = ReplicatedStorage:WaitForChild("OddvaultShared")
local templates = ServerStorage:FindFirstChild("OddvaultTemplates")
-- Rojo uses the same authored recipes; Command Bar preserves edited templates.
if not templates then
	templates = Instance.new("Folder")
	templates.Name = "OddvaultTemplates"
	templates:SetAttribute("OddvaultOwned", true)
	Builder.Templates(
		templates,
		require(shared.RoomDefinitions),
		require(shared.DimensionDefinitions).GiantsKitchen
	)
	templates.Parent = ServerStorage
end
assert(templates:GetAttribute("OddvaultOwned") == true, "Refusing foreign template root")
local world = workspace:FindFirstChild("OddvaultWorld")
if not world then
	world = Instance.new("Model")
	world.Name = "OddvaultWorld"
	world:SetAttribute("OddvaultOwned", true)
	Builder.Hub(world)
	world.Parent = workspace
end
assert(world:GetAttribute("OddvaultOwned") == true, "Refusing foreign world root")
local remotes = shared:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name, remotes.Parent = "Remotes", shared
	for _, name in ipairs({ "Transition", "TransitionDone", "StreamReady", "Notice" }) do
		local remote = Instance.new("RemoteEvent")
		remote.Name, remote.Parent = name, remotes
	end
end
for _, model in ipairs(world.RiftRuntime:GetChildren()) do
	if model:GetAttribute("Preview") == true then
		model:Destroy()
	end
end
local service = Service.new(world, templates, remotes)
service:Start()
local debugActions = Debug.Attach(service)
game:BindToClose(function()
	service:Stop()
	if debugActions then
		debugActions:Destroy()
	end
end)
print(
	"[Oddvault] Dimension map and kitchen expedition ready. Artifact displays are visual models; recovery, dimension rules and persistence are future gameplay."
)
