---@param a number
---@param b number
---@param t number
---@return number
local function lerp(a, b, t)
	return a + (b - a) * t
end

return lerp
