---@param index integer The field index
---@param validators CompositeSchemaBoolFieldValidator[]? Optional validators for the field
---@return CompositeSchemaBoolField
return function(index, validators)
	return { i = index, type = "bool_values", validators = validators }
end
