--!strict
-- Phase 1 budgets. Structural values use the eight-stud kit grid.
return table.freeze({
	Version = "0.1.0",
	GenerationVersion = 1,
	Grid = 8,
	RoomSize = 96,
	ConnectorLength = 32,
	Step = 128,
	CarryWidth = 24,
	CarryHeight = 24,
	RoomCountMin = 5,
	RoomCountMax = 10,
	MaxPartsPerRoom = 100,
	MaxPartsPerRift = 1000,
	ReadyLifetime = 90,
	RunLifetime = 240,
	TransitionTimeout = 10,
	MaxOccupants = 4,
	Cells = {
		{ Id = "A", X = 1536, Z = 0 },
		{ Id = "B", X = -1536, Z = 0 },
		{ Id = "C", X = 0, Z = 1536 },
		{ Id = "D", X = 0, Z = -1536 },
	},
})
