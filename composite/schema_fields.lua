return {
	---@param index integer The field index
	---@param validators CompositeSchemaFloatFieldValidator[]? Optional validators for the field
	---@return CompositeSchemaFloatField
	FloatField = function(index, validators)
		return { i = index, type = "float_values", validators = validators }
	end,

	---@param index integer The field index
	---@param validators CompositeSchemaBoolFieldValidator[]? Optional validators for the field
	---@return CompositeSchemaBoolField
	BoolField = function(index, validators)
		return { i = index, type = "bool_values", validators = validators }
	end,
}
