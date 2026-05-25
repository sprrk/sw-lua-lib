local unpackText = require("ascii3packer/unpack")

describe("pack", function()
	it("unpack an array with bitmasks back into text", function()
		local packed = {
			11,
			6713199,
			2122337,
			7479345,
			3289856,
		}

		local result = unpackText(packed)
		assert.equals("foo bar 123", result)
	end)
end)
