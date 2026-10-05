--!strict
--[[
	Run untrusted-to-succeed code (handlers, init/start hooks) without letting an error
	escape, keeping the traceback so the log says *where* it failed.

		local ok, resultOrError = Safe.call(handler, player, ...)
		-- ok == true:  the rest are handler's return values
		-- ok == false: resultOrError is the message plus traceback
]]

local Safe = {}

local function addTraceback(err: unknown): string
	return debug.traceback(tostring(err), 2)
end

function Safe.call(callback: (...any) -> ...any, ...: any): (boolean, ...any)
	return xpcall(callback, addTraceback, ...)
end

return Safe
