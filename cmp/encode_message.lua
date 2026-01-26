---@enum MessageEncodeError
local MessageEncodeErrors = {
	RESERVED_HEADER_CONFLICT = 1,
	MISSING_MESSAGE_TYPE = 2,
}

local constants = require("./cmp_constants")
local PROTOCOL_VERSION_SIGNATURE = constants.PROTOCOL_VERSION_SIGNATURE
local HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE = constants.HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE
local HEADER_OFFSET_MESSAGE_TYPE = constants.HEADER_OFFSET_MESSAGE_TYPE

local function makeMessageEncoderFunc()
	---@param data CompositeData
	---@param messageType CMPMessageType
	---@return CMPMessage|nil,MessageEncodeError|nil
	local function encodeMessage(data, messageType)
		if not messageType or messageType == 0 then
			return nil, MessageEncodeErrors.MISSING_MESSAGE_TYPE
		end

		local floats, bools = {}, {}
		local sourceFloats = data.float_values
		local sourceBools = data.bool_values
		for i = 1, 32 do
			floats[i] = sourceFloats[i] or 0
			bools[i] = sourceBools[i] or false
		end

		-- Check for header conflicts
		if floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] ~= 0 or floats[HEADER_OFFSET_MESSAGE_TYPE] ~= 0 then
			return nil, MessageEncodeErrors.RESERVED_HEADER_CONFLICT
		end

		-- Set the headers
		floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] = PROTOCOL_VERSION_SIGNATURE
		floats[HEADER_OFFSET_MESSAGE_TYPE] = messageType

		return { float_values = floats, bool_values = bools }, nil
	end

	return encodeMessage
end

return { makeMessageEncoderFunc = makeMessageEncoderFunc, MessageEncodeErrors = MessageEncodeErrors }
