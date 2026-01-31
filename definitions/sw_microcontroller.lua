---@meta

---@table input
input = {}

---@param index number
---@return boolean
function input.getBool(index) end

---@param index number
---@return number
function input.getNumber(index) end

---@table output
output = {}

---@param index number
---@param value boolean
---@return nil
function output.setBool(index, value) end

---@param index number
---@param value number
---@return nil
function output.setNumber(index, value) end

---@table property
property = {}

---@param label string
---@return boolean
function property.getBool(label) end

---@param label string
---@return number
function property.getNumber(label) end

---@param label string
---@return string
function property.getText(label) end
