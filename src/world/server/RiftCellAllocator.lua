--!strict
local Allocator = {}
Allocator.__index = Allocator
export type Cell = { Id: string, X: number, Z: number }
export type Lease = { CellId: string, RiftId: string, Token: number, X: number, Z: number }
type State = { Cells: { Cell }, Leases: { [string]: Lease }, Serial: number }
export type CellAllocator = typeof(setmetatable({} :: State, Allocator))

function Allocator.new(cells: { Cell }): CellAllocator
	local copy: { Cell } = {}
	local ids: { [string]: boolean } = {}
	for _, cell in ipairs(cells) do
		assert(not ids[cell.Id], "Duplicate cell ID")
		ids[cell.Id] = true
		table.insert(copy, { Id = cell.Id, X = cell.X, Z = cell.Z })
	end
	return setmetatable({ Cells = copy, Leases = {}, Serial = 0 }, Allocator)
end

function Allocator.Reserve(self: CellAllocator, riftId: string): (Lease?, string?)
	assert(type(riftId) == "string" and #riftId > 0, "Invalid RiftId")
	for _, lease in pairs(self.Leases) do
		if lease.RiftId == riftId then
			return nil, "Rift already reserved"
		end
	end
	for _, cell in ipairs(self.Cells) do
		if not self.Leases[cell.Id] then
			self.Serial += 1
			local lease =
				{ CellId = cell.Id, RiftId = riftId, Token = self.Serial, X = cell.X, Z = cell.Z }
			self.Leases[cell.Id] = lease
			return table.clone(lease), nil
		end
	end
	return nil, "All Rift cells are occupied"
end

function Allocator.Release(self: CellAllocator, lease: Lease?): boolean
	if not lease then
		return false
	end
	local current = self.Leases[lease.CellId]
	if not current or current.Token ~= lease.Token or current.RiftId ~= lease.RiftId then
		return false
	end
	self.Leases[lease.CellId] = nil
	return true
end

function Allocator.Count(self: CellAllocator): number
	local count = 0
	for _ in pairs(self.Leases) do
		count += 1
	end
	return count
end
return Allocator
