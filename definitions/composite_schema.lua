---@meta

---@alias CompositeSchemaFloatFieldValidator fun(value: number): number
---@alias CompositeSchemaBoolFieldValidator fun(value: boolean): boolean
---@alias CompositeSchemaAscii3FieldValidator (fun(v: integer): string)|fun(v: string): integer

---@class (exact) CompositeSchemaFloatField
---@field i integer The field index
---@field type `float_values` The target/type inside the CompositeData table
---@field validators CompositeSchemaFloatFieldValidator[]?

---@class (exact) CompositeSchemaBoolField
---@field i integer The field index
---@field type `bool_values` The target/type inside the CompositeData table
---@field validators CompositeSchemaBoolFieldValidator[]?

---@class (exact) CompositeSchemaAscii3Field
---@field i integer The field index
---@field type `float_values` The target/type inside the CompositeData table
---@field validators CompositeSchemaAscii3FieldValidator[]?
