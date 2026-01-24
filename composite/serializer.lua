local _mapFields = require("./_map_fields")

---@alias CompositeSerializerFunc<T> fun(obj: T): CompositeData

---@param schema CompositeSchema
---@return CompositeSerializerFunc
---
--- Example usage:
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
--- -- Define a simple class for an object:
--- ---@class (exact) TestObj
--- ---@field foo number
--- ---@field bar boolean
--- ---@field buzz boolean
---
--- -- Create our object:
--- ---@type TestObj
--- local obj = { foo = 1.2, bar = false, buzz = true }
---
--- -- Create the serializer:
--- ---@type CompositeSerializerFunc<TestObj>
--- local serialize = makeSerializerFunc(schema)
---
--- -- Serialize the object into composite data:
--- local data = serialize(obj)
---
local function makeSerializerFunc(schema)
	---@param fieldMap CompositeSchemaFloatFieldMapping
	---@return fun(obj: table): CompositeFloatValues
	---@overload fun(fieldMap: CompositeSchemaBoolFieldMapping): fun(obj: table): CompositeBoolValues
	local function _makeParser(fieldMap)
		local indices, names, actions, nIndices = fieldMap[1], fieldMap[2], fieldMap[3], fieldMap[4]
		return function(obj)
			local result = {}
			for k = 1, nIndices do
				local value, action = obj[names[k]], actions[k]
				result[indices[k]] = action and action(value) or value
			end
			return result
		end
	end

	local _parseFloats = _makeParser(_mapFields(schema.floatFields))
	local _parseBools = _makeParser(_mapFields(schema.boolFields))

	return function(obj)
		return { float_values = _parseFloats(obj), bool_values = _parseBools(obj) }
	end
end

return makeSerializerFunc
