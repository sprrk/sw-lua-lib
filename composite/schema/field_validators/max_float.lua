---@param maxValue number
---@return CompositeSchemaFloatFieldValidator
return function(maxValue)
	return function(value)
		if value > maxValue then
			return maxValue
		else
			return value
		end
	end
end
