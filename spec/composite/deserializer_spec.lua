local makeDeserializerFunc = require("composite/deserializer")
local FloatField = require("composite/schema_fields").FloatField
local BoolField = require("composite/schema_fields").BoolField
local minFloat = require("composite/schema_field_validators").minFloat
local maxFloat = require("composite/schema_field_validators").maxFloat

describe("deserializer", function()
	it("deserializes composite data to objects", function()
		local schema = { foo = FloatField(1), bar = BoolField(1), baz = FloatField(2), buzz = BoolField(7) }
		local deserialize = makeDeserializerFunc(schema)
		local data = { float_values = { [1] = 1.2, [2] = -400.3 }, bool_values = { [1] = true, [7] = true } }
		local obj = deserialize(data)

		assert.equals(1.2, obj.foo)
		assert.equals(-400.3, obj.baz)
		assert.equals(true, obj.bar)
		assert.equals(true, obj.buzz)
	end)

	it("applies field validators", function()
		local schema = {
			foo = FloatField(1, { minFloat(2) }),
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		}
		local data = { float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 8.1 } }
		local deserialize = makeDeserializerFunc(schema)
		local obj = deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.bar)
		assert.equals(3, obj.baz)
		assert.equals(5, obj.buzz)
	end)
end)
