---@generic T
---@alias ObservableValueCallback<T> fun(newValue: T, oldValue: T)

---@generic T : string|number|integer|boolean
---@param initialValue T
---@return ObservableValue<T>
local function ObservableValue(initialValue)
	local _storedValue = initialValue
	local _runningCallbacks = false -- Guard to prevent infinite callback loop
	local _dirty = false
	local _pendingValue = initialValue

	---@class ObservableValue<T>
	---@field protected _callbacks ObservableValueCallback<T>[]
	local instance = {
		_callbacks = {},
	}

	---@param callback ObservableValueCallback<T>
	--- Add a callback function to be called when the value changes.
	function instance:addCallback(callback)
		self._callbacks[#self._callbacks + 1] = callback
	end

	---@param callback ObservableValueCallback<T>
	--- Remove a previously registered callback function.
	function instance:removeCallback(callback)
		local _callbacks = self._callbacks
		for i = 1, #_callbacks do
			if _callbacks[i] == callback then
				table.remove(_callbacks, i)
				return
			end
		end
	end

	---@param newValue T
	---@param oldValue T
	---@protected
	function instance:_triggerCallbacks(newValue, oldValue)
		local _callbacks = instance._callbacks
		for i = 1, #_callbacks do
			_callbacks[i](newValue, oldValue)
		end
	end

	---@return T
	function instance:get()
		return _storedValue
	end

	---@param newValue T
	---@return boolean isModified
	--- Set a new value and trigger all callbacks.
	function instance:set(newValue)
		if _storedValue == newValue or _runningCallbacks then
			return false
		end

		_runningCallbacks = true
		self:_triggerCallbacks(newValue, _storedValue)
		_storedValue = newValue
		_runningCallbacks = false

		-- Reset the dirty flag and pending value in case setDeferred was used earlier
		_dirty = false
		_pendingValue = _storedValue

		return true
	end

	---@param newValue T
	---@return boolean isModified
	--- Set a new value to be applied later, without triggering callbacks yet.
	--- Use flush() to apply the deferred value.
	function instance:setDeferred(newValue)
		if _pendingValue == newValue or _runningCallbacks then
			return false
		end

		_pendingValue = newValue
		_dirty = true
		return true -- Optimistic; this value is going to change eventually
	end

	---@return nil
	--- Apply pending deferred changes and trigger all callbacks.
	function instance:flush()
		if _dirty and not _runningCallbacks then
			_runningCallbacks = true
			_dirty = false
			self:_triggerCallbacks(_pendingValue, _storedValue)
			_storedValue = _pendingValue
			_runningCallbacks = false
		end
	end

	return instance
end

return ObservableValue
