--!nocheck
return function(t)
	local Lifecycle = t.load("ReplicatedStorage.Shared.Lifecycle")
	local Log = t.load("ReplicatedStorage.Shared.Log")
	local expect = t.expect

	local events
	local logged

	-- A unit that records every hook call in `events`.
	local function unit(name, dependencies)
		return {
			Name = name,
			Dependencies = dependencies,
			init = function(_self, _registry)
				table.insert(events, "init:" .. name)
			end,
			start = function(_self)
				table.insert(events, "start:" .. name)
			end,
		}
	end

	t.beforeEach(function()
		events = {}
		logged = {}
		Log.setSink(function(level, tag, message)
			table.insert(logged, { level = level, tag = tag, message = message })
		end)
	end)

	t.afterEach(function()
		Log.setSink(nil)
	end)

	t.describe("Lifecycle ordering", function()
		t.it("keeps registration order when there are no dependencies", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A"))
			lifecycle:register(unit("B"))
			lifecycle:register(unit("C"))
			expect(lifecycle:resolveOrder()).toEqual({ "A", "B", "C" })
		end)

		t.it("puts dependencies first regardless of registration order", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A", { "B" }))
			lifecycle:register(unit("B"))
			expect(lifecycle:resolveOrder()).toEqual({ "B", "A" })
		end)

		t.it("falls back to registration order among units that are ready", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("C"))
			lifecycle:register(unit("A", { "B" }))
			lifecycle:register(unit("B"))
			expect(lifecycle:resolveOrder()).toEqual({ "C", "B", "A" })
		end)

		t.it("handles chains and diamonds", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("D", { "B", "C" }))
			lifecycle:register(unit("B", { "A" }))
			lifecycle:register(unit("C", { "A" }))
			lifecycle:register(unit("A"))
			local order = lifecycle:resolveOrder()
			expect(order[1]).toBe("A")
			expect(order[4]).toBe("D")
		end)

		t.it("rejects a dependency on an unregistered unit, naming both", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A", { "Ghost" }))
			expect(function()
				lifecycle:resolveOrder()
			end).toThrow("'A' depends on 'Ghost'")
		end)

		t.it("rejects dependency cycles, naming the units involved", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A", { "B" }))
			lifecycle:register(unit("B", { "A" }))
			lifecycle:register(unit("Free"))
			expect(function()
				lifecycle:resolveOrder()
			end).toThrow("dependency cycle among: A, B")
		end)
	end)

	t.describe("Lifecycle registration", function()
		t.it("rejects duplicate names", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A"))
			expect(function()
				lifecycle:register(unit("A"))
			end).toThrow("duplicate unit name 'A'")
		end)

		t.it("rejects units without a usable Name", function()
			local lifecycle = Lifecycle.new("Test")
			expect(function()
				lifecycle:register({})
			end).toThrow("non-empty string Name")
			expect(function()
				lifecycle:register({ Name = "" })
			end).toThrow("non-empty string Name")
		end)

		t.it("rejects registering after run", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:run()
			expect(function()
				lifecycle:register(unit("Late"))
			end).toThrow("after run()")
		end)

		t.it("rejects running twice", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:run()
			expect(function()
				lifecycle:run()
			end).toThrow("run() called twice")
		end)
	end)

	t.describe("Lifecycle run", function()
		t.it("initialises every unit before starting any, in dependency order", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A", { "B" }))
			lifecycle:register(unit("B"))
			lifecycle:run()
			expect(events).toEqual({ "init:B", "init:A", "start:B", "start:A" })
		end)

		t.it("units without hooks are fine", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register({ Name = "Bare" })
			expect(function()
				lifecycle:run()
			end).never.toThrow()
		end)

		t.it("hands each unit a registry that can look up other units", function()
			local lifecycle = Lifecycle.new("Test")
			local found
			lifecycle:register({ Name = "B", Marker = "from B" })
			lifecycle:register({
				Name = "A",
				Dependencies = { "B" },
				init = function(_self, registry)
					found = registry:get("B").Marker
				end,
			})
			lifecycle:run()
			expect(found).toBe("from B")
		end)

		t.it("registry:get errors for an unknown unit", function()
			local lifecycle = Lifecycle.new("Test")
			local caught
			lifecycle:register({
				Name = "A",
				init = function(_self, registry)
					local ok, err = pcall(registry.get, registry, "Nope")
					caught = if ok then nil else err
				end,
			})
			lifecycle:run()
			expect(caught).toContain("no unit named 'Nope'")
		end)

		t.it("a failing init aborts boot, names the unit, and starts nothing", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A"))
			lifecycle:register({
				Name = "Bad",
				init = function()
					error("kaboom")
				end,
			})
			lifecycle:register(unit("C"))
			expect(function()
				lifecycle:run()
			end).toThrow("init of 'Bad' failed")
			expect(events).toEqual({ "init:A" }) -- C never initialised, no start ran
		end)

		t.it("the failure message keeps the original error", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register({
				Name = "Bad",
				init = function()
					error("kaboom")
				end,
			})
			expect(function()
				lifecycle:run()
			end).toThrow("kaboom")
		end)

		t.it("a failing start is logged and the other units still start", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register({
				Name = "Bad",
				start = function()
					error("start kaboom")
				end,
			})
			lifecycle:register(unit("Good"))
			lifecycle:run()
			expect(events).toEqual({ "init:Good", "start:Good" })
			local errors = {}
			for _, entry in logged do
				if entry.level == "Error" then
					table.insert(errors, entry.message)
				end
			end
			expect(errors).toHaveLength(1)
			expect(errors[1]).toContain("start of 'Bad' failed")
			expect(errors[1]).toContain("start kaboom")
		end)

		t.it(
			"starts run in their own threads, so one that yields does not block the rest",
			function()
				local lifecycle = Lifecycle.new("Test")
				lifecycle:register({
					Name = "Slow",
					start = function()
						t.wait(0.05)
						table.insert(events, "slow done")
					end,
				})
				lifecycle:register(unit("Fast"))
				lifecycle:run()
				expect(events).toEqual({ "init:Fast", "start:Fast" })
				t.wait(0.15)
				expect(events).toEqual({ "init:Fast", "start:Fast", "slow done" })
			end
		)

		t.it("logs a one-line summary of what started", function()
			local lifecycle = Lifecycle.new("Test")
			lifecycle:register(unit("A"))
			lifecycle:run()
			expect(logged[#logged].message).toContain("started 1 unit(s): A")
		end)
	end)
end
