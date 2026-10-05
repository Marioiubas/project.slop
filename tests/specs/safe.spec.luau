--!nocheck
return function(t)
	local Safe = t.load("ReplicatedStorage.Shared.Safe")
	local expect = t.expect

	t.describe("Safe.call", function()
		t.it("returns true and the results when the callback succeeds", function()
			local ok, a, b = Safe.call(function(x, y)
				return x + y, "done"
			end, 2, 3)
			expect(ok).toBe(true)
			expect(a).toBe(5)
			expect(b).toBe("done")
		end)

		t.it("works for callbacks that return nothing", function()
			local results = table.pack(Safe.call(function() end))
			expect(results.n).toBe(1)
			expect(results[1]).toBe(true)
		end)

		t.it("returns false and the message, with a traceback, when the callback errors", function()
			local ok, message = Safe.call(function()
				error("boom")
			end)
			expect(ok).toBe(false)
			expect(message).toContain("boom")
			expect(message).toContain("\n") -- the traceback follows the message
		end)

		t.it("turns non-string errors into text", function()
			local ok, message = Safe.call(function()
				error({ code = 7 })
			end)
			expect(ok).toBe(false)
			expect(type(message)).toBe("string")
		end)

		t.it("passes every argument through, including nil holes", function()
			local count
			Safe.call(function(...)
				count = select("#", ...)
			end, 1, nil, 3, nil)
			expect(count).toBe(4)
		end)
	end)
end
