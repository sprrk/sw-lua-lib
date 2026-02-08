local FloatField = require("composite/schema/fields/float_field")
local BoolField = require("composite/schema/fields/bool_field")
local minFloat = require("composite/schema/field_validators/min_float")
local maxFloat = require("composite/schema/field_validators/max_float")
local CompositeSchema = require("composite/schema/schema")

describe("CompositeSchema", function()
	it("serializes objects to composite data", function()
		local schema =
			CompositeSchema({ foo = FloatField(1), bar = BoolField(1), baz = FloatField(2), buzz = BoolField(7) })

		local obj = { foo = 1.2, baz = -400.3, bar = true, buzz = true }
		local data = schema:serialize(obj)

		assert.equals(1.2, data.float_values[1])
		assert.equals(-400.3, data.float_values[2])
		assert.equals(true, data.bool_values[1])
		assert.equals(true, data.bool_values[7])
	end)

	it("applies field validators during serialization", function()
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})
		local obj = { foo = 1.2, bar = 7, baz = 2.4, buzz = 8.1 }
		local data = schema:serialize(obj)

		assert.equals(2, data.float_values[1])
		assert.equals(5, data.float_values[2])
		assert.equals(3, data.float_values[3])
		assert.equals(5, data.float_values[4])
	end)

	it("deserializes composite data to objects", function()
		local schema =
			CompositeSchema({ foo = FloatField(1), bar = BoolField(1), baz = FloatField(2), buzz = BoolField(7) })
		local data = { float_values = { [1] = 1.2, [2] = -400.3 }, bool_values = { [1] = true, [7] = true } }
		local obj = schema:deserialize(data)

		assert.equals(1.2, obj.foo)
		assert.equals(-400.3, obj.baz)
		assert.equals(true, obj.bar)
		assert.equals(true, obj.buzz)
	end)

	it("applies field validators during deserialization", function()
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})
		local data = { float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 8.1 } }
		local obj = schema:deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.bar)
		assert.equals(3, obj.baz)
		assert.equals(5, obj.buzz)
	end)

	it("can serialize and deserialize back and forth", function()
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})
		local data = { float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 8.1 } }
		local obj = schema:deserialize(data)
		data = schema:serialize(obj)
		obj = schema:deserialize(data)
		data = schema:serialize(obj)
		obj = schema:deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.bar)
		assert.equals(3, obj.baz)
		assert.equals(5, obj.buzz)
	end)
end)
