--!nocheck
return function(t)
	local Janitor = t.load("ReplicatedStorage.Shared.Janitor")
	local Signal = t.load("ReplicatedStorage.Shared.Signal")
	local expect = t.expect

	t.describe("Janitor", function()
		t.it("cleans functions newest first", function()
			local janitor = Janitor.new()
			local order = {}
			janitor:Add(function()
				table.insert(order, "first added")
			end)
			janitor:Add(function()
				table.insert(order, "second added")
			end)
			janitor:Cleanup()
			expect(order).toEqual({ "second added", "first added" })
		end)

		t.it("returns the item from Add so it can be used inline", function()
			local janitor = Janitor.new()
			local item = { Destroy = function() end }
			expect(janitor:Add(item)).toBe(item)
		end)

		t.it("calls Destroy on tables that have one", function()
			local janitor = Janitor.new()
			local destroyed = false
			janitor:Add({
				Destroy = function()
					destroyed = true
				end,
			})
			janitor:Cleanup()
			expect(destroyed).toBe(true)
		end)

		t.it("disconnects Signal connections", function()
			local janitor = Janitor.new()
			local signal = Signal.new()
			local calls = 0
			janitor:Add(signal:Connect(function()
				calls += 1
			end))
			signal:Fire()
			janitor:Cleanup()
			signal:Fire()
			expect(calls).toBe(1)
		end)

		t.it("uses an explicit method name when given", function()
			local janitor = Janitor.new()
			local stopped = false
			janitor:Add({
				Stop = function()
					stopped = true
				end,
			}, "Stop")
			janitor:Cleanup()
			expect(stopped).toBe(true)
		end)

		t.it("cancels threads", function()
			local janitor = Janitor.new()
			local thread = t.spawn(function()
				t.wait(30)
			end)
			expect(coroutine.status(thread)).toBe("suspended")
			janitor:Add(thread)
			janitor:Cleanup()
			expect(coroutine.status(thread)).toBe("dead")
		end)

		t.it("cleans each item once and stays usable after Cleanup", function()
			local janitor = Janitor.new()
			local calls = 0
			janitor:Add(function()
				calls += 1
			end)
			janitor:Cleanup()
			janitor:Cleanup()
			expect(calls).toBe(1)
			janitor:Add(function()
				calls += 1
			end)
			janitor:Cleanup()
			expect(calls).toBe(2)
		end)

		t.it("Remove cleans one item and stops tracking it", function()
			local janitor = Janitor.new()
			local calls = 0
			local item = function()
				calls += 1
			end
			janitor:Add(item)
			expect(janitor:Remove(item)).toBe(true)
			expect(calls).toBe(1)
			expect(janitor:Remove(item)).toBe(false)
			janitor:Cleanup()
			expect(calls).toBe(1)
		end)

		t.it("Destroy cleans up, and anything added afterwards is cleaned immediately", function()
			local janitor = Janitor.new()
			local calls = 0
			janitor:Add(function()
				calls += 1
			end)
			janitor:Destroy()
			expect(calls).toBe(1)
			expect(janitor:IsDestroyed()).toBe(true)
			janitor:Add(function()
				calls += 1
			end)
			expect(calls).toBe(2)
		end)

		t.it("one failing cleanup does not stop the rest and is reported once", function()
			local janitor = Janitor.new()
			local cleaned = {}
			janitor:Add(function()
				table.insert(cleaned, "oldest")
			end)
			janitor:Add(function()
				error("cleanup exploded")
			end)
			janitor:Add(function()
				table.insert(cleaned, "newest")
			end)
			local warnings = t.captureWarnings(function()
				janitor:Cleanup()
			end)
			expect(cleaned).toEqual({ "newest", "oldest" })
			expect(warnings).toHaveLength(1)
			expect(warnings[1]).toContain("cleanup exploded")
		end)

		t.it("reports items it does not know how to clean", function()
			local janitor = Janitor.new()
			janitor:Add({ nothing = "useful" })
			local warnings = t.captureWarnings(function()
				janitor:Cleanup()
			end)
			expect(warnings).toHaveLength(1)
			expect(warnings[1]).toContain("don't know how to clean up")
		end)

		t.it("rejects nil at the call site", function()
			local janitor = Janitor.new()
			expect(function()
				janitor:Add(nil)
			end).toThrow("called with nil")
		end)

		t.it("an item that Adds during cleanup is kept for the next cleanup", function()
			local janitor = Janitor.new()
			local lateCalls = 0
			janitor:Add(function()
				janitor:Add(function()
					lateCalls += 1
				end)
			end)
			janitor:Cleanup()
			expect(lateCalls).toBe(0)
			janitor:Cleanup()
			expect(lateCalls).toBe(1)
		end)
	end)
end
