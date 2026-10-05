--!strict
--[[
	Per-key token bucket. Each key (e.g. a player's UserId) gets `Burst` tokens that
	refill at `PerSecond`; a call is allowed only if it can spend a token.

		local limiter = RateLimiter.new({ Burst = 10, PerSecond = 5 })
		if not limiter:tryConsume(player.UserId) then return end

	Call `forget(key)` when the key goes away (PlayerRemoving) so nothing leaks.
	Pure logic: the clock is injectable so tests don't have to wait.
]]

export type Options = {
	Burst: number,
	PerSecond: number,
	-- Monotonic seconds. Defaults to os.clock.
	Clock: (() -> number)?,
}

export type RateLimiter = {
	-- Spends `cost` tokens (default 1) and returns true, or returns false and spends nothing.
	tryConsume: (self: RateLimiter, key: unknown, cost: number?) -> boolean,
	forget: (self: RateLimiter, key: unknown) -> (),
	clear: (self: RateLimiter) -> (),
}

type Bucket = {
	Tokens: number,
	LastRefill: number,
}

local RateLimiter = {}

function RateLimiter.new(options: Options): RateLimiter
	assert(options.Burst >= 1, "RateLimiter: Burst must be at least 1")
	assert(options.PerSecond > 0, "RateLimiter: PerSecond must be positive")

	local burst = options.Burst
	local perSecond = options.PerSecond
	local clock = options.Clock or os.clock
	local buckets: { [any]: Bucket } = {}

	local limiter = {} :: RateLimiter

	function limiter.tryConsume(_self: RateLimiter, key: unknown, cost: number?): boolean
		local amount = cost or 1
		local now = clock()
		local bucket = buckets[key]
		if bucket == nil then
			bucket = { Tokens = burst, LastRefill = now }
			buckets[key] = bucket
		else
			-- max(0, ...) keeps a clock that steps backwards from refunding or draining tokens.
			local elapsed = math.max(0, now - bucket.LastRefill)
			bucket.Tokens = math.min(burst, bucket.Tokens + elapsed * perSecond)
			bucket.LastRefill = now
		end

		if bucket.Tokens < amount then
			return false
		end
		bucket.Tokens -= amount
		return true
	end

	function limiter.forget(_self: RateLimiter, key: unknown)
		buckets[key] = nil
	end

	function limiter.clear(_self: RateLimiter)
		table.clear(buckets)
	end

	return limiter
end

return RateLimiter
