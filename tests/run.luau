--!nocheck
--[[
	Runs every tests/specs/*.spec.luau against the real src/ modules (see ADR 0005).

	    lune run tests/run                 # everything
	    lune run tests/run -- signal       # only specs/tests whose name contains "signal"

	Exits non-zero if any test fails (or if no test ran at all).
]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local Loader = require("../tools/lib/rojo_loader")
local TestKit = require("./lib/testkit")

local filter = process.args[1]

local specNames = {}
for _, entry in fs.readDir("tests/specs") do
	if string.match(entry, "%.spec%.luau$") then
		table.insert(specNames, entry)
	end
end
table.sort(specNames)

local loader = Loader.new()

local totals = { passed = 0, failed = 0, skipped = 0 }
for _, fileName in specNames do
	local specFunction = require("./specs/" .. string.gsub(fileName, "%.luau$", ""))
	local result = TestKit.runSpec(specFunction, loader, filter)

	totals.passed += result.passed
	totals.failed += result.failed
	totals.skipped += result.skipped

	if result.passed + result.failed > 0 then
		local status = if result.failed == 0 then "PASS" else "FAIL"
		print(`{status}  {fileName}  ({result.passed}/{result.passed + result.failed})`)
		for _, failure in result.failures do
			print(`  x {failure.name}`)
			for line in string.gmatch(failure.message, "[^\n]+") do
				print(`      {line}`)
			end
		end
	end
end

local summary = `Tests: {totals.passed} passed, {totals.failed} failed`
if totals.skipped > 0 then
	summary ..= `, {totals.skipped} skipped (filter: {filter})`
end
print(summary)

if totals.failed > 0 then
	process.exit(1)
elseif totals.passed == 0 then
	print("No tests ran: check the filter and tests/specs/")
	process.exit(1)
end
