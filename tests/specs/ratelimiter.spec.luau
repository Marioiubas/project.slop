--!nocheck
return function(t)
	local RateLimiter = t.load("ServerScriptService.Server.RateLimiter")
	local expect = t.expect

	local now
	local function newLimiter(burst, perSecond)
		return RateLimiter.new({
			Burst = burst,
			PerSecond = perSecond,
			Clock = function()
				return now
			end,
		})
	end

	t.beforeEach(function()
		now = 100
	end)

	t.describe("RateLimiter", function()
		t.it("allows a full burst and then refuses", function()
			local limiter = newLimiter(3, 1)
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(false)
		end)

		t.it("refills at PerSecond", function()
			local limiter = newLimiter(2, 2)
			limiter:tryConsume("a")
			limiter:tryConsume("a")
			expect(limiter:tryConsume("a")).toBe(false)
			now += 0.5 -- one token back
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(false)
		end)

		t.it("never refills past the burst", function()
			local limiter = newLimiter(2, 10)
			limiter:tryConsume("a")
			now += 1000
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(false)
		end)

		t.it("keeps keys independent", function()
			local limiter = newLimiter(1, 1)
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(false)
			expect(limiter:tryConsume("b")).toBe(true)
		end)

		t.it("a refused call spends nothing", function()
			local limiter = newLimiter(1, 1)
			limiter:tryConsume("a")
			for _ = 1, 50 do
				limiter:tryConsume("a")
			end
			now += 1
			expect(limiter:tryConsume("a")).toBe(true)
		end)

		t.it("supports a cost above one", function()
			local limiter = newLimiter(5, 1)
			expect(limiter:tryConsume("a", 3)).toBe(true)
			expect(limiter:tryConsume("a", 3)).toBe(false)
			expect(limiter:tryConsume("a", 2)).toBe(true)
		end)

		t.it("forget gives a key a fresh bucket", function()
			local limiter = newLimiter(1, 1)
			limiter:tryConsume("a")
			expect(limiter:tryConsume("a")).toBe(false)
			limiter:forget("a")
			expect(limiter:tryConsume("a")).toBe(true)
		end)

		t.it("clear resets every key", function()
			local limiter = newLimiter(1, 1)
			limiter:tryConsume("a")
			limiter:tryConsume("b")
			limiter:clear()
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("b")).toBe(true)
		end)

		t.it("a clock that steps backwards neither refunds nor drains tokens", function()
			local limiter = newLimiter(2, 1)
			limiter:tryConsume("a")
			now -= 50
			expect(limiter:tryConsume("a")).toBe(true)
			expect(limiter:tryConsume("a")).toBe(false)
		end)

		t.it("works with non-string keys", function()
			local limiter = newLimiter(1, 1)
			expect(limiter:tryConsume(12345)).toBe(true)
			expect(limiter:tryConsume(12345)).toBe(false)
		end)

		t.it("validates its options", function()
			expect(function()
				RateLimiter.new({ Burst = 0, PerSecond = 1 })
			end).toThrow("Burst")
			expect(function()
				RateLimiter.new({ Burst = 1, PerSecond = 0 })
			end).toThrow("PerSecond")
		end)
	end)
end
