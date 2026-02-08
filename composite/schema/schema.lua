---@param value number
---@param field CompositeSchemaFloatField
---@return number
---@overload fun(value: boolean, field: CompositeSchemaBoolField): boolean
local function _parse(value, field)
	local validators = field.validators
	if validators then
		for i = 1, #validators do
			value = validators[i](value)
		end
	end
	return value
end

---@class (exact) CompositeSchemaFields: table<string, CompositeSchemaFloatField|CompositeSchemaBoolField>

---@class (exact) CompositeSchema<T>
---@field type "schema"
---@field fields CompositeSchemaFields
---@field serialize fun(self, obj: T): CompositeData
---@field deserialize fun(self, data: CompositeData, baseOffset: integer?): T

---@param fields table<string, CompositeSchemaFloatField|CompositeSchemaBoolField|CompositeSchema>
---@param startIndex integer? Optional start index (offset)
---@return CompositeSchema
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
--- local minFloat = require("./schema/field_validators/min_float")
--- local FloatField = require("./schema/fields/float_field")
--- local BoolField = require("./schema/fields/bool_field")
---
--- ---@type CompositeSchema<TestObj>
--- local schema = CompositeSchema({ foo = FloatField(1), bar = BoolField(1), buzz = BoolField(2) })
---
--- -- Create our object:
--- ---@type TestObj
--- local testObj = { foo = 2.1, bar = true, buzz = true }
---
--- -- Serialize the object into composite data:
--- local data = schema:serialize(testObj)
--- -- Result: { float_values = { [1] = 2.2 }, bool_values = { [1] = true, [2] = true } }
---
--- -- Deserialize the composite data back into our object:
--- local obj = schema:deserialize(data)
---
--- -- Note: Check the tests for more complex examples (schema nesting, etc.).
---
local function CompositeSchema(fields, startIndex)
	startIndex = math.max((startIndex or 1), 1)
	local offset = startIndex - 1

	---@class CompositeSchema
	local instance = { type = "schema", fields = fields }

	function instance:serialize(obj)
		local result = { float_values = {}, bool_values = {} }
		for name, field in pairs(fields) do
			if field.type == "schema" then
				-- Recursively serialize nested schemas and merge into our result
				for key, values in pairs(field:serialize(obj[name])) do
					for index, value in pairs(values) do
						result[key][index + offset] = value
					end
				end
			else
				result[field.type][field.i + offset] = _parse(obj[name], field)
			end
		end
		return result
	end

	function instance:deserialize(data, baseOffset)
		local actualOffset = (baseOffset or 0) + offset
		local obj = {}
		for name, field in pairs(fields) do
			if field.type == "schema" then
				obj[name] = field:deserialize(data, actualOffset)
			else
				obj[name] = _parse(data[field.type][field.i + actualOffset], field)
			end
		end
		return obj
	end

	return instance
end

return CompositeSchema
