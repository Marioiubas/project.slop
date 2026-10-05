--!strict
-- Pure Luau: the engine and standalone tests run the same planning/validation code.
local Planner = {}
export type RoomDefinition = {
	Role: string,
	Width: number,
	Depth: number,
	CarryWidth: number,
	CarryHeight: number,
}
export type Dimension = {
	Enabled: boolean,
	DimensionId: string,
	GenerationVersion: number,
	RoomSet: { string },
}
export type Config = {
	Step: number,
	Grid: number,
	RoomSize: number,
	CarryWidth: number,
	CarryHeight: number,
	RoomCountMin: number,
	RoomCountMax: number,
}
export type Node = {
	Id: number,
	TemplateId: string,
	Role: string,
	X: number,
	Z: number,
	Optional: boolean,
}
export type Edge = {
	A: number,
	B: number,
	Direction: string,
	Opposite: string,
	Width: number,
	Height: number,
}
export type Graph = {
	Seed: number,
	DimensionId: string,
	GenerationVersion: number,
	Nodes: { Node },
	Edges: { Edge },
	Entry: number,
	Extraction: number,
	MainPath: { number },
	MainPathLength: number,
}
type Direction = { X: number, Z: number, Opposite: string }
local directions: { [string]: Direction } = {
	N = { X = 0, Z = -1, Opposite = "S" },
	S = { X = 0, Z = 1, Opposite = "N" },
	E = { X = 1, Z = 0, Opposite = "W" },
	W = { X = -1, Z = 0, Opposite = "E" },
}
Planner.Directions = directions

local function random(seed: number): (number) -> number
	-- Park-Miller: fixed algorithm, no dependence on global math.random state.
	local state = (seed % 2147483646) + 1
	return function(maximum: number): number
		state = (state * 16807) % 2147483647
		return (state % maximum) + 1
	end
end

function Planner.Plan(
	seed: number,
	dimension: Dimension,
	definitions: { [string]: RoomDefinition },
	constants: Config
): Graph
	assert(
		type(seed) == "number" and seed == math.floor(seed) and seed >= 0 and seed <= 2147483645,
		"Invalid seed"
	)
	assert(dimension.Enabled, "Dimension is not enabled")
	local nextInt = random(seed)
	local pools: { [string]: { string } } = {}
	for _, roomId in ipairs(dimension.RoomSet) do
		local room = assert(definitions[roomId], "Missing room definition: " .. roomId)
		pools[room.Role] = pools[room.Role] or {}
		table.insert(pools[room.Role], roomId)
	end
	local side = nextInt(2) == 1 and -1 or 1
	local nodes: { Node } = {}
	local function node(id: number, role: string, x: number, z: number, optional: boolean?)
		local pool = assert(pools[role], "Missing room role: " .. role)
		nodes[id] = {
			Id = id,
			TemplateId = pool[nextInt(#pool)],
			Role = role,
			X = x * constants.Step,
			Z = z * constants.Step,
			Optional = optional or false,
		}
	end
	node(1, "Entry", 0, 0)
	node(2, "Explore", 0, 1)
	node(3, "Junction", 0, 2)
	node(4, "Landmark", 0, 3)
	node(5, "Explore", 0, 4)
	node(6, "Extraction", 0, 5)
	node(7, "Explore", side, 2, true)
	node(8, "Explore", side, 3, true)
	local edges: { Edge } = {}
	for _, pair in ipairs({
		{ 1, 2 },
		{ 2, 3 },
		{ 3, 4 },
		{ 4, 5 },
		{ 5, 6 },
		{ 3, 7 },
		{ 7, 8 },
		{
			8,
			4,
		},
	}) do
		local a, b = nodes[pair[1]], nodes[pair[2]]
		local direction = a.X < b.X and "E" or a.X > b.X and "W" or a.Z < b.Z and "S" or "N"
		table.insert(edges, {
			A = a.Id,
			B = b.Id,
			Direction = direction,
			Opposite = directions[direction].Opposite,
			Width = constants.CarryWidth,
			Height = constants.CarryHeight,
		})
	end
	return {
		Seed = seed,
		DimensionId = dimension.DimensionId,
		GenerationVersion = dimension.GenerationVersion,
		Nodes = nodes,
		Edges = edges,
		Entry = 1,
		Extraction = 6,
		MainPath = { 1, 2, 3, 4, 5, 6 },
		MainPathLength = 5 * constants.Step,
	}
end

function Planner.Validate(
	graph: Graph,
	definitions: { [string]: RoomDefinition },
	constants: Config
): (boolean, { string })
	local errors: { string } = {}
	local function check(condition: any, message: string)
		if not condition then
			table.insert(errors, message)
		end
	end
	check(
		#graph.Nodes >= constants.RoomCountMin and #graph.Nodes <= constants.RoomCountMax,
		"Room count outside budget"
	)
	check(graph.Nodes[graph.Entry] and graph.Nodes[graph.Entry].Role == "Entry", "Missing entry")
	check(
		graph.Nodes[graph.Extraction] and graph.Nodes[graph.Extraction].Role == "Extraction",
		"Missing extraction"
	)
	local occupied: { [string]: boolean } = {}
	local adjacency: { [number]: { number } } = {}
	local sockets: { [number]: { [string]: boolean } } = {}
	local landmark = false
	for index, node in ipairs(graph.Nodes) do
		check(node.Id == index, "Room IDs must match graph indices")
		local key = tostring(node.X) .. ":" .. tostring(node.Z)
		check(not occupied[key], "Overlapping room centers")
		occupied[key] = true
		adjacency[index] = {}
		sockets[index] = {}
		local room = definitions[node.TemplateId]
		check(room ~= nil, "Unknown template")
		if room then
			check(room.Role == node.Role, "Template role mismatch")
			check(
				room.Width == constants.RoomSize and room.Depth == constants.RoomSize,
				"Unsupported footprint"
			)
			check(
				room.CarryWidth >= constants.CarryWidth
					and room.CarryHeight >= constants.CarryHeight,
				"Cargo route too small"
			)
			check(node.X % constants.Grid == 0 and node.Z % constants.Grid == 0, "Off-grid room")
			landmark = landmark or room.Role == "Landmark"
		end
	end
	check(landmark, "Missing landmark")
	for i, a in ipairs(graph.Nodes) do
		for j = i + 1, #graph.Nodes do
			local b = graph.Nodes[j]
			check(
				math.abs(a.X - b.X) >= constants.RoomSize
					or math.abs(a.Z - b.Z) >= constants.RoomSize,
				"Overlapping room bounds"
			)
		end
	end
	local seenEdges: { [string]: boolean } = {}
	for _, edge in ipairs(graph.Edges) do
		local a, b = graph.Nodes[edge.A], graph.Nodes[edge.B]
		local direction = directions[edge.Direction]
		local valid = a and b and direction and edge.A ~= edge.B
		check(valid, "Invalid edge")
		if valid then
			local key = tostring(math.min(edge.A, edge.B))
				.. ":"
				.. tostring(math.max(edge.A, edge.B))
			check(not seenEdges[key], "Duplicate edge")
			seenEdges[key] = true
			check(
				b.X - a.X == direction.X * constants.Step
					and b.Z - a.Z == direction.Z * constants.Step,
				"Misaligned sockets"
			)
			check(edge.Opposite == direction.Opposite, "Socket direction mismatch")
			check(
				not sockets[edge.A][edge.Direction] and not sockets[edge.B][edge.Opposite],
				"Socket used twice"
			)
			sockets[edge.A][edge.Direction], sockets[edge.B][edge.Opposite] = true, true
			check(
				edge.Width >= constants.CarryWidth and edge.Height >= constants.CarryHeight,
				"Connector too narrow for cargo"
			)
			table.insert(adjacency[edge.A], edge.B)
			table.insert(adjacency[edge.B], edge.A)
		end
	end
	local visited, queue = { [graph.Entry] = true }, { graph.Entry }
	local cursor = 1
	while cursor <= #queue do
		for _, other in ipairs(adjacency[queue[cursor]] or {}) do
			if not visited[other] then
				visited[other] = true
				table.insert(queue, other)
			end
		end
		cursor += 1
	end
	for index, _ in ipairs(graph.Nodes) do
		check(visited[index], "Unreachable room " .. index)
	end
	check(
		graph.MainPath[1] == graph.Entry and graph.MainPath[#graph.MainPath] == graph.Extraction,
		"Invalid main path endpoints"
	)
	local distance = 0
	for index = 2, #graph.MainPath do
		local a, b = graph.MainPath[index - 1], graph.MainPath[index]
		local linked = false
		for _, other in ipairs(adjacency[a] or {}) do
			linked = linked or other == b
		end
		check(linked, "Broken main path")
		if graph.Nodes[a] and graph.Nodes[b] then
			distance += math.abs(graph.Nodes[a].X - graph.Nodes[b].X) + math.abs(
				graph.Nodes[a].Z - graph.Nodes[b].Z
			)
		end
	end
	check(
		distance == graph.MainPathLength and distance >= 450 and distance <= 900,
		"Invalid traversal length"
	)
	return #errors == 0, errors
end

function Planner.Fingerprint(graph: Graph): string
	local parts = { tostring(graph.Seed), tostring(graph.GenerationVersion), graph.DimensionId }
	for _, node in ipairs(graph.Nodes) do
		table.insert(parts, string.format("%d:%s:%d:%d", node.Id, node.TemplateId, node.X, node.Z))
	end
	for _, edge in ipairs(graph.Edges) do
		table.insert(parts, string.format("%d>%d:%s", edge.A, edge.B, edge.Direction))
	end
	return table.concat(parts, "|")
end
return Planner
