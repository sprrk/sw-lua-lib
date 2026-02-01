---@meta

---@param tick_time number
---@return nil
function onTick(tick_time) end

---@table component
component = {}

---@param index number
---@param mass number
---@param rps number
---@return number, boolean
function component.slotTorqueApplyMomentum(index, mass, rps) end

---@return nil
function onRemoveFromSimulation() end

---@return nil
function onRender() end

---@alias Matrix table

---@table matrix
matrix = {}
