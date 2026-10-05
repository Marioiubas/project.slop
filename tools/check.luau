--!nocheck
--[[
	The Stage 0 gate in one command. Run it before every commit, from the repo root:

	    lune run tools/check

	format check -> lint -> type check -> rojo build -> unit tests -> content validation.
	Runs every step even if an earlier one fails, then exits non-zero if any did.
	(Fix formatting automatically with `stylua src tests tools`.)
]]

local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isFile("default.project.json") then
	print("Run this from the repository root (default.project.json not found).")
	process.exit(1)
end
if not fs.isDir("build") then
	fs.writeDir("build")
end

local steps = {
	{
		name = "format  (stylua --check)",
		program = "stylua",
		args = { "--check", "src", "tests", "tools" },
	},
	{
		name = "lint    (selene)",
		program = "selene",
		args = { "--quiet", "src", "tests", "tools" },
	},
	{ name = "types   (luau-lsp)", program = "lune", args = { "run", "tools/typecheck" } },
	{
		name = "build   (rojo)",
		program = "rojo",
		args = { "build", "default.project.json", "-o", "build/GrabTheWeird.rbxl" },
	},
	{ name = "tests   (lune)", program = "lune", args = { "run", "tests/run" } },
	{ name = "content (validate)", program = "lune", args = { "run", "tools/validate_content" } },
}

local failed = {}
for _, step in steps do
	print(`\n=== {step.name} ===`)
	local result = process.exec(step.program, step.args, { stdio = "inherit" })
	if not result.ok then
		table.insert(failed, step.name)
	end
end

print("\n=== summary ===")
if #failed == 0 then
	print(`all {#steps} steps passed`)
else
	for _, name in failed do
		print(`FAILED: {name}`)
	end
	process.exit(1)
end
