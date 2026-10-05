--!nocheck
return function(t)
	local Log = t.load("ReplicatedStorage.Shared.Log")
	local expect = t.expect

	local lines

	t.beforeEach(function()
		lines = {}
		Log.setLevel("Info")
		Log.setSink(function(level, tag, message)
			table.insert(lines, { level, tag, message })
		end)
	end)

	t.afterEach(function()
		Log.setSink(nil)
		Log.setLevel("Info")
	end)

	t.describe("Log", function()
		t.it("delivers level, tag and message to the sink", function()
			Log.new("Net"):info("hello")
			expect(lines).toEqual({ { "Info", "Net", "hello" } })
		end)

		t.it("formats arguments", function()
			Log.new("Net"):info("%s has %d items", "bag", 3)
			expect(lines[1][3]).toBe("bag has 3 items")
		end)

		t.it(
			"leaves a message alone when there are no arguments, even with a percent sign",
			function()
				Log.new("Net"):info("100% done")
				expect(lines[1][3]).toBe("100% done")
			end
		)

		t.it("never throws on a bad format string", function()
			expect(function()
				Log.new("Net"):info("%d items", "not a number")
			end).never.toThrow()
			expect(lines[1][3]).toBe("%d items")
		end)

		t.it("hides messages below the current level", function()
			local log = Log.new("Net")
			log:debug("hidden")
			log:info("shown")
			expect(#lines).toBe(1)
			Log.setLevel("Debug")
			log:debug("now shown")
			expect(#lines).toBe(2)
			Log.setLevel("Error")
			log:warn("hidden again")
			log:error("still shown")
			expect(#lines).toBe(3)
			expect(lines[3][1]).toBe("Error")
		end)

		t.it("getLevel reports what setLevel set", function()
			Log.setLevel("Warn")
			expect(Log.getLevel()).toBe("Warn")
		end)

		t.it("rejects an unknown level", function()
			expect(function()
				Log.setLevel("Loud")
			end).toThrow("unknown level")
		end)

		t.it("the default sink sends warnings and errors through warn", function()
			Log.setSink(nil)
			local warnings = t.captureWarnings(function()
				Log.new("Net"):warn("careful")
				Log.new("Net"):error("broken")
			end)
			expect(warnings).toEqual({ "[WARN][Net] careful", "[ERROR][Net] broken" })
		end)
	end)
end
