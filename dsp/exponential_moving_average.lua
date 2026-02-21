---@class EMAFilterKwargs
---@field alpha number? Smoothing factor (0-1), default 0.3

---@param kwargs EMAFilterKwargs
---@return (fun(value: number): number) filterFunc, (fun(_kwargs: EMAFilterKwargs): nil) updateFunc, (fun(): nil) resetFunc
local function EMAFilter(kwargs)
	-- Exponential Moving Average / first-order low-pass filter.
	-- Lower alpha is smoother but slower, higher alpha is faster but less smooth.

	local alpha = (kwargs and kwargs.alpha) or 0.3
	local initialized = false
	local currentValue = 0

	return function(newValue)
		if not initialized then
			currentValue = newValue
			initialized = true
			return newValue
		end

		currentValue = currentValue + alpha * (newValue - currentValue)
		return currentValue
	end, function(_kwargs)
		alpha = _kwargs.alpha or 0.3
	end, function()
		currentValue = 0
		initialized = false
	end
end

return EMAFilter
