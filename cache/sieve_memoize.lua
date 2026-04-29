local m = {}

---@alias MemoizeKey integer|number|string|boolean
---@alias MemoizableFunc<T_Arg,T_Output> fun(arg: T_Arg): T_Output

---@generic T_Payload
---@class (exact) MemoizeWrappedPayload<T_Payload>
---@field key MemoizeKey Cache key, preferably based on table contents
---@field payload T_Payload Wrapped payload

---@generic T_Payload
---@param key MemoizeKey
---@param payload T_Payload
---@return MemoizeWrappedPayload<T_Payload>
function m.wrapPayload(key, payload)
	return { key = key, payload = payload }
end

---@generic T_Arg: MemoizeKey, T_Output
---@param func MemoizableFunc<T_Arg,T_Output> The function to memoize
---@param cacheSize integer The cache size, must be > 0
---@return fun(arg: MemoizeWrappedPayload): T_Output
---@overload fun(func: MemoizableFunc<T_Arg,T_Output>, cacheSize: integer): fun(arg: T_Arg): T_Output
--- Memoization based on the SIEVE algorithm.
--- Optimized for Lua 5.4.
---
--- Usage example:
---
--- local foo = memoize(
--- 	---@param v integer
--- 	function(v)
--- 		print("miss")
--- 		return v * 2
--- 	end,
--- 	32
--- )
---
--- foo(3) -- prints "miss"
--- foo(3) -- no print
---
--- ---@class BarPayload
--- ---@field fuzz string
---
--- local bar = memoize(
--- 	---@param v BarPayload
--- 	function(v)
--- 		print("miss")
--- 		return v.fuzz
--- 	end,
--- 	32
--- )
---
--- local wrappedPayload = wrapPayload("custom_key", { test = "test!" })
--- bar(wrappedPayload) -- prints "miss"
--- bar(wrappedPayload) -- no print
---
function m.memoize(func, cacheSize)
	local cache = {} -- key -> index in ring buffer (1..cacheSize)
	local values = {} -- index -> cached value
	local visited = {} -- index -> boolean (SIEVE mark bit)
	local keyAt = {} -- index -> key (reverse mapping for eviction)
	local hand = 0 -- current position in ring buffer
	local size = 0 -- current occupancy (0..cacheSize)

	if cacheSize < 1 then
		error("invalid cache size")
	end

	---@return integer slot Slot index for immediate reuse
	--- Advance hand, clear visited bits, evict first unvisited.
	local function evictOne()
		local handLocal = hand -- Hoisted for efficiency
		local start = handLocal

		repeat
			handLocal = handLocal + 1
			if handLocal > cacheSize then -- Wrap manually, because modulo is more expensive in Lua 5.4
				handLocal = 1
			end

			local victimKey = keyAt[handLocal]
			if victimKey then
				if not visited[handLocal] then
					-- Cold item; evict it
					cache[victimKey] = nil
					values[handLocal] = nil
					keyAt[handLocal] = nil
					hand = handLocal
					return handLocal
				end
				-- Hot item; clear visited, keep for next round
				visited[handLocal] = false
			else
				-- Empty slot; use it
				hand = handLocal
				return handLocal
			end
		until handLocal == start

		-- Full circle, all visited; evict at hand
		local victimKey = keyAt[handLocal]
		cache[victimKey] = nil
		values[handLocal] = nil
		keyAt[handLocal] = nil
		hand = handLocal
		return handLocal
	end

	return function(arg)
		local key, val
		if type(arg) ~= "table" then
			-- Hotter path, primitive keys are more common
			key = arg
			val = arg
		else
			-- We'll assume we've got a properly wrapped payload
			key = arg.key
			val = arg.payload
		end

		-- Fast path: hash lookup, mark visited on hit
		local idx = cache[key]
		if idx then
			visited[idx] = true
			return values[idx]
		end

		-- Miss path: acquire slot
		local slot

		if size < cacheSize then
			size = size + 1
			slot = size -- Next free index
		else
			-- Cache is full; evict and get the free slot
			slot = evictOne()
		end

		-- Store new entry
		local result = func(val)

		keyAt[slot] = key
		cache[key] = slot
		values[slot] = result
		visited[slot] = true -- New item starts protected

		return result
	end
end

return m
