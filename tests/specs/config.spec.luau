--!nocheck
return function(t)
	local Config = t.load("ReplicatedStorage.Shared.Config")
	local expect = t.expect

	t.describe("Config", function()
		t.it("is deep-frozen", function()
			expect(table.isfrozen(Config)).toBe(true)
			expect(table.isfrozen(Config.Network)).toBe(true)
			expect(table.isfrozen(Config.Network.DefaultRate)).toBe(true)
		end)

		t.it("refuses runtime mutation at any depth", function()
			expect(function()
				Config.GameName = "Changed"
			end).toThrow()
			expect(function()
				Config.Network.DefaultRate.Burst = 999
			end).toThrow()
		end)

		t.it("has a valid starting log level", function()
			expect(Config.Log.Level).toMatch("^%u%l+$")
			expect(table.find({ "Debug", "Info", "Warn", "Error" }, Config.Log.Level)).toBeTruthy()
		end)

		t.it("has sane network tunables", function()
			expect(Config.Network.DefaultRate.Burst).toBeGreaterThan(0)
			expect(Config.Network.DefaultRate.PerSecond).toBeGreaterThan(0)
			expect(Config.Network.RemotesWaitTimeoutSeconds).toBeGreaterThan(0)
			expect(Config.Network.ViolationLogIntervalSeconds).toBeGreaterThan(0)
			expect(Config.Network.RemotesFolderName).toMatch("^[%a_][%w_]*$")
		end)
	end)
end
