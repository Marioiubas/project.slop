--!nocheck
return function(t)
	local Signal = t.load("ReplicatedStorage.Shared.Signal")
	local expect = t.expect

	t.describe("Signal", function()
		t.it("passes fired values to handlers", function()
			local signal = Signal.new()
			local received
			signal:Connect(function(...)
				received = { ... }
			end)
			signal:Fire(1, "two", true)
			expect(received).toEqual({ 1, "two", true })
		end)

		t.it("calls handlers in connection order", function()
			local signal = Signal.new()
			local order = {}
			signal:Connect(function()
				table.insert(order, "a")
			end)
			signal:Connect(function()
				table.insert(order, "b")
			end)
			signal:Fire()
			expect(order).toEqual({ "a", "b" })
		end)

		t.it("stops calling a handler once its connection is disconnected", function()
			local signal = Signal.new()
			local calls = 0
			local connection = signal:Connect(function()
				calls += 1
			end)
			signal:Fire()
			connection:Disconnect()
			signal:Fire()
			expect(calls).toBe(1)
			expect(connection.Connected).toBe(false)
		end)

		t.it("tolerates disconnecting twice", function()
			local signal = Signal.new()
			local connection = signal:Connect(function() end)
			connection:Disconnect()
			expect(function()
				connection:Disconnect()
			end).never.toThrow()
		end)

		t.it("Once fires a single time", function()
			local signal = Signal.new()
			local calls = 0
			signal:Once(function()
				calls += 1
			end)
			signal:Fire()
			signal:Fire()
			expect(calls).toBe(1)
		end)

		t.it("a handler that errors does not stop the others or the firer", function()
			local signal = Signal.new()
			local reached = false
			signal:Connect(function()
				error("handler failure")
			end)
			signal:Connect(function()
				reached = true
			end)
			-- task.spawn reports the error (as a warning here) without throwing it at Fire.
			local reports = t.captureWarnings(function()
				expect(function()
					signal:Fire()
				end).never.toThrow()
			end)
			expect(reached).toBe(true)
			expect(reports).toHaveLength(1)
			expect(reports[1]).toContain("handler failure")
		end)

		t.it("a handler connected during Fire only hears later Fires", function()
			local signal = Signal.new()
			local lateCalls = 0
			signal:Once(function()
				signal:Connect(function()
					lateCalls += 1
				end)
			end)
			signal:Fire()
			expect(lateCalls).toBe(0)
			signal:Fire()
			expect(lateCalls).toBe(1)
		end)

		t.it("a handler disconnected during Fire is not called later in that Fire", function()
			local signal = Signal.new()
			local secondCalled = false
			local second
			signal:Connect(function()
				second:Disconnect()
			end)
			second = signal:Connect(function()
				secondCalled = true
			end)
			signal:Fire()
			expect(secondCalled).toBe(false)
		end)

		t.it("Wait yields until the next Fire and returns its values", function()
			local signal = Signal.new()
			local got
			t.spawn(function()
				got = { signal:Wait() }
			end)
			expect(got).toBeNil()
			signal:Fire("x", 2)
			expect(got).toEqual({ "x", 2 })
		end)

		t.it("DisconnectAll removes every handler but the signal stays usable", function()
			local signal = Signal.new()
			local calls = 0
			local connection = signal:Connect(function()
				calls += 1
			end)
			signal:DisconnectAll()
			signal:Fire()
			expect(calls).toBe(0)
			expect(connection.Connected).toBe(false)
			signal:Connect(function()
				calls += 1
			end)
			signal:Fire()
			expect(calls).toBe(1)
		end)

		t.it("Destroy makes later Connect and Fire inert", function()
			local signal = Signal.new()
			local calls = 0
			signal:Destroy()
			local connection = signal:Connect(function()
				calls += 1
			end)
			signal:Fire()
			expect(calls).toBe(0)
			expect(connection.Connected).toBe(false)
		end)
	end)
end
