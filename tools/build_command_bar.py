#!/usr/bin/env python3
"""Bundle auditable Luau sources into one offline Roblox Studio Command Bar installer."""
from pathlib import Path
import argparse
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
MODULES = {
    "shared": ["Constants", "DimensionDefinitions", "RoomDefinitions", "GraphPlanner"],
    "server": ["RiftCellAllocator", "WorldBuilder", "RiftGenerator", "RiftService", "DebugService"],
}


def literal(text):
    equals = "="
    while "]" + equals + "]" in text:
        equals += "="
    return "[" + equals + "[\n" + text + "]" + equals + "]"


def sources():
    files = {f"{group}/{name}": ROOT / "src/world" / group / f"{name}.lua" for group, names in MODULES.items() for name in names}
    files["Bootstrap"] = ROOT / "src/world/server/Bootstrap.server.lua"
    files["Client"] = ROOT / "src/world/client/WorldClient.client.lua"
    return {key: path.read_text() for key, path in files.items()}


INSTALLER = r'''
local RunService = game:GetService("RunService")
assert(RunService:IsStudio() and not RunService:IsRunning(), "Paste this installer in Studio's Command Bar in EDIT mode, with Play stopped.")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local roots = {
    { Parent = ReplicatedStorage, Name = "OddvaultShared" },
    { Parent = ServerScriptService, Name = "OddvaultServer" },
    { Parent = ServerStorage, Name = "OddvaultTemplates" },
    { Parent = workspace, Name = "OddvaultWorld" },
    { Parent = StarterPlayer.StarterPlayerScripts, Name = "OddvaultClient" },
}
for _, root in ipairs(roots) do
    local existing = root.Parent:FindFirstChild(root.Name)
    assert(not existing or existing:GetAttribute("OddvaultOwned") == true, "Name conflict with unowned content: " .. root.Name)
end
local existingBackups = ServerStorage:FindFirstChild("OddvaultBackups")
assert(not existingBackups or existingBackups:GetAttribute("OddvaultOwned") == true, "Foreign OddvaultBackups folder")
local staging = Instance.new("Folder")
staging.Name = "OddvaultStaging_" .. HttpService:GenerateGUID(false)
staging.Parent = ServerStorage
local function owned(class, name)
    local object = Instance.new(class)
    object.Name, object.Parent = name, staging
    object:SetAttribute("OddvaultOwned", true)
    object:SetAttribute("Version", "0.1.0")
    return object
end
local function source(class, name, text, parent)
    local object = Instance.new(class)
    object.Name = name
    if object:IsA("BaseScript") then object.Enabled = false end
    object.Source, object.Parent = text, parent
    return object
end
local ok, result = pcall(function()
    local shared, server = owned("Folder", "OddvaultShared"), owned("Folder", "OddvaultServer")
    local templates, world = owned("Folder", "OddvaultTemplates"), owned("Model", "OddvaultWorld")
    local client = source("LocalScript", "OddvaultClient", SOURCES.Client, staging)
    client:SetAttribute("OddvaultOwned", true)
    client:SetAttribute("Version", "0.1.0")
    local sharedRef = Instance.new("ObjectValue")
    sharedRef.Name, sharedRef.Value, sharedRef.Parent = "SharedRef", shared, server
    for key, text in pairs(SOURCES) do
        local group, name = string.match(key, "^(%w+)/(.+)$")
        if group then source("ModuleScript", name, text, group == "shared" and shared or server) end
    end
    local remotes = Instance.new("Folder")
    remotes.Name, remotes.Parent = "Remotes", shared
    for _, name in ipairs({ "Transition", "TransitionDone", "StreamReady", "Notice" }) do
        local remote = Instance.new("RemoteEvent")
        remote.Name, remote.Parent = name, remotes
    end
    local bootstrap = source("Script", "Bootstrap", SOURCES.Bootstrap, server)
    local builder, generator = require(server.WorldBuilder), require(server.RiftGenerator)
    local rooms, dimensions, constants = require(shared.RoomDefinitions), require(shared.DimensionDefinitions), require(shared.Constants)
    builder.Templates(templates, rooms, dimensions.GiantsKitchen)
    for _, room in ipairs(templates.GiantsKitchen.Rooms:GetChildren()) do generator.ValidateTemplate(room, rooms[room:GetAttribute("RoomId")]) end
    builder.Hub(world)
    if OPTIONS.CreatePreview then
        local preview = generator.Generate(templates, world.RiftRuntime, {
            RiftId = "Preview_12345", DimensionId = "GiantsKitchen", Seed = 12345, Difficulty = 1,
            PartyId = "Preview", CellId = "A", Origin = Vector3.new(constants.Cells[1].X, 0, constants.Cells[1].Z),
        })
        preview.Model:SetAttribute("Preview", true)
        if OPTIONS.DebugPreview then require(server.DebugService).Visualize(preview, true) end
    end
    return { shared, server, templates, world, client, Bootstrap = bootstrap }
end)
if not ok then staging:Destroy(); error("Oddvault installation rejected; previous content was preserved: " .. tostring(result), 0) end

-- All authored kit validation is complete before replacing an owned installation.
ChangeHistoryService:SetWaypoint("Before Oddvault installation")
local backups = existingBackups
if not backups then
    backups = Instance.new("Folder")
    backups.Name, backups.Parent = "OddvaultBackups", ServerStorage
    backups:SetAttribute("OddvaultOwned", true)
end
local backup
for index, root in ipairs(roots) do
    local existing = root.Parent:FindFirstChild(root.Name)
    if existing then
        if not backup then
            backup = Instance.new("Folder")
            backup.Name = "Installation_" .. os.date("!%Y%m%d_%H%M%S") .. "_" .. HttpService:GenerateGUID(false)
            backup.Parent = backups
        end
        existing.Parent = backup
    end
    result[index].Parent = root.Parent
end
result.Bootstrap.Enabled, result[5].Enabled = true, true
staging:Destroy()
if OPTIONS.SetStreaming then
    local configured, reason = pcall(function()
        workspace.StreamingEnabled = true
        workspace.StreamingMinRadius = 64
        workspace.StreamingTargetRadius = 384
    end)
    if not configured then warn("[Oddvault] Set Workspace StreamingEnabled=true, StreamingMinRadius=64 and StreamingTargetRadius=384 in Properties:", reason) end
end
if workspace.CurrentCamera then workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(82, 64, -128), Vector3.new(0, 12, -8)) end
ChangeHistoryService:SetWaypoint("Oddvault installed")
print("[Oddvault] Installed Phase 1: seven templates, seeded preview, four isolated cells and server-owned portal routes. Press Play.")
if backup then print("[Oddvault] Previous installation preserved in ServerStorage/OddvaultBackups/" .. backup.Name) end
'''


def build():
    contents = sources()
    payload = "-- GENERATED by tools/build_command_bar.py. Paste the ENTIRE file in Studio's Command Bar in Edit mode.\n"
    payload += "-- Offline installer: no HTTP, loadstring, plugins or imported asset IDs.\n"
    payload += "local OPTIONS = { CreatePreview = true, DebugPreview = true, SetStreaming = true }\nlocal SOURCES = {\n"
    payload += "".join(f"    [{json.dumps(key)}] = {literal(value)},\n" for key, value in sorted(contents.items()))
    payload += "}\n" + INSTALLER
    manifest = {"version": "0.1.0", "sources": {key: hashlib.sha256(value.encode()).hexdigest() for key, value in sorted(contents.items())}, "installer_sha256": hashlib.sha256(payload.encode()).hexdigest()}
    return payload, json.dumps(manifest, indent=2) + "\n"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Fail if checked-in distribution differs from source")
    args = parser.parse_args()
    payload, manifest = build()
    directory = ROOT / "dist"
    if args.check:
        assert (directory / "OddvaultCommandBar.lua").read_text() == payload, "Stale Command Bar bundle"
        assert (directory / "manifest.json").read_text() == manifest, "Stale manifest"
        print("Command Bar distribution matches all source files.")
    else:
        directory.mkdir(exist_ok=True)
        (directory / "OddvaultCommandBar.lua").write_text(payload)
        (directory / "manifest.json").write_text(manifest)
        print(f"Built {len(payload.encode()):,} bytes from {len(sources())} Luau sources.")
