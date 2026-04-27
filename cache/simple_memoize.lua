---@generic T: integer|number|string|boolean|table|function, K: integer|number|string|boolean
---@param func fun(arg: K): T
---@return fun(arg: K): T
local function memoize(func)
	local cache = {}

	return function(arg)
		local hit = cache[arg]

		if hit ~= nil then
			return hit
		end

		local result = func(arg)
		cache[arg] = result

		return result
	end
end

return memoize
