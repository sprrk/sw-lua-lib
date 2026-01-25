local FIFOQueue = require("../queue/fifo_queue").FIFOQueue

---@alias CompositePublisherWriteFunc fun(data: CompositeData|CompositeDataPartial): any

---@param writeFunc CompositePublisherWriteFunc
---@param queueSizeBits integer Queues will hold 2^bits items
---@return CompositePublisher
---
--- Example usage:
---
--- -- Define a writer function:
--- ---@type CompositePublisherWriteFunc
--- local write = function(data)
--- 	output.setNumber(1, data.float_values[1])
--- 	output.setNumber(2, data.float_values[2])
--- 	--- etc.
--- end
---
--- -- Create the publisher with our writer function:
--- local publisher = CompositePublisher(write, 10) -- 2^10=1024 items per queue
--- -- Note: Keep the queue size as low as possible for proper memory usage
---
--- -- Add a composite item to the low-prio queue:
--- ---@type CompositeDataPartial
--- local data = { float_values = { [1] = 42, [2] = 1.53 }, bool_values = {} }
--- publisher:add(data, 3)
---
--- -- Run the publisher so that it writes to its output:
--- publisher:tick()
---
local function CompositePublisher(writeFunc, queueSizeBits)
	---@class CompositePublisher
	local instance = {}

	local EMPTY = { float_values = {}, bool_values = {} }
	for i = 1, 32 do
		EMPTY.float_values[i] = 0
		EMPTY.bool_values[i] = false
	end
	---@cast EMPTY +CompositeData

	local queueHi = FIFOQueue(queueSizeBits)
	local queueMid = FIFOQueue(queueSizeBits)
	local queueLo = FIFOQueue(queueSizeBits)
	local prios = { queueHi, queueMid, queueLo }
	local active = false

	---@param data CompositeData|CompositeDataPartial
	---@param prio 1|2|3
	---@return boolean|nil,FIFOQueueError|nil
	function instance:add(data, prio)
		return prios[prio]:add(data)
	end

	---@return nil
	function instance:tick()
		local data = queueHi:pop() or queueMid:pop() or queueLo:pop()

		if data then
			writeFunc(data)
			active = true
		else
			if active then
				-- Clear the composite output once, to prevent the last data from staying up
				writeFunc(EMPTY)
				active = false
			end
		end
	end

	return instance
end

return CompositePublisher
