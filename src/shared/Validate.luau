--!strict
--[[
	Composable validators for untrusted input (remote arguments, content data).

	A validator is `(value: unknown) -> (ok: boolean, reason: string?)` and never throws.
	Everything is strict by default: numbers must be finite, strings are length-capped,
	and `shape` rejects unknown fields.

		local validators = { Validate.integer(1, 5), Validate.optional(Validate.string()) }
		local ok, reason = Validate.args(validators, ...)
]]

local Types = require(script.Parent.Types)

type Validator = Types.Validator

export type NumberOptions = {
	min: number?,
	max: number?,
	integer: boolean?,
}

export type StringOptions = {
	minLength: number?,
	-- Defaults to Validate.DEFAULT_MAX_STRING_LENGTH so a string can never be unbounded.
	maxLength: number?,
	-- A Luau pattern the whole string must match, e.g. "^[a-z][a-z0-9_]*$".
	pattern: string?,
}

local Validate = {}

Validate.DEFAULT_MAX_STRING_LENGTH = 256

function Validate.number(options: NumberOptions?): Validator
	local min = if options then options.min else nil
	local max = if options then options.max else nil
	local integer = if options then options.integer == true else false

	return function(value: unknown): (boolean, string?)
		if type(value) ~= "number" then
			return false, "expected number, got " .. typeof(value)
		end
		-- NaN and +/-inf pass the type check but poison any arithmetic downstream.
		if value ~= value or value == math.huge or value == -math.huge then
			return false, "number must be finite"
		end
		if integer and value % 1 ~= 0 then
			return false, "expected an integer"
		end
		if min ~= nil and value < min then
			return false, string.format("must be >= %s", tostring(min))
		end
		if max ~= nil and value > max then
			return false, string.format("must be <= %s", tostring(max))
		end
		return true, nil
	end
end

function Validate.integer(min: number?, max: number?): Validator
	return Validate.number({ min = min, max = max, integer = true })
end

function Validate.string(options: StringOptions?): Validator
	local minLength = if options and options.minLength then options.minLength else 0
	local maxLength = if options and options.maxLength
		then options.maxLength
		else Validate.DEFAULT_MAX_STRING_LENGTH
	local pattern = if options then options.pattern else nil

	return function(value: unknown): (boolean, string?)
		if type(value) ~= "string" then
			return false, "expected string, got " .. typeof(value)
		end
		if #value < minLength then
			return false, string.format("must be at least %d character(s)", minLength)
		end
		if #value > maxLength then
			return false, string.format("must be at most %d character(s)", maxLength)
		end
		if pattern ~= nil and string.match(value, pattern) == nil then
			return false, "does not match the required format"
		end
		return true, nil
	end
end

function Validate.boolean(): Validator
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "boolean" then
			return false, "expected boolean, got " .. typeof(value)
		end
		return true, nil
	end
end

-- The value must equal one of `allowed` (compared with `==`; use primitives).
function Validate.oneOf(allowed: { unknown }): Validator
	return function(value: unknown): (boolean, string?)
		if table.find(allowed, value) == nil then
			return false, "not an allowed value"
		end
		return true, nil
	end
end

-- Accepts nil, otherwise defers to `inner`.
function Validate.optional(inner: Validator): Validator
	return function(value: unknown): (boolean, string?)
		if value == nil then
			return true, nil
		end
		return inner(value)
	end
end

--[[
	A table with exactly these string keys. Every field is required unless its
	validator accepts nil (wrap it in `Validate.optional`). Unknown keys are rejected,
	which catches typos in content data and smuggled extra fields in payloads.
]]
function Validate.shape(fields: { [string]: Validator }): Validator
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "table" then
			return false, "expected table, got " .. typeof(value)
		end
		local record = value :: { [unknown]: unknown }

		for key in record do
			if type(key) ~= "string" then
				return false, "table keys must be strings"
			end
			if fields[key] == nil then
				return false, string.format("unexpected field '%s'", key)
			end
		end

		-- Sorted so the first reported problem is stable between runs.
		local names = {}
		for name in fields do
			table.insert(names, name)
		end
		table.sort(names)

		for _, name in names do
			local ok, reason = fields[name](record[name])
			if not ok then
				return false, string.format("field '%s': %s", name, reason or "invalid")
			end
		end
		return true, nil
	end
end

--[[
	Validates an argument list: at most `#validators` arguments, and argument N must
	satisfy validators[N]. Pass `Validate.optional(...)` for arguments that may be omitted.
]]
function Validate.args(validators: { Validator }, ...: unknown): (boolean, string?)
	local count = select("#", ...)
	if count > #validators then
		return false, string.format("expected at most %d argument(s), got %d", #validators, count)
	end
	for index, validator in validators do
		local ok, reason = validator((select(index, ...)))
		if not ok then
			return false, string.format("argument %d: %s", index, reason or "invalid")
		end
	end
	return true, nil
end

return Validate
