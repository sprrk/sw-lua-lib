---@class (exact) CMPMessageSchema
---@field float_values { [integer]: string } | nil
---@field bool_values { [integer]: string } | nil

---@generic T
---@param schema CMPMessageSchema
---@return MessageDeserializer<T>
---
--- Example usage:
---
--- -- Define the message schema:
--- ---@type CMPMessageSchema
--- local EXAMPLE_SCHEMA = {
--- 	float_values = {
--- 		[1] = "radius",
--- 		[3] = "width",
--- 		[5] = "springK",
--- 		[6] = "dampK",
--- 	},
--- 	bool_values = {
--- 		[1] = "enableSteering",
--- 		[2] = "enableBraking",
--- 	},
--- }
---
--- -- Define a class to hold the deserialized data:
--- ---@class (exact) WheelConfig
--- ---@field radius number
--- ---@field width number
--- ---@field springK number
--- ---@field dampK number
--- ---@field enableSteering boolean
--- ---@field enableBraking boolean
---
--- -- Create the deserializer and deserialize a message:
--- ---@type MessageDeserializer<WheelConfig>
--- local deserializer = MessageDeserializer(EXAMPLE_SCHEMA)
--- local data = deserializer:deserializeMessage(message)
---
local function MessageDeserializer(schema)
	---@class MessageDeserializer<T>
	local instance = {}

	local schemaFloatValues = schema.float_values
	local schemaBoolValues = schema.bool_values

	---@param message CMPMessage
	---@return T
	function instance:deserializeMessage(message)
		local result = {}

		if schemaFloatValues then
			for index, value in ipairs(message.float_values) do
				local name = schemaFloatValues[index]
				if name then
					result[name] = value
				end
			end
		end

		if schemaBoolValues then
			for index, value in ipairs(message.bool_values) do
				local name = schemaBoolValues[index]
				if name then
					result[name] = value
				end
			end
		end

		return result
	end

	return instance
end

return MessageDeserializer
