---@param text string Text to pack
---@return integer[] packed Array with packed chars (24-bit bitmask encoding 3 ASCII characters (8 bits each))
--- Pack a string into an array of 24-bit integers, with each integer containing up to 3 characters.
--- The first element is the original string length. Incomplete groups at the end are padded with null bytes (0).
local function packText(text)
	local packed, n, byte = { #text }, #text, string.byte

	for i = 1, n, 3 do
		local b1, b2, b3 = byte(text, i, i + 2)
		packed[#packed + 1] = (b1 or 0) * 65536 + (b2 or 0) * 256 + (b3 or 0)
	end

	return packed
end

return packText
