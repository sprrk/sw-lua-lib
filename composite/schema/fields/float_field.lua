---@param index integer The field index
---@param validators CompositeSchemaFloatFieldValidator[]? Optional validators for the field
---@return CompositeSchemaFloatField
return function(index, validators)
	return { i = index, type = "float_values", validators = validators }
end
