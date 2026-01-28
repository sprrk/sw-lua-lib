local _mapFields = require("./_map_fields")

---@alias CompositeDeserializerFunc<T> fun(data: CompositeData): T

---@param schema CompositeSchema
---@return CompositeDeserializerFunc
---
--- Example usage:
---
--- -- Define a simple class for an object:
--- ---@class (exact) TestObj
--- ---@field foo number
--- ---@field bar boolean
--- ---@field buzz boolean
---
--- -- Define the schema:
--- local minFloat = require("./schema_field_validators").minFloat
--- local FloatField = require("./schema_fields").FloatField
--- local BoolField = require("./schema_fields").BoolField
---
--- ---@type CompositeSchema
--- local schema = {
--- 	foo = FloatField(1, { minFloat(2.12) }),
--- 	bar = BoolField(1),
--- 	buzz = BoolField(2),
--- }
---
--- -- Create the deserializer function:
--- ---@type CompositeDeserializerFunc<TestObj>
--- local deserialize = makeDeserializerFunc(schema)
---
--- -- Deserialize the composite data into our object:
--- local obj = deserialize({ float_values = { [1] = 2.2 }, bool_values = { [1] = true, [2] = true } })
---
local function makeDeserializerFunc(schema)
	---@type CompositeSchemaFieldMapping
	local fieldMap = _mapFields(schema)

	local indices, names, types, actions, nIndices = fieldMap[1], fieldMap[2], fieldMap[3], fieldMap[4], fieldMap[5]

	---@param data CompositeData
	---@return table
	return function(data)
		local obj = {}
		for k = 1, nIndices do
			local value, action = data[types[k]][indices[k]], actions[k]
			obj[names[k]] = action and action(value) or value
		end
		return obj
	end
end

return makeDeserializerFunc
