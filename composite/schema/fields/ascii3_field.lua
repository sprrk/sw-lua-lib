-- Lookup table for encoding/decoding
local ENC, DEC = { ["\0"] = 0 }, { [0] = "" } -- Overwrite null char with empty string
for i = 32, 126 do -- Printable ASCII
	local c = string.char(i)
	ENC[c], DEC[i] = i, c
end

---@type CompositeSchemaAscii3FieldValidator
local function _parse(v)
	if type(v) == "string" then
		-- Encode
		return (ENC[v:sub(1, 1)] or 0) * 65536 + (ENC[v:sub(2, 2)] or 0) * 256 + (ENC[v:sub(3, 3)] or 0)
	else
		-- Decode
		return DEC[math.floor(v / 65536) % 256] .. DEC[math.floor(v / 256) % 256] .. DEC[v % 256]
	end
end

---@param index integer The field index
---@return CompositeSchemaAscii3Field
return function(index)
	return { i = index, type = "float_values", validators = { _parse } }
end
