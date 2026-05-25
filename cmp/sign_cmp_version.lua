---@param v integer CMP version
return function(v)
	return v * 0x9E3779 + 0x2D -- scramble: version * 24 bit ratio + offset
end
