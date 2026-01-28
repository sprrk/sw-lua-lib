---@alias CompositeSchemaFieldMapping [ integer[], string[], `float_values`|`bool_values`, ((fun(value: number): number)[]), integer ]

---@param fields (CompositeSchemaFloatField|CompositeSchemaBoolField)[]
---@return CompositeSchemaFieldMapping
---@nodiscard
local function _mapFields(fields)
	local indices, names, types, actions = {}, {}, {}, {}
	for name, field in pairs(fields) do
		indices[#indices + 1] = field.i
		names[#names + 1] = name
		types[#types + 1] = field.type
		actions[#actions + 1] = field.validators
				and next(field.validators)
				and function(v)
					for _, f in ipairs(field.validators) do
						v = f(v)
					end
					return v
				end
			or nil -- keep nil when no validators
	end
	return { indices, names, types, actions, #indices }
end

return _mapFields
