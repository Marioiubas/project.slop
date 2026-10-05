--!strict
--[[
	Minimal typed signal for in-game events (not a replacement for RemoteEvents).

		local changed = Signal.new() :: Signal.Signal<number, string>
		local connection = changed:Connect(function(count, reason) ... end)
		changed:Fire(3, "picked up")
		connection:Disconnect()

	- Handlers run in their own thread (`task.spawn`), in connection order, so one
	  erroring or yielding handler never affects the others or the firer.
	- Connecting/disconnecting while a Fire is in progress only affects later Fires.
]]

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, handler: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, handler: (T...) -> ()) -> Connection,
	-- Yields until the next Fire, then returns the fired values.
	Wait: (self: Signal<T...>) -> ...any,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	-- DisconnectAll, and make every later Connect/Fire a no-op.
	Destroy: (self: Signal<T...>) -> (),
}

type Record = {
	Connection: Connection,
	Handler: any,
	Once: boolean,
}

local Signal = {}

function Signal.new<T...>(): Signal<T...>
	local records: { Record } = {}
	local destroyed = false

	local function connect(handler: (T...) -> (), once: boolean): Connection
		if destroyed then
			return {
				Connected = false,
				Disconnect = function() end,
			}
		end

		local connection: Connection
		local record: Record
		connection = {
			Connected = true,
			Disconnect = function(self: Connection)
				if not self.Connected then
					return
				end
				self.Connected = false
				local index = table.find(records, record)
				if index then
					table.remove(records, index)
				end
			end,
		}
		record = { Connection = connection, Handler = handler, Once = once }
		table.insert(records, record)
		return connection
	end

	local function disconnectAll()
		for _, record in records do
			record.Connection.Connected = false
		end
		table.clear(records)
	end

	local signal = {} :: Signal<T...>

	function signal.Connect(_self: Signal<T...>, handler: (T...) -> ()): Connection
		return connect(handler, false)
	end

	function signal.Once(_self: Signal<T...>, handler: (T...) -> ()): Connection
		return connect(handler, true)
	end

	function signal.Wait(_self: Signal<T...>): ...any
		local thread = coroutine.running()
		connect(function(...: T...)
			task.spawn(thread, ...)
		end, true)
		return coroutine.yield()
	end

	function signal.Fire(_self: Signal<T...>, ...: T...)
		if destroyed then
			return
		end
		for _, record in table.clone(records) do
			if record.Connection.Connected then
				if record.Once then
					record.Connection:Disconnect()
				end
				task.spawn(record.Handler, ...)
			end
		end
	end

	function signal.DisconnectAll(_self: Signal<T...>)
		disconnectAll()
	end

	function signal.Destroy(_self: Signal<T...>)
		destroyed = true
		disconnectAll()
	end

	return signal
end

return Signal
