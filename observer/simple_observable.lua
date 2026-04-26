---@generic T : integer|number|string|boolean
---@param initialValue T
---@param onChangeCallback fun(newValue: T, oldValue: T)
---@return fun(): T getterFunc, fun(newValue: T): boolean setterFunc
local function observable(initialValue, onChangeCallback)
	local storedValue = initialValue

	return function()
		return storedValue
	end, function(newValue)
		if storedValue ~= newValue then
			onChangeCallback(newValue, storedValue)
			storedValue = newValue
			return true
		end
		return false
	end
end

return observable
