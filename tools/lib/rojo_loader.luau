--!nocheck
--[[
	Runs the game's real ModuleScripts outside Roblox (under Lune), for tests and tools.

	It asks `rojo sourcemap` what the DataModel looks like, builds a tiny stand-in tree
	(Name / Parent / children by name / FindFirstChild / WaitForChild / GetService / IsA /
	GetFullName), and gives every module a `script` and a `require` that follow Roblox's
	rules, so `require(script.Parent.Signal)` in src/ works unchanged.

	Only pure-logic modules can load: anything touching `game:GetService(...)` APIs,
	Instance.new, or Roblox datatypes needs Studio. Keep logic in small pure modules.

	    local loader = Loader.new()                       -- run from the repository root
	    local Signal = loader:require("ReplicatedStorage.Shared.Signal")
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local SCRIPT_CLASSES = { ModuleScript = true, Script = true, LocalScript = true }

local NodeMeta = {}
local methods = {}

local function fullName(node)
	local parts = {}
	local current = node
	while current ~= nil and rawget(current, "Parent") ~= nil do
		table.insert(parts, 1, rawget(current, "Name"))
		current = rawget(current, "Parent")
	end
	return table.concat(parts, ".")
end

function methods.FindFirstChild(self, name)
	for _, child in rawget(self, "_children") do
		if child.Name == name then
			return child
		end
	end
	return nil
end

function methods.WaitForChild(self, name)
	local child = methods.FindFirstChild(self, name)
	if child == nil then
		-- Real WaitForChild would yield; under test nothing will ever create it.
		error(`WaitForChild({name}) would wait forever under {fullName(self)}`, 2)
	end
	return child
end

function methods.GetChildren(self)
	return table.clone(rawget(self, "_children"))
end

function methods.GetFullName(self)
	return fullName(self)
end

function methods.IsA(self, className)
	local own = rawget(self, "ClassName")
	return own == className
		or className == "Instance"
		or (SCRIPT_CLASSES[own] == true and className == "LuaSourceContainer")
end

function methods.GetService(self, name)
	local service = methods.FindFirstChild(self, name)
	if service == nil then
		error(`'{name}' is not a service in this project`, 2)
	end
	return service
end

NodeMeta.__index = function(self, key)
	if key == "Parent" then
		return nil -- the root's Parent is nil, as `game.Parent` is in Roblox
	end
	local method = methods[key]
	if method ~= nil then
		return method
	end
	local child = methods.FindFirstChild(self, key)
	if child ~= nil then
		return child
	end
	error(
		`{tostring(key)} is not a valid member of {rawget(self, "ClassName")} "{fullName(self)}"`,
		2
	)
end
NodeMeta.__tostring = function(self)
	return rawget(self, "Name")
end
NodeMeta.__newindex = function(_self, key)
	error(`cannot assign to {tostring(key)}: loader nodes are read-only`, 2)
end

local function makeNode(spec, parent)
	local filePath = nil
	for _, path in spec.filePaths or {} do
		if string.match(path, "%.luau?$") then
			filePath = path
			break
		end
	end

	local node = {
		Name = spec.name,
		ClassName = spec.className,
		Parent = parent,
		_children = {},
		_filePath = filePath,
	}
	setmetatable(node, NodeMeta)
	for _, childSpec in spec.children or {} do
		table.insert(node._children, makeNode(childSpec, node))
	end
	return node
end

local Loader = {}
Loader.__index = Loader

function Loader.new(projectFile)
	projectFile = projectFile or "default.project.json"
	if not fs.isFile(projectFile) then
		error(`{projectFile} not found: run this from the repository root`, 2)
	end

	local result = process.exec("rojo", { "sourcemap", projectFile })
	if not result.ok then
		error(
			"`rojo sourcemap` failed (is rojo installed? try `rokit install`):\n" .. result.stderr,
			2
		)
	end

	local self = setmetatable({}, Loader)
	self.root = makeNode(serde.decode("json", result.stdout), nil)
	self._cache = {}
	self._loading = {}
	self._warnHandler = nil
	self._task = self:_makeTask()

	-- The `require` every loaded module sees (closes over this loader).
	self._requireFn = function(target)
		return self:_requireNode(target)
	end
	return self
end

-- Redirect `warn` calls made by loaded modules (nil restores the real warn).
function Loader:setWarnHandler(handler)
	self._warnHandler = handler
end

function Loader:_warn(...)
	local handler = self._warnHandler
	if handler ~= nil then
		handler(...)
	else
		warn(...)
	end
end

-- Modules see a `task` whose spawn/defer/delay report an error in the spawned function
-- through `warn` instead of crashing, as Roblox prints it without throwing at the spawner.
function Loader:_makeTask()
	local function guard(callback)
		return function(...)
			local ok, err = xpcall(callback, debug.traceback, ...)
			if not ok then
				self:_warn("error in task thread: " .. tostring(err))
			end
		end
	end

	local sandboxTask = {}
	function sandboxTask.spawn(target, ...)
		if type(target) == "thread" then
			return task.spawn(target, ...)
		end
		return task.spawn(guard(target), ...)
	end
	function sandboxTask.defer(target, ...)
		if type(target) == "thread" then
			return task.defer(target, ...)
		end
		return task.defer(guard(target), ...)
	end
	function sandboxTask.delay(seconds, target, ...)
		if type(target) == "thread" then
			return task.delay(seconds, target, ...)
		end
		return task.delay(seconds, guard(target), ...)
	end
	return setmetatable(sandboxTask, { __index = task })
end

function Loader:find(path)
	local node = self.root
	for segment in string.gmatch(path, "[^%.]+") do
		node = methods.FindFirstChild(node, segment)
		if node == nil then
			error(`no instance at '{path}' (stopped at '{segment}')`, 3)
		end
	end
	return node
end

function Loader:_requireNode(node)
	if type(node) ~= "table" or getmetatable(node) ~= NodeMeta then
		error("require expects a ModuleScript instance from the loader's tree", 3)
	end
	local filePath = rawget(node, "_filePath")
	if rawget(node, "ClassName") ~= "ModuleScript" or filePath == nil then
		error(`{fullName(node)} is not a ModuleScript`, 3)
	end

	local cached = self._cache[node]
	if cached ~= nil then
		return cached.value
	end
	if self._loading[node] then
		error(`cyclic require while loading {fullName(node)}`, 3)
	end
	self._loading[node] = true

	local environment = {
		script = node,
		game = self.root,
		task = self._task,
		require = self._requireFn,
		warn = function(...)
			self:_warn(...)
		end,
	}
	local chunk = luau.load(fs.readFile(filePath), {
		debugName = filePath,
		environment = environment,
	})
	local results = table.pack(chunk())
	self._loading[node] = nil
	if results.n ~= 1 or results[1] == nil then
		error(`{fullName(node)} must return exactly one non-nil value`, 3)
	end

	self._cache[node] = { value = results[1] }
	return results[1]
end

-- Require a module by dotted DataModel path, e.g. "ReplicatedStorage.Shared.Signal".
function Loader:require(path)
	return self:_requireNode(self:find(path))
end

return Loader
