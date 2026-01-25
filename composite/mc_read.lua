---@return CompositeData
return function()
	local iN, iB, floats, bools = input.getNumber, input.getBool, {}, {}
	for i = 1, 32 do
		floats[i] = iN(i)
		bools[i] = iB(i)
	end
	return { float_values = floats, bool_values = bools }
end
