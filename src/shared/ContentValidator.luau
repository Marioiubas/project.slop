--!strict
--[[
	Checks content data against its schema and returns human-readable problems
	(empty list = valid). Pure: give it any content/schema pair, so tests can feed it
	deliberately broken fixtures and `tools/validate_content` feeds it the real thing.

	Checks: every schema'd collection exists and is a list; every entry matches its
	shape (required fields, types, unknown fields); ids and declared `unique` fields
	are unique; `refs` point at ids that exist; no collection lacks a schema.
]]

local Schema = require(script.Parent.Content.Schema)

type Schema = Schema.Schema

export type Content = { [string]: { unknown } }

local ContentValidator = {}

local function sortedKeys(map: { [string]: unknown }): { string }
	local keys = {}
	for key in map do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function isList(value: unknown): boolean
	if type(value) ~= "table" then
		return false
	end
	local count = 0
	for _ in value :: { [unknown]: unknown } do
		count += 1
	end
	return count == #(value :: { unknown })
end

function ContentValidator.validate(content: Content, schema: Schema): { string }
	local problems: { string } = {}
	local function report(message: string, ...: any)
		table.insert(problems, string.format(message, ...))
	end

	for _, name in sortedKeys(content :: any) do
		if schema[name] == nil then
			report("%s: collection has no schema (add it to Content/Schema.luau)", name)
		end
	end

	-- First pass: collect valid ids per collection so refs can be resolved in either order.
	local idsByCollection: { [string]: { [string]: boolean } } = {}
	for _, name in sortedKeys(schema :: any) do
		local ids: { [string]: boolean } = {}
		idsByCollection[name] = ids
		local entries = content[name]
		if isList(entries) then
			for _, entry in entries do
				local entryId = (entry :: any).id
				if type(entry) == "table" and type(entryId) == "string" then
					ids[entryId] = true
				end
			end
		end
	end

	for _, name in sortedKeys(schema :: any) do
		local collection = schema[name]
		local entries = content[name]

		if entries == nil then
			report("%s: collection is missing from Content", name)
			continue
		end
		if not isList(entries) then
			report("%s: collection must be a list of entries", name)
			continue
		end

		for ref, target in collection.refs do
			if schema[target] == nil then
				report("%s: schema ref '%s' targets unknown collection '%s'", name, ref, target)
			end
		end

		local uniqueFields = { "id" }
		for _, field in collection.unique do
			table.insert(uniqueFields, field)
		end
		local firstSeen: { [string]: { [any]: number } } = {}
		for _, field in uniqueFields do
			firstSeen[field] = {}
		end

		for index, entry in entries do
			local label = string.format("%s[%d]", name, index)
			if type(entry) == "table" and type((entry :: any).id) == "string" then
				label = string.format("%s (id '%s')", label, (entry :: any).id)
			end

			local ok, reason = collection.entry(entry)
			if not ok then
				report("%s: %s", label, reason or "invalid entry")
				continue
			end

			local record = entry :: { [string]: any }
			for _, field in uniqueFields do
				local value = record[field]
				local earlier = firstSeen[field][value]
				if earlier ~= nil then
					report(
						"%s: duplicate %s '%s' (first used by %s[%d])",
						label,
						field,
						tostring(value),
						name,
						earlier
					)
				else
					firstSeen[field][value] = index
				end
			end

			for field, target in collection.refs do
				local value = record[field]
				local targetIds = idsByCollection[target]
				if value ~= nil and targetIds ~= nil and not targetIds[value] then
					report(
						"%s: %s '%s' does not exist in %s",
						label,
						field,
						tostring(value),
						target
					)
				end
			end
		end
	end

	return problems
end

return ContentValidator
