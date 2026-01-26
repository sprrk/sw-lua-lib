---@enum MessageDecodeError
local MessageDecodeErrors = {
	INVALID_PROTOCOL_VERSION_SIGNATURE = 1,
	MISSING_MESSAGE_TYPE = 2,
}

local function makeMessageDecoderFunc()
	local constants = require("./cmp_constants")
	local PROTOCOL_VERSION_SIGNATURE = constants.PROTOCOL_VERSION_SIGNATURE
	local HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE = constants.HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE
	local HEADER_OFFSET_MESSAGE_TYPE = constants.HEADER_OFFSET_MESSAGE_TYPE

	---@param data CMPMessage|CompositeData
	---@return CompositeData|nil, CMPMessageType|nil, MessageDecodeError|nil
	local function decodeMessage(data)
		local floats = data.float_values
		local _messageType = floats[HEADER_OFFSET_MESSAGE_TYPE]

		if not _messageType or _messageType == 0 then
			return nil, nil, MessageDecodeErrors.MISSING_MESSAGE_TYPE
		elseif floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] ~= PROTOCOL_VERSION_SIGNATURE then
			return nil, nil, MessageDecodeErrors.INVALID_PROTOCOL_VERSION_SIGNATURE
		end

		-- At this point we've verified the message data and can safely cast
		-- it back to a regular composite data format
		---@cast data -CMPMessage, +CompositeData

		-- Strip headers
		floats[HEADER_OFFSET_MESSAGE_TYPE] = 0
		floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] = 0

		return data, _messageType, nil
	end

	return decodeMessage
end

return { makeMessageDecoderFunc = makeMessageDecoderFunc, MessageDecodeErrors = MessageDecodeErrors }
