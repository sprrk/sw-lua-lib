---@param minValue number
---@return CompositeSchemaFloatFieldValidator
return function(minValue)
	return function(value)
		if value < minValue then
			return minValue
		else
			return value
		end
	end
end
