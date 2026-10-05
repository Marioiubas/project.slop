--!strict
--[[
	Tagged, levelled logging.

		local log = Log.new("NetworkService")
		log:info("published %d remotes", count)

	`warn` and `error` both print through `warn` so they never throw; use `error()`
	yourself when you actually want to stop execution.
	Tests (and future telemetry) can redirect output with `Log.setSink`.
]]

local Config = require(script.Parent.Config)
local Types = require(script.Parent.Types)

type LogLevel = Types.LogLevel
export type Sink = (level: LogLevel, tag: string, message: string) -> ()

export type Logger = {
	debug: (self: Logger, message: string, ...any) -> (),
	info: (self: Logger, message: string, ...any) -> (),
	warn: (self: Logger, message: string, ...any) -> (),
	error: (self: Logger, message: string, ...any) -> (),
}

local SEVERITY: { [LogLevel]: number } = {
	Debug = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
}

local function defaultSink(level: LogLevel, tag: string, message: string)
	local line = string.format("[%s] %s", tag, message)
	if level == "Warn" or level == "Error" then
		warn(string.format("[%s]%s", string.upper(level), line))
	else
		print(line)
	end
end

local currentLevel: LogLevel = Config.Log.Level :: LogLevel
local currentSink: Sink = defaultSink

local Log = {}

function Log.setLevel(level: LogLevel)
	assert(SEVERITY[level] ~= nil, "Log.setLevel: unknown level " .. tostring(level))
	currentLevel = level
end

function Log.getLevel(): LogLevel
	return currentLevel
end

-- Pass nil to restore the default (print/warn) sink.
function Log.setSink(sink: Sink?)
	currentSink = sink or defaultSink
end

local function emit(level: LogLevel, tag: string, message: string, ...: any)
	if SEVERITY[level] < SEVERITY[currentLevel] then
		return
	end
	if select("#", ...) > 0 then
		-- A bad format string must never take down the caller.
		local ok, formatted = pcall(string.format, message, ...)
		message = if ok then formatted else message
	end
	currentSink(level, tag, message)
end

function Log.new(tag: string): Logger
	local logger = {} :: Logger
	function logger.debug(_self: Logger, message: string, ...: any)
		emit("Debug", tag, message, ...)
	end
	function logger.info(_self: Logger, message: string, ...: any)
		emit("Info", tag, message, ...)
	end
	function logger.warn(_self: Logger, message: string, ...: any)
		emit("Warn", tag, message, ...)
	end
	function logger.error(_self: Logger, message: string, ...: any)
		emit("Error", tag, message, ...)
	end
	return logger
end

return Log
