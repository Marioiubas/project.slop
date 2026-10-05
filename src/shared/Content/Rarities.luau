--!strict
--[[
	Rarity tiers (blueprint "Artifact Architecture"). Display names may change during
	art direction; `id` is the stable key other content references, so don't rename ids.
	`order` ascends with rarity. `color` is a hex string (no Roblox datatypes in data).
]]

return table.freeze({
	{ id = "common", displayName = "Common", order = 1, color = "#9AA0A6" },
	{ id = "odd", displayName = "Odd", order = 2, color = "#4CAF50" },
	{ id = "bizarre", displayName = "Bizarre", order = 3, color = "#3F8EFC" },
	{ id = "impossible", displayName = "Impossible", order = 4, color = "#B15CFF" },
	{ id = "forbidden", displayName = "Forbidden", order = 5, color = "#FF3B5C" },
})
