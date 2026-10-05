--!strict
-- Server entry point: register every Service, then let Lifecycle boot them in dependency order.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Lifecycle = require(Shared.Lifecycle)

local Services = script.Parent.Services

local lifecycle = Lifecycle.new("Server")
lifecycle:register(require(Services.NetworkService))
lifecycle:register(require(Services.DiagnosticsService))
lifecycle:run()
