local _decode_message = require("./decode_message")
local decodeMessage = _decode_message.makeMessageDecoderFunc()
local MISSING_MESSAGE_TYPE = _decode_message.MessageDecodeErrors.MISSING_MESSAGE_TYPE
local INVALID_PROTOCOL_VERSION_SIGNATURE = _decode_message.MessageDecodeErrors.INVALID_PROTOCOL_VERSION_SIGNATURE

---@param messageHandlers table<CMPMessageType, fun(data: CompositeData)>
---@return fun(data: CompositeData): nil
--- A basic message receiver that receives raw composite message data, decodes it,
--- and routes it to registered handlers based on message type.
---
--- Invalid, incompatible or non-message data is silently discarded.
--- Valid messages without registered handlers are silently ignored.
---
--- Example usage:
---
---   local MESSAGE_TYPES = { FOO = 2 }
---   local function handler(data)
---   	print(data)
---   end
---   local receiveMessage = makeMessageReceiverFunc({ [MESSAGE_TYPES.FOO] = handler })
---   local inputData = component.getInputLogicSlotComposite(1)
---   receiveMessage(inputData)  -- Handler func is invoked if message is valid and type matches
---
local function makeMessageReceiverFunc(messageHandlers)
	return function(data)
		local message, messageType, err = decodeMessage(data)
		if err then
			if err == MISSING_MESSAGE_TYPE or err == INVALID_PROTOCOL_VERSION_SIGNATURE then
				-- The input data is not a message, or is invalid/incompatible; discard and skip
				return
			else
				error("unknown_error")
			end
		end

		local handler = messageHandlers[messageType]
		if handler then
			handler(message)
		end
	end
end

return makeMessageReceiverFunc
