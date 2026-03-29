---@class (exact) ComponentState
---@field onEntry fun()?
---@field onTick fun(tick_time: number)|fun()|nil
---@field onRender fun()|nil
---@field onExit fun()?

local _onExit

---@type fun(state: ComponentState): nil
---
--- A simple state machine for component mod scripts.
---
--- Note: if onTick or onRender is omitted in a state definition, then the previous
---       handler will remain in use. To clear onTick/onRender in a state, an empty
---       function should be passed.
---
--- Example usage:
---
--- -- Forward-declare all states so they can be referenced inside other states
--- local StateDefault, StateTwo
---
--- ---@type ComponentState
--- StateDefault = (function()
--- 	local foo = 1
--- 	local bar = 2
---
--- 	return {
--- 		onTick = function()
--- 			component.setOutputLogicSlotFloat(2, bar)
--- 			setState(StateTwo) -- Switch to the other state
--- 		end,
--- 		onRender = function()
--- 			-- Explicitly clear the onRender function with a no-op
--- 		end,
--- 		onExit = function()
--- 			foo = foo + 0.75
--- 			component.setOutputLogicSlotFloat(3, foo)
--- 		end,
--- 	}
--- end)() -- NOTE: States must be defined as follows: State = (function() return {...} end)()
---
--- ---@type ComponentState
--- StateTwo = (function()
--- 	local m = matrix.translation(0, 0, 0)
--- 	local bar = 2
---
--- 	return {
--- 		onEntry = function()
--- 			bar = bar + 1
--- 			component.setOutputLogicSlotFloat(1, bar)
--- 		end,
--- 		onTick = function()
--- 			foo = foo + 0.5
--- 			component.setOutputLogicSlotFloat(2, foo)
--- 			setState(StateDefault)
--- 		end,
--- 		onRender = function()
--- 			component.renderMesh0(m)
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
	onRender = state.onRender or onRender
end
