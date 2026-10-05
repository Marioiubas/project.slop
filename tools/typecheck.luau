--!nocheck
--[[
	Strict type-checks src/ with luau-lsp, the way Studio's script analysis would.

	    lune run tools/typecheck                        # auto-detects Roblox type definitions
	    lune run tools/typecheck -- path/to/globalTypes.d.luau

	luau-lsp's CLI doesn't ship Roblox's API types, so this needs a definitions file.
	It looks (in order) at: the argument, $LUAU_DEFINITIONS, then the Luau Language Server
	extension's cache in VS Code / Cursor / Antigravity / VSCodium. Install the extension
	once and open any Roblox project and it downloads the file.

	Definitions written for older luau-lsp releases use `declare class`; the pinned
	luau-lsp expects `declare extern type ... with`, so the file is converted into
	build/globalTypes.d.luau first.

	With no definitions available this SKIPS (exit 0) instead of failing, so a fresh
	machine can still run `lune run tools/check`; a real type error exits non-zero.
]]

local fs = require("@lune/fs")
local process = require("@lune/process")

local function run(program, args)
	return process.exec(program, args)
end

local function fileExists(path)
	return path ~= nil and fs.isFile(path)
end

local function findDefinitions()
	local explicit = process.args[1] or process.env.LUAU_DEFINITIONS
	if explicit ~= nil and explicit ~= "" then
		if not fileExists(explicit) then
			print(`typecheck: definitions file not found: {explicit}`)
			process.exit(1)
		end
		return explicit
	end

	local home = process.env.USERPROFILE or process.env.HOME
	local appData = process.env.APPDATA
	local editors = { "Code", "Code - Insiders", "Cursor", "Antigravity", "VSCodium" }
	local roots = {}
	for _, editor in editors do
		if appData ~= nil then
			table.insert(roots, `{appData}/{editor}/User/globalStorage/johnnymorganz.luau-lsp`)
		end
		if home ~= nil then
			table.insert(
				roots,
				`{home}/Library/Application Support/{editor}/User/globalStorage/johnnymorganz.luau-lsp`
			)
			table.insert(roots, `{home}/.config/{editor}/User/globalStorage/johnnymorganz.luau-lsp`)
		end
	end

	local names = {
		"globalTypes.None.d.luau",
		"globalTypes.PluginSecurity.d.luau",
		"globalTypes.RobloxScriptSecurity.d.luau",
		"globalTypes.d.luau",
	}
	for _, root in roots do
		for _, name in names do
			if fileExists(`{root}/{name}`) then
				return `{root}/{name}`
			end
		end
	end
	return nil
end

-- `declare class A extends B` -> `declare extern type A extends B with`
local function convertDefinitions(source)
	local lines = {}
	for line in string.gmatch(source, "([^\n]*)\n?") do
		line = string.gsub(line, "\r$", "")
		local name, base = string.match(line, "^declare class (%S+) extends (%S+) end$")
		if name ~= nil then
			line = `declare extern type {name} extends {base} with end`
		else
			name, base = string.match(line, "^declare class (%S+) extends (%S+)$")
			if name ~= nil then
				line = `declare extern type {name} extends {base} with`
			else
				name = string.match(line, "^declare class (%S+) end$")
				if name ~= nil then
					line = `declare extern type {name} with end`
				else
					name = string.match(line, "^declare class (%S+)$")
					if name ~= nil then
						line = `declare extern type {name} with`
					end
				end
			end
		end
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

local definitions = findDefinitions()
if definitions == nil then
	print("typecheck: SKIPPED (no Roblox type definitions found)")
	print(
		"  Install the 'Luau Language Server' extension, or pass a globalTypes.d.luau path / set LUAU_DEFINITIONS."
	)
	process.exit(0)
end

if not fs.isDir("build") then
	fs.writeDir("build")
end

local source = fs.readFile(definitions)
if
	string.find(source, "\ndeclare class ", 1, true) ~= nil
	or string.sub(source, 1, 14) == "declare class "
then
	source = convertDefinitions(source)
end
fs.writeFile("build/globalTypes.d.luau", source)

local sourcemap = run("rojo", { "sourcemap", "default.project.json", "-o", "build/sourcemap.json" })
if not sourcemap.ok then
	print("typecheck: `rojo sourcemap` failed:\n" .. sourcemap.stderr)
	process.exit(1)
end

local result = run("luau-lsp", {
	"analyze",
	"--sourcemap",
	"build/sourcemap.json",
	"--definitions=@roblox=build/globalTypes.d.luau",
	"src",
})

-- luau-lsp chats on stderr/stdout with "[INFO]"/"[WARN]" lines; keep only real findings.
local findings = {}
for line in string.gmatch(result.stdout .. "\n" .. result.stderr, "[^\n]+") do
	if not string.match(line, "^%[%u+%]") and string.match(line, "%S") then
		table.insert(findings, line)
	end
end

if #findings > 0 or not result.ok then
	print("typecheck: FAILED")
	for _, line in findings do
		print("  " .. line)
	end
	process.exit(1)
end
print(`typecheck: OK (definitions: {definitions})`)
