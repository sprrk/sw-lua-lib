local packText = require("ascii3packer/pack")

describe("pack", function()
	it("packs text to an array with bitmasks", function()
		local text = "foo bar 123"

		local result = packText(text)
		assert.equals(11, result[1])
		assert.equals(6713199, result[2])
		assert.equals(2122337, result[3])
		assert.equals(7479345, result[4])
		assert.equals(3289856, result[5])
		assert.equals(nil, result[6])
	end)
end)
