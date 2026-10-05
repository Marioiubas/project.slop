--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("OddvaultShared"):WaitForChild("Remotes")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "OddvaultWorldUI", false, 20
gui.Parent = player:WaitForChild("PlayerGui")
local hint = Instance.new("TextLabel")
hint.Size, hint.AnchorPoint, hint.Position =
	UDim2.new(0.9, 0, 0, 64), Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -24)
hint.BackgroundColor3, hint.BackgroundTransparency = Color3.fromRGB(36, 48, 69), 0.12
hint.TextColor3, hint.Font, hint.TextSize = Color3.fromRGB(244, 246, 244), Enum.Font.GothamBold, 18
hint.TextWrapped, hint.Text, hint.Parent = true, "Walk to the cyan portal. Find the way home.", gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize, limit.Parent = Vector2.new(600, 100), hint
local corner = Instance.new("UICorner")
corner.CornerRadius, corner.Parent = UDim.new(0, 12), hint
local padding = Instance.new("UIPadding")
padding.PaddingLeft, padding.PaddingRight, padding.Parent = UDim.new(0, 12), UDim.new(0, 12), hint
local fade = Instance.new("Frame")
fade.Size, fade.BackgroundColor3, fade.BackgroundTransparency =
	UDim2.fromScale(1, 1), Color3.fromRGB(48, 225, 245), 1
fade.ZIndex, fade.Parent = 10, gui
local token, noticeSerial = nil, 0
local function notice(message)
	noticeSerial += 1
	local serial = noticeSerial
	hint.Visible, hint.Text = true, message
	task.delay(7, function()
		if noticeSerial == serial and not token then
			hint.Visible = false
		end
	end)
end
local function targetReady(request)
	local world = workspace:FindFirstChild("OddvaultWorld")
	if not world then
		return false
	end
	if not request.Entering then
		local hub = world:FindFirstChild("Hub")
		return hub ~= nil
			and hub:FindFirstChild("Plaza") ~= nil
			and hub:FindFirstChild("HomeArrival") ~= nil
	end
	local runtime = world:FindFirstChild("RiftRuntime")
	local rift = runtime and runtime:FindFirstChild("Rift_" .. request.RiftId)
	local geometry = rift and rift:FindFirstChild("Geometry")
	local room = geometry and geometry:FindFirstChild(request.RoomName)
	return room ~= nil
		and room:GetAttribute("RiftId") == request.RiftId
		and room:FindFirstChild("Collision") ~= nil
		and room.Collision:FindFirstChild("Floor") ~= nil
		and room:FindFirstChild("SpawnPoints") ~= nil
		and room.SpawnPoints:FindFirstChildWhichIsA("BasePart") ~= nil
end
remotes.Transition.OnClientEvent:Connect(function(request)
	token = request.Token
	notice("Stepping through the Rift...")
	TweenService:Create(fade, TweenInfo.new(0.2), { BackgroundTransparency = 0.15 }):Play()
	local deadline = os.clock() + 8
	local ok = pcall(function()
		if workspace.StreamingEnabled then
			player:RequestStreamAroundAsync(request.Position, 5)
		end
	end)
	while ok and token == request.Token and os.clock() < deadline and not targetReady(request) do
		task.wait(0.1)
	end
	if token == request.Token then
		remotes.StreamReady:FireServer(request.Token, ok and targetReady(request) == true)
	end
end)
remotes.TransitionDone.OnClientEvent:Connect(function(doneToken, _, message)
	if doneToken ~= token then
		return
	end
	token = nil
	TweenService:Create(fade, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
	notice(message)
end)
remotes.Notice.OnClientEvent:Connect(notice)
player.CharacterAdded:Connect(function()
	token = nil
	fade.BackgroundTransparency = 1
end)
task.delay(9, function()
	if not token and noticeSerial == 0 then
		hint.Visible = false
	end
end)
