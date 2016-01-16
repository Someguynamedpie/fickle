local gui = require('gui')
local M = {}

local curState
function M.setState( state )
	if curState then
		curState:leave()
	end
	gui.clear()
	curState = state
	curState:enter()
end

return M