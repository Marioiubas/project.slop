--!nocheck
return function(t)
	local Validate = t.load("ReplicatedStorage.Shared.Validate")
	local expect = t.expect

	local function accepts(validator, value)
		local ok = validator(value)
		return ok
	end

	local function reasonFor(validator, value)
		local ok, reason = validator(value)
		expect(ok).toBe(false)
		return reason
	end

	t.describe("Validate.number", function()
		t.it("accepts finite numbers and rejects everything else", function()
			local v = Validate.number()
			expect(accepts(v, 3.5)).toBe(true)
			expect(accepts(v, -2)).toBe(true)
			expect(reasonFor(v, "3")).toContain("expected number, got string")
			expect(reasonFor(v, nil)).toContain("got nil")
			expect(reasonFor(v, true)).toContain("got boolean")
		end)

		t.it("rejects NaN and infinity", function()
			local v = Validate.number()
			expect(reasonFor(v, 0 / 0)).toContain("finite")
			expect(reasonFor(v, math.huge)).toContain("finite")
			expect(reasonFor(v, -math.huge)).toContain("finite")
		end)

		t.it("enforces min and max inclusively", function()
			local v = Validate.number({ min = 0, max = 10 })
			expect(accepts(v, 0)).toBe(true)
			expect(accepts(v, 10)).toBe(true)
			expect(reasonFor(v, -0.1)).toContain(">= 0")
			expect(reasonFor(v, 10.1)).toContain("<= 10")
		end)

		t.it("integer rejects fractions", function()
			local v = Validate.integer(1, 5)
			expect(accepts(v, 3)).toBe(true)
			expect(reasonFor(v, 2.5)).toContain("integer")
			expect(reasonFor(v, 0)).toContain(">= 1")
			expect(reasonFor(v, 6)).toContain("<= 5")
		end)
	end)

	t.describe("Validate.string", function()
		t.it("accepts strings and rejects other types", function()
			local v = Validate.string()
			expect(accepts(v, "hello")).toBe(true)
			expect(accepts(v, "")).toBe(true)
			expect(reasonFor(v, 5)).toContain("expected string, got number")
		end)

		t.it("caps length by default so a string can never be unbounded", function()
			local v = Validate.string()
			expect(accepts(v, string.rep("a", Validate.DEFAULT_MAX_STRING_LENGTH))).toBe(true)
			expect(reasonFor(v, string.rep("a", Validate.DEFAULT_MAX_STRING_LENGTH + 1))).toContain(
				"at most"
			)
		end)

		t.it("honours explicit min and max length", function()
			local v = Validate.string({ minLength = 2, maxLength = 4 })
			expect(reasonFor(v, "a")).toContain("at least 2")
			expect(accepts(v, "abcd")).toBe(true)
			expect(reasonFor(v, "abcde")).toContain("at most 4")
		end)

		t.it("matches the whole pattern", function()
			local v = Validate.string({ pattern = "^[a-z][a-z0-9_]*$" })
			expect(accepts(v, "teacup_2")).toBe(true)
			expect(reasonFor(v, "Teacup")).toContain("format")
			expect(reasonFor(v, "9lives")).toContain("format")
			expect(reasonFor(v, "has space")).toContain("format")
		end)
	end)

	t.describe("Validate.boolean / oneOf / optional", function()
		t.it("boolean accepts only booleans", function()
			local v = Validate.boolean()
			expect(accepts(v, false)).toBe(true)
			expect(reasonFor(v, 0)).toContain("expected boolean")
			expect(reasonFor(v, nil)).toContain("expected boolean")
		end)

		t.it("oneOf accepts only listed values", function()
			local v = Validate.oneOf({ "small", "large", 3 })
			expect(accepts(v, "small")).toBe(true)
			expect(accepts(v, 3)).toBe(true)
			expect(reasonFor(v, "huge")).toContain("not an allowed value")
		end)

		t.it("optional accepts nil and otherwise defers to the inner validator", function()
			local v = Validate.optional(Validate.integer(0))
			expect(accepts(v, nil)).toBe(true)
			expect(accepts(v, 4)).toBe(true)
			expect(reasonFor(v, -1)).toContain(">= 0")
			expect(reasonFor(v, "x")).toContain("expected number")
		end)
	end)

	t.describe("Validate.shape", function()
		local v = Validate.shape({
			id = Validate.string({ minLength = 1 }),
			count = Validate.integer(0),
			note = Validate.optional(Validate.string()),
		})

		t.it("accepts a complete record, with or without optional fields", function()
			expect(accepts(v, { id = "a", count = 1 })).toBe(true)
			expect(accepts(v, { id = "a", count = 1, note = "hi" })).toBe(true)
		end)

		t.it("rejects non-tables", function()
			expect(reasonFor(v, "nope")).toContain("expected table")
			expect(reasonFor(v, nil)).toContain("expected table")
		end)

		t.it("rejects a missing required field and names it", function()
			expect(reasonFor(v, { id = "a" })).toContain("field 'count'")
		end)

		t.it("rejects an invalid field value and names it", function()
			expect(reasonFor(v, { id = "a", count = -1 })).toContain("field 'count'")
		end)

		t.it("rejects unknown fields (typos and smuggled extras)", function()
			expect(reasonFor(v, { id = "a", count = 1, cuont = 2 })).toContain(
				"unexpected field 'cuont'"
			)
		end)

		t.it("rejects non-string keys", function()
			expect(reasonFor(v, { id = "a", count = 1, [1] = "x" })).toContain(
				"keys must be strings"
			)
		end)
	end)

	t.describe("Validate.args", function()
		local validators = { Validate.integer(1), Validate.optional(Validate.string()) }

		t.it("accepts matching positional arguments, omitting trailing optionals", function()
			expect(Validate.args(validators, 5, "x")).toBe(true)
			expect(Validate.args(validators, 5)).toBe(true)
		end)

		t.it("rejects too many arguments", function()
			local ok, reason = Validate.args(validators, 5, "x", "extra")
			expect(ok).toBe(false)
			expect(reason).toContain("at most 2")
		end)

		t.it("rejects a bad argument and reports its position", function()
			local ok, reason = Validate.args(validators, 5, 99)
			expect(ok).toBe(false)
			expect(reason).toContain("argument 2")
		end)

		t.it("rejects a missing required argument", function()
			local ok, reason = Validate.args(validators)
			expect(ok).toBe(false)
			expect(reason).toContain("argument 1")
		end)

		t.it("treats an explicit nil like a missing argument", function()
			local ok = Validate.args(validators, nil)
			expect(ok).toBe(false)
		end)

		t.it("with no validators, accepts only an empty call", function()
			expect(Validate.args({})).toBe(true)
			expect(Validate.args({}, 1)).toBe(false)
		end)
	end)
end
