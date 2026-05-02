---@generic T
---@param tickInterval integer
---@param callback fun(): T
---@return fun(): T|nil
--- Simple callback timer. Usage example:
--- local timer = createCallbackTimer(10, function() return doSomething() end)
--- function onTick()
---   timer()
--- end
---
local function createCallbackTimer(tickInterval, callback)
	local counter = 0

	return function()
		counter = counter + 1
		if counter >= tickInterval then
			counter = 0
			return callback()
		end
	end
end

return createCallbackTimer
