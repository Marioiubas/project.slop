--!strict
-- Future dimensions must bring a rule implementation and their own authored kit.
return {
	GiantsKitchen = {
		DimensionId = "GiantsKitchen",
		DisplayName = "Giant's Kitchen",
		Enabled = true,
		GenerationVersion = 1,
		FantasySentence = "You are tiny in a kitchen of impossible things.",
		CorePhysicalRule = "Scale",
		SecondaryRule = "Awkward cargo (Phase 2)",
		TraversalModifier = "Oversized household terrain",
		PrimaryHazard = "Appliances activating (Phase 2)",
		SecondaryHazards = { "Spills", "Falling utensils" },
		ArtifactBehaviourBias = { "Heavy", "Awkward" },
		MutationBias = { "Golden", "Living" },
		InstabilityBehaviour = "Kitchen comes alive (Phase 2)",
		ExtractionBehaviour = "Visible cyan gateway; guaranteed wide route",
		ColorPalette = {
			Cream = { 246, 225, 185 },
			Wood = { 176, 103, 53 },
			Coral = { 232, 88, 58 },
			Cyan = { 48, 225, 245 },
			Gold = { 255, 196, 50 },
			Ink = { 36, 48, 69 },
		},
		LightingProfile = "Warm countertop / cyan extraction",
		AudioProfile = {}, -- No unlicensed or invented asset IDs.
		RoomSet = {
			"Entry",
			"Countertop",
			"Pantry",
			"Junction",
			"FridgeLandmark",
			"DrawerPassage",
			"Extraction",
		},
		PropSet = { "Mug", "CerealBox", "Plate", "Fridge", "Utensils" },
		CreatureSet = {},
		RarityWeights = {}, -- Spawn/reward system intentionally absent in Phase 1.
		DifficultyRange = { 1, 1 },
		CoopMechanic = "Shared 24-stud cargo lanes; carrying follows in Phase 2",
		SignatureLandmark = "FridgeLandmark",
		SecretRules = {},
	},
}
