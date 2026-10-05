-- Lightweight engine double for geometry/lifecycle regression checks.
-- This does NOT emulate Roblox physics, replication, Studio permissions or rendering.
local Mock = {}
local V = {}
V.__index = function(self, key)
	if key == "Magnitude" then
		return math.sqrt(self.X ^ 2 + self.Y ^ 2 + self.Z ^ 2)
	end
	if key == "Unit" then
		return self / self.Magnitude
	end
	return V[key]
end
local function vector(x, y, z)
	return setmetatable({ X = x, Y = y, Z = z }, V)
end
function V.__add(a, b)
	return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
function V.__sub(a, b)
	return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
function V.__mul(a, b)
	if type(a) == "number" then
		a, b = b, a
	end
	return vector(a.X * b, a.Y * b, a.Z * b)
end
function V.__div(a, b)
	return vector(a.X / b, a.Y / b, a.Z / b)
end
function V.__unm(a)
	return vector(-a.X, -a.Y, -a.Z)
end
function V:Dot(b)
	return self.X * b.X + self.Y * b.Y + self.Z * b.Z
end
function V:Cross(b)
	return vector(
		self.Y * b.Z - self.Z * b.Y,
		self.Z * b.X - self.X * b.Z,
		self.X * b.Y - self.Y * b.X
	)
end
local CF = {}
local function frame(p, r, u, back)
	return setmetatable({
		Position = p,
		RightVector = r or vector(1, 0, 0),
		UpVector = u or vector(0, 1, 0),
		Back = back or vector(0, 0, 1),
	}, CF)
end
CF.__index = function(self, key)
	if key == "LookVector" then
		return -self.Back
	end
	return CF[key]
end
local function transform(cf, v)
	return cf.RightVector * v.X + cf.UpVector * v.Y + cf.Back * v.Z
end
function CF.__mul(a, b)
	if getmetatable(b) == V then
		return a.Position + transform(a, b)
	end
	return frame(
		a.Position + transform(a, b.Position),
		transform(a, b.RightVector),
		transform(a, b.UpVector),
		transform(a, b.Back)
	)
end
function CF:Inverse()
	local r, u, b = self.RightVector, self.UpVector, self.Back
	local inverse =
		frame(vector(0, 0, 0), vector(r.X, u.X, b.X), vector(r.Y, u.Y, b.Y), vector(r.Z, u.Z, b.Z))
	inverse.Position = transform(inverse, -self.Position)
	return inverse
end
function CF:ToObjectSpace(b)
	return self:Inverse() * b
end
function CF:PointToObjectSpace(b)
	return self:Inverse() * b
end
local CFrame = {}
function CFrame.new(x, y, z)
	return frame(type(x) == "table" and x or vector(x or 0, y or 0, z or 0))
end
function CFrame.Angles(x, y, z)
	local sx, cx, sy, cy, sz, cz =
		math.sin(x), math.cos(x), math.sin(y), math.cos(y), math.sin(z), math.cos(z)
	return frame(vector(0, 0, 0), vector(1, 0, 0), vector(0, cx, sx), vector(0, -sx, cx))
		* frame(vector(0, 0, 0), vector(cy, 0, -sy), vector(0, 1, 0), vector(sy, 0, cy))
		* frame(vector(0, 0, 0), vector(cz, sz, 0), vector(-sz, cz, 0), vector(0, 0, 1))
end
function CFrame.lookAt(p, target)
	local back = (p - target).Unit
	local right = vector(0, 1, 0):Cross(back).Unit
	return frame(p, right, back:Cross(right), back)
end
local function signal()
	local handlers = {}
	return {
		Connect = function(_, callback)
			local entry = { Callback = callback, Connected = true }
			table.insert(handlers, entry)
			return {
				Disconnect = function()
					entry.Connected = false
				end,
			}
		end,
		Fire = function(_, ...)
			for _, entry in ipairs(handlers) do
				if entry.Connected then
					entry.Callback(...)
				end
			end
		end,
	}
end
function Mock.new()
	local methods, meta, all = {}, {}, {}
	local inheritance = {
		Part = { "BasePart" },
		SpawnLocation = { "BasePart" },
		Script = { "BaseScript" },
		LocalScript = { "BaseScript" },
		PointLight = { "Light" },
		Workspace = { "Model" },
	}
	meta.__index = function(self, key)
		if methods[key] then
			return methods[key]
		end
		if key == "Position" and self:IsA("BasePart") then
			return self._props.CFrame.Position
		end
		if self._props[key] ~= nil then
			return self._props[key]
		end
		return self:FindFirstChild(key)
	end
	meta.__newindex = function(self, key, value)
		if key == "Parent" then
			local previous = self._props.Parent
			if previous then
				for i, child in ipairs(previous._children) do
					if child == self then
						table.remove(previous._children, i)
						break
					end
				end
			end
			if value then
				table.insert(value._children, self)
			end
		end
		self._props[key] = value
	end
	local function new(class)
		local object = setmetatable({
			_props = { ClassName = class, Name = class },
			_children = {},
			_attrs = {},
			_tags = {},
		}, meta)
		if object:IsA("BasePart") then
			object.CFrame, object.Size, object.PivotOffset =
				CFrame.new(), vector(1, 1, 1), CFrame.new()
			object.Anchored, object.CanCollide = true, false
		end
		if object:IsA("Model") then
			object.WorldPivot = CFrame.new()
		end
		if class == "ProximityPrompt" then
			object.Triggered = signal()
		end
		if class == "RemoteEvent" then
			object.OnServerEvent = signal()
			object.Messages = {}
		end
		if class == "Player" then
			object.CharacterAdded = signal()
			object.CharacterRemoving = signal()
		end
		table.insert(all, object)
		return object
	end
	function methods:IsA(class)
		if class == "Instance" or self.ClassName == class then
			return true
		end
		for _, parent in ipairs(inheritance[self.ClassName] or {}) do
			if parent == class then
				return true
			end
		end
		return false
	end
	function methods:SetAttribute(key, value)
		self._attrs[key] = value
	end
	function methods:GetAttribute(key)
		return self._attrs[key]
	end
	function methods:GetChildren()
		return table.clone(self._children)
	end
	function methods:GetDescendants()
		local descendants = {}
		local function visit(object)
			for _, child in ipairs(object._children) do
				table.insert(descendants, child)
				visit(child)
			end
		end
		visit(self)
		return descendants
	end
	function methods:FindFirstChild(name)
		for _, child in ipairs(self._children) do
			if child.Name == name then
				return child
			end
		end
	end
	function methods:WaitForChild(name)
		return assert(self:FindFirstChild(name), "Mock missing child: " .. name)
	end
	function methods:FindFirstChildOfClass(class)
		for _, child in ipairs(self._children) do
			if child.ClassName == class then
				return child
			end
		end
	end
	function methods:FindFirstChildWhichIsA(class)
		for _, child in ipairs(self._children) do
			if child:IsA(class) then
				return child
			end
		end
	end
	function methods:Destroy()
		for _, child in ipairs(self:GetChildren()) do
			child:Destroy()
		end
		self.Parent = nil
		self._props.Destroyed = true
		table.clear(self._tags)
	end
	function methods:GetPivot()
		if self.PrimaryPart then
			return self.PrimaryPart.CFrame * self.PrimaryPart.PivotOffset
		end
		return self.WorldPivot
	end
	function methods:PivotTo(cf)
		local delta = cf * self:GetPivot():Inverse()
		for _, part in ipairs(self:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CFrame = delta * part.CFrame
			end
		end
		self.WorldPivot = cf
	end
	function methods:Clone()
		local mapping = {}
		local function copy(original)
			local clone = new(original.ClassName)
			mapping[original] = clone
			for key, value in pairs(original._props) do
				if key ~= "Parent" then
					clone[key] = value
				end
			end
			clone._attrs, clone._tags = table.clone(original._attrs), table.clone(original._tags)
			for _, child in ipairs(original:GetChildren()) do
				copy(child).Parent = clone
			end
			return clone
		end
		local clone = copy(self)
		for _, object in pairs(mapping) do
			for key, value in pairs(object._props) do
				if mapping[value] then
					object[key] = mapping[value]
				end
			end
		end
		return clone
	end
	function methods:FireClient(player, ...)
		table.insert(self.Messages, { Player = player, Args = { ... } })
	end
	local services = {}
	for _, name in ipairs({
		"ReplicatedStorage",
		"ServerStorage",
		"ServerScriptService",
		"StarterPlayer",
		"ChangeHistoryService",
		"HttpService",
		"RunService",
		"CollectionService",
		"Players",
	}) do
		services[name] = new(name)
	end
	new("Folder").Parent = services.StarterPlayer
	services.StarterPlayer._children[1].Name = "StarterPlayerScripts"
	services.RunService.IsStudio = function()
		return true
	end
	services.RunService.IsRunning = function()
		return false
	end
	services.ChangeHistoryService.SetWaypoint = function() end
	local guid = 0
	services.HttpService.GenerateGUID = function()
		guid += 1
		return "mock-guid-" .. guid
	end
	services.CollectionService.AddTag = function(_, object, tag)
		object._tags[tag] = true
	end
	services.CollectionService.HasTag = function(_, object, tag)
		return object._tags[tag] == true
	end
	services.Players.GetPlayers = function()
		return services.Players:GetChildren()
	end
	services.Players.PlayerAdded, services.Players.PlayerRemoving = signal(), signal()
	local workspace = new("Workspace")
	workspace.StreamingEnabled = true
	local enum = setmetatable({}, {
		__index = function(self, key)
			local item = setmetatable({}, {
				__index = function(_, value)
					return key .. "." .. value
				end,
			})
			rawset(self, key, item)
			return item
		end,
	})
	local env = {
		game = {
			GetService = function(_, name)
				return assert(services[name], name)
			end,
			BindToClose = function() end,
		},
		workspace = workspace,
		Instance = { new = new },
		CFrame = CFrame,
		Vector3 = { new = vector, zero = vector(0, 0, 0) },
		Vector2 = {
			new = function(x, y)
				return { X = x, Y = y }
			end,
		},
		Color3 = {
			fromRGB = function(r, g, b)
				return { R = r / 255, G = g / 255, B = b / 255 }
			end,
		},
		Enum = enum,
		UDim2 = {
			fromScale = function(x, y)
				return { x, y }
			end,
			fromOffset = function(x, y)
				return { x, y }
			end,
		},
		task = {
			spawn = function(callback)
				table.insert(Mock.Scheduled, callback)
			end,
			defer = function(callback)
				table.insert(Mock.Scheduled, callback)
			end,
			wait = function()
				error("Use deterministic lifecycle test steps")
			end,
		},
		warn = function(...)
			print("EXPECTED WARNING", ...)
		end,
	}
	Mock.Scheduled = {}
	setmetatable(env, { __index = getfenv(0) })
	local cache = {}
	env.require = function(module)
		if cache[module] then
			return cache[module]
		end
		local fn = assert(loadstring(module.Source, module.Name))
		setfenv(fn, setmetatable({ script = module }, { __index = env }))
		cache[module] = fn()
		return cache[module]
	end
	env.Services, env.All = services, all
	return env
end
return Mock
