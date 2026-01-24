---@alias CompositeSchemaFloatFieldMapping [ integer[], string[], ((fun(value: number): number)[]), integer ]
---@alias CompositeSchemaBoolFieldMapping [ integer[], string[], ((fun(value: number): number)[]), integer ]

---@param fields CompositeSchemaFloatField[]
---@return CompositeSchemaFloatFieldMapping
---@overload fun(fields: CompositeSchemaBoolField[]): CompositeSchemaBoolFieldMapping
---@nodiscard
local function _mapFields(fields)
	local indices, names, actions = {}, {}, {}
	for name, field in pairs(fields) do
		indices[#indices + 1] = field.i
		names[#names + 1] = name
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
	return { indices, names, actions, #indices }
end

return _mapFields
