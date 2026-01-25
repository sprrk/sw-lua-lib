---@param data CompositeData|CompositeDataPartial
---@return nil
return function(data)
	local sN, sB, floats, bools = output.setNumber, output.setBool, data.float_values, data.bool_values
	for i = 1, 32 do
		sN(i, floats[i] or 0)
		sB(i, bools[i] or false)
	end
end
