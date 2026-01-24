return {
	minFloat =
		---@param minValue number
		---@return CompositeSchemaFloatFieldValidator
		function(minValue)
			return function(value)
				if value < minValue then
					return minValue
				else
					return value
				end
			end
		end,
	maxFloat =
		---@param maxValue number
		---@return CompositeSchemaFloatFieldValidator
		function(maxValue)
			return function(value)
				if value > maxValue then
					return maxValue
				else
					return value
				end
			end
		end,
}
