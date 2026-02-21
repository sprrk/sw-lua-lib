---@param x number
---@param a number
---@param b number
---@return number
local function clamp(x, a, b)
	return x < a and a or x > b and b or x
end

return clamp
