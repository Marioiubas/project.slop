--!nocheck
--[[
	Validates src/shared/Content against its schema: ids, required fields, unknown
	fields, uniqueness, and references (e.g. an artifact's rarity must exist).

	    lune run tools/validate_content

	Exits non-zero and lists every problem if the content is invalid.
]]

local process = require("@lune/process")
local Loader = require("./lib/rojo_loader")

local loader = Loader.new()
local content = loader:require("ReplicatedStorage.Shared.Content")
local schema = loader:require("ReplicatedStorage.Shared.Content.Schema")
local ContentValidator = loader:require("ReplicatedStorage.Shared.ContentValidator")

local problems = ContentValidator.validate(content, schema)

if #problems > 0 then
	print(`Content is INVALID ({#problems} problem(s)):`)
	for _, problem in problems do
		print(`  - {problem}`)
	end
	process.exit(1)
end

local collections, entries = 0, 0
for _, list in content do
	collections += 1
	entries += #list
end
print(
	`Content OK: {collections} collection(s), {entries} entr{if entries == 1 then "y" else "ies"}`
)
