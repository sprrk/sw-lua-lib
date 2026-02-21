---@param value number
---@param resolution number
---@return number
local function snap(value, resolution)
	if value >= 0 then
		return math.floor(value / resolution + 0.5) * resolution
	else
		return math.ceil(value / resolution - 0.5) * resolution
	end
end

return snap
