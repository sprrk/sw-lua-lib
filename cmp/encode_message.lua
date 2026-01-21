---@enum MessageEncodeError
local MessageEncodeErrors = {
	RESERVED_HEADER_CONFLICT = 1,
	MISSING_MESSAGE_TYPE = 2,
}

local function makeMessageEncoderFunc()
	-- Reusable private buffer and values tables to reduce garbage collection overhead
	local EMPTY_BOOL_VALUES = {}
	for i = 1, 32 do
		EMPTY_BOOL_VALUES[i] = false
	end
	---@type CMPMessage
	local PAYLOAD_BUF = {
		float_values = {}, ---@diagnostic disable-line:missing-fields
		bool_values = EMPTY_BOOL_VALUES,
	}

	local constants = require("cmp/cmp_constants")
	local PROTOCOL_VERSION_SIGNATURE = constants.PROTOCOL_VERSION_SIGNATURE
	local HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE = constants.HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE
	local HEADER_OFFSET_MESSAGE_TYPE = constants.HEADER_OFFSET_MESSAGE_TYPE

	---@param data CompositeData
	---@param messageType CMPMessageType
	---@return CMPMessage|nil,MessageEncodeError|nil
	local function encodeMessage(data, messageType)
		if not messageType or messageType == 0 then
			return nil, MessageEncodeErrors.MISSING_MESSAGE_TYPE
		end

		local payload = PAYLOAD_BUF

		local floats = payload.float_values
		local sourceFloats = data.float_values
		if sourceFloats then
			for i = 1, 32 do
				floats[i] = sourceFloats[i] or 0
			end
		else
			for i = 1, 32 do
				floats[i] = 0
			end
		end

		-- Use the bool_values if given, if omitted then use reusable constant
		payload.bool_values = data.bool_values or EMPTY_BOOL_VALUES

		-- Check for header conflicts
		if floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] ~= 0 or floats[HEADER_OFFSET_MESSAGE_TYPE] ~= 0 then
			return nil, MessageEncodeErrors.RESERVED_HEADER_CONFLICT
		end

		-- Set the headers
		floats[HEADER_OFFSET_PROTOCOL_VERSION_SIGNATURE] = PROTOCOL_VERSION_SIGNATURE
		floats[HEADER_OFFSET_MESSAGE_TYPE] = messageType

		return payload, nil
	end

	return encodeMessage
end

return { makeMessageEncoderFunc = makeMessageEncoderFunc, MessageEncodeErrors = MessageEncodeErrors }
