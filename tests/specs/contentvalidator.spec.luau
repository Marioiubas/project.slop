--!nocheck
return function(t)
	local Content = t.load("ReplicatedStorage.Shared.Content")
	local Schema = t.load("ReplicatedStorage.Shared.Content.Schema")
	local ContentValidator = t.load("ReplicatedStorage.Shared.ContentValidator")
	local Validate = t.load("ReplicatedStorage.Shared.Validate")
	local expect = t.expect

	local function rarities()
		return {
			{ id = "common", displayName = "Common", order = 1, color = "#9AA0A6" },
			{ id = "odd", displayName = "Odd", order = 2, color = "#4CAF50" },
		}
	end

	local function validContent()
		return {
			Rarities = rarities(),
			Artifacts = {
				{ id = "teacup", displayName = "Teacup of Regret", rarity = "odd" },
				{ id = "spoon", displayName = "Sentient Spoon", rarity = "common" },
			},
		}
	end

	local function problemsFor(content, schema)
		return ContentValidator.validate(content, schema or Schema)
	end

	-- The single assertion most cases need: exactly one problem, containing `text`.
	local function expectOneProblem(content, text, schema)
		local problems = problemsFor(content, schema)
		expect(problems).toHaveLength(1)
		expect(problems[1]).toContain(text)
	end

	t.describe("the real game content", function()
		t.it("passes validation", function()
			expect(problemsFor(Content)).toEqual({})
		end)

		t.it("has the five rarity tiers in ascending order", function()
			local ids = {}
			for index, rarity in Content.Rarities do
				expect(rarity.order).toBe(index)
				table.insert(ids, rarity.id)
			end
			expect(ids).toEqual({ "common", "odd", "bizarre", "impossible", "forbidden" })
		end)
	end)

	t.describe("ContentValidator", function()
		t.it("accepts valid content", function()
			expect(problemsFor(validContent())).toEqual({})
		end)

		t.it("accepts an empty collection", function()
			local content = validContent()
			content.Artifacts = {}
			expect(problemsFor(content)).toEqual({})
		end)

		t.it("reports a missing required field with the entry's position and id", function()
			local content = validContent()
			content.Artifacts[2].displayName = nil
			expectOneProblem(content, "Artifacts[2] (id 'spoon'): field 'displayName'")
		end)

		t.it("reports an unknown field (a typo)", function()
			local content = validContent()
			content.Artifacts[1].rarty = "odd"
			expectOneProblem(content, "unexpected field 'rarty'")
		end)

		t.it("reports an id that isn't snake_case", function()
			local content = validContent()
			content.Artifacts[1].id = "Tea-Cup"
			expectOneProblem(content, "field 'id'")
		end)

		t.it("reports duplicate ids and points at the first use", function()
			local content = validContent()
			content.Artifacts[2].id = "teacup"
			expectOneProblem(content, "duplicate id 'teacup' (first used by Artifacts[1])")
		end)

		t.it("reports a rarity that doesn't exist", function()
			local content = validContent()
			content.Artifacts[1].rarity = "mythic"
			expectOneProblem(content, "rarity 'mythic' does not exist in Rarities")
		end)

		t.it("reports a rarity of the wrong type as a shape problem", function()
			local content = validContent()
			content.Artifacts[1].rarity = 3
			expectOneProblem(content, "field 'rarity'")
		end)

		t.it("reports duplicate values in a declared-unique field", function()
			local content = validContent()
			content.Rarities[2].order = 1
			expectOneProblem(content, "duplicate order '1'")
		end)

		t.it("reports a malformed colour", function()
			local content = validContent()
			content.Rarities[1].color = "grey"
			expectOneProblem(content, "field 'color'")
		end)

		t.it("reports a collection missing from the content", function()
			local content = validContent()
			content.Artifacts = nil
			expectOneProblem(content, "Artifacts: collection is missing from Content")
		end)

		t.it("reports a collection that has no schema", function()
			local content = validContent()
			content.Mutations = {}
			expectOneProblem(content, "Mutations: collection has no schema")
		end)

		t.it("reports a collection that isn't a list", function()
			local content = validContent()
			content.Artifacts = { teacup = { id = "teacup" } }
			expectOneProblem(content, "Artifacts: collection must be a list")
		end)

		t.it("reports an entry that isn't a table", function()
			local content = validContent()
			content.Artifacts[1] = "teacup"
			expectOneProblem(content, "Artifacts[1]: expected table")
		end)

		t.it("reports every problem, not just the first", function()
			local content = validContent()
			content.Artifacts[1].rarity = "mythic"
			content.Artifacts[2].displayName = nil
			expect(problemsFor(content)).toHaveLength(2)
		end)

		t.it("reports a schema ref that targets an unknown collection", function()
			local id = Validate.string({ pattern = "^[a-z]+$" })
			local schema = {
				Things = {
					entry = Validate.shape({ id = id, owner = id }),
					unique = {},
					refs = { owner = "Nobody" },
				},
			}
			local content = { Things = { { id = "a", owner = "b" } } }
			local problems = problemsFor(content, schema)
			expect(problems[1]).toContain("targets unknown collection 'Nobody'")
		end)

		t.it("resolves refs regardless of collection order", function()
			-- Artifacts sorts before Rarities, so this exercises the id pre-pass.
			expect(problemsFor(validContent())).toEqual({})
		end)
	end)
end
