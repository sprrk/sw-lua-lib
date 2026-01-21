---@enum FIFOQueueError
local FIFOQueueErrors = {
	MAX_SIZE_EXCEEDED = 1,
}

---@generic T
---@param bits integer Queue will hold 2^bits items
---@return FIFOQueue<T>
local function FIFOQueue(bits)
	-- Usage:
	-- ---@type FIFOQueue<string>
	-- local queue = FIFOQueue(4)
	-- queue:add("foo")
	-- local value = queue:pop()

	if bits <= 0 or bits > 20 then
		-- Clamp to sane bit sizes; 2^20=1048576 and should be plenty
		error()
	end
	local maxSize = 2 ^ bits
	local head = 1
	local tail = 1
	local size = 0
	local hasItems = false
	local queue = {}

	---@class FIFOQueue<T>
	---@field public currentSize integer The current size of the queue
	local instance = {
		currentSize = 0,
	}

	---@param item T
	---@return boolean|nil,FIFOQueueError|nil
	function instance:add(item)
		if size >= maxSize then
			return nil, FIFOQueueErrors.MAX_SIZE_EXCEEDED
		end

		queue[tail] = item
		tail = (tail % maxSize) + 1
		size = size + 1
		self.currentSize = size
		hasItems = true
		return true
	end

	---@return T|nil item
	function instance:pop()
		if size <= 0 then
			return nil
		end

		local idx = head
		local item = queue[idx]
		queue[idx] = nil
		head = (idx % maxSize) + 1
		size = size - 1
		self.currentSize = size

		-- Clear the queue to release memory when idle
		if hasItems and size == 0 then
			queue = {}
			head = 1
			tail = 1
			hasItems = false
		end

		return item
	end

	---@return nil
	function instance:clear()
		if hasItems then
			queue = {}
			head = 1
			tail = 1
			size = 0
			self.currentSize = 0
			hasItems = false
		end
	end

	return instance
end

return { FIFOQueue = FIFOQueue, FIFOQueueErrors = FIFOQueueErrors }
