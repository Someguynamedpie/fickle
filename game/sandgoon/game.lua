local system = require'system'
local game = {}

ROUNDSTATE_PREROUND = 1
ROUNDSTATE_GAME     = 2
ROUNDSTATE_POSTROUND= 3

function game.getLevel()
	return game.level
end

function game.setLevel( lvl )
	game.level = lvl
end

function game.getRoundState()
	return game.roundState
end

function game.getRoundTimer()
	return system.getTime() - (game.roundStart or system.getTime())
end
