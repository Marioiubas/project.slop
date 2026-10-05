--!strict
local rooms = {}
for _, definition in ipairs({
	{ "Entry", "Entry", "THE COUNTERTOP", "Portal" },
	{ "Countertop", "Explore", "MUG CROSSING", "Mug" },
	{ "Pantry", "Explore", "FORBIDDEN PANTRY", "CerealBox" },
	{ "Junction", "Junction", "ONE MORE ROOM?", "Plate" },
	{ "FridgeLandmark", "Landmark", "THE WATCHFUL FRIDGE", "Fridge" },
	{ "DrawerPassage", "Explore", "CUTLERY DRAWER", "Utensils" },
	{ "Extraction", "Extraction", "GET IT HOME", "Portal" },
}) do
	rooms[definition[1]] = {
		RoomId = definition[1],
		Role = definition[2],
		Label = definition[3],
		Prop = definition[4],
		Width = 96,
		Depth = 96,
		Height = 64,
		CarryWidth = 24,
		CarryHeight = 24,
		KitVersion = 1,
	}
end
return rooms
