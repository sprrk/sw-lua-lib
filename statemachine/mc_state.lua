---@class (exact) MicrocontrollerState
---@field onEntry fun()?
---@field onTick fun()|nil
---@field onDraw fun()|nil
---@field onExit fun()?

local _onExit

---@type fun(state: MicrocontrollerState): nil
---
--- A simple state machine for microcontroller scripts.
---
--- Note: if onTick or onDraw is omitted in a state definition, then the previous
---       handler will remain in use. To clear onTick/onDraw in a state, an empty
---       function should be passed.
---
--- Example usage:
---
--- -- Forward-declare all states so they can be referenced inside other states
--- local StateDefault, StateTwo
---
--- ---@type MicrocontrollerState
--- StateDefault = (function()
--- 	local foo = 1
--- 	local bar = 2
---
--- 	return {
--- 		onTick = function()
--- 			output.setNumber(2, bar)
--- 			setState(StateTwo) -- Switch to the other state
--- 		end,
--- 		onDraw = function()
--- 			-- Explicitly clear the onDraw function with a no-op
--- 		end,
--- 		onExit = function()
--- 			foo = foo + 0.75
--- 			output.setNumber(3, foo)
--- 		end,
--- 	}
--- end)() -- NOTE: States must be defined as follows: State = (function() return {...} end)()
---
--- ---@type MicrocontrollerState
--- StateTwo = (function()
--- 	local foo = 1
--- 	local bar = 2
---
--- 	return {
--- 		onEntry = function()
--- 			bar = bar + 1
--- 			output.setNumber(1, bar)
--- 		end,
--- 		onTick = function()
--- 			foo = foo + 0.5
--- 			output.setNumber(2, foo)
--- 			setState(StateDefault)
--- 		end,
--- 		onDraw = function()
--- 			screen.drawText(5, 5, "foo")
--- 		end,
--- 	}
--- end)()
---
--- setState(StateDefault)
---
return function(state)
	-- Call the previous exit handler if it exists
	if _onExit then
		_onExit()
	end

	-- Call the entry handler if it exists
	if state.onEntry then
		state.onEntry()
	end

	-- Store the exit handler
	_onExit = state.onExit

	-- Swap out the global functions
	onTick = state.onTick or onTick
	onDraw = state.onDraw or onDraw
end
