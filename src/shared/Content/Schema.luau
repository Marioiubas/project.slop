--!strict
--[[
	Describes the shape of every content collection so `ContentValidator` can check it.
	Add a collection to `Content/init.luau` AND here; the validator fails if one is missing.
]]

local Types = require(script.Parent.Parent.Types)
local Validate = require(script.Parent.Parent.Validate)

export type CollectionSchema = {
	-- Validates one entry. Use Validate.shape so unknown fields are rejected.
	entry: Types.Validator,
	-- Extra fields that must be unique across the collection (`id` always is).
	unique: { string },
	-- field name -> collection whose `id` that field must reference.
	refs: { [string]: string },
}

export type Schema = { [string]: CollectionSchema }

-- Stable snake_case key other content and saved data refer to.
local id = Validate.string({ minLength = 2, maxLength = 48, pattern = "^[a-z][a-z0-9_]*$" })
local displayName = Validate.string({ minLength = 1, maxLength = 64 })

local schema: Schema = {
	Rarities = {
		entry = Validate.shape({
			id = id,
			displayName = displayName,
			order = Validate.integer(1, 100),
			color = Validate.string({ pattern = "^#%x%x%x%x%x%x$" }),
		}),
		unique = { "order" },
		refs = {},
	},

	Artifacts = {
		entry = Validate.shape({
			id = id,
			displayName = displayName,
			rarity = id,
		}),
		unique = {},
		refs = { rarity = "Rarities" },
	},
}

return table.freeze(schema)
