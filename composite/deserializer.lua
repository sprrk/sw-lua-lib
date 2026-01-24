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
--- 	floatFields = { foo = FloatField(1, { minFloat(2.12) }) },
--- 	boolFields = { bar = BoolField(1), buzz = BoolField(2) },
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
	---@param fieldMap CompositeSchemaFloatFieldMapping
	---@return fun(target: table, values: CompositeFloatValues)
	---@overload fun(fieldMap: CompositeSchemaBoolFieldMapping): fun(target: table, values: CompositeBoolValues)
	local function _makeFiller(fieldMap)
		local indices, names, actions, nIndices = fieldMap[1], fieldMap[2], fieldMap[3], fieldMap[4]
		return function(target, values)
			for k = 1, nIndices do
				local value, action = values[indices[k]], actions[k]
				target[names[k]] = action and action(value) or value
			end
		end
	end

	local _fillFloats = _makeFiller(_mapFields(schema.floatFields))
	local _fillBools = _makeFiller(_mapFields(schema.boolFields))

	return function(data)
		local result = {}
		_fillFloats(result, data.float_values)
		_fillBools(result, data.bool_values)
		return result
	end
end

return makeDeserializerFunc
