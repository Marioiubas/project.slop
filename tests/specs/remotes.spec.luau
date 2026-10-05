--!nocheck
-- Guards the remote registry: a malformed definition would otherwise only show up
-- when NetworkService boots in Studio. Every remote added later is checked here too.
return function(t)
	local Remotes = t.load("ReplicatedStorage.Shared.Remotes")
	local Validate = t.load("ReplicatedStorage.Shared.Validate")
	local expect = t.expect

	local KINDS = { Intent = true, Request = true, Notify = true }

	t.describe("Remotes registry", function()
		t.it("is frozen", function()
			expect(table.isfrozen(Remotes)).toBe(true)
		end)

		t.it("every definition is well formed", function()
			for name, definition in Remotes do
				-- Names become Instance names: keep them plain identifiers.
				expect(name).toMatch("^[%a][%w_]*$")
				expect(KINDS[definition.kind]).toBe(true)
				expect(type(definition.args)).toBe("table")
				for index, validator in definition.args do
					expect(type(index)).toBe("number")
					expect(type(validator)).toBe("function")
				end
				if definition.rate ~= nil then
					expect(definition.rate.Burst).toBeGreaterThan(0)
					expect(definition.rate.PerSecond).toBeGreaterThan(0)
				end
			end
		end)

		t.it("Ping is a Request taking exactly one non-negative number", function()
			local ping = Remotes.Ping
			expect(ping.kind).toBe("Request")
			expect(Validate.args(ping.args, 12.5)).toBe(true)
			expect(Validate.args(ping.args, -1)).toBe(false)
			expect(Validate.args(ping.args, "12")).toBe(false)
			expect(Validate.args(ping.args)).toBe(false)
			expect(Validate.args(ping.args, 1, 2)).toBe(false)
		end)
	end)
end
