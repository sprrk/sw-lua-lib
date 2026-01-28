---@meta

---@alias CompositeSchemaFloatFieldValidator fun(value: number): number
---@alias CompositeSchemaBoolFieldValidator fun(value: boolean): boolean

---@class (exact) CompositeSchemaFloatField
---@field i integer The field index
---@field type `float_values` The target/type inside the CompositeData table
---@field validators CompositeSchemaFloatFieldValidator[]?

---@class (exact) CompositeSchemaBoolField
---@field i integer The field index
---@field type `bool_values` The target/type inside the CompositeData table
---@field validators CompositeSchemaBoolFieldValidator[]?

---@class (exact) CompositeSchema: table<string, CompositeSchemaFloatField|CompositeSchemaBoolField>
