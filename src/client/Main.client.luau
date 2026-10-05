--!strict
-- Client entry point: register every Controller, then let Lifecycle boot them in dependency order.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared") :: typeof(ReplicatedStorage.Shared)
local Lifecycle = require(Shared.Lifecycle)

local Controllers = script.Parent.Controllers

local lifecycle = Lifecycle.new("Client")
lifecycle:register(require(Controllers.NetworkController))
lifecycle:register(require(Controllers.DiagnosticsController))
lifecycle:run()
