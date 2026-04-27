--- SIEVE cache, based on the following:
--- https://www.usenix.org/conference/nsdi24/presentation/zhang-yazhuo
--- https://sieve-cache.com/

---@param size integer Max. size of the cache
---@return SieveCache
local function SieveCache(size)
	-- Pre-allocated fixed dense arrays
	local keys = {} ---@type (string|number|false)[]
	local values = {} ---@type any[]
	local visited = {} ---@type integer[] 0 or 1
	local nextSlot = {} ---@type integer[] Next toward head (newer entries, 0 = none)
	local prevSlot = {} ---@type integer[] Prev toward tail (older entries, 0 = none)

	-- Initialize free list
	for i = 1, size do
		keys[i] = false
		values[i] = false
		visited[i] = 0
		nextSlot[i] = i + 1
		prevSlot[i] = i - 1
	end
	nextSlot[size] = 0
	prevSlot[1] = 0

	-- State
	local lookup = {} ---@type table<string|number, integer> key -> slot
	local head = 0 -- Newest entry in FIFO queue
	local tail = 0 -- Oldest entry in FIFO queue
	local hand = 0 -- Eviction scan position
	local freeHead = 1 -- First available slot
	local count = 0 -- Current occupancy

	---@return integer slot Index of allocated slot, or 0 if none available
	--- Allocate a slot from the free list
	local function allocSlot()
		if freeHead == 0 then
			return 0
		end
		local slot = freeHead
		freeHead = nextSlot[slot]
		if freeHead ~= 0 then
			prevSlot[freeHead] = 0
		end
		return slot
	end

	---@param slot integer Index of slot to free
	--- Return a slot to the free list
	local function freeSlot(slot)
		keys[slot] = false
		values[slot] = false
		visited[slot] = 0
		nextSlot[slot] = freeHead
		if freeHead ~= 0 then
			prevSlot[freeHead] = slot
		end
		prevSlot[slot] = 0
		freeHead = slot
	end

	---@param slot integer Index of slot to unlink
	--- Unlink a slot from the FIFO queue
	local function unlinkFIFO(slot)
		local p = prevSlot[slot]
		local n = nextSlot[slot]
		if p ~= 0 then
			nextSlot[p] = n
		else
			head = n
		end
		if n ~= 0 then
			prevSlot[n] = p
		else
			tail = p
		end
	end

	---@param slot integer Index of slot to insert
	--- Insert a slot at the head of the FIFO queue (newest position)
	local function insertAtHead(slot)
		nextSlot[slot] = head
		prevSlot[slot] = 0
		if head ~= 0 then
			prevSlot[head] = slot
		end
		head = slot
		if tail == 0 then
			tail = slot
		end
	end

	--- SIEVE eviction: hand scans from tail toward head, clearing visited bits.
	--- Evicts the first unvisited entry found, or tail if all visited.
	local function evict()
		-- Lazy hand initialization: start at tail (oldest)
		local candidate = hand
		if candidate == 0 then
			candidate = tail
		end

		-- Scan toward head (older to newer; tail to head), clearing visited bits
		while candidate ~= 0 and visited[candidate] == 1 do
			visited[candidate] = 0
			candidate = nextSlot[candidate] -- move toward head (newer)
		end

		-- If all entries were visited, evict tail (oldest)
		if candidate == 0 then
			candidate = tail
		end

		-- Update hand to predecessor of evicted node (older direction)
		hand = prevSlot[candidate]

		-- Remove from structures
		lookup[keys[candidate]] = nil
		unlinkFIFO(candidate)
		freeSlot(candidate)
		count = count - 1
	end

	---@class SieveCache
	local instance = {}

	---@param key string|number
	---@param value any
	--- Store or update a key-value pair
	function instance:set(key, value)
		if value == nil then
			error("nil value not allowed in cache")
		end

		-- Update existing entry: lazy promotion (mark visited, stay in place)
		local slot = lookup[key]
		if slot ~= nil then
			values[slot] = value
			visited[slot] = 1
			return
		end

		-- Evict if at capacity
		if count >= size then
			evict()
		end

		-- Allocate and populate new slot (slot guaranteed non-zero after eviction)
		slot = allocSlot()

		keys[slot] = key
		values[slot] = value
		visited[slot] = 0 -- new entries start unvisited
		lookup[key] = slot

		insertAtHead(slot) -- FIFO order: newest at head
		count = count + 1
	end

	---@param key string|number
	---@return any|nil value The cached value, or nil if not found
	---@return boolean found True if key exists in cache
	--- Retrieve a value by key
	function instance:get(key)
		local slot = lookup[key]
		if slot == nil then
			return nil, false
		end

		-- SIEVE: Set the visited bit
		visited[slot] = 1

		return values[slot], true
	end

	--- Clear all entries from the cache
	function instance:clear()
		-- Clear hash map
		for k, _ in pairs(lookup) do
			lookup[k] = nil
		end

		-- Rebuild free list from all slots
		for i = 1, size do
			keys[i] = false
			values[i] = false
			visited[i] = 0
			nextSlot[i] = i + 1
			prevSlot[i] = i - 1
		end
		nextSlot[size] = 0
		prevSlot[1] = 0

		-- Reset state
		head = 0
		tail = 0
		hand = 0
		freeHead = 1
		count = 0
	end

	return instance
end

return SieveCache
