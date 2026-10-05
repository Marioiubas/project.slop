--!strict
local RunService = game:GetService("RunService")
local Builder = require(script.Parent.WorldBuilder)
local Generator = require(script.Parent.RiftGenerator)
local Debug = {}

function Debug.Visualize(generated: Generator.Generated, enabled: boolean)
	assert(RunService:IsStudio(), "Debug tools are Studio-only")
	local existing = generated.Model:FindFirstChild("Debug")
	if existing then
		existing:Destroy()
	end
	if not enabled then
		return
	end
	local folder = Builder.Folder(generated.Model, "Debug")
	for _, room in pairs(generated.Rooms) do
		local pivot = room:GetPivot()
		local bounds = Builder.Part(
			folder,
			"RoomBounds",
			Vector3.new(96, 0.15, 96),
			pivot * CFrame.new(0, 0.2, 0),
			room:GetAttribute("Optional") and Builder.Colors.Gold or Builder.Colors.Cyan,
			false
		)
		bounds.Transparency = 0.92
		local gui = Instance.new("BillboardGui")
		gui.Size, gui.StudsOffset, gui.MaxDistance =
			UDim2.fromOffset(260, 64), Vector3.new(0, 8, 0), 140
		gui.Adornee, gui.AlwaysOnTop, gui.Parent = bounds, true, folder
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 0.25
		label.BackgroundColor3, label.TextColor3, label.Font =
			Builder.Colors.Ink, Builder.Colors.White, Enum.Font.Gotham
		label.TextSize, label.TextWrapped, label.Parent = 13, true, gui
		label.Text = string.format(
			"ROOM %d / %s\nSEED %d / %s",
			room:GetAttribute("NodeId"),
			room:GetAttribute("RoomId"),
			generated.Graph.Seed,
			generated.Model:GetAttribute("RiftId")
		)
		for _, socket in ipairs(room.Sockets:GetChildren()) do
			local marker = Builder.Part(
				folder,
				"SocketMarker",
				Vector3.new(2, 2, 2),
				socket.CFrame,
				socket:GetAttribute("Connected") and Builder.Colors.Cyan or Builder.Colors.Coral,
				false
			)
			marker.Transparency = 0.3
		end
	end
	for _, edge in ipairs(generated.Graph.Edges) do
		local a, b =
			generated.Rooms[edge.A]:GetPivot().Position, generated.Rooms[edge.B]:GetPivot().Position
		local line = Builder.Part(
			folder,
			"SocketLink",
			Vector3.new(0.5, 0.2, (a - b).Magnitude),
			CFrame.lookAt((a + b) / 2 + Vector3.new(0, 0.4, 0), b + Vector3.new(0, 0.4, 0)),
			Builder.Colors.Gold,
			false
		)
		line.Transparency = 0.2
	end
	for _, object in ipairs(folder:GetDescendants()) do
		object:SetAttribute("RiftId", generated.Model:GetAttribute("RiftId"))
	end
end

function Debug.Attach(service: any): BindableFunction?
	if not RunService:IsStudio() then
		return nil
	end
	local actions = Instance.new("BindableFunction")
	actions.Name, actions.Parent = "DebugActions", service.World
	actions.OnInvoke = function(action, dimension, seed)
		if action == "generate" then
			local rift, reason = service:Create(dimension or "GiantsKitchen", seed or 12345)
			if not rift then
				return { Error = reason }
			end
			Debug.Visualize(rift.Generated, true)
			return {
				RiftId = rift.RiftId,
				Seed = rift.Generated.Graph.Seed,
				CellId = rift.Lease.CellId,
				Statistics = Generator.Statistics(rift.Generated.Model),
			}
		elseif action == "cleanup" then
			local closing = {}
			for _, rift in pairs(service.Rifts) do
				table.insert(closing, rift)
			end
			for _, rift in ipairs(closing) do
				service:Close(rift, "Debug cleanup")
			end
			return { CellsInUse = service.Allocator:Count() }
		elseif action == "stats" then
			local result = { CellsInUse = service.Allocator:Count(), Rifts = {} }
			for _, rift in pairs(service.Rifts) do
				table.insert(result.Rifts, {
					RiftId = rift.RiftId,
					CellId = rift.Lease.CellId,
					Seed = rift.Generated.Graph.Seed,
					State = rift.State,
					Statistics = Generator.Statistics(rift.Generated.Model),
				})
			end
			return result
		elseif action == "visualize" then
			for _, rift in pairs(service.Rifts) do
				Debug.Visualize(rift.Generated, dimension == true)
			end
			return true
		end
		error("Unknown action: generate, cleanup, stats, visualize")
	end
	return actions
end
return Debug
