---@meta

---@alias CMPMessageType integer
---@alias CMPVersion integer
---@alias CMPVersionSignature integer

---@class (exact) CMPMessageFloatValues: CompositeFloatValues
---@field public [31] CMPMessageType
---@field public [32] CMPVersionSignature

---@class (exact) CMPMessage
---@field public float_values CMPMessageFloatValues
---@field public bool_values CompositeBoolValues
