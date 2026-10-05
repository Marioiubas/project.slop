--!strict
--[[
	Collects things that need cleaning up and cleans them all in one call.

		local janitor = Janitor.new()
		janitor:Add(part)                       -- Instance        -> :Destroy()
		janitor:Add(event:Connect(fn))          -- connection      -> :Disconnect()
		janitor:Add(function() ... end)         -- function        -> called
		janitor:Add(task.delay(5, fn))          -- thread          -> task.cancel
		janitor:Add(someObject, "Stop")         -- any table       -> someObject:Stop()
		janitor:Cleanup()                       -- everything, newest first; janitor stays usable
		janitor:Destroy()                       -- Cleanup + later Adds are cleaned immediately

	One item failing never stops the rest; failures are reported with `warn` after
	all items have been cleaned.
]]

export type Janitor = {
	-- Returns `item` so it can be used inline: `local part = janitor:Add(Instance.new("Part"))`.
	Add: <T>(self: Janitor, item: T, method: string?) -> T,
	-- Cleans `item` now and stops tracking it. Returns false if it wasn't tracked.
	Remove: (self: Janitor, item: unknown) -> boolean,
	Cleanup: (self: Janitor) -> (),
	Destroy: (self: Janitor) -> (),
	IsDestroyed: (self: Janitor) -> boolean,
}

type Entry = {
	Item: any,
	Method: string?,
}

local AUTO_METHODS = { "Destroy", "Disconnect", "destroy", "disconnect" }

local function cleanItem(entry: Entry)
	local item = entry.Item
	local kind = typeof(item)
	local explicit = entry.Method

	-- An explicit method name wins for anything that can have methods called on it.
	if explicit ~= nil and kind ~= "function" and kind ~= "thread" then
		item[explicit](item)
	elseif kind == "function" then
		item()
	elseif kind == "thread" then
		task.cancel(item)
	elseif kind == "Instance" then
		item:Destroy()
	elseif kind == "RBXScriptConnection" then
		item:Disconnect()
	else
		for _, name in AUTO_METHODS do
			local method: any = item[name]
			if type(method) == "function" then
				(method :: (any) -> ())(item)
				return
			end
		end
		error("Janitor: don't know how to clean up a " .. kind)
	end
end

-- pcall's inferred signature drops the error value when the callee returns nothing.
local function try(callback: () -> ()): (boolean, string?)
	local ok, err = pcall(callback :: any)
	return ok, if ok then nil else tostring(err)
end

local Janitor = {}

function Janitor.new(): Janitor
	local entries: { Entry } = {}
	local destroyed = false

	local function runCleanup(list: { Entry })
		local failures: { string } = {}
		-- Newest first, so things built on top of earlier items are torn down first.
		for index = #list, 1, -1 do
			local entry = list[index]
			local ok, err = try(function()
				cleanItem(entry)
			end)
			if not ok then
				table.insert(failures, tostring(err))
			end
		end
		if #failures > 0 then
			warn(
				"Janitor: " .. #failures .. " cleanup(s) failed:\n" .. table.concat(failures, "\n")
			)
		end
	end

	local janitor = {} :: Janitor

	function janitor.Add<T>(_self: Janitor, item: T, method: string?): T
		local value: any = item -- checked via a copy so `item` keeps its declared type T
		if value == nil then
			error("Janitor:Add called with nil", 2)
		end
		local entry: Entry = { Item = item, Method = method }
		if destroyed then
			runCleanup({ entry })
		else
			table.insert(entries, entry)
		end
		return item
	end

	function janitor.Remove(_self: Janitor, item: unknown): boolean
		for index, entry in entries do
			if entry.Item == item then
				table.remove(entries, index)
				runCleanup({ entry })
				return true
			end
		end
		return false
	end

	function janitor.Cleanup(_self: Janitor)
		-- Detach first so a cleanup callback that Adds to this janitor can't loop forever.
		local pending = entries
		entries = {}
		runCleanup(pending)
	end

	function janitor.Destroy(self: Janitor)
		destroyed = true
		self:Cleanup()
	end

	function janitor.IsDestroyed(_self: Janitor): boolean
		return destroyed
	end

	return janitor
end

return Janitor
