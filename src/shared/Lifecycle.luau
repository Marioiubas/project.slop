--!strict
--[[
	Boots a set of units (server Services, client Controllers) in dependency order.

		local lifecycle = Lifecycle.new("Server")
		lifecycle:register(require(Services.NetworkService))
		lifecycle:register(require(Services.DiagnosticsService)) -- Dependencies = { "NetworkService" }
		lifecycle:run()

	A unit is a table with a unique `Name` and, all optional:
	  Dependencies: names of units that must be initialised/started before this one.
	  init(registry): wire up. Runs synchronously, in dependency order, and MUST NOT yield.
	                  Use `registry:get(name)` to reach another unit's public API.
	  start():        begin work. Runs after *every* unit has been initialised, each in its
	                  own thread (so it may yield), again in dependency order.

	A failing `init` aborts boot with an error naming the unit: better a loud failure at
	startup than a half-initialised game. A failing `start` is logged and the rest go on.
]]

local Log = require(script.Parent.Log)
local Safe = require(script.Parent.Safe)

export type Registry = {
	-- Returns `any` on purpose: annotate the result with the dependency's exported `Api` type.
	get: (self: Registry, name: string) -> any,
}

-- All `register` requires is a unique `Name`; units carry their own API alongside it.
export type Unit = { Name: string }

-- The optional hooks Lifecycle looks for on a unit (see the header comment).
type UnitImpl = {
	Name: string,
	Dependencies: { string }?,
	init: ((self: any, registry: Registry) -> ())?,
	start: ((self: any) -> ())?,
}

export type Lifecycle = {
	register: (self: Lifecycle, unit: Unit) -> (),
	-- Initialises, then starts, every registered unit. Call once.
	run: (self: Lifecycle) -> (),
	get: (self: Lifecycle, name: string) -> any,
	-- Registration order resolved against dependencies (valid after `run`, or via `resolveOrder`).
	resolveOrder: (self: Lifecycle) -> { string },
}

local Lifecycle = {}

function Lifecycle.new(label: string): Lifecycle
	local log = Log.new("Lifecycle:" .. label)
	local units: { [string]: UnitImpl } = {}
	local registrationOrder: { string } = {}
	local hasRun = false

	local lifecycle = {} :: Lifecycle
	local registry = {} :: Registry

	function registry.get(_self: Registry, name: string): any
		local unit = units[name]
		if unit == nil then
			error(string.format("[%s] no unit named '%s' is registered", label, name), 2)
		end
		return unit
	end

	function lifecycle.get(_self: Lifecycle, name: string): any
		return registry:get(name)
	end

	function lifecycle.register(_self: Lifecycle, unit: Unit)
		if hasRun then
			error(string.format("[%s] cannot register units after run()", label), 2)
		end
		if type(unit) ~= "table" or type(unit.Name) ~= "string" or unit.Name == "" then
			error(string.format("[%s] a unit needs a non-empty string Name", label), 2)
		end
		if units[unit.Name] ~= nil then
			error(string.format("[%s] duplicate unit name '%s'", label, unit.Name), 2)
		end
		units[unit.Name] = unit :: any
		table.insert(registrationOrder, unit.Name)
	end

	-- Kahn's algorithm. Among units that are ready, registration order wins, so the
	-- result is deterministic and matches what the author wrote when no deps exist.
	function lifecycle.resolveOrder(_self: Lifecycle): { string }
		local remaining: { [string]: number } = {}
		local dependents: { [string]: { string } } = {}

		for _, name in registrationOrder do
			local dependencies: { string } = units[name].Dependencies or {}
			remaining[name] = #dependencies
			for _, dependency in dependencies do
				if units[dependency] == nil then
					error(
						string.format(
							"[%s] '%s' depends on '%s', which is not registered",
							label,
							name,
							dependency
						),
						2
					)
				end
				dependents[dependency] = dependents[dependency] or {}
				table.insert(dependents[dependency], name)
			end
		end

		local order: { string } = {}
		local placed: { [string]: boolean } = {}
		while #order < #registrationOrder do
			local progressed = false
			for _, name in registrationOrder do
				if not placed[name] and remaining[name] == 0 then
					placed[name] = true
					table.insert(order, name)
					local waiting: { string } = dependents[name] or {}
					for _, dependent in waiting do
						remaining[dependent] -= 1
					end
					progressed = true
					break -- restart the scan so registration order is re-applied
				end
			end
			if not progressed then
				local stuck: { string } = {}
				for _, name in registrationOrder do
					if not placed[name] then
						table.insert(stuck, name)
					end
				end
				error(
					string.format(
						"[%s] dependency cycle among: %s",
						label,
						table.concat(stuck, ", ")
					),
					2
				)
			end
		end
		return order
	end

	function lifecycle.run(self: Lifecycle)
		if hasRun then
			error(string.format("[%s] run() called twice", label), 2)
		end
		hasRun = true

		local order = self:resolveOrder()

		for _, name in order do
			local unit = units[name]
			if unit.init then
				local ok, err = Safe.call(unit.init :: any, unit, registry)
				if not ok then
					error(
						string.format("[%s] init of '%s' failed: %s", label, name, tostring(err)),
						0
					)
				end
			end
		end

		for _, name in order do
			local unit = units[name]
			if unit.start then
				task.spawn(function()
					local ok, err = Safe.call(unit.start :: any, unit)
					if not ok then
						log:error("start of '%s' failed: %s", name, tostring(err))
					end
				end)
			end
		end

		log:info("started %d unit(s): %s", #order, table.concat(order, ", "))
	end

	return lifecycle
end

return Lifecycle
