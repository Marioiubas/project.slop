--!strict
--[[
	All game content, grouped by collection. Content is data: systems read it, they
	never hard-code it. Every collection here needs an entry in `Schema.luau`, which
	`ContentValidator` checks (run `lune run tools/validate_content`).
]]

return table.freeze({
	Rarities = require(script.Rarities),
	Artifacts = require(script.Artifacts),
})
