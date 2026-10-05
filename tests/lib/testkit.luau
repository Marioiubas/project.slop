--!nocheck
--[[
	A deliberately small test framework (see ADR 0005): describe / it / expect, hooks,
	async-friendly (tests may yield with `t.wait`), no dependencies.

	A spec file returns a function that receives the context `t`:

	    return function(t)
	        local Signal = t.load("ReplicatedStorage.Shared.Signal")
	        t.describe("Signal", function()
	            t.it("fires", function()
	                t.expect(1 + 1).toBe(2)
	                t.expect({ 1 }).toEqual({ 1 })
	                t.expect(function() error("boom") end).toThrow("boom")
	                t.expect(5).never.toBe(6)
	            end)
	        end)
	    end
]]

local task = require("@lune/task")

local TEST_TIMEOUT_SECONDS = 5

local TestKit = {}

-- Rendering ------------------------------------------------------------------

local function pretty(value, depth)
	depth = depth or 0
	local kind = type(value)
	if kind == "string" then
		return string.format("%q", value)
	elseif kind ~= "table" then
		return tostring(value)
	elseif depth >= 3 then
		return "{...}"
	end

	local parts = {}
	local count = 0
	for _ in value do
		count += 1
	end
	if count == #value then
		for _, item in value do
			table.insert(parts, pretty(item, depth + 1))
		end
	else
		local keys = {}
		for key in value do
			table.insert(keys, key)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		for _, key in keys do
			table.insert(parts, `{tostring(key)} = {pretty(value[key], depth + 1)}`)
		end
	end
	return "{ " .. table.concat(parts, ", ") .. " }"
end

local function deepEqual(a, b, seen)
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	seen = seen or {}
	if seen[a] == b then
		return true
	end
	seen[a] = b
	for key, value in a do
		if not deepEqual(value, b[key], seen) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

-- Expectations ---------------------------------------------------------------

local function fail(message)
	error({ __expectation = message }, 0)
end

local function makeExpectation(actual, negated)
	local function check(pass, message, negatedMessage)
		if negated then
			pass = not pass
			message = negatedMessage
		end
		if not pass then
			fail(message)
		end
	end

	local expectation = {}

	function expectation.toBe(expected)
		check(
			actual == expected,
			`expected {pretty(actual)} to be {pretty(expected)}`,
			`expected {pretty(actual)} not to be {pretty(expected)}`
		)
	end

	function expectation.toEqual(expected)
		check(
			deepEqual(actual, expected),
			`expected {pretty(actual)} to equal {pretty(expected)}`,
			`expected {pretty(actual)} not to equal {pretty(expected)}`
		)
	end

	function expectation.toBeNil()
		check(actual == nil, `expected {pretty(actual)} to be nil`, "expected a non-nil value")
	end

	function expectation.toBeTruthy()
		check(
			actual ~= nil and actual ~= false,
			`expected {pretty(actual)} to be truthy`,
			`expected {pretty(actual)} to be falsy`
		)
	end

	function expectation.toBeFalsy()
		check(
			actual == nil or actual == false,
			`expected {pretty(actual)} to be falsy`,
			`expected {pretty(actual)} to be truthy`
		)
	end

	function expectation.toBeGreaterThan(limit)
		check(
			type(actual) == "number" and actual > limit,
			`expected {pretty(actual)} to be > {pretty(limit)}`,
			`expected {pretty(actual)} not to be > {pretty(limit)}`
		)
	end

	function expectation.toBeLessThan(limit)
		check(
			type(actual) == "number" and actual < limit,
			`expected {pretty(actual)} to be < {pretty(limit)}`,
			`expected {pretty(actual)} not to be < {pretty(limit)}`
		)
	end

	function expectation.toBeCloseTo(expected, tolerance)
		tolerance = tolerance or 1e-9
		check(
			type(actual) == "number" and math.abs(actual - expected) <= tolerance,
			`expected {pretty(actual)} to be within {tolerance} of {pretty(expected)}`,
			`expected {pretty(actual)} not to be within {tolerance} of {pretty(expected)}`
		)
	end

	-- String: substring. Table: has the element (==).
	function expectation.toContain(needle)
		local found = false
		if type(actual) == "string" then
			found = string.find(actual, needle, 1, true) ~= nil
		elseif type(actual) == "table" then
			found = table.find(actual, needle) ~= nil
		end
		check(
			found,
			`expected {pretty(actual)} to contain {pretty(needle)}`,
			`expected {pretty(actual)} not to contain {pretty(needle)}`
		)
	end

	function expectation.toMatch(pattern)
		check(
			type(actual) == "string" and string.match(actual, pattern) ~= nil,
			`expected {pretty(actual)} to match {pretty(pattern)}`,
			`expected {pretty(actual)} not to match {pretty(pattern)}`
		)
	end

	function expectation.toHaveLength(length)
		check(
			type(actual) == "table" and #actual == length,
			`expected {pretty(actual)} to have length {length}`,
			`expected {pretty(actual)} not to have length {length}`
		)
	end

	-- `actual` must be a function. Optional `substring` must appear in the error message.
	function expectation.toThrow(substring)
		local ok, err = pcall(actual)
		local message = if type(err) == "table" and err.__expectation
			then err.__expectation
			else tostring(err)
		local threw = not ok
			and (substring == nil or string.find(message, substring, 1, true) ~= nil)
		local detail = if substring ~= nil then ` containing {pretty(substring)}` else ""
		check(
			threw,
			if ok
				then `expected the function to throw{detail} but it returned`
				else `expected the error {pretty(message)} to contain {pretty(substring)}`,
			`expected the function not to throw{detail}, but it threw {pretty(message)}`
		)
	end

	if not negated then
		expectation.never = makeExpectation(actual, true)
	end
	return expectation
end

-- Suites ---------------------------------------------------------------------

local function newSuite(name, parent)
	return { name = name, parent = parent, entries = {}, beforeEach = {}, afterEach = {} }
end

local function suitePath(suite)
	local names = {}
	local current = suite
	while current ~= nil and current.name ~= "" do
		table.insert(names, 1, current.name)
		current = current.parent
	end
	return names
end

local function runBody(callback)
	local finished = false
	local ok, err = nil, nil
	local thread = task.spawn(function()
		ok, err = xpcall(callback, function(raised)
			if type(raised) == "table" and raised.__expectation ~= nil then
				return raised
			end
			return debug.traceback(tostring(raised), 2)
		end)
		finished = true
	end)

	local deadline = os.clock() + TEST_TIMEOUT_SECONDS
	while not finished do
		if os.clock() > deadline then
			task.cancel(thread)
			return false,
				`timed out after {TEST_TIMEOUT_SECONDS}s (a test that yields needs something to wake it)`
		end
		task.wait()
	end
	if not ok and type(err) == "table" then
		return false, err.__expectation
	end
	return ok, err
end

-- Runs one spec. Returns { passed = n, failed = n, skipped = n, failures = { {name, message} } }.
function TestKit.runSpec(specFunction, loader, filter)
	local root = newSuite("", nil)
	local current = root
	local t = {}

	function t.describe(name, body)
		local suite = newSuite(name, current)
		table.insert(current.entries, { suite = suite })
		local previous = current
		current = suite
		body()
		current = previous
	end

	function t.it(name, body)
		table.insert(current.entries, { test = { name = name, body = body, suite = current } })
	end

	function t.beforeEach(hook)
		table.insert(current.beforeEach, hook)
	end

	function t.afterEach(hook)
		table.insert(current.afterEach, hook)
	end

	t.expect = function(actual)
		return makeExpectation(actual, false)
	end

	function t.load(path)
		return loader:require(path)
	end

	-- Returns the list of messages `warn` was called with while `body` ran.
	function t.captureWarnings(body)
		local captured = {}
		loader:setWarnHandler(function(...)
			local parts = {}
			for _, part in { ... } do
				table.insert(parts, tostring(part))
			end
			table.insert(captured, table.concat(parts, " "))
		end)
		local ok, err = pcall(body)
		loader:setWarnHandler(nil)
		if not ok then
			error(err, 0)
		end
		return captured
	end

	function t.wait(seconds)
		task.wait(seconds)
	end

	-- Starts `callback` in its own thread (like task.spawn); returns the thread.
	function t.spawn(callback, ...)
		return task.spawn(callback, ...)
	end

	specFunction(t)

	local result = { passed = 0, failed = 0, skipped = 0, failures = {} }

	local function runTest(test)
		local names = suitePath(test.suite)
		table.insert(names, test.name)
		local fullName = table.concat(names, " > ")
		if
			filter ~= nil and not string.find(string.lower(fullName), string.lower(filter), 1, true)
		then
			result.skipped += 1
			return
		end

		-- Hooks run outermost-first before, innermost-first after (and after failures too).
		local chain = {}
		local suite = test.suite
		while suite ~= nil do
			table.insert(chain, 1, suite)
			suite = suite.parent
		end

		local ok, err = true, nil
		for _, scope in chain do
			for _, hook in scope.beforeEach do
				if ok then
					ok, err = runBody(hook)
				end
			end
		end
		if ok then
			ok, err = runBody(test.body)
		end
		for index = #chain, 1, -1 do
			for _, hook in chain[index].afterEach do
				local hookOk, hookErr = runBody(hook)
				if ok and not hookOk then
					ok, err = false, hookErr
				end
			end
		end

		if ok then
			result.passed += 1
		else
			result.failed += 1
			table.insert(result.failures, { name = fullName, message = tostring(err) })
		end
	end

	local function runSuite(suite)
		for _, entry in suite.entries do
			if entry.suite ~= nil then
				runSuite(entry.suite)
			else
				runTest(entry.test)
			end
		end
	end
	runSuite(root)

	return result
end

return TestKit
