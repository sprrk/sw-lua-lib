---@meta

---@alias CompositeSchemaFloatFieldValidator fun(value: number): number
---@alias CompositeSchemaBoolFieldValidator fun(value: boolean): boolean

---@class (exact) CompositeSchemaFloatField
---@field i integer The field index
---@field validators CompositeSchemaFloatFieldValidator[]?

---@class (exact) CompositeSchemaBoolField
---@field i integer The field index
---@field validators CompositeSchemaBoolFieldValidator[]?

---@class (exact) CompositeSchema
---@field floatFields table<string, CompositeSchemaFloatField>
---@field boolFields table<string, CompositeSchemaBoolField>
