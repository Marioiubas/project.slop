--!strict
--[[
	Artifact definitions: data only, no logic (blueprint "Artifact Architecture").

	Intentionally empty in Stage 0. Stage 1 adds the first artifact; Stage 2 widens the
	schema in `Schema.luau` to the full blueprint field list. Add an entry like:

		{ id = "teacup_of_regret", displayName = "Teacup of Regret", rarity = "odd" },

	`tools/validate_content` (and CI later) rejects bad ids, missing fields and rarity
	references that don't exist.
]]

return table.freeze({} :: { { id: string, displayName: string, rarity: string } })
