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

	it("can serialize nested schemas 1 level deep", function()
		local nestedA = CompositeSchema({
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
		})
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = nestedA,
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})

		local obj = { foo = 1.2, nestedA = { bar = 7, baz = 2.4 }, buzz = 8.1 }
		local data = schema:serialize(obj)

		assert.equals(2, data.float_values[1])
		assert.equals(5, data.float_values[2])
		assert.equals(3, data.float_values[3])
		assert.equals(5, data.float_values[4])
	end)

	it("can deserialize nested schemas 1 level deep", function()
		local nestedA = CompositeSchema({
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
		})
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = nestedA,
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})

		local data = { float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 8.1 } }
		local obj = schema:deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.nestedA.bar)
		assert.equals(3, obj.nestedA.baz)
		assert.equals(5, obj.buzz)
	end)

	it("can serialize nested schemas 2 levels deep", function()
		local nestedA = CompositeSchema({
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			nestedB = CompositeSchema({ fuzz = FloatField(6) }),
		})
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = nestedA,
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})

		local obj = { foo = 1.2, nestedA = { bar = 7, baz = 2.4, nestedB = { fuzz = 42 } }, buzz = 8.1 }
		local data = schema:serialize(obj)

		assert.equals(2, data.float_values[1])
		assert.equals(5, data.float_values[2])
		assert.equals(3, data.float_values[3])
		assert.equals(5, data.float_values[4])
		assert.equals(42, data.float_values[6])
	end)

	it("can deserialize nested schemas 2 levels deep", function()
		local nestedA = CompositeSchema({
			bar = FloatField(2, { maxFloat(5) }),
			baz = FloatField(3, { minFloat(3), maxFloat(5) }),
			nestedB = CompositeSchema({ fuzz = FloatField(6) }),
		})
		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = nestedA,
			buzz = FloatField(4, { minFloat(3), maxFloat(5) }),
		})

		local data = { float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 8.1, [6] = 42 } }
		local obj = schema:deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.nestedA.bar)
		assert.equals(3, obj.nestedA.baz)
		assert.equals(5, obj.buzz)
		assert.equals(42, obj.nestedA.nestedB.fuzz)
	end)

	it("serializes nested schemas with offsets", function()
		local nestedFields = {
			bar = FloatField(1, { maxFloat(5) }),
			baz = FloatField(2, { minFloat(3), maxFloat(5) }),
			nestedB = CompositeSchema({ fuzz = FloatField(3) }),
		}

		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = CompositeSchema(nestedFields, 2),
			buzz = FloatField(5, { minFloat(3), maxFloat(6.42) }),
			nestedB = CompositeSchema(nestedFields, 6),
		})

		local obj = {
			foo = 1.2,
			nestedA = { bar = 7, baz = 2.4, nestedB = { fuzz = 42 } },
			nestedB = { bar = 0.25, baz = 3.4, nestedB = { fuzz = 27 } },
			buzz = 8.1,
		}
		local data = schema:serialize(obj)

		assert.equals(2, data.float_values[1]) -- obj.foo
		assert.equals(5, data.float_values[2]) -- obj.nestedA.bar
		assert.equals(3, data.float_values[3]) -- obj.nestedA.baz
		assert.equals(42, data.float_values[4]) -- obj.nestedA.nestedB.fuzz
		assert.equals(6.42, data.float_values[5]) -- obj.buzz
		assert.equals(0.25, data.float_values[6]) -- obj.nestedB.bar
		assert.equals(3.4, data.float_values[7]) -- obj.nestedB.baz
		assert.equals(27, data.float_values[8]) -- obj.nestedB.nestedB.fuzz
	end)

	it("deserializes nested schemas with offsets", function()
		local nestedFields = {
			bar = FloatField(1, { maxFloat(5) }),
			baz = FloatField(2, { minFloat(3), maxFloat(5) }),
			nestedB = CompositeSchema({ fuzz = FloatField(3) }),
		}

		local schema = CompositeSchema({
			foo = FloatField(1, { minFloat(2) }),
			nestedA = CompositeSchema(nestedFields, 2),
			buzz = FloatField(5, { minFloat(3), maxFloat(6.42) }),
			nestedB = CompositeSchema(nestedFields, 6),
		})

		local data = {
			float_values = { [1] = 1.2, [2] = 7, [3] = 2.4, [4] = 42, [5] = 8.1, [6] = 0.25, [7] = 3.4, [8] = 27 },
			bool_values = {},
		}
		local obj = schema:deserialize(data)

		assert.equals(2, obj.foo)
		assert.equals(5, obj.nestedA.bar)
		assert.equals(3, obj.nestedA.baz)
		assert.equals(42, obj.nestedA.nestedB.fuzz)
		assert.equals(6.42, obj.buzz)
		assert.equals(0.25, obj.nestedB.bar)
		assert.equals(3.4, obj.nestedB.baz)
		assert.equals(27, obj.nestedB.nestedB.fuzz)
	end)
end)
