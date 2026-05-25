---@param packed integer[] Array with packed chars (24-bit bitmask encoding 3 ASCII characters (8 bits each))
---@return string text Unpacked text
--- Unpack an array of 24-bit integers back into a string.
--- The first element of the array is the original string length.
local function unpackText(packed)
	local t, ti, n, flr, ch = {}, 0, #packed, math.floor, string.char
	for i = 2, n do
		local v = packed[i]
		t[ti + 1] = ch(flr(v / 65536))
		t[ti + 2] = ch(flr(v / 256) % 256)
		t[ti + 3] = ch(v % 256)
		ti = ti + 3
	end
	return table.concat(t, "", 1, packed[1])
end

return unpackText
