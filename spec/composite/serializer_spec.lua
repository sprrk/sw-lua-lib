local makeSerializerFunc = require("composite/serializer")
local FloatField = require("composite/schema_fields").FloatField
local BoolField = require("composite/schema_fields").BoolField
local minFloat = require("composite/schema_field_validators").minFloat
local maxFloat = require("composite/schema_field_validators").maxFloat

describe("serializer", function()
	it("serializes objects to composite data", function()
		local schema = { foo = FloatField(1), bar = BoolField(1), baz = FloatField(2), buzz = BoolField(7) }
		local obj = { foo = 1.2, baz = -400.3, bar = true, buzz = true }
		local serialize = makeSerializerFunc(schema)
		local data = serialize(obj)

		assert.equals(1.2, data.float_values[1])
		assert.equals(-400.3, data.float_values[2])
		assert.equals(true, data.bool_values[1])
		assert.equals(true, data.bool_values[7])
	end)

	it("applies field validators", function()
		local schema = {
			foo = FloatField(1, { minFloat(2) }),
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		}
		local obj = { foo = 1.2, bar = 7, baz = 2.4, buzz = 8.1 }
		local serialize = makeSerializerFunc(schema)
		local data = serialize(obj)

		assert.equals(2, data.float_values[1])
		assert.equals(5, data.float_values[2])
		assert.equals(3, data.float_values[3])
		assert.equals(5, data.float_values[4])
	end)
end)
