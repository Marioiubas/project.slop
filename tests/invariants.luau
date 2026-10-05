local Planner = require("../src/world/shared/GraphPlanner")
local Constants = require("../src/world/shared/Constants")
local Rooms = require("../src/world/shared/RoomDefinitions")
local Dimensions = require("../src/world/shared/DimensionDefinitions")
local Allocator = require("../src/world/server/RiftCellAllocator")
local count = 0
local function check(condition, message)
	count += 1
	assert(condition, message)
end
local function graph(seed)
	return Planner.Plan(seed, Dimensions.GiantsKitchen, Rooms, Constants)
end
local signatures = {}
for seed = 0, 999 do
	local plan = graph(seed)
	local valid, errors = Planner.Validate(plan, Rooms, Constants)
	check(valid, table.concat(errors, "; "))
	check(
		Planner.Fingerprint(plan) == Planner.Fingerprint(graph(seed)),
		"Same seed must reproduce map"
	)
	check(#plan.Nodes == 8 and #plan.Edges == 8, "Graph must contain a rejoining optional route")
	check(plan.MainPathLength == 640, "Incorrect traversal length")
	signatures[plan.Nodes[2].TemplateId .. ":" .. plan.Nodes[5].TemplateId .. ":" .. plan.Nodes[7].X] =
		true
end
local variants = 0
for _ in pairs(signatures) do
	variants += 1
end
check(variants >= 12, "Seeds must select varied authored compositions")
check(not pcall(graph, -1), "Negative seed accepted")
check(not pcall(graph, 1.5), "Fractional seed accepted")
check(not pcall(graph, math.huge), "Nonfinite seed accepted")
check(Planner.Validate(graph(2147483645), Rooms, Constants), "Largest seed rejected")
local function reject(mutate, message)
	local plan = graph(12345)
	mutate(plan)
	check(not Planner.Validate(plan, Rooms, Constants), message)
end
reject(function(p)
	p.Nodes[8].X, p.Nodes[8].Z = p.Nodes[7].X, p.Nodes[7].Z
end, "Overlap accepted")
reject(function(p)
	p.Edges[1].Width = 16
end, "Narrow cargo connector accepted")
reject(function(p)
	table.remove(p.Edges, 5)
end, "Disconnected extraction accepted")
reject(function(p)
	p.Nodes[1].Role = "Explore"
end, "Missing entry accepted")
reject(function(p)
	p.Nodes[4].TemplateId = "Countertop"
end, "Missing landmark accepted")
reject(function(p)
	p.Nodes[7].X += 8
end, "Unsnapped sockets accepted")
reject(function(p)
	p.Edges[1].Opposite = "E"
end, "Bad socket opposition accepted")
reject(function(p)
	p.MainPathLength = 900
end, "False traversal metric accepted")
reject(function(p)
	table.insert(p.Edges, table.clone(p.Edges[1]))
end, "Duplicated edge accepted")
local allocator = Allocator.new(Constants.Cells)
local leases = {}
for i = 1, 4 do
	leases[i] = assert(allocator:Reserve("Rift_" .. i))
	check(allocator:Count() == i, "Incorrect allocation count")
end
check(not allocator:Reserve("overflow"), "Allocated fifth cell")
check(not allocator:Reserve("Rift_1"), "Rift reserved twice")
check(
	not allocator:Release({ CellId = leases[1].CellId, Token = leases[1].Token, RiftId = "forged" }),
	"Wrong owner released cell"
)
check(allocator:Release(leases[1]), "Release failed")
local replacement = assert(allocator:Reserve("replacement"))
check(
	replacement.CellId == leases[1].CellId and replacement.Token ~= leases[1].Token,
	"Cell not safely reused"
)
check(not allocator:Release(leases[1]), "Stale token released replacement")
check(allocator:Release(replacement), "Replacement release failed")
for i = 2, 4 do
	check(allocator:Release(leases[i]), "Cell release failed")
end
check(allocator:Count() == 0, "Allocator leaked cells")
print(
	string.format(
		"PASS: %d invariant checks across 1,000 seeds (%d compositions).",
		count,
		variants
	)
)
